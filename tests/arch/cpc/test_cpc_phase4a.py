# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Phase 4a compiler-side checks for --arch cpc (the runtime side is
# checked in the emulator by cpcbuild's tests/conformance/graphics.bas
# and textio.bas):
#
# - PLOT/CIRCLE coordinates are 16-bit on cpc (mode pixels, up to 640
#   wide) and stay 8-bit on the Spectrum archs.
# - Constant BEEP arguments are converted by the target arch's own
#   beep module: Spectrum ROM loop counts on zx48k, the firmware sound
#   manager's (duration, tone period) on cpc.
# --------------------------------------------------------------------

import os
import subprocess
import sys

import pytest

from src import arch, zxbc
from src.arch.cpc import beep as cpc_beep
from src.symbols.type_ import Type
from src.zxbc import zxbparser


def _compile_asm(tmp_path, arch_name: str, source: str) -> str:
    bas = os.path.join(tmp_path, f"{arch_name}.bas")
    out = os.path.join(tmp_path, f"{arch_name}.asm")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)
    assert zxbc.main(["--arch", arch_name, "--output-format=asm", bas, "-o", out]) == 0
    with open(out, encoding="utf-8") as f:
        return f.read()


def _user_code(asm: str) -> str:
    """The compiled program itself, without the runtime library."""
    return asm.split(";; --- end of user code ---")[0]


@pytest.mark.parametrize(
    "arch_name, plot_type, circle_type",
    [
        ("zx48k", Type.ubyte, Type.byte_),
        ("zxnext", Type.ubyte, Type.byte_),
        ("cpc", Type.integer, Type.integer),
    ],
)
def test_graphics_coord_type_per_arch(arch_name, plot_type, circle_type):
    previous = arch.target.__name__.rsplit(".", 1)[-1]
    try:
        arch.set_target_arch(arch_name)
        assert zxbparser.graphics_coord_type(Type.ubyte) == plot_type
        assert zxbparser.graphics_coord_type(Type.byte_) == circle_type
    finally:
        arch.set_target_arch(previous)


def test_cpc_plot_keeps_16_bit_coordinates(tmp_path):
    code = _user_code(_compile_asm(tmp_path, "cpc", "PLOT 300, 150\nCIRCLE 600, 100, 300\n"))
    assert "300" in code
    assert "600" in code


def test_cpc_beep_constants_use_cpc_units(tmp_path):
    code = _user_code(_compile_asm(tmp_path, "cpc", "BEEP 1, 0\n"))
    assert "239" in code  # middle C tone period: 62500 / 261.63
    assert "100" in code  # 1 s in 1/100 s


def test_zx48k_beep_constants_unchanged(tmp_path):
    from src.arch.zx48k import beep as zx_beep

    de, hl = zx_beep.getDEHL(1.0, 0.0)
    code = _user_code(_compile_asm(tmp_path, "zx48k", "BEEP 1, 0\n"))
    assert str(de) in code
    assert str(hl) in code


@pytest.mark.parametrize(
    "duration, pitch, expected",
    [
        (1, 0, (100, 239)),  # middle C
        (0.5, 12, (50, 119)),  # an octave up
        (0.25, -12, (25, 478)),  # an octave down
        (1, -60, (100, 4095)),  # below the AY's range: clamped
        (0, 0, (0, 239)),
    ],
)
def test_cpc_beep_get_dehl(duration, pitch, expected):
    assert cpc_beep.getDEHL(duration, pitch) == expected


@pytest.mark.parametrize("duration, pitch", [(11, 0), (-1, 0), (1, 128), (1, -61)])
def test_cpc_beep_out_of_range(duration, pitch):
    with pytest.raises(cpc_beep.BeepError):
        cpc_beep.getDEHL(duration, pitch)


@pytest.mark.parametrize("lib", ["attr.bas", "screen.bas", "sinclair.bas", "print42.bas", "print64.bas"])
def test_spectrum_only_stdlib_is_a_clear_error_on_cpc(tmp_path, lib):
    # A subprocess, not zxbc.main(): main() keeps its error stream in
    # OPTIONS and doesn't flush it, so in-process capture is unreliable.
    bas = os.path.join(tmp_path, "prog.bas")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(f"#include <{lib}>\nEND\n")
    zxbc_py = os.path.join(os.path.dirname(__file__), os.pardir, os.pardir, os.pardir, "zxbc.py")
    result = subprocess.run(
        [sys.executable, zxbc_py, "--arch", "cpc", "--output-format=asm", bas, "-o", os.path.join(tmp_path, "p.asm")],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode != 0
    assert f"{lib} is not available for --arch cpc" in result.stderr
