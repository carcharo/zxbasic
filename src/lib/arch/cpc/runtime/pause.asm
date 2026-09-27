; Phase-1 stub for zx48k/runtime/pause.asm (was: jumping straight into
; the Spectrum ROM's PAUSE_1 &1F3D, waiting for N interrupts or a
; keypress). Trapped rather than made a no-op: skipping the wait
; entirely would silently change program timing/behaviour, a worse
; failure mode than a visible hang.
; TODO(cpc): Phase 4a -> loop over MC_WAIT_FLYBACK (&BD19) for timed
; pauses, KM_WAIT_KEY (&BB18) for PAUSE 0.

#include once <stub.asm>

    push namespace core

__PAUSE:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
