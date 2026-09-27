; Phase-1 stub for zx48k/runtime/border.asm (was: `BORDER EQU 229Bh`,
; calling straight into the Spectrum ROM's border routine with the
; colour in A). TODO(cpc): Phase 4a -> SCR_SET_BORDER &BC38 through a
; firmware call gate (colour in B/C, not A).

#include once <stub.asm>

    push namespace core

BORDER:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
