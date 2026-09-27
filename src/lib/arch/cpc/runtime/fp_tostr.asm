; fp_tostr.asm -- converts a FLOAT to decimal ASCII text
;
; Ported from src/lib/arch/zx81sd/runtime/fp_tostr.asm. Used by printf.asm
; (PRINT of a FLOAT) and str.asm (STR$). The Spectrum ROM does this with
; PRINT-FP, a large routine that also supports scientific (E-format)
; notation and depends on machinery this runtime doesn't have (CHAN-OPEN
; channels, the BASIC editor's growable workspace). This is a simplified
; replacement, by design: sign + integer part + up to 5 decimals, ROUNDED
; (half away from zero) to the 5th decimal, no scientific notation,
; trailing zeros trimmed (and the decimal point too, if every decimal
; came out zero). Covers ordinary PRINT/STR$ use of FLOAT. Numbers whose
; magnitude needs scientific notation to read sensibly (e.g. 1e10, 1e-7)
; still print in full fixed-point form -- very large values as a long
; digit string, very small ones as "0" once rounding sinks them below
; the 5 decimals shown.
;
; Builds on the calculator above (fp_calc.asm: duplicate/int/subtract/
; negate) and pure Z80 routines already in the runtime (__FTOU32REG/
; __FTOU8 for FLOAT -> integer conversion, __DIVU32).

#include once <fp_calc.asm>
#include once <stackf.asm>
#include once <ftou32reg.asm>
#include once <arith/div32.asm>

    push namespace core

; --- Working variables (not re-entrant, transient use only) ----------------
FP_STR_ORIG:    defb 0, 0, 0, 0, 0  ; A E D C B of the value (made positive)
FP_STR_INT:     defb 0, 0, 0, 0, 0  ; integer part
FP_STR_FRAC:    defb 0, 0, 0, 0, 0  ; fractional part (updated each iteration)
FP_STR_COUNT:   defb 0              ; remaining decimal digits to emit
FP_STR_NEG:     defb 0              ; 1 if the value was negative
FP_STR_WR:      defw 0              ; write cursor into FP_STR_BUF
FP_STR_BUF:     defs 24             ; output buffer (sign + integer + '.' + decimals)

; ---------------------------------------------------------------------------
; STORE5 -- stores A,E,D,C,B into (HL),(HL+1)..(HL+4)
; LOAD5  -- loads A,E,D,C,B from (HL),(HL+1)..(HL+4)
; (Z80 has no LD E,(nn)/LD D,(nn)/etc, only LD A,(nn) and register-pair
; loads, so this always goes through HL indirection.)
; ---------------------------------------------------------------------------
STORE5:
    ld   (hl), a
    inc  hl
    ld   (hl), e
    inc  hl
    ld   (hl), d
    inc  hl
    ld   (hl), c
    inc  hl
    ld   (hl), b
    ret

LOAD5:
    ld   a, (hl)
    inc  hl
    ld   e, (hl)
    inc  hl
    ld   d, (hl)
    inc  hl
    ld   c, (hl)
    inc  hl
    ld   b, (hl)
    ret

; ---------------------------------------------------------------------------
; EMIT_CHAR -- writes A into the output buffer and advances the cursor
; ---------------------------------------------------------------------------
EMIT_CHAR:
    push hl
    ld   hl, (FP_STR_WR)
    ld   (hl), a
    inc  hl
    ld   (FP_STR_WR), hl
    pop  hl
    ret

; ---------------------------------------------------------------------------
; EMIT_U32 -- writes DEHL (a 32-bit unsigned integer) as decimal digits into
; the output buffer (no leading zeros; "0" if the value is zero). Same
; algorithm as __PRINTU32 (printi32.asm/printnum.asm), but writing to the
; buffer instead of the screen.
; ---------------------------------------------------------------------------
EMIT_U32:
    PROC
    LOCAL EMIT_U32_LOOP
    LOCAL EMIT_U32_START
    LOCAL EMIT_U32_CONT

    ld   b, 0

EMIT_U32_LOOP:
    ld   a, h
    or   l
    or   d
    or   e
    jp   z, EMIT_U32_START

    push bc
    ld   bc, 0
    push bc
    ld   bc, 10
    push bc
    call __DIVU32
    pop  bc

    exx
    ld   a, l
    or   '0'
    push af
    exx
    inc  b
    jp   EMIT_U32_LOOP

EMIT_U32_START:
    ld   a, b
    or   a
    jp   nz, EMIT_U32_CONT
    ld   a, '0'
    call EMIT_CHAR
    ret

EMIT_U32_CONT:
    pop  af
    push bc
    call EMIT_CHAR
    pop  bc
    djnz EMIT_U32_CONT
    ret

    ENDP

; ---------------------------------------------------------------------------
; FP_TO_STR -- converts a FLOAT to decimal ASCII text
; Input:  A,E,D,C,B = FLOAT value (the runtime's usual convention)
; Output: HL = pointer to the text (no length prefix), BC = length
; ---------------------------------------------------------------------------
FP_TO_STR:
    PROC
    LOCAL FP_TO_STR_POS
    LOCAL FP_TO_STR_POS2
    LOCAL FP_TO_STR_FRACLOOP
    LOCAL FP_TO_STR_FRACDONE
    LOCAL FP_TO_STR_TRIMLOOP
    LOCAL FP_TO_STR_TRIMDOT
    LOCAL FP_TO_STR_TRIMKEEP
    LOCAL FP_TO_STR_DONE

    ld   hl, FP_STR_ORIG
    call STORE5

    ld   hl, FP_STR_BUF
    ld   (FP_STR_WR), hl
    push af                  ; byte0 is still needed below -- don't clobber A
    xor  a
    ld   (FP_STR_NEG), a
    pop  af

    ; Is it zero? (canonical form: A=0 and the whole mantissa 0)
    or   e
    or   d
    or   c
    or   b
    jr   nz, FP_TO_STR_POS
    ld   a, '0'
    call EMIT_CHAR
    jp   FP_TO_STR_DONE

FP_TO_STR_POS:
    ; Bit 7 of E is the sign in both the small-integer and full-float
    ; formats (see fp_calc.asm / __FTOU32REG).
    ld   a, (FP_STR_ORIG + 1)
    bit  7, a
    jr   z, FP_TO_STR_POS2

    ld   a, '-'
    call EMIT_CHAR
    ld   a, 1
    ld   (FP_STR_NEG), a

    ; Make the original value positive (negate) to work in abs from here on
    ld   hl, FP_STR_ORIG
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $1B                ;;negate
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_ORIG
    call STORE5

FP_TO_STR_POS2:
    ; Round to 5 decimals (half away from zero): x = x + 0.000005, then
    ; truncate as before. Carries into the integer part fall out for
    ; free (e.g. 0.999996 -> 1.000001 -> INT gives 1).
    ld   hl, FP_STR_ORIG
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $34                ;;stk-data: push 0.000005
    defb $DF                ;;Exponent: $6F, Bytes: 4
    defb $27, $C5, $AC, $47
    defb $0F                ;;addition
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_ORIG
    call STORE5

    ; intx = INT(x)  (x is already >= 0 at this point)
    ld   hl, FP_STR_ORIG
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $31                ;;duplicate
    defb $27                ;;int
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_INT
    call STORE5

    ; frac = x - intx
    ld   hl, FP_STR_INT
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $03                ;;subtract
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_FRAC
    call STORE5

    ; print the integer part (already >= 0, fits in 32 bits unsigned)
    ld   hl, FP_STR_INT
    call LOAD5
    call __FTOU32REG        ; DEHL = integer part
    call EMIT_U32

    ld   a, '.'
    call EMIT_CHAR
    ld   a, 5
    ld   (FP_STR_COUNT), a

FP_TO_STR_FRACLOOP:
    ld   hl, FP_STR_FRAC
    call LOAD5
    call __FPSTACK_PUSH      ; stack: [frac]

    xor  a
    ld   d, 10
    ld   e, a
    ld   c, a
    ld   b, a
    call __FPSTACK_PUSH      ; stack: [frac, 10]
    rst  30h
    defb $04                ;;multiply
    defb $38                ;;end-calc
                             ; stack: [frac*10]
    rst  30h
    defb $31                ;;duplicate
    defb $27                ;;int
    defb $38                ;;end-calc
                             ; stack: [frac*10, digit]
    call __FPSTACK_POP
    call __FTOU8             ; A = digit (0-9)
    push af                  ; stash the digit (same trick as val.asm's rst 30h)

    pop  af
    push af
    ld   d, a
    xor  a
    ld   e, a
    ld   c, a
    ld   b, a
    call __FPSTACK_PUSH      ; stack: [frac*10, digit]
    rst  30h
    defb $03                ;;subtract
    defb $38                ;;end-calc
                             ; stack: [frac*10 - digit] = new frac
    call __FPSTACK_POP
    ld   hl, FP_STR_FRAC
    call STORE5

    pop  af                  ; recover the digit
    or   '0'
    call EMIT_CHAR

    ld   hl, FP_STR_COUNT
    dec  (hl)
    jr   nz, FP_TO_STR_FRACLOOP

FP_TO_STR_FRACDONE:
    ; trim trailing zeros (and the decimal point too, if every decimal
    ; came out zero)
    ld   hl, (FP_STR_WR)

FP_TO_STR_TRIMLOOP:
    dec  hl
    ld   a, (hl)
    cp   '.'
    jr   z, FP_TO_STR_TRIMDOT
    cp   '0'
    jr   nz, FP_TO_STR_TRIMKEEP
    jr   FP_TO_STR_TRIMLOOP

FP_TO_STR_TRIMDOT:
    ld   (FP_STR_WR), hl
    jp   FP_TO_STR_DONE

FP_TO_STR_TRIMKEEP:
    inc  hl
    ld   (FP_STR_WR), hl

FP_TO_STR_DONE:
    ld   hl, (FP_STR_WR)
    ld   de, FP_STR_BUF
    or   a
    sbc  hl, de              ; HL = text length
    ld   b, h
    ld   c, l
    ld   hl, FP_STR_BUF

    ; Rounding can sink a small negative value to zero (e.g. -0.000004);
    ; drop the sign so it doesn't print as "-0". Text is "-0" (length 2)
    ; only in that case -- any other negative result is longer or has a
    ; nonzero digit after the sign.
    ld   a, (FP_STR_NEG)
    or   a
    ret  z
    ld   a, b
    or   a
    ret  nz
    ld   a, c
    cp   2
    ret  nz
    ld   a, (FP_STR_BUF + 1)
    cp   '0'
    ret  nz
    inc  hl
    dec  bc
    ret

    ENDP

    pop namespace
