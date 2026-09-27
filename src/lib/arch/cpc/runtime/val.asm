; val.asm -- VAL(a$): converts text to a floating-point number
;
; Ported from src/lib/arch/zx81sd/runtime/val.asm. Replaces zx48k's
; val.asm, which uses the Spectrum ROM's VAL: besides converting the
; text, the real ROM feeds the string back into the BASIC interpreter and
; evaluates it as a full expression (so VAL("2+2") works and gives 4 on a
; real Spectrum). That lives in the ROM's BASIC line scanner, a separate
; subsystem from the calculator, and is not ported here.
;
; This version supports only a single decimal LITERAL: optional sign,
; digits, and an optional decimal point followed by more digits. It does
; NOT evaluate expressions (VAL("2+2") does not work; VAL("2.5") or
; VAL("-13") do). This covers the common case of VAL(INPUT(...)) reading
; a number typed by the user. Any non-numeric character simply ends the
; parse at that point (the rest of the string is ignored) rather than
; raising an error.
;
; The number is built digit by digit with the calculator already ported
; above (fp_calc.asm): value = value*10 + digit, then divided by
; 10^(number of decimals) if there was a fractional part.

#include once <mem/free.asm>
#include once <stackf.asm>

    push namespace core

; --- Working variables (not re-entrant, transient use during VAL) ---------
VAL_PTR:        defw 0      ; pointer to the next character to read
VAL_LEN:        defw 0      ; characters remaining to read
VAL_STRPTR:     defw 0      ; original pointer to the string (to free it)
VAL_FREE_FLAG:  defb 0      ; 1 if the string must be freed when done
VAL_NEG:        defb 0      ; 1 if the number is negative
VAL_INFRAC:     defb 0      ; 1 once the decimal point has been seen
VAL_DECIMALS:   defb 0      ; number of digits read after the decimal point

VAL:
    ; Input:  HL = address of a$ (2 bytes of length + data)
    ;         A  = 1 if a$ must be freed when done (not a variable)
    ; Output: A EDCB = floating-point number (via __FPSTACK_POP)
    PROC

    LOCAL VAL_EMPTY
    LOCAL VAL_LOOP
    LOCAL VAL_GOT_SIGN
    LOCAL VAL_NOT_DOT
    LOCAL VAL_DIGIT
    LOCAL VAL_DIGIT_ADVANCE
    LOCAL VAL_DONE
    LOCAL VAL_DIV_LOOP
    LOCAL VAL_NOT_NEG
    LOCAL VAL_EMPTY_SKIP
    LOCAL VAL_NO_FREE
    LOCAL PUSH_DIGIT

    ld   (VAL_FREE_FLAG), a
    ld   a, h
    or   l
    jp   z, VAL_EMPTY       ; NULL string -> 0 (jp: VAL_EMPTY is far away)

    ld   (VAL_STRPTR), hl

    ld   e, (hl)
    inc  hl
    ld   d, (hl)
    inc  hl                 ; DE = string length
    ld   (VAL_LEN), de
    ld   (VAL_PTR), hl      ; HL = start of the text

    xor  a
    ld   (VAL_NEG), a
    ld   (VAL_INFRAC), a
    ld   (VAL_DECIMALS), a

    ld   hl, (VAL_LEN)
    ld   a, h
    or   l
    jp   z, VAL_DONE        ; empty string -> 0

    ld   hl, (VAL_PTR)
    ld   a, (hl)
    cp   '-'
    jr   nz, VAL_GOT_SIGN
    ld   a, 1
    ld   (VAL_NEG), a
    inc  hl
    ld   (VAL_PTR), hl
    ld   de, (VAL_LEN)
    dec  de
    ld   (VAL_LEN), de
VAL_GOT_SIGN:

    ; FP accumulator = 0
    xor  a
    ld   e, a
    ld   d, a
    ld   c, a
    ld   b, a
    call __FPSTACK_PUSH

VAL_LOOP:
    ld   hl, (VAL_LEN)
    ld   a, h
    or   l
    jp   z, VAL_DONE

    ld   hl, (VAL_PTR)
    ld   a, (hl)

    cp   '.'
    jr   nz, VAL_NOT_DOT
    ld   a, 1
    ld   (VAL_INFRAC), a
    jr   VAL_DIGIT_ADVANCE  ; the point doesn't count as a digit, just advance

VAL_NOT_DOT:
    cp   '0'
    jp   c, VAL_DONE
    cp   '9' + 1
    jp   nc, VAL_DONE

VAL_DIGIT:
    sub  '0'                ; A = digit 0-9
    push af

    ld   a, 10
    call PUSH_DIGIT
    rst  30h
    defb $04                ;;multiply
    defb $38                ;;end-calc

    pop  af
    call PUSH_DIGIT
    rst  30h
    defb $0F                ;;addition
    defb $38                ;;end-calc

    ld   a, (VAL_INFRAC)
    or   a
    jr   z, VAL_DIGIT_ADVANCE
    ld   hl, VAL_DECIMALS
    inc  (hl)

VAL_DIGIT_ADVANCE:
    ld   hl, (VAL_PTR)
    inc  hl
    ld   (VAL_PTR), hl
    ld   hl, (VAL_LEN)
    dec  hl
    ld   (VAL_LEN), hl
    jp   VAL_LOOP

VAL_DONE:
    ld   a, (VAL_DECIMALS)
    or   a
    jr   z, VAL_NOT_NEG
    ld   b, a
VAL_DIV_LOOP:
    push bc
    ld   a, 10
    call PUSH_DIGIT
    rst  30h
    defb $05                ;;division
    defb $38                ;;end-calc
    pop  bc
    djnz VAL_DIV_LOOP

VAL_NOT_NEG:
    ld   a, (VAL_NEG)
    or   a
    jr   z, VAL_EMPTY_SKIP
    rst  30h
    defb $1B                ;;negate
    defb $38                ;;end-calc
VAL_EMPTY_SKIP:

    call __FPSTACK_POP      ; A EDCB = result

    push af
    push de
    push bc
    ld   a, (VAL_FREE_FLAG)
    or   a
    jr   z, VAL_NO_FREE
    ld   hl, (VAL_STRPTR)
    call __MEM_FREE
VAL_NO_FREE:
    pop  bc
    pop  de
    pop  af
    ret

VAL_EMPTY:
    xor  a
    ld   e, a
    ld   d, a
    ld   c, a
    ld   b, a
    jp   __FPSTACK_POP

; --- Pushes A (0-255) as a small positive integer --------------------------
PUSH_DIGIT:
    ld   d, a
    xor  a
    ld   e, a
    ld   c, a
    ld   b, a
    jp   __FPSTACK_PUSH

    ENDP

    pop namespace
