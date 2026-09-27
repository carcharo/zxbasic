; Sets ink color in ATTR_P permanently
; Parameter: Ink color in A register
;
; Amstrad CPC: byte-for-byte zx48k's version for the permanent entry
; (INK) -- it only touches ATTR_P/MASK_P by name via sysvars.asm, which
; cpc's own sysvars.asm relocates into the private runtime block, so a
; plain INK statement just updates memory (it takes effect at the next
; PRINT's COPY_ATTR, exactly like zx48k). INK_TMP additionally pushes
; the new pen to the firmware immediately (via __SET_ATTR_MODE,
; copy_attr.asm) -- unlike the Spectrum, where SET_ATTR re-reads ATTR_T
; per character, the CPC firmware's pen is persistent state, so a
; mid-PRINT `PRINT INK n;...` has to update it right away.

#include once <copy_attr.asm>
#include once <sysvars.asm>

    push namespace core

INK:
    PROC
    LOCAL __SET_INK
    LOCAL __SET_INK2

    ld de, ATTR_P

__SET_INK:
    cp 8
    jr nz, __SET_INK2

    inc de ; Points DE to MASK_T or MASK_P
    ld a, (de)
    or 7 ; Set bits 0,1,2 to enable transparency
    ld (de), a
    ret

__SET_INK2:
    ; Another entry. This will set the ink color at location pointer by DE
    and 7	; # Gets color mod 8
    ld b, a	; Saves the color
    ld a, (de)
    and 0F8h ; Clears previous value
    or b
    ld (de), a
    inc de ; Points DE to MASK_T or MASK_P
    ld a, (de)
    and 0F8h ; Reset bits 0,1,2 sign to disable transparency
    ld (de), a ; Store new attr
    ret

; Sets the INK color passed in A register in the ATTR_T variable, and
; pushes it to the firmware right away (see the file header).
INK_TMP:
    ld de, ATTR_T
    call __SET_INK
    jp __SET_ATTR_MODE

    ENDP

    pop namespace
