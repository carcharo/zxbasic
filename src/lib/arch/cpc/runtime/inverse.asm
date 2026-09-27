; Sets INVERSE flag in P_FLAG permanently
; Parameter: INVERSE flag in bit 0 of A register
;
; Amstrad CPC: INVERSE only touches P_FLAG by name (no ROM/HW), kept
; byte-for-byte identical to zx48k's. INVERSE_TMP tail-calls into
; copy_attr.asm's __SET_ATTR_MODE, which traps (see copy_attr.asm), so is
; dead code for now.

#include once <copy_attr.asm>

    push namespace core

INVERSE:
    PROC

    and 1	; # Convert to 0/1
    add a, a; # Shift left 3 bits for permanent
    add a, a
    add a, a
    ld hl, P_FLAG
    res 3, (hl)
    or (hl)
    ld (hl), a
    ret

; Sets INVERSE flag in P_FLAG temporarily
INVERSE_TMP:
    and 1
    add a, a
    add a, a; # Shift left 2 bits for temporary
    ld hl, P_FLAG
    res 2, (hl)
    or (hl)
    ld (hl), a
    jp __SET_ATTR_MODE

    ENDP

    pop namespace
