# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------

# Z80N (ZX Next) opcodes can't run on the CPC's Z80: enabling zxnext
# via #pragma or -N must be a compile error on --arch cpc.

import os

import pytest

from src import zxbc
from src.api.config import OPTIONS

MSG = "zxnext (Z80N opcodes) is not available on --arch cpc"
NEXT_ASM = "asm\n    swapnib\nend asm\n"


def _compile(tmp_path, source: str, *flags: str, arch: str = "cpc"):
    bas = os.path.join(tmp_path, "t.bas")
    out = os.path.join(tmp_path, "t.asm")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)

    err = os.path.join(tmp_path, "t.err")
    rc = zxbc.main(["--arch", arch, "--output-format=asm", "--errmsg", err, *flags, bas, "-o", out])
    OPTIONS.stderr.flush()
    with open(err, encoding="utf-8") as f:
        return rc, f.read()


def test_pragma_zxnext_true_is_error_on_cpc(tmp_path):
    rc, err = _compile(tmp_path, "REM first\n#pragma zxnext=TRUE\n" + NEXT_ASM)
    assert rc != 0
    assert MSG in err
    assert "t.bas:2:" in err


def test_flag_zxnext_is_error_on_cpc(tmp_path):
    for flag in ("-N", "--zxnext"):
        rc, err = _compile(tmp_path, "PRINT 1\n", flag)
        assert rc != 0
        assert MSG in err


def test_pragma_zxnext_false_ok_on_cpc(tmp_path):
    rc, err = _compile(tmp_path, "#pragma zxnext=FALSE\nPRINT 1\n")
    assert rc == 0, err


def test_pragma_push_pop_zxnext_ok_on_cpc(tmp_path):
    src = "#pragma push(zxnext)\n#pragma pop(zxnext)\nPRINT 1\n"
    rc, err = _compile(tmp_path, src)
    assert rc == 0, err


def test_error_does_not_leak_to_next_compile(tmp_path):
    rc, _ = _compile(tmp_path, "#pragma zxnext=TRUE\nPRINT 1\n")
    assert rc != 0
    rc, err = _compile(tmp_path, "PRINT 1\n")
    assert rc == 0, err


def test_zxnext_from_previous_compile_does_not_leak_into_cpc(tmp_path):
    # An in-process --arch zxnext -N compile leaves zxnext set; a following
    # cpc compile that doesn't ask for it must still succeed.
    rc, err = _compile(tmp_path, "PRINT 1\n", "-N", arch="zxnext")
    assert rc == 0, err
    rc, err = _compile(tmp_path, "PRINT 1\n")
    assert rc == 0, err


@pytest.mark.parametrize("arch", ["zx48k", "zxnext"])
def test_zxnext_pragma_still_works_elsewhere(tmp_path, arch):
    rc, err = _compile(tmp_path, "#pragma zxnext=TRUE\n" + NEXT_ASM, arch=arch)
    assert rc == 0, err


@pytest.mark.parametrize("arch", ["zx48k", "zxnext"])
def test_zxnext_flag_still_works_elsewhere(tmp_path, arch):
    rc, err = _compile(tmp_path, NEXT_ASM, "-N", arch=arch)
    assert rc == 0, err
