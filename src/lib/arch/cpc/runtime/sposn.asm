; Phase-1 stub for zx48k/runtime/sposn.asm (was: print cursor
; positioning, converting between S_POSN and a Spectrum VRAM/attribute
; address via the ROM's interleaved-bitmap formula). Meaningless on the
; CPC's linear mode 1 layout. Used internally by print.asm and directly
; by the stdlib POS()/CSRLIN() functions.
; TODO(cpc): Phase 2/4a -> together with print.asm and attr.asm.

#include once <stub.asm>

    push namespace core

__LOAD_S_POSN:
    jp __CPC_NOT_IMPLEMENTED

__SAVE_S_POSN:
    jp __CPC_NOT_IMPLEMENTED

__SET_SCR_PTR:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
