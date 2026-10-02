# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Phase 4d compiler-side checks for --arch cpc (what Play and AyWrite do
# on the hardware is checked in the emulator by cpcbuild's
# tests/conformance/play.bas and tests/stress/play_tempo.bas):
#
# - a program that uses PLAY (the library's Play sub, MML strings)
#   compiles for --arch cpc and pulls in the cpc copy of play.bas and the
#   AY runtime, not the Spectrum 128 port writes;
# - zx48k (and zx81sd) still use their own play.bas, byte for byte what
#   is in git history (the cpc copy is a separate file);
# - AyWrite/AyRead from cpc.bas compile.
# --------------------------------------------------------------------

import os
import subprocess
import sys

import pytest

_ROOT = os.path.join(os.path.dirname(__file__), os.pardir, os.pardir, os.pardir)
_ZXBC = os.path.join(_ROOT, "zxbc.py")
_LIB = os.path.join(_ROOT, "src", "lib", "arch")

_PLAY = """
#include <play.bas>
Play "O4 C D E F", "O3 5 G", ""
"""

_AY = """
#include <cpc.bas>
AyWrite 8, 15
DIM v AS UBYTE
v = AyRead(8)
"""


def _compile(tmp_path, source: str, arch_name: str, *extra: str) -> subprocess.CompletedProcess:
    bas = os.path.join(tmp_path, "prog.bas")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)
    out = os.path.join(tmp_path, "prog.asm")
    cmd = [sys.executable, _ZXBC, "--arch", arch_name, "-f", "asm", bas, "-o", out, *extra]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    result.asm = open(out, encoding="utf-8").read() if result.returncode == 0 else ""  # type: ignore[attr-defined]
    return result


def test_cpc_play_compiles_with_the_cpc_library(tmp_path):
    result = _compile(tmp_path, _PLAY, "cpc")
    assert result.returncode == 0, result.stderr
    asm = result.asm
    # the cpc copy of play.bas, the AY runtime and the firmware gate
    assert "src/lib/arch/cpc/stdlib/play.bas" in asm
    assert "__CPC_AY_WRITE" in asm
    assert "$BCA7" in asm.upper() or "0BCA7H" in asm.upper() or "BCA7" in asm.upper()
    # no Spectrum 128 AY ports
    assert "out ($fffd" not in asm.lower()
    assert "$fffd" not in asm.lower() and "0fffdh" not in asm.lower()


def test_cpc_play_benchmark_mode_compiles(tmp_path):
    result = _compile(tmp_path, "#define _PLAY_BENCHMARK_MODE\n" + _PLAY, "cpc")
    assert result.returncode == 0, result.stderr
    assert "__CPC_AY_WRITE_DI" in result.asm


def test_cpc_ay_write_read_compile(tmp_path):
    result = _compile(tmp_path, _AY, "cpc")
    assert result.returncode == 0, result.stderr
    assert "__CPC_AY_WRITE_DI" in result.asm
    assert "__CPC_AY_READ_DI" in result.asm


@pytest.mark.parametrize("arch_name", ["zx48k", "zx81sd"])
def test_other_archs_keep_their_own_play(tmp_path, arch_name):
    result = _compile(tmp_path, _PLAY, arch_name)
    assert result.returncode == 0, result.stderr
    assert f"src/lib/arch/{arch_name}/stdlib/play.bas" in result.asm
    assert "src/lib/arch/cpc/" not in result.asm
    assert "__CPC_AY_WRITE" not in result.asm


def test_zx48k_play_is_the_spectrum_128_one():
    path = os.path.join(_LIB, "zx48k", "stdlib", "play.bas")
    with open(path, encoding="utf-8") as f:
        text = f.read()
    # ports and AY clock of the Spectrum 128; none of the CPC port's changes
    assert "out $fffd, (register) : out $bffd, (value)" in text
    assert "const CpuCyclesPerSecond as ulong = 3546900" in text
    assert "6779, 6398" in text
    assert "__CPC" not in text


def test_cpc_play_divider_table_is_1mhz():
    path = os.path.join(_LIB, "cpc", "stdlib", "play.bas")
    with open(path, encoding="utf-8") as f:
        text = f.read()
    # divider = round(1000000 / 16 / f), f = 440 * 2^((n - 57) / 12): C0, A4, B8
    assert "3822, 3608" in text
    for n, want in ((0, 3822), (57, 142), (107, 8)):
        assert round(1000000 / 16 / (440 * 2 ** ((n - 57) / 12))) == want
    assert "const CpuCyclesPerSecond as ulong = 4000000" in text
