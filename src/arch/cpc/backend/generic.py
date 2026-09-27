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
    here jumps to .core.__CPC_END (bootstrap.asm), which normally just
    does RST 0 -- the firmware's full restart, landing back on BASIC's
    Ready prompt.

    Reaching address 0 (RST 0's target) is not, by itself, proof that the
    program actually reached END: a crash that happens to reset the
    machine, or a runtime error (error.asm's __ERROR, which also ends in
    RST 0 after printing "Error n"), lands there too. .core.__CPC_END is
    the single choke point for a *clean* END, so it -- not generic.py --
    is where a distinguishing marker belongs. Under
    -D __CPC_PRINTER_ECHO__ (cpcbuild's cpcrun.py test harness) it sends
    a line containing only "\x04END" to the printer, through the
    firmware gate, before the RST 0; cpcrun.py looks for that line to
    tell a clean END apart from an address-0 hit with no marker (crash/
    reset or an uncaught runtime error) -- see bootstrap.asm's
    __CPC_END for the marker format and cpcrun.py for how it's consumed.

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
    output.append("jp .core.__CPC_END")
    return output
