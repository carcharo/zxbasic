; Sets paper color in ATTR_P permanently
; Parameter: Paper color in A register
;
; Amstrad CPC: byte-for-byte zx48k's version for the permanent entry
; (PAPER). PAPER_TMP additionally pushes the new pen to the firmware
; right away, via __SET_ATTR_MODE -- see ink.asm's header for why.

#include once <copy_attr.asm>
#include once <sysvars.asm>

    push namespace core

PAPER:
    PROC
    LOCAL __SET_PAPER
    LOCAL __SET_PAPER2

    ld de, ATTR_P

__SET_PAPER:
    cp 8
    jr nz, __SET_PAPER2
    inc de
    ld a, (de)
    or 038h
    ld (de), a
    ret

    ; Another entry. This will set the paper color at location pointer by DE
__SET_PAPER2:
    and 7	; # Remove
    rlca
    rlca
    rlca		; a *= 8

    ld b, a	; Saves the color
    ld a, (de)
    and 0C7h ; Clears previous value
    or b
    ld (de), a
    inc de ; Points to MASK_T or MASK_P accordingly
    ld a, (de)
    and 0C7h  ; Resets bits 3,4,5
    ld (de), a
    ret


; Sets the PAPER color passed in A register in the ATTR_T variable, and
; pushes it to the firmware right away (see the file header).
PAPER_TMP:
    ld de, ATTR_T
    call __SET_PAPER
    jp __SET_ATTR_MODE
    ENDP

    pop namespace
