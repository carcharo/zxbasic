# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------

# CPC memory defaults (org, heap address) must not leak into the next
# compilation run in the same process (as tests and IDE plugins do).

import os

import pytest

from src import zxbc


def _org_of(tmp_path, arch: str) -> str:
    bas = os.path.join(tmp_path, f"{arch}.bas")
    out = os.path.join(tmp_path, f"{arch}.asm")
    with open(bas, "w", encoding="utf-8") as f:
        f.write("DIM a AS UBYTE = 1\na = a + 1\n")

    assert zxbc.main(["--arch", arch, "--output-format=asm", bas, "-o", out]) == 0
    with open(out, encoding="utf-8") as f:
        return next(line.strip() for line in f if line.strip().startswith("org "))


@pytest.mark.parametrize("next_arch", ["zx48k", "zxnext"])
def test_cpc_org_does_not_leak(tmp_path, next_arch):
    assert _org_of(tmp_path, "cpc") == "org 4096"
    assert _org_of(tmp_path, next_arch) == "org 32768"
