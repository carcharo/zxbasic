; Copies the permanent attribute (ATTR_P/MASK_P/FLAGS2/P_FLAG) into the
; temporary one (ATTR_T/MASK_T/...) at the start of every PRINT
; statement, then pushes the resulting ink/paper pens (and INVERSE) to
; the firmware -- see __SET_ATTR_MODE below, which does the actual
; firmware call and is also the shared re-apply entry used whenever
; INK_TMP/PAPER_TMP/INVERSE_TMP/OVER_TMP change the temporary attribute
; mid-statement (e.g. `PRINT INK 2; "x"; PAPER 1; "y"`).
;
; zx48k's COPY_ATTR self-modifies a PRINT_MODE/INVERSE_MODE opcode pair
; inside print.asm's VRAM writer, guarded by ___PRINT_IS_USED___ (which
; zxbparser.py defines whenever a program uses PRINT at all). There is
; no such opcode table here -- print.asm calls the firmware's
; TXT_OUTPUT instead of writing VRAM directly, so applying an attribute
; just means calling TXT_SET_PEN/TXT_SET_PAPER/TXT_INVERSE. That work
; doesn't depend on whether PRINT is used elsewhere (if it isn't, this
; file is never linked in at all), so the ___PRINT_IS_USED___ branch
; zx48k has is dropped.

#include once <fwcall.asm>
#include once <sysvars.asm>

    push namespace core

COPY_ATTR:
    ; Copies current permanent attribs into temporary attribs, then
    ; applies them to the firmware (pen/paper/inverse).
    PROC

    LOCAL __REFRESH_TMP

    ld hl, (ATTR_P)      ; = ATTR_P (L) + MASK_P (H), adjacent bytes
    ld (ATTR_T), hl      ; -> ATTR_T (L) + MASK_T (H)

    ld hl, FLAGS2
    call __REFRESH_TMP

    ld hl, P_FLAG
    call __REFRESH_TMP

    jp __SET_ATTR_MODE

; zx48k's bit-shuffle: permanent flags live in the odd bits (1,3,5,7),
; temporary ones in the even bits (0,2,4,6) of the same byte; this
; copies one into the other. Pure bit manipulation, no CPC-specific
; change needed.
__REFRESH_TMP:
    ld a, (hl)
    and 0b10101010
    ld c, a
    rra
    or c
    ld (hl), a
    ret

    ENDP


; Applies ATTR_T's ink/paper pens (mod 4 -- mode 1 has 4 pens, see
; sysvars.asm's bit-layout comment) and P_FLAG's temporary INVERSE bit
; (bit 2) to the firmware's current pen/paper. Always re-derives both
; pens from ATTR_T first (rather than tracking whether they're already
; inverted), so it's safe to call repeatedly as flags change mid-PRINT.
;
; Entry: none (rereads ATTR_T/P_FLAG directly; unlike zx48k's version,
; A is not significant on entry).
; Firmware entries called (via the gate): TXT_SET_PEN (&BB90, A = ink
; pen), TXT_SET_PAPER (&BB96, A = paper pen), and, only when the
; temporary INVERSE flag is set, TXT_INVERSE (&BB9C, swaps the current
; pen/paper for the stream -- simpler than computing the swap here).
; Registers clobbered: AF, HL (main); BC', DE', HL', AF' (the gate,
; once per firmware call above).
__SET_ATTR_MODE:
    PROC
    LOCAL __SAM_NOINV

    ld a, (ATTR_T)
    and 3                ; ink pen: bits 0-2 stored mod 8, mod 4 for the
                          ; firmware is just the low 2 bits
    call .core.__FW_CALL
    defw $BB90            ; TXT_SET_PEN

    ld a, (ATTR_T)
    and 038h              ; paper: bits 3-5
    rrca
    rrca
    rrca                  ; -> bits 0-2, mod 8
    and 3                 ; mod 4 for the firmware
    call .core.__FW_CALL
    defw $BB96             ; TXT_SET_PAPER

    ld a, (P_FLAG)
    and 4                 ; temporary INVERSE bit (bit 2 -- see inverse.asm)
    jr z, __SAM_NOINV
    call .core.__FW_CALL
    defw $BB9C              ; TXT_INVERSE: swap current pen/paper
__SAM_NOINV:
    ret
    ENDP

    pop namespace
