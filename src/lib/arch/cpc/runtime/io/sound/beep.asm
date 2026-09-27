; Phase-1 stub for zx48k/runtime/io/sound/beep.asm (was: the BEEP
; statement, calling the Spectrum ROM's tone generator directly at &03F8,
; pitch/duration encoded as ROM-specific timing loop counts). No CPC
; equivalent at that address; the CPC's beeper is driven completely
; differently (PSG channel via the firmware's MC_SOUND_REGISTER &BD34 /
; SOUND_QUEUE &BCAA, or AY ports directly).
; TODO(cpc): Phase 4a.

#include once <stub.asm>

    push namespace core

BEEP:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
