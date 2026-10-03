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
; buffer (KM_CHAR_RETURN). INKEY$ reads the key currently held, so it
; sees the key anyway while it stays down; the put-back only matters
; to a following INKEY$ when built with -D CPC_INKEY_BUFFERED (which
; reads the buffer).
;
; Parameter: frames in HL.
; Firmware entries called (via the gate): KM_READ_CHAR (&BB09),
; KL_TIME_PLEASE (&BD0D, -> DEHL ticks), KM_CHAR_RETURN (&BB0C, A).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).

#ifdef CPC_BAREMETAL

; Bare-metal mode (-D CPC_BAREMETAL): no firmware, so the frames come from
; FH_FRAMES (the frame counter the interrupt handler keeps, isr.asm and
; framecore.asm: one count per frame flyback, 50 Hz) and the key test is
; the keyboard matrix scan. Interrupts must be on, as in all compiled
; code: the counter only moves in the handler.
;
; PAUSE n ends early on a NEW key press (a key not down at the previous
; poll, so a key held when PAUSE starts, or kept down, doesn't end it;
; SHIFT, CONTROL and the joystick count as keys). PAUSE 0 waits for such
; a key only. The pause lasts between n-1 and n frames (it starts
; mid-frame, as the Spectrum's does).
;
; Hardware used: PPI ports A/C and the AY's port A (keyboard matrix) via
; io/keyboard/kscan.asm's __CPC_KSCAN_ROWS (interrupts off for each scan,
; on afterwards); nothing else. Firmware entries called: none.
;
; (__CPC_WAIT_FRAMES, the frame wait, is in waitframes.asm.)
; __PAUSE -- HL = frames (0 = until a key).
; Registers clobbered: AF, BC, DE, HL.

#include once <sysvars.asm>
#include once <io/keyboard/kscan.asm>

    push namespace core

__PAUSE:
    PROC
    LOCAL __P_LOOP, __P_NOCOUNT

    push hl
    call __P_NEWKEY         ; the keys already down are not "new"
    pop  bc                 ; BC = frames left (0: until a key)
    ld   de, (FH_FRAMES)
__P_LOOP:
    push bc
    push de
    call __P_NEWKEY
    pop  de
    pop  bc
    ret  nz                 ; a new key
    ld   hl, (FH_FRAMES)
    or   a
    sbc  hl, de
    jr   z, __P_LOOP        ; no new frame yet
    ld   a, b
    or   c
    jr   z, __P_NOCOUNT     ; PAUSE 0: only a key ends it
    ld   a, c
    sub  l
    ld   c, a
    ld   a, b
    sbc  a, h
    ld   b, a
    ret  c
    ld   a, b
    or   c
    ret  z
__P_NOCOUNT:
    add  hl, de
    ex   de, hl             ; DE = the count we have seen
    jr   __P_LOOP
    ENDP

; __P_NEWKEY -- scans the keyboard (rows 0-9) and returns NZ if a key is
; down that was not at the previous scan (the first scan stores the
; state). Registers clobbered: AF, BC, DE, HL.
__P_NEWKEY:
    PROC
    LOCAL __PN_LOOP
    ld   de, $000A
    call __CPC_KSCAN_ROWS   ; returns with interrupts on
    ld   hl, __CPC_KEYS
    ld   de, __P_PREV
    ld   b, 10
    ld   c, 0
__PN_LOOP:
    ld   a, (de)            ; previous state
    cpl
    and  (hl)               ; down now and not before
    or   c
    ld   c, a
    ld   a, (hl)
    ld   (de), a            ; this scan becomes the previous one
    inc  hl
    inc  de
    djnz __PN_LOOP
    ld   a, c
    or   a
    ret
    ENDP

__P_PREV:
    defs 10                 ; the keyboard state at the last poll

    pop namespace

#else

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

#endif
