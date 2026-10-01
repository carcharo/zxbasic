# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Phase 1 milestone guard test for the Amstrad CPC backend (--arch cpc).
#
# The Phase 1 milestone is: programs compile to a flat binary, and NO
# Spectrum ROM call, Spectrum sysvar address or Spectrum hardware port
# remains in any cpc build (they are either ported -- relocated sysvars
# -- or stubbed -- trap via .core.__CPC_NOT_IMPLEMENTED, to be replaced
# in later phases).
#
# This test compiles a small corpus of .bas snippets with --arch cpc,
# first to .asm (to text-scan the *code* for forbidden Spectrum
# references -- comments are allowed and expected to mention them, since
# every Phase 1 stub's header explains what Spectrum-specific thing it
# replaces) and then to .bin (to confirm it actually assembles). Every
# corpus entry must both compile and assemble; a construct that can't
# yet is listed in KNOWN_GAPS with a comment instead of silently being
# left out.
# --------------------------------------------------------------------

import os
import re

import pytest

from src import zxbc

ZXBASIC_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, os.path.pardir, os.path.pardir))
_INCLUDE_PATH = ":".join(os.path.join(ZXBASIC_ROOT, x) for x in ("stdlib", "runtime"))

# --------------------------------------------------------------------
# The corpus. Each entry compiles standalone; comments in the generated
# asm are allowed to mention Spectrum addresses (every Phase 1 stub's
# header does, to explain what it replaces) -- only *code* lines are
# scanned, see _strip_comment().
# --------------------------------------------------------------------
CORPUS: dict[str, str] = {
    "empty": """
        END
    """,
    "int_math": """
        DIM a AS UBYTE
        DIM b AS UINTEGER
        DIM c AS ULONG
        a = 3 * 5
        b = 1000 * 2 / 3
        c = 100000 * 3
        c = c / 7
        END
    """,
    "fixed_point": """
        DIM x AS FIXED
        x = 1.5
        x = x * 2.25
        x = x / 3.0
        END
    """,
    "float_math": """
        DIM x AS FLOAT
        DIM y AS FLOAT
        x = 1.5
        y = x + 2.5
        y = y - 1.0
        y = y * 2.0
        y = y / 3.0
        y = SIN(x)
        y = SQR(x)
        END
    """,
    "strings": """
        DIM a AS STRING
        DIM b AS STRING
        a = "hello"
        b = a + " world"
        b = b(1 TO 3)
        PRINT LEN(b)
        PRINT STR$(3.14)
        PRINT VAL("3.14")
        PRINT CHR$(65)
        END
    """,
    "arrays": """
        DIM a(3, 4) AS INTEGER
        a(1, 2) = 5
        PRINT a(1, 2)
        PRINT a(3, 4)
        END
    """,
    "data_read_restore": """
        DATA 1, 2, 3
        DIM x AS INTEGER
        READ x
        RESTORE
        READ x
        END
    """,
    "print_and_attrs": """
        PRINT "hi"
        PRINT AT 2, 3; "there"
        INK 1
        PAPER 2
        BRIGHT 1
        FLASH 0
        OVER 0
        INVERSE 0
        BOLD 1
        ITALIC 1
        CLS
        BORDER 4
        END
    """,
    "graphics": """
        PLOT 10, 10
        DRAW 5, 5
        DRAW 5, 5, 1.5
        CIRCLE 10, 10, 5
        END
    """,
    "graphics_mode_pixels": """
        PLOT 319, 199
        CIRCLE 160, 100, 90
        PLOT OVER 1; INVERSE 1; INK 2; 0, 0
        DRAW OVER 1; -300, -150
        BORDER 3
        END
    """,
    "sound_and_pause": """
        BEEP 1, 1
        PAUSE 1
        END
    """,
    "sound_runtime_args": """
        DIM d, p AS FLOAT
        d = 0.5
        p = 12
        BEEP d, p
        END
    """,
    "cpc_stdlib": """
        #include <cpc.bas>
        #include <point.bas>
        #include <input.bas>
        Mode 0
        SetInk 1, 6
        SetBorder 3
        WaitVsync
        PRINT GetMode(), POINT(10, 10)
        PRINT INPUT(10)
        END
    """,
    "inkey": """
        PRINT INKEY$
        END
    """,
    "random": """
        RANDOMIZE 1
        PRINT RND
        END
    """,
    "usr": """
        PRINT USR "a"
        PRINT USR 100
        END
    """,
    "load_save_code": """
        LOAD "x" CODE 0, 100
        SAVE "x" CODE 0, 100
        END
    """,
}

# Constructs that are known not to work yet under --arch cpc, with the
# reason. Kept out of CORPUS (they can't compile), but recorded here so
# the gap isn't silently invisible.
KNOWN_GAPS = {
    "SCREEN$()": (
        "Not cpc-specific: not a language builtin on any arch (checked "
        "against --arch zx48k too), and no stdlib .bas exports it. Not a "
        "gap introduced by this port. (POINT() is cpc stdlib point.bas.)"
    ),
}


# --------------------------------------------------------------------
# Forbidden-reference patterns (Phase 1 milestone, see module header).
# --------------------------------------------------------------------

# Spectrum RST vectors: rst 8 (error trap), rst 10h (PRINT-A), rst 28h
# (FP calculator) in any spelling. rst 30h (our own RST 6 target) and
# rst 0 (our own END) are fine and intentionally NOT matched here.
_RST_RE = re.compile(r"\brst\s+(?:8\b|10h\b|\$10\b|28h\b|\$28\b|40\b)", re.IGNORECASE)

# A jp/call to a bare numeric address below 0x4000 (decimal or hex),
# which would have to be Spectrum/generic-ROM code -- nothing legitimate
# in a cpc build calls a literal address that low (firmware lives at
# 0xBB00+ and is called through the gate in later phases, never as a
# bare numeric jp/call target).
_LOW_JUMP_RE = re.compile(
    r"\b(?:jp|call)\s+(?:"
    r"(\$?[0-3][0-9a-f]{3}h)"  # $0000-$3fffh style
    r"|(0x[0-3][0-9a-f]{3})"  # 0x0000-0x3fff style
    r"|([0-9]{1,5})"  # bare decimal
    r")\b",
    re.IGNORECASE,
)

# Spectrum sysvar range 23552-23733 ($5C00-$5CB5) used as a literal
# address/EQU value.
_SYSVAR_DEC_RE = re.compile(r"\b2(?:3552|3[5-6][0-9]{2}|37[0-2][0-9]|373[0-3])\b")
_SYSVAR_HEX_RE = re.compile(r"\$?0?5c[0-9a-b][0-9a-f]h?\b", re.IGNORECASE)

# Spectrum ULA / 128K paging / AY hardware ports.
_PORT_RE = re.compile(
    r"(?:out\s*\(\s*\$?0?fe(?:h)?\s*\)|in\s+a\s*,\s*\(\s*\$?0?fe(?:h)?\s*\))"
    r"|\b(?:0x7ffd|7ffdh|0xfffd|fffdh|0xbffd|bffdh)\b",
    re.IGNORECASE,
)


def _strip_comment(line: str) -> str:
    """Strips a `;`-introduced end-of-line comment. Good enough for
    generated asm, which never has a `;` inside a string operand on the
    same line as one of the patterns we scan for."""
    return line.split(";", 1)[0]


def _find_forbidden_references(asm_text: str) -> list[str]:
    problems = []
    for lineno, raw_line in enumerate(asm_text.splitlines(), 1):
        code = _strip_comment(raw_line)
        if not code.strip():
            continue

        if _RST_RE.search(code):
            problems.append(f"line {lineno}: forbidden RST: {raw_line.strip()!r}")

        m = _LOW_JUMP_RE.search(code)
        if m is not None:
            # A bare decimal jp/call target under 0x4000 could also be a
            # local/global *label name* that merely starts with digits
            # in some other numbering scheme, but zxbasm/zxbparser labels
            # are never purely numeric, and every jp/call in cpc output
            # otherwise takes a symbolic (.core.XXX or user) label -- so
            # a purely numeric operand here is always a real address.
            problems.append(f"line {lineno}: forbidden low jp/call target: {raw_line.strip()!r}")

        if _SYSVAR_DEC_RE.search(code) or _SYSVAR_HEX_RE.search(code):
            problems.append(f"line {lineno}: forbidden Spectrum sysvar address: {raw_line.strip()!r}")

        if _PORT_RE.search(code):
            problems.append(f"line {lineno}: forbidden Spectrum hardware port: {raw_line.strip()!r}")

    return problems


def _compile(name: str, source: str, out_path: str, file_type: str) -> int:
    bas_path = out_path + ".bas"
    with open(bas_path, "w", encoding="utf-8") as f:
        f.write(source)

    args = [
        "--arch",
        "cpc",
        f"--output-format={file_type}",
        bas_path,
        "-o",
        out_path,
        "-I",
        _INCLUDE_PATH,
    ]
    return zxbc.main(args)


@pytest.fixture(autouse=True)
def _reset_global_state():
    # zxbc.main() re-initialises config/backend/parser state at the top
    # of every call (see src/zxbc/zxbc.py), the same in-process pattern
    # tests/functional/test_basic.py relies on for hundreds of
    # sequential compiles, so no extra teardown is needed here.
    yield


@pytest.mark.parametrize("name", sorted(CORPUS))
def test_corpus_program_has_no_spectrum_references(name, tmp_path):
    source = CORPUS[name]
    asm_path = str(tmp_path / f"{name}.asm")

    rc = _compile(name, source, asm_path, "asm")
    assert rc == 0, f"{name}: failed to compile to asm (see stderr above)"

    with open(asm_path, encoding="utf-8") as f:
        asm_text = f.read()

    problems = _find_forbidden_references(asm_text)
    assert not problems, f"{name}: forbidden Spectrum reference(s) found:\n" + "\n".join(problems)


@pytest.mark.parametrize("name", sorted(CORPUS))
def test_corpus_program_assembles_to_bin(name, tmp_path):
    source = CORPUS[name]
    bin_path = str(tmp_path / f"{name}.bin")

    rc = _compile(name, source, bin_path, "bin")
    assert rc == 0, f"{name}: failed to assemble to a .bin (see stderr above)"
    assert os.path.isfile(bin_path), f"{name}: compiler reported success but produced no .bin"
    assert os.path.getsize(bin_path) > 0, f"{name}: .bin is empty"


def test_known_gaps_are_documented():
    # This is not a real check -- it just makes sure KNOWN_GAPS isn't
    # empty if someone removes an entry without updating the report.
    assert KNOWN_GAPS
