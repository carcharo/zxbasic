# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Phase 4c compiler-side checks for --arch cpc:
#
# - check_memory_layout()'s RESERVED_RANGE_LABELS: a program that defines
#   the generic label .core.__CPC_RESERVE_4000 (as a library with a back
#   screen does, e.g. cpcbuild's EnableDoubleBuffer, checked in the emulator
#   by cpcbuild's tests) gets &4000-&7FFF reserved; code+data and the heap
#   must stay out of it. Programs that don't define it are unaffected.
# --------------------------------------------------------------------

import os
import subprocess
import sys
from types import SimpleNamespace

import pytest

from src.zxbc import zxbc as zxbc_module

_ZXBC = os.path.join(os.path.dirname(__file__), os.pardir, os.pardir, os.pardir, "zxbc.py")

_DBUF = """
ASM
push namespace core
__CPC_RESERVE_4000:
pop namespace
END ASM
"""

_NO_DBUF = """
PRINT 1
"""

# about 13 KB of padding: pushes the code past &4000
_BIG = """
ASM
defs 13000
END ASM
"""


def _compile(tmp_path, source: str, *extra: str) -> subprocess.CompletedProcess:
    bas = os.path.join(tmp_path, "prog.bas")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)
    cmd = [sys.executable, _ZXBC, "--arch", "cpc", bas, "-o", os.path.join(tmp_path, "prog.bin"), *extra]
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def test_double_buffer_small_program_builds(tmp_path):
    assert _compile(tmp_path, _DBUF).returncode == 0


def test_double_buffer_code_past_4000_is_an_error(tmp_path):
    result = _compile(tmp_path, _DBUF + _BIG)
    assert result.returncode != 0
    assert "reserved because the program uses a library that reserves it" in result.stderr


def test_double_buffer_heap_below_8000_is_an_error(tmp_path):
    result = _compile(tmp_path, _DBUF + 'DIM a$ = "x"\nPRINT a$\n', "--heap-size", "10000")
    assert result.returncode != 0
    assert "the heap" in result.stderr


def test_no_double_buffer_big_program_builds(tmp_path):
    assert _compile(tmp_path, _NO_DBUF + _BIG).returncode == 0


@pytest.mark.parametrize(
    "labels, org, length, errors",
    [
        ((), 0x1000, 0x4000, 0),  # label absent: nothing reserved
        ((".x",), 0x1000, 0x2000, 0),  # ends at 0x2FFF, below the range
        ((".x",), 0x1000, 0x3001, 1),  # last byte at 0x4000
        ((".x",), 0x8000, 0x100, 0),  # starts at the end of the range
    ],
)
def test_reserved_range_check(monkeypatch, labels, org, length, errors):
    reported = []
    monkeypatch.setattr(zxbc_module.errmsg, "error", lambda lineno, msg, **kw: reported.append(msg))
    backend = SimpleNamespace(MAX_CODE_ADDRESS=None, RESERVED_RANGE_LABELS={".x": (0x4000, 0x8000, "test")})
    zxbc_module.check_memory_layout(backend, False, org, length, labels)
    assert len(reported) == errors
