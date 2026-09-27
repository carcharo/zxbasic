# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Build-time memory-layout check (check_memory_layout() in
# src/zxbc/zxbc.py): a program's compiled code+data must not run into a
# heap placed at a fixed address (OPTIONS.heap_address), and on the
# Amstrad CPC it must also stay below the private runtime block at
# 0x9E00 (Backend.MAX_CODE_ADDRESS) even when the program never uses a
# heap at all -- see src/arch/cpc/backend/main.py's memory map.
# --------------------------------------------------------------------

import os

import pytest

from src import zxbc

# Uses a heap: string concatenation pulls in strcat.asm (one of
# common.MEMINITS), which is what makes emit_prologue() actually emit
# the heap start EQU -- see check_memory_layout()'s heap_in_use
# parameter.
_HEAP_PROGRAM = """
DIM a AS STRING
DIM b AS STRING
a = "hello"
b = a + " world"
PRINT b
END
"""

_FITS_PROGRAM = """
PRINT "hello"
END
"""

# Never touches the heap (no strings, no dynamic memory), but is big
# enough that, placed near the top of memory, its end address pushes
# past the cpc's private-block ceiling (0x9E00).
_MODERATE_PROGRAM = """
DIM a(200) AS INTEGER
DIM i AS INTEGER
FOR i = 0 TO 199
  a(i) = i * 2
NEXT i
PRINT a(100)
END
"""


def _write(tmp_path, name: str, source: str) -> str:
    path = os.path.join(tmp_path, name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(source)
    return path


@pytest.fixture(autouse=True)
def _reset_global_state():
    # zxbc.main() re-initialises config/backend/parser state at the top
    # of every call (see src/zxbc/zxbc.py), the same in-process pattern
    # tests/functional/test_basic.py relies on for hundreds of
    # sequential compiles, so no extra teardown is needed here.
    yield


def test_cpc_default_layout_fits(tmp_path):
    """A small program compiled with cpc's defaults (org 0x1000, heap
    top-aligned just below the private block) must compile cleanly."""
    bas = _write(tmp_path, "fits.bas", _FITS_PROGRAM)
    out = os.path.join(tmp_path, "fits.bin")

    assert zxbc.main(["--arch", "cpc", bas, "-o", out]) == 0
    assert os.path.isfile(out)
    assert os.path.getsize(out) > 0


def test_cpc_default_layout_fits_with_heap_in_use(tmp_path):
    """Same as above, but with a program that actually requires a heap:
    cpc's default top-aligned heap_address must not collide with its
    own code+data."""
    bas = _write(tmp_path, "fits_heap.bas", _HEAP_PROGRAM)
    out = os.path.join(tmp_path, "fits_heap.bin")

    assert zxbc.main(["--arch", "cpc", bas, "-o", out]) == 0
    assert os.path.isfile(out)


def test_cpc_heap_below_code_is_fine(tmp_path):
    """A heap placed entirely below the code doesn't overlap it."""
    bas = _write(tmp_path, "heap_below.bas", _HEAP_PROGRAM)
    out = os.path.join(tmp_path, "heap_below.bin")

    assert zxbc.main(["--arch", "cpc", "--org", "0x8000", "--heap-address", "0x4000", bas, "-o", out]) == 0
    assert os.path.isfile(out)


def test_cpc_heap_address_overlapping_code_is_an_error(tmp_path, capsys):
    """--heap-address placed just above --org, inside the compiled
    binary, must be rejected: nothing else catches code that uses the
    heap growing over a heap pinned at a fixed address."""
    bas = _write(tmp_path, "heap_overlap.bas", _HEAP_PROGRAM)
    out = os.path.join(tmp_path, "heap_overlap.bin")

    rc = zxbc.main(["--arch", "cpc", "--org", "0x8000", "--heap-address", "0x8010", bas, "-o", out])

    assert rc != 0
    assert not os.path.exists(out), "must not write a binary that overlaps its own heap"
    assert "overlaps the heap" in capsys.readouterr().err


def test_cpc_org_past_private_block_is_an_error(tmp_path, capsys):
    """Code+data must stay below the cpc's private runtime block
    (0x9E00) even though this program never touches the heap."""
    bas = _write(tmp_path, "moderate.bas", _MODERATE_PROGRAM)
    out = os.path.join(tmp_path, "moderate.bin")

    rc = zxbc.main(["--arch", "cpc", "--org", "0x9DF0", bas, "-o", out])

    assert rc != 0
    assert not os.path.exists(out), "must not write a binary that runs past the private block"
    assert "memory limit of 0x9E00" in capsys.readouterr().err


def test_zx48k_heap_address_overlapping_code_is_an_error(tmp_path, capsys):
    """The generic rule (not cpc-specific): zx48k with an explicit
    --heap-address that the compiled code overlaps must also fail."""
    bas = _write(tmp_path, "heap_overlap48.bas", _HEAP_PROGRAM)
    out = os.path.join(tmp_path, "heap_overlap48.bin")

    rc = zxbc.main(["--arch", "zx48k", "--org", "0x8000", "--heap-address", "0x8010", bas, "-o", out])

    assert rc != 0
    assert not os.path.exists(out)
    assert "overlaps the heap" in capsys.readouterr().err


def test_zx48k_default_heap_is_unaffected(tmp_path):
    """zx48k's default heap is inline (heap_address is None, so the
    heap's DEFS lives inside the binary itself), so the generic
    heap-overlap check must not apply, even though this program does
    use the heap. Also confirms zx48k has no MAX_CODE_ADDRESS ceiling."""
    bas = _write(tmp_path, "heap_default48.bas", _HEAP_PROGRAM)
    out = os.path.join(tmp_path, "heap_default48.bin")

    assert zxbc.main(["--arch", "zx48k", bas, "-o", out]) == 0
    assert os.path.isfile(out)
