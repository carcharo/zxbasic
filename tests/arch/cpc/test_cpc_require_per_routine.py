# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# A #require inside a SUB/FUNCTION body only applies if that routine is
# emitted; at file level it is global.
# --------------------------------------------------------------------

import os

import pytest

from src import zxbc

_DIR = os.path.join(os.path.dirname(__file__), "req")
_MARKER = "REQ_TEST_MARKER"

_FILE_LEVEL = '#require "reqlib.asm"\nPRINT 1\n'
_CALLED = 'SUB Used()\n  #require "reqlib.asm"\n  PRINT 1\nEND SUB\nUsed()\n'
_UNCALLED = 'SUB Unused()\n  #require "reqlib.asm"\n  PRINT 1\nEND SUB\nPRINT 2\n'
_ONLY_FROM_DROPPED = (
    'SUB Inner()\n  #require "reqlib.asm"\n  PRINT 1\nEND SUB\nSUB Outer()\n  Inner()\nEND SUB\nPRINT 2\n'
)


@pytest.fixture(autouse=True)
def _reset_global_state():
    yield


def _asm(tmp_path, source: str, opt: int) -> str:
    bas = os.path.join(tmp_path, "t.bas")
    out = os.path.join(tmp_path, "t.asm")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)
    assert zxbc.main(["--arch", "cpc", f"-O{opt}", "-I", _DIR, "-A", "-o", out, bas]) == 0
    with open(out, encoding="utf-8") as f:
        return f.read()


@pytest.mark.parametrize("opt", [0, 2])
def test_file_level_require_is_included(tmp_path, opt):
    assert _MARKER in _asm(tmp_path, _FILE_LEVEL, opt)


@pytest.mark.parametrize("opt", [0, 2])
def test_require_in_called_sub_is_included(tmp_path, opt):
    assert _MARKER in _asm(tmp_path, _CALLED, opt)


def test_require_in_uncalled_sub_dropped_at_O2(tmp_path):
    assert _MARKER not in _asm(tmp_path, _UNCALLED, 2)


def test_require_in_uncalled_sub_kept_at_O0(tmp_path):
    assert _MARKER in _asm(tmp_path, _UNCALLED, 0)


def test_require_in_sub_called_only_by_dropped_sub_dropped_at_O2(tmp_path):
    assert _MARKER not in _asm(tmp_path, _ONLY_FROM_DROPPED, 2)
