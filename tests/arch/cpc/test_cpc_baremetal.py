# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# --------------------------------------------------------------------
# Bare-metal mode for --arch cpc (-D CPC_BAREMETAL, Phase 6): the backend
# picks the no-firmware memory map (private block $BC00, stack top $BC00,
# code+data+heap below $B800), the runtime has no firmware gate (so a
# firmware call fails to build), and the choice doesn't leak into the
# next in-process compile.
# --------------------------------------------------------------------

import os

from src import zxbc

_BARE = ["-D", "CPC_BAREMETAL"]

# No PRINT: bare text output is a later step; this needs only the boot.
_SIMPLE = """
POKE $C000, $FF
END
"""

# A direct firmware call (TXT_OUTPUT through the gate).
_FIRMWARE_CALL = """
ASM
    ld a, 65
    call .core.__FW_CALL
    defw $BB5A
END ASM
END
"""


def _compile(tmp_path, source: str, *flags: str, fmt: str = "asm"):
    bas = os.path.join(tmp_path, "t.bas")
    out = os.path.join(tmp_path, "t." + fmt)
    err = os.path.join(tmp_path, "t.err")
    with open(bas, "w", encoding="utf-8") as f:
        f.write(source)
    rc = zxbc.main(["--arch", "cpc", f"--output-format={fmt}", "--errmsg", err, *flags, bas, "-o", out])
    text = ""
    if os.path.exists(out) and fmt == "asm":
        with open(out, encoding="utf-8") as f:
            text = f.read()
    with open(err, encoding="utf-8") as f:
        return rc, text, f.read()


def test_bare_memory_map(tmp_path):
    rc, asm, err = _compile(tmp_path, _SIMPLE, *_BARE)
    assert rc == 0, err
    assert f"CPC_PRIV_BASE EQU {0xBC00}" in asm
    assert f"CPC_STACK_TOP EQU {0xBC00}" in asm
    assert "CPC_INIT_00_BOOTSTRAP" in asm
    assert "__CPC_FW_CALL" not in asm and "__FW_CALL:" not in asm


def test_firmware_map_unchanged(tmp_path):
    rc, asm, err = _compile(tmp_path, _SIMPLE)
    assert rc == 0, err
    assert f"CPC_PRIV_BASE EQU {0x9E00}" in asm
    assert f"CPC_STACK_TOP EQU {0xA600}" in asm
    assert "__FW_CALL:" in asm


def test_bare_heap_below_stack(tmp_path):
    src = 'DIM a AS STRING\na = "x" + "y"\nPOKE $C000, LEN a\nEND\n'
    rc, asm, err = _compile(tmp_path, src, *_BARE)
    assert rc == 0, err
    # heap top-aligned under the bare stack ($B800), default heap size
    heap = [line for line in asm.splitlines() if "ZXBASIC_MEM_HEAP" in line and "EQU" in line]
    assert heap, asm[:2000]
    assert int(heap[0].split("EQU")[1]) < 0xB800
    assert int(heap[0].split("EQU")[1]) > 0x9E00


def test_firmware_call_refused_in_bare_mode(tmp_path):
    # Fails to assemble: the gate (.core.__FW_CALL) doesn't exist in bare
    # mode (the "undefined label" message goes to stderr).
    rc, _asm, _err = _compile(tmp_path, _FIRMWARE_CALL, *_BARE, fmt="bin")
    assert rc != 0


def test_firmware_call_fine_in_firmware_mode(tmp_path):
    rc, _asm, err = _compile(tmp_path, _FIRMWARE_CALL, fmt="bin")
    assert rc == 0, err


def test_bare_mode_does_not_leak_into_next_compile(tmp_path):
    rc, _asm, err = _compile(tmp_path, _SIMPLE, *_BARE)
    assert rc == 0, err
    rc, asm, err = _compile(tmp_path, _SIMPLE)
    assert rc == 0, err
    assert f"CPC_PRIV_BASE EQU {0x9E00}" in asm


def test_bare_code_limit_is_higher(tmp_path):
    # ~45 KB of data from &0040 ends past the firmware limit ($9E00) but
    # below the bare one ($B800).
    src = "DIM big(45000) AS UBYTE\nbig(1) = 1\nPOKE $C000, big(1)\nEND\n"
    rc, _asm, err = _compile(tmp_path, src, "-H", "256", fmt="bin")
    assert rc != 0
    rc, _asm, err = _compile(tmp_path, src, "-H", "256", *_BARE, fmt="bin")
    assert rc == 0, err
