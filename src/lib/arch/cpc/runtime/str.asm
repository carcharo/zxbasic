; str.asm -- the STR$( ) function
;
; Ported from src/lib/arch/zx81sd/runtime/str.asm. Replaces zx48k's
; str.asm, which uses the calculator's 'str$' literal ($2Eh) together
; with STK-STO-$ and RECLAIM2 (ROM $19E8h) to build the string in the
; ROM's own workspace. This uses fp_tostr.asm (the simplified conversion
; above) directly and copies the result into a fresh heap block
; (mem/alloc.asm).

#include once <fp_tostr.asm>
#include once <mem/alloc.asm>

    push namespace core

__STR:
__STR_FAST:
    ; Input:  A,E,D,C,B = FLOAT value
    ; Output: HL = pointer to the string (heap), format [length(2B)][text]
    call FP_TO_STR      ; HL = pointer to text, BC = length
    PROC
    LOCAL __STR_END

    push hl             ; save pointer to text (FP_STR_BUF)
    push bc             ; save length

    ld   hl, 2
    add  hl, bc
    ld   b, h
    ld   c, l
    call __MEM_ALLOC    ; HL = new block of (length+2) bytes (or NULL)

    pop  bc             ; text length
    pop  de             ; pointer to text (FP_STR_BUF)

    ld   a, h
    or   l
    jr   z, __STR_END   ; out of memory -> return NULL

    push hl
    ld   (hl), c
    inc  hl
    ld   (hl), b
    inc  hl             ; HL = destination for the text

    ex   de, hl         ; HL = source (text), DE = destination

    ldir

    pop  hl             ; HL = pointer to the resulting string

__STR_END:
    ret

    ENDP

    pop namespace
