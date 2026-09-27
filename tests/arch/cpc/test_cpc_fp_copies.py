# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Guard test for the Amstrad CPC backend (Phase 1).
#
# The 25 files listed in FP_COPY_FILES below are meant to be exact copies
# of the corresponding src/lib/arch/zx48k/runtime/ file, with every
# `rst 28h` replaced by `rst 30h` (on the cpc, &0028 is the firmware's
# RST 5 FIRM JUMP, so the float calculator entry has to move to RST 6,
# &0030) plus a short header and an added `#include once <fp_calc.asm>`
# line.
#
# This test re-derives that same substitution independently (it does not
# import the generator script that created the files) and fails if a cpc
# copy has drifted from what a fresh substitution of the current zx48k
# file would produce -- e.g. if zx48k's file is updated upstream but the
# cpc copy isn't regenerated, or if someone hand-edits a cpc copy.
# --------------------------------------------------------------------

import os

import pytest

ZXBASIC_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, os.path.pardir, os.path.pardir))
ZX48K_RUNTIME = os.path.join(ZXBASIC_ROOT, "src", "lib", "arch", "zx48k", "runtime")
CPC_RUNTIME = os.path.join(ZXBASIC_ROOT, "src", "lib", "arch", "cpc", "runtime")

# The 25 rst-28h-only files, relative to <arch>/runtime/.
FP_COPY_FILES = [
    "arith/addf.asm",
    "arith/subf.asm",
    "arith/mulf.asm",
    "arith/modf.asm",
    "negf.asm",
    "cmp/eqf.asm",
    "cmp/nef.asm",
    "cmp/ltf.asm",
    "cmp/lef.asm",
    "cmp/gtf.asm",
    "cmp/gef.asm",
    "bool/andf.asm",
    "bool/orf.asm",
    "bool/xorf.asm",
    "bool/notf.asm",
    "math/sin.asm",
    "math/cos.asm",
    "math/tan.asm",
    "math/asin.asm",
    "math/acos.asm",
    "math/atan.asm",
    "math/exp.asm",
    "math/logn.asm",
    "math/pow.asm",
    "math/sqrt.asm",
]

# The cpc copy's header ends with this exact line.
_MARKER = "#include once <fp_calc.asm>\n"


def _strip_cpc_header(cpc_text: str) -> str:
    """Removes the generated header + the added `#include once
    <fp_calc.asm>` line (and the single blank line that follows it),
    returning what should be byte-for-byte the original zx48k content
    (after the rst 28h -> rst 30h substitution).
    """
    idx = cpc_text.index(_MARKER)
    rest = cpc_text[idx + len(_MARKER) :]
    # Exactly one blank line separates the added include from the
    # original file's own first line.
    assert rest.startswith("\n"), "expected exactly one blank line after the added #include"
    return rest[1:]


@pytest.mark.parametrize("relpath", FP_COPY_FILES)
def test_cpc_fp_copy_matches_zx48k_with_rst30h(relpath: str):
    zx48k_path = os.path.join(ZX48K_RUNTIME, relpath)
    cpc_path = os.path.join(CPC_RUNTIME, relpath)

    assert os.path.isfile(zx48k_path), f"missing zx48k source: {zx48k_path}"
    assert os.path.isfile(cpc_path), f"missing cpc copy: {cpc_path}"

    zx48k_text = open(zx48k_path, encoding="utf-8").read()
    cpc_text = open(cpc_path, encoding="utf-8").read()

    assert "rst 28h" in zx48k_text, f"{relpath}: expected literal 'rst 28h' in the zx48k source"
    # No other rst-28h spelling should ever sneak into these files; if
    # that ever changes, this substitution (and the generator that made
    # the cpc copies) needs revisiting.
    assert "rst 40" not in zx48k_text.lower()
    assert "rst $28" not in zx48k_text.lower()

    expected = zx48k_text.replace("rst 28h", "rst 30h")
    actual = _strip_cpc_header(cpc_text)

    # Normalize end-of-file trailing blank lines before comparing: some
    # zx48k sources (negf.asm, at least) end with two blank lines, which
    # the repo's own pre-commit end-of-file-fixer hook trims back to a
    # single trailing newline whenever the cpc copy is touched. That is
    # whitespace-only drift at EOF, not a real change to the routine, so
    # it must not fail this test every time pre-commit normalizes a cpc
    # copy that was last regenerated from an un-normalized zx48k file.
    assert actual.rstrip("\n") == expected.rstrip("\n"), (
        f"{relpath}: cpc copy has drifted from a fresh rst28h->rst30h substitution of zx48k's file"
    )


def test_fp_copy_file_list_is_exhaustive():
    """Every zx48k runtime file that is a straight 'copy: rst 28h ->
    rst 30h' port (25 files) must be listed above -- no more, no less --
    and every listed cpc copy must actually exist on disk.
    """
    assert len(FP_COPY_FILES) == 25
    assert len(set(FP_COPY_FILES)) == 25

    for relpath in FP_COPY_FILES:
        cpc_path = os.path.join(CPC_RUNTIME, relpath)
        assert os.path.isfile(cpc_path), f"missing cpc copy: {cpc_path}"


def test_fp_calc_placeholder_exists():
    """fp_calc.asm (the Phase 1 RST 6 trap + installer -- see its own
    header) must exist alongside the 25 copies that #include it.
    """
    fp_calc_path = os.path.join(CPC_RUNTIME, "fp_calc.asm")
    assert os.path.isfile(fp_calc_path)
    text = open(fp_calc_path, encoding="utf-8").read()
    assert "FP_CALC_ENTRY" in text
    assert "#init" in text
