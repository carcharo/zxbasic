; -----------------------------------------------------------------------
; Amstrad CPC firmware sound manager, non-blocking entries
;
; The firmware's sound manager plays queued notes from its 300 Hz
; interrupt handler, which is always running in compiled code (isr.asm),
; so a note can be queued and the program carries on. BEEP (beeper.asm)
; queues one and then waits; these routines never wait. The sound block
; (SOUND_BLK) and the envelope buffer (SND_ENV) live in the private block
; (central 32K), where the firmware can read them with the ROMs enabled.
; The firmware copies both (checked: tests/conformance/sound.bas), so
; they can be reused at once.
;
; All firmware calls go through the IX-preserving gate (the sound manager
; corrupts IX, which is the BASIC frame pointer).
;
; Sound block (9 bytes): 0 channels (bit 0-2: A/B/C), rendezvous (3-5),
; hold (6), flush (7); 1 volume envelope; 2 tone envelope; 3-4 tone
; period; 5 noise period; 6 start volume; 7-8 duration in 1/100 s.

#include once <fwcall.asm>
#include once <sysvars.asm>

    push namespace core

; __CPC_SND_QUEUE -- queue one note without waiting.
; In: A = channel byte (bits 0-2 channels, 3-5 rendezvous, 7 flush; bit 6
; hold is cleared, nothing would release it), HL = tone period (clamped
; to 4095), DE = duration in 1/100 s (0 = one run of the volume
; envelope), B = start volume (0-15), C = volume envelope (0 = none).
; Out: A = 1 if queued, 0 if the channel's queue was full.
; Firmware entries called: SOUND_QUEUE (&BCAA, HL = block; Carry =
; queued; corrupts IX, so via __FW_CALL_IX).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (gate).
__CPC_SND_QUEUE:
    and  $BF
    ld   (SOUND_BLK + 0), a
    ld   a, h
    and  $F0
    jr   z, __SND_PER_OK
    ld   hl, 4095
__SND_PER_OK:
    ld   (SOUND_BLK + 3), hl
    ld   (SOUND_BLK + 7), de
    ld   a, b
    and  $0F
    ld   (SOUND_BLK + 6), a
    ld   a, c
    ld   (SOUND_BLK + 1), a
    xor  a
    ld   (SOUND_BLK + 2), a     ; no tone envelope
    ld   (SOUND_BLK + 5), a     ; no noise
    ld   hl, SOUND_BLK
    call .core.__FW_CALL_IX
    defw $BCAA                  ; SOUND_QUEUE: Carry = queued
    sbc  a, a                   ; A = 0 or $FF
    and  1
    ret

; __CPC_SND_CHECK -- A = channel bit (1, 2 or 4) -> A = SOUND_CHECK
; status: bits 0-2 free queue slots (0-4), bit 3-5 rendezvous waiting
; for A/B/C, bit 6 held, bit 7 a sound is playing.
; Firmware entries called: SOUND_CHECK (&BCAD).
; Registers clobbered: AF, BC, DE, HL (as the firmware leaves them);
; BC', DE', HL', AF' (the gate).
__CPC_SND_CHECK:
    call .core.__FW_CALL_IX
    defw $BCAD
    ret

; __CPC_SND_BUSY -- A = channel bit -> A = 1 if that channel is playing
; or has anything queued (fewer than 4 free slots, or status bit 7), else 0.
; Registers clobbered: as __CPC_SND_CHECK, and C.
__CPC_SND_BUSY:
    PROC
    LOCAL __SB_DONE
    call __CPC_SND_CHECK
    ld   c, a
    and  7
    cp   4
    ld   a, 1
    jr   c, __SB_DONE
    bit  7, c
    jr   nz, __SB_DONE
    xor  a
__SB_DONE:
    ret
    ENDP

; __CPC_SND_ENV -- A = envelope number (1-15), HL = user data of B
; sections (3 bytes each, 1-5), copied after a section count into SND_ENV
; and given to SOUND_AMPL_ENVELOPE.
; Firmware entries called: SOUND_AMPL_ENVELOPE (&BCBC, A = number,
; HL = 16 byte data).
; Registers clobbered: AF, BC, DE, HL; BC', DE', HL', AF' (the gate).
__CPC_SND_ENV:
    PROC
    LOCAL __SE_OK
    ex   af, af'            ; keep the envelope number
    ld   a, b
    or   a
    ret  z                  ; no sections
    cp   6
    jr   c, __SE_OK
    ld   a, 5
__SE_OK:
    ld   de, SND_ENV
    ld   (de), a
    inc  de
    ld   b, a
    add  a, a
    add  a, b               ; 3 * sections
    ld   c, a
    ld   b, 0
    ldir
    ex   af, af'
    ld   hl, SND_ENV
    call .core.__FW_CALL_IX
    defw $BCBC              ; SOUND_AMPL_ENVELOPE
    ret
    ENDP

; __CPC_SND_RESET -- SOUND_RESET (&BCA7): empties every queue, silences
; the chip.
; Registers clobbered: AF, BC, DE, HL; BC', DE', HL', AF' (the gate).
__CPC_SND_RESET:
    call .core.__FW_CALL_IX
    defw $BCA7
    ret

    pop namespace
