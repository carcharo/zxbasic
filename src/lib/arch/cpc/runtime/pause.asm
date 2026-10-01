; -----------------------------------------------------------------------
; Amstrad CPC -- PAUSE n
;
; As on the Spectrum: waits n frames (1/50 s), or until a key is
; pressed; PAUSE 0 waits for a key only. zx48k jumps into the Spectrum
; ROM's PAUSE_1 (&1F3D).
;
; Frames are counted on the firmware's 300 Hz tick count (KL_TIME_PLEASE),
; 6 ticks per frame. The count only advances while interrupts run, which
; is inside gate calls, so the loop keeps calling the firmware and no
; tick is missed. A key that ends the pause is put back in the key
; buffer (KM_CHAR_RETURN), so a following INKEY$ sees it, like the
; Spectrum, where the key is still held down.
;
; Parameter: frames in HL.
; Firmware entries called (via the gate): KM_READ_CHAR (&BB09),
; KL_TIME_PLEASE (&BD0D, -> DEHL ticks), KM_CHAR_RETURN (&BB0C, A).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).

#include once <fwcall.asm>
#include once <sysvars.asm>

    push namespace core

__PAUSE:
    PROC
    LOCAL __P_LOOP, __P_KEY

    ld   b, h
    ld   c, l               ; BC = frames left
    call .core.__FW_CALL
    defw $BD0D              ; KL_TIME_PLEASE
    ld   a, l
    ld   (PAUSE_TICK), a    ; tick count at the last frame boundary

__P_LOOP:
    call .core.__FW_CALL
    defw $BB09              ; KM_READ_CHAR: Carry = a key
    jr   c, __P_KEY
    ld   a, b
    or   c
    jr   z, __P_LOOP        ; PAUSE 0: only a key ends it
    call .core.__FW_CALL
    defw $BD0D              ; KL_TIME_PLEASE: L = low byte
    ld   a, (PAUSE_TICK)
    ld   d, a
    ld   a, l
    sub  d                  ; ticks since the last frame boundary
    cp   6
    jr   c, __P_LOOP
    ld   a, d
    add  a, 6
    ld   (PAUSE_TICK), a    ; one frame later (catches up if behind)
    dec  bc
    ld   a, b
    or   c
    jr   nz, __P_LOOP
    ret

__P_KEY:
    call .core.__FW_CALL
    defw $BB0C              ; KM_CHAR_RETURN: keep it for INKEY$
    ret
    ENDP

    pop namespace
