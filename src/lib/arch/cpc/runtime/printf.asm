; printf.asm -- PRINT of a FLOAT number
;
; Ported from src/lib/arch/zx81sd/runtime/printf.asm. Replaces zx48k's
; printf.asm, which uses the calculator's 'str$' literal ($2Eh: STR$ +
; STK-STO-$ + a temporary ROM heap block) and then prints the resulting
; string. This uses fp_tostr.asm (the simplified conversion above)
; directly and prints its characters one at a time, through print.asm's
; __PRINTCHAR (TXT_OUTPUT via the firmware gate -- see print.asm's own
; header), without going through the heap at all.

#include once <fp_tostr.asm>
#include once <print.asm>

    push namespace core

__PRINTF:
    ; Input: A,E,D,C,B = FLOAT value
    call FP_TO_STR      ; HL = pointer to text, BC = length
    PROC
    LOCAL __PRINTF_LOOP

__PRINTF_LOOP:
    ld   a, b
    or   c
    ret  z

    ld   a, (hl)
    push hl
    push bc
    call __PRINTCHAR
    pop  bc
    pop  hl
    inc  hl
    dec  bc
    jr   __PRINTF_LOOP

    ENDP

    pop namespace
