; -----------------------------------------------------------------------
; Amstrad CPC -- BEEP with constant arguments, and the shared tone player
;
; zx48k's __BEEPER jumps into the Spectrum ROM's beeper loop (&03B5)
; with ROM timing-loop counts. For cpc, the compiler converts constant
; BEEP arguments with src/arch/cpc/beep.py instead, into the firmware
; sound manager's units, and BEEP with run-time values (beep.asm)
; computes the same two numbers at run time:
;
;   tone period = 62500 / frequency  (AY clocked at 1 MHz; middle C =
;                                     239, measured in Caprice32)
;   duration    = seconds * 100      (1/100 s units)
;
; The tone is queued on channel A with SOUND_QUEUE and BEEP waits for it
; to finish, as the Spectrum's BEEP does. That makes the firmware the
; AY's owner while it plays: a program using the Play/music libraries
; (direct AY access, Phase 4d) must not also use BEEP (the plan's
; "one owner of the AY" rule).

#include once <fwcall.asm>
#include once <sysvars.asm>

    push namespace core

; __BEEPER -- the compiler's constant-BEEP entry: tone period pushed,
; duration (1/100 s) in HL.
__BEEPER:
    ex   de, hl             ; DE = duration
    pop  hl                 ; return address
    ex   (sp), hl           ; HL = period; return address back on top

; __CPC_TONE -- HL = tone period, DE = duration in 1/100 s. Plays a
; square wave on channel A at full volume and returns when it's done.
; A zero duration plays nothing (to the firmware, 0 would mean "as long
; as the volume envelope"). The period is clamped to the AY's 1-4095.
; Firmware entries called: SOUND_QUEUE (&BCAA, HL = sound block, via
; the IX-preserving gate), SOUND_CHECK (&BCAD, A = channel bit ->
; A = status).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).
__CPC_TONE:
    PROC
    LOCAL __T_PER_HI, __T_PER_OK, __T_QUEUE, __T_WAIT

    ld   a, d
    or   e
    ret  z
    ld   a, h
    and  $F0
    jr   z, __T_PER_HI
    ld   hl, 4095
__T_PER_HI:
    ld   a, h
    or   l
    jr   nz, __T_PER_OK
    inc  hl
__T_PER_OK:
    ld   (SOUND_BLK + 3), hl    ; tone period
    ld   (SOUND_BLK + 7), de    ; duration
    ld   a, 1
    ld   (SOUND_BLK + 0), a     ; channel A, no rendezvous/hold/flush
    xor  a
    ld   (SOUND_BLK + 1), a     ; no volume envelope
    ld   (SOUND_BLK + 2), a     ; no tone envelope
    ld   (SOUND_BLK + 5), a     ; no noise
    ld   a, 15
    ld   (SOUND_BLK + 6), a     ; full volume

__T_QUEUE:
    ld   hl, SOUND_BLK
    call .core.__FW_CALL_IX
    defw $BCAA                  ; SOUND_QUEUE: Carry = queued
    jr   nc, __T_QUEUE          ; queue full: retry as it drains

__T_WAIT:                       ; until channel A is idle and empty
    ld   a, 1
    call .core.__FW_CALL
    defw $BCAD                  ; SOUND_CHECK
    bit  7, a                   ; still playing?
    jr   nz, __T_WAIT
    and  7                      ; free queue slots (4 = empty)
    cp   4
    jr   c, __T_WAIT
    ret
    ENDP

    pop namespace
