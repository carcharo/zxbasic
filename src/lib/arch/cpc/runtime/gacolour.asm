; -----------------------------------------------------------------------
; Colours -- firmware and Gate Array together (SetInk, SetBorder)
;
; Written from scratch for this project (MIT); see cpc.bas. From the
; public documentation of the Gate Array's colour registers and colour
; numbers (cpcwiki.eu), checked in the emulator (cpcbuild's
; tools/palette_check.py).
;
; A colour change goes two ways (notes.md, Q-4c palette decision): through
; the firmware (SCR_SET_INK / SCR_SET_BORDER), so its own ink tables stay
; right, and straight to the Gate Array, so it shows at once instead of
; at the firmware's next ink update.
;
; Gate Array write (port &7Fxx): first a pen-select byte (0-15, or &10
; for the border), then a colour byte &40 + hardware colour code (0-31).
; The firmware numbers colours 0-26; __CPC_HWCOL maps them to the codes.

#include once <fwcall.asm>

    push namespace core

; Firmware colour number (0-26) -> Gate Array colour byte (&40 + code).
__CPC_HWCOL:
    defb $54, $44, $55, $5C, $58, $5D, $4C, $45, $4D     ;  0- 8
    defb $56, $46, $57, $5E, $40, $5F, $4E, $47, $4F     ;  9-17
    defb $52, $42, $53, $5A, $59, $5B, $4A, $43, $4B     ; 18-26

; __CPC_GA_SET -- writes one colour to the Gate Array only (the firmware's
; tables are not touched). A = pen 0-15, or 16 for the border; C =
; firmware colour 0-26. Out-of-range values are ignored. The two writes
; are made with interrupts off (the firmware's interrupt handler selects
; pens too, for flashing inks), and it returns with interrupts on.
; Firmware entries called: none.
; Registers clobbered: AF, BC, HL.
__CPC_GA_SET:
    PROC
    LOCAL __CGS_NOADD

    cp   17
    ret  nc
    ld   b, a               ; B = pen select byte
    ld   a, c
    cp   27
    ret  nc
    ld   hl, __CPC_HWCOL
    add  a, l
    ld   l, a
    jr   nc, __CGS_NOADD
    inc  h
__CGS_NOADD:
    ld   c, (hl)            ; C = colour byte
    ld   a, b
    ld   b, $7F             ; port &7Fxx; the low byte is ignored
    di
    out  (c), a             ; select the pen
    out  (c), c             ; colour: data = C
    ei
    ret
    ENDP

; __CPC_SET_INK -- A = pen (0-15), C = firmware colour 0-26: sets it in
; the firmware (not flashing: both inks the same) and on the Gate Array.
; Colours above 26 and pens above 15 are ignored (the firmware itself
; wraps pen 16 round to pen 0, so it is not passed on).
; Firmware entry called: SCR_SET_INK (&BC32, A = pen, B and C = colour).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the gate).
__CPC_SET_INK:
    cp   16
    ret  nc
    ld   b, a
    ld   a, c
    cp   27
    ret  nc
    ld   a, b
#ifndef CPC_BAREMETAL
    ld   b, c
    push af
    push bc
    call .core.__FW_CALL
    defw $BC32
    pop  bc
    pop  af
#endif
    jp   __CPC_GA_SET           ; bare-metal mode: the Gate Array only

; __CPC_SET_BORDER -- A = firmware colour 0-26: sets the border in the
; firmware and on the Gate Array. Colours above 26 are ignored.
; Firmware entry called: SCR_SET_BORDER (&BC38, B and C = colour).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the gate).
__CPC_SET_BORDER:
    cp   27
    ret  nc
    ld   b, a
    ld   c, a
#ifndef CPC_BAREMETAL
    push bc
    call .core.__FW_CALL
    defw $BC38
    pop  bc
#endif
    ld   a, 16
    jp   __CPC_GA_SET           ; bare-metal mode: the Gate Array only

    pop namespace
