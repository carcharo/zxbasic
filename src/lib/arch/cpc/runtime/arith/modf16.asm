; Computes A % B for fixed values
;
; Amstrad CPC override: only change from zx48k's version is TEMP's
; storage address. zx48k uses the Spectrum ROM's MEMBOT sysvar as a
; 6-byte scratch (return address + divider DE/HL); on the CPC that
; address falls inside ordinary program RAM, so MODF16_SCRATCH
; (sysvars.asm) is a dedicated 6-byte slot instead, kept separate from
; ARRAY_SCRATCH so the two scratch users can never alias each other.

#include once <arith/divf16.asm>
#include once <arith/mulf16.asm>
#include once <sysvars.asm>

    push namespace core

__MODF16:
    ; 16.16 Fixed point Division (signed)
    ; DE.HL = Divisor, Stack Top = Divider
    ; A = Dividend, B = Divisor => A % B

PROC
    LOCAL TEMP

TEMP EQU MODF16_SCRATCH   ; cpc: dedicated scratch, not MEMBOT

    pop bc              ; ret addr
    ld (TEMP), bc       ; stores it temporarily
    ld (TEMP + 2), hl   ; stores HP of divider
    ld (TEMP + 4), de   ; stores DE of divider

    call __DIVF16
    rlc d				; Sign into carry
    sbc a, a			; a register = -1 sgn(DE), or 0
    ld d, a
    ld e, a				; DE = 0 if it was positive or 0; -1 if it was negative

    ld bc, (TEMP + 4)	; Pushes original divider into the stack
    push bc
    ld bc, (TEMP + 2)
    push bc

    ld bc, (TEMP)    ; recovers return address
    push bc
    jp __MULF16			; multiplies and return from there

ENDP

    pop namespace
