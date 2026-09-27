; Phase-1 stub for zx48k/runtime/cls.asm (was: clearing the Spectrum
; bitmap and attribute area directly, then resetting
; COORDS/S_POSN/DFCC/DFCCL). The CPC's mode 1 screen is a different size
; and layout, and has no separate attribute plane to clear (see
; attr.asm).
; TODO(cpc): Phase 4a -> firmware's SCR_CLEAR (&BC14).

#include once <stub.asm>

    push namespace core

CLS:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
