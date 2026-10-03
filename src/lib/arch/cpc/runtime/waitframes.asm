; -----------------------------------------------------------------------
; Amstrad CPC -- wait for frames (bare-metal mode, -D CPC_BAREMETAL)
;
; Shared by BEEP (io/sound/beeper.asm), WaitVsync (stdlib/cpc.bas) and
; cpcbuild's WaitRetrace/FlipBuffer. Counts changes of FH_FRAMES, the
; frame counter the interrupt handler keeps (isr.asm, framecore.asm: one
; count per frame flyback, 50 Hz), so interrupts must be on, as in all
; compiled code. Hardware used: none (reads the counter only). Firmware
; entries called: none.

#include once <sysvars.asm>

    push namespace core

; __CPC_WAIT_FRAMES -- BC = number of frames to wait (0 returns at once).
; Waits for BC changes of FH_FRAMES from now, i.e. returns just after the
; BC-th frame flyback, between BC-1 and BC frames after the call; catches
; up if the loop was held off for a while.
; Registers clobbered: AF, BC, DE, HL.
__CPC_WAIT_FRAMES:
    PROC
    LOCAL __WF_POLL
    ld   a, b
    or   c
    ret  z
    ld   de, (FH_FRAMES)
__WF_POLL:
    ld   hl, (FH_FRAMES)    ; one instruction: atomic against the handler
    or   a
    sbc  hl, de             ; HL = frames since the last look
    jr   z, __WF_POLL
    ld   a, c
    sub  l
    ld   c, a
    ld   a, b
    sbc  a, h
    ld   b, a               ; BC -= HL
    ret  c                  ; (more frames passed than were left)
    add  hl, de
    ex   de, hl             ; DE = the count we have seen
    ld   a, b
    or   c
    jr   nz, __WF_POLL
    ret
    ENDP

    pop namespace
