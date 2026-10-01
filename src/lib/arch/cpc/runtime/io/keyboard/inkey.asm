; -----------------------------------------------------------------------
; Amstrad CPC -- INKEY$
;
; Returns the next character from the firmware's key buffer
; (KM_READ_CHAR), or "" if there is none. zx48k scans the Spectrum
; keyboard through ROM routines instead (&028E/&031E/&0333).
;
; Differences from the Spectrum, where INKEY$ is the key held down right
; now: this is the CPC's own buffered model (like Locomotive BASIC's
; INKEY$). A key pressed once is returned once, and a key held down
; repeats at the firmware's auto-repeat rate. Codes are the CPC's own:
; RETURN 13, DEL 127, cursor keys 240-243 (up, down, left, right).
; Games that need several keys at once should test them directly
; (KM_TEST_KEY; a keyboard library comes in Phase 4c).
;
; Returns HL = a new ZX BASIC string (or 0 if out of memory).
; Firmware entry called (via the gate): KM_READ_CHAR (&BB09, -> Carry =
; got one, A = character).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).

#include once <fwcall.asm>
#include once <mem/alloc.asm>

    push namespace core

INKEY:
    PROC

    call .core.__FW_CALL
    defw $BB09              ; KM_READ_CHAR
    ld   e, a               ; E = character
    sbc  a, a
    and  1
    ld   d, a               ; D = length: 1 if a key, else 0
    push de
    ld   bc, 3              ; 2-byte length + 1 character
    call __MEM_ALLOC
    pop  de
    ld   a, h
    or   l
    ret  z                  ; out of memory

    ld   (hl), d
    inc  hl
    ld   (hl), 0
    inc  hl
    ld   (hl), e
    dec  hl
    dec  hl
    ret

    ENDP

    pop namespace
