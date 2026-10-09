# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# #pragma hidata = <address>: the data of the initialised global arrays
# declared after it is placed from that address up (the rest of the
# array stays where it is), and the memory-layout check looks at that
# data segment as well as at the main program (check_memory_layout() in
# src/zxbc/zxbc.py).
# --------------------------------------------------------------------

import os

import pytest

from src import zxbc

_ARRAYS = """
#pragma hidata = 0x8000
DIM a(3) AS UBYTE => {1, 2, 3, 4}
DIM b(1) AS UINTEGER => {$1234, $5678}
#pragma hidata = 0
DIM c(1) AS UBYTE => {9, 8}
PRINT a(1); b(1); c(1)
END
"""

_RESERVE_ASM = "asm\n  .core.__CPC_RESERVE_4000:\nend asm\n"

_STRING_HEAP = 'DIM s AS STRING\nDIM t AS STRING\ns = "hello"\nt = s + " world"\nPRINT t\n'


@pytest.fixture(autouse=True)
def _reset_global_state():
    yield


def _build(tmp_path, source: str, *args: str, org: str = "0x40") -> tuple[int, bytes, dict[str, int]]:
    bas = os.path.join(tmp_path, "t.bas")
    out = os.path.join(tmp_path, "t.bin")
    mmap = os.path.join(tmp_path, "t.map")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)
    rc = zxbc.main(["--arch", "cpc", "--org", org, *args, "-M", mmap, bas, "-o", out])
    if rc != 0:
        return rc, b"", {}
    with open(out, "rb") as f:
        binary = f.read()
    labels = {}
    with open(mmap, encoding="utf-8") as f:
        for line in f:
            addr, _, name = line.strip().partition(": ")
            if name:
                labels[name] = int(addr, 16)
    return rc, binary, labels


def test_pragma_places_arrays_consecutively(tmp_path):
    rc, binary, labels = _build(tmp_path, _ARRAYS)

    assert rc == 0
    # the file is one contiguous image from the origin (0x40), the gap zero filled
    assert binary[0x8000 - 0x40 : 0x8008 - 0x40] == bytes([1, 2, 3, 4, 0x34, 0x12, 0x78, 0x56])
    assert len(binary) == 0x8008 - 0x40
    # c is declared after "= 0": its data stays with the program
    assert labels["._c"] < 0x1000 and not any(0x8008 <= v < 0x9000 for v in labels.values() if v)


def test_pragma_asm_output(tmp_path):
    bas = os.path.join(tmp_path, "t.bas")
    out = os.path.join(tmp_path, "t.asm")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(_ARRAYS)
    assert zxbc.main(["--arch", "cpc", "-f", "asm", "-o", out, bas]) == 0
    with open(out, encoding="utf-8") as f:
        asm = f.read()

    assert "org 32768" in asm and "org 32772" in asm
    assert asm.count("org __HIDATA_BACK_") == 2


def test_no_pragma_has_no_high_segment(tmp_path):
    rc, binary, _ = _build(tmp_path, "DIM a(3) AS UBYTE => {1, 2, 3, 4}\nPRINT a(1)\n")

    assert rc == 0
    assert len(binary) < 0x1000


def test_data_above_4000_reservation_is_accepted(tmp_path):
    rc, binary, _ = _build(tmp_path, _RESERVE_ASM + _ARRAYS)

    assert rc == 0
    assert len(binary) == 0x8008 - 0x40


def test_data_inside_4000_reservation_is_an_error(tmp_path, capsys):
    rc, _, _ = _build(tmp_path, _RESERVE_ASM + _ARRAYS.replace("0x8000", "0x7FFE"))

    assert rc != 0
    assert "data placed at 0x7FFE" in capsys.readouterr().err


def test_code_running_into_reservation_is_still_an_error(tmp_path, capsys):
    rc, _, _ = _build(tmp_path, _RESERVE_ASM + "DIM a(17000) AS UBYTE\na(1) = 1\nPRINT a(1)\n")

    assert rc != 0
    assert "compiled code+data" in capsys.readouterr().err


def test_data_overlapping_heap_is_an_error_and_moving_the_heap_fixes_it(tmp_path, capsys):
    source = _STRING_HEAP + _ARRAYS.replace("0x8000", "0x8B5C")
    rc, _, _ = _build(tmp_path, source)

    assert rc != 0
    err = capsys.readouterr().err
    assert "data placed at 0x8B5C" in err and "overlaps the heap" in err and "--heap-address" in err

    rc, binary, _ = _build(tmp_path, source, "--heap-size", "512")
    assert rc == 0
    assert binary[0x8B5C - 0x40 : 0x8B60 - 0x40] == bytes([1, 2, 3, 4])


def test_data_past_private_block_is_an_error(tmp_path, capsys):
    rc, _, _ = _build(tmp_path, _ARRAYS.replace("0x8000", "0x9DFE"))

    assert rc != 0
    assert "ends at 0x" in capsys.readouterr().err


def test_baremetal_build(tmp_path):
    rc, binary, _ = _build(tmp_path, _ARRAYS, "-D", "CPC_BAREMETAL")

    assert rc == 0
    assert binary[0x8000 - 0x40 : 0x8004 - 0x40] == bytes([1, 2, 3, 4])


def test_other_archs_reject_the_pragma(tmp_path, capsys):
    bas = os.path.join(tmp_path, "t.bas")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(_ARRAYS)

    assert zxbc.main(["--arch", "zx48k", bas, "-o", os.path.join(tmp_path, "t.bin")]) != 0
    assert "only available on --arch cpc" in capsys.readouterr().err
