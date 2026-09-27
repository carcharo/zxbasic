# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# Amstrad CPC — END opcode handler
# --------------------------------------------------------------------

from src.arch.interface.quad import Quad
from src.arch.z80.backend import Bits16, common


def _end(ins: Quad):
    """End-of-program sequence for the Amstrad CPC.

    RUN"<file>" enters the program via the firmware's MC_BOOT_PROGRAM,
    which never returns -- even a single RET resets the machine -- so
    there is no BASIC to cleanly return to. Unlike the generic zx48k END
    (which restores the caller's SP/IX/IY from CALL_BACK and RETs), END
    here just performs RST 0: the firmware's full restart, landing back on
    BASIC's Ready prompt.

    If END appears more than once in the program (early exits), later
    occurrences generate a JP to the first emitted END block.
    """
    output = Bits16.get_oper(ins[1])
    output.append("ld b, h")
    output.append("ld c, l")

    if common.FLAG_end_emitted:
        return output + [f"jp {common.END_LABEL}"]

    common.FLAG_end_emitted = True

    output.append(f"{common.END_LABEL}:")
    output.append("rst 0")
    return output
