; Phase-1 stub for zx48k/runtime/io/sound/beeper.asm: a faster beep
; routine calling the Spectrum ROM directly at &03B5, with parameters
; encoded in the ROM's own timing-loop format. No cpc equivalent at that
; address.
; TODO(cpc): Phase 4a -> together with beep.asm.

#include once <stub.asm>

    push namespace core

__BEEPER:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
