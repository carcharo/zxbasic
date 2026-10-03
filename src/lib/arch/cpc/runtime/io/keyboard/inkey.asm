; -----------------------------------------------------------------------
; Amstrad CPC -- INKEY$
;
; Default: as on the Spectrum, the key held down right now, or "" if
; none. The keyboard matrix is scanned directly (kscan.asm) and the key
; is turned into a character with the firmware's own key translation
; tables, so the machine's layout is respected: SHIFT gives the shifted
; character, CONTROL the control character, and the caps and shift locks
; work as on the firmware. A key held down is returned again by every
; call (no auto-repeat, no buffering). SHIFT and CONTROL themselves are
; not keys, the joystick is ignored, and when several keys are held the
; first in matrix order (row 0 first, bit 0 first within a row: cursor
; up, cursor right, cursor down... ) that gives a character is returned.
; Codes are the CPC's own: RETURN 13, DEL 127, ESC 252, COPY 224, cursor
; keys 240-243 (up, down, left, right), keypad "0".."9" as digits. See
; kscan.asm (__CPC_KEYCHAR) for the details of the translation.
; The firmware's key buffer keeps filling in the background, so INPUT
; (input.bas) flushes it when it starts.
;
; Bare-metal mode (-D CPC_BAREMETAL): the same, with the translation
; tables and the caps/shift locks of kbare.asm instead of the firmware's
; (no firmware is called). -D CPC_INKEY_BUFFERED is an error there: there
; is no firmware key buffer.
;
; With -D CPC_INKEY_BUFFERED: the CPC's own buffered model (like
; Locomotive BASIC's INKEY$) instead: the next character from the
; firmware's key buffer (KM_READ_CHAR), or "" if there is none. A key
; pressed once is returned once, and a key held down repeats at the
; firmware's auto-repeat rate.
;
; zx48k scans the Spectrum keyboard through ROM routines instead
; (&028E/&031E/&0333).
;
; Returns HL = a new ZX BASIC string (or 0 if out of memory).
; Firmware entries called (via the gate): default: see __CPC_KEYCHAR in
; kscan.asm (only when a key is held); buffered: KM_READ_CHAR (&BB09, ->
; Carry = got one, A = character).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate). Default mode reads the PPI with interrupts off (returns with
; them on).

#ifdef CPC_BAREMETAL
#ifdef CPC_INKEY_BUFFERED
#error "CPC_INKEY_BUFFERED needs the firmware's key buffer: it can't be used with CPC_BAREMETAL"
#endif
#endif

#include once <fwcall.asm>
#include once <mem/alloc.asm>
#ifndef CPC_INKEY_BUFFERED
#include once <io/keyboard/kscan.asm>
#ifdef CPC_BAREMETAL
#include once <io/keyboard/kbare.asm>
#endif
#endif

    push namespace core

INKEY:
    PROC

#ifdef CPC_INKEY_BUFFERED
    call .core.__FW_CALL
    defw $BB09              ; KM_READ_CHAR
#else
    call __CPC_KEYHELD      ; Carry = a key, A = its character
#endif
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
