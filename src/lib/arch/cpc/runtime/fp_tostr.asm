; fp_tostr.asm -- converts a FLOAT to decimal ASCII text, Spectrum style
;
; Used by printf.asm (PRINT of a FLOAT) and str.asm (STR$). Produces the same
; text as the Spectrum ROM's PRINT-FP (which also backs STR$ there):
;   - up to 8 significant digits, rounded, trailing zeros dropped;
;   - fixed notation while the decimal exponent n (value = 0.DDDD * 10^n)
;     satisfies -4 <= n <= 8:  "12345678", "0.5", ".03", ".00001"
;     (the leading "0" only when n = 0, as the ROM does);
;   - otherwise exponent notation "d[.ddd]E+x" / "E-x": 1E+8, 1.5E-10,
;     1.2345679E+9 (sign always shown, exponent not padded).
; The same algorithm as the ROM routine, so the digits (last one included)
; agree with it: the integer part is converted exactly when it is < 2^28
; (larger values are first scaled by a power of ten with the calculator),
; the fraction is taken as a 32-bit binary fraction and turned into digits
; by repeated multiplication by 10, and a carry decides the rounding of
; the 8th digit. Scaling uses the calculator (fp_calc.asm) for the same
; float operations the ROM performs (powers of ten built by squaring), so
; the rounding noise in scaled values is the same too.
;
; Entry: FP_TO_STR, A,E,D,C,B = FLOAT; returns HL = text, BC = length.
; Not re-entrant (static work area below).

#include once <fp_calc.asm>
#include once <stackf.asm>
#include once <ftou32reg.asm>
#include once <arith/div32.asm>

    push namespace core

; --- Working variables (not re-entrant, transient use only) ----------------
FP_STR_X:       defb 0, 0, 0, 0, 0  ; value being converted (abs, maybe scaled)
FP_STR_INT:     defb 0, 0, 0, 0, 0  ; INT(x)
FP_STR_FRAC:    defb 0, 0, 0, 0, 0  ; x - INT(x)
FP_STR_PV:      defb 0, 0, 0, 0, 0  ; power of ten used by FP_STR_E2FP
FP_STR_FM:      defb 0, 0, 0, 0     ; 32-bit fraction, little endian
FP_STR_NDIG:    defb 0              ; digits in FP_STR_DIG
FP_STR_DEXP:    defb 0              ; decimal exponent n (signed)
FP_STR_SC:      defb 0              ; scratch (E2FP exponent bits, FRAC exponent)
FP_STR_DIV:     defb 0              ; E2FP: nonzero = divide
FP_STR_DIG:     defs 10             ; digits 0..9 (values, not ASCII)
FP_STR_WR:      defw 0              ; write cursor into FP_STR_BUF
FP_STR_BUF:     defs 24             ; output text

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
; FP_STR_MUL10 -- A = A*10 + C; returns A = low byte, C = high byte.
; Preserves B, DE, HL.
; ---------------------------------------------------------------------------
FP_STR_MUL10:
    push hl
    push de
    ld   l, a
    ld   h, 0
    ld   e, l
    ld   d, h
    add  hl, hl
    add  hl, hl
    add  hl, de
    add  hl, hl
    ld   e, c
    add  hl, de             ; D is 0 here
    ld   c, h
    ld   a, l
    pop  de
    pop  hl
    ret

; ---------------------------------------------------------------------------
; FP_STR_LG2 -- A = signed byte n; returns A = |INT(n * 0.30103)| (the ROM's
; LOG(2^A) helper: the floor for n >= 0, the magnitude of the floor for
; n < 0).
; ---------------------------------------------------------------------------
FP_STR_LG2:
    ld   d, a
    rla
    sbc  a, a
    ld   e, a
    ld   c, a
    xor  a
    ld   b, a
    call __FPSTACK_PUSH
    rst  30h
    defb $34                ;;stk-data: 0.30103
    defb $EF                ;;Exponent: $7F, Bytes: 4
    defb $1A, $20, $9A, $85
    defb $04                ;;multiply
    defb $27                ;;int
    defb $38                ;;end-calc
    call __FPSTACK_POP      ; small integer: E = sign, D = low byte
    ld   a, d
    bit  7, e
    ret  z
    neg
    ret

; ---------------------------------------------------------------------------
; FP_STR_E2FP -- multiplies the calculator stack top by 10^A (A a signed
; byte, negative = divide) with binary powers of ten, as the ROM's E-TO-FP.
; ---------------------------------------------------------------------------
FP_STR_E2FP:
    PROC
    LOCAL E2_POS
    LOCAL E2_LOOP
    LOCAL E2_DIVIDE
    LOCAL E2_NOBIT

    ld   c, 0
    or   a
    jp   p, E2_POS
    neg
    inc  c
E2_POS:
    ld   (FP_STR_SC), a
    ld   a, c
    ld   (FP_STR_DIV), a
    ld   hl, FP_STR_PV      ; PV = 10 (small integer)
    xor  a
    ld   (hl), a
    inc  hl
    ld   (hl), a
    inc  hl
    ld   (hl), 10
    inc  hl
    ld   (hl), a
    inc  hl
    ld   (hl), a
E2_LOOP:
    ld   a, (FP_STR_SC)
    srl  a
    ld   (FP_STR_SC), a
    jr   nc, E2_NOBIT
    ld   hl, FP_STR_PV
    call LOAD5
    call __FPSTACK_PUSH     ; [x, p]
    ld   a, (FP_STR_DIV)
    or   a
    jr   nz, E2_DIVIDE
    rst  30h
    defb $04                ;;multiply
    defb $38                ;;end-calc
    jr   E2_NOBIT
E2_DIVIDE:
    rst  30h
    defb $05                ;;division
    defb $38                ;;end-calc
E2_NOBIT:
    ld   a, (FP_STR_SC)
    or   a
    ret  z
    ld   hl, FP_STR_PV      ; p = p * p
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $31                ;;duplicate
    defb $04                ;;multiply
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_PV
    call STORE5
    jr   E2_LOOP
    ENDP

; ---------------------------------------------------------------------------
; FP_STR_DIGITS -- emits B digits of FP_STR_DIG (from HL; C left; digits
; past the end print as '0'), then, if digits remain, '.' + zeros + the
; rest. B <= 0 (decimal point before the first digit): -B zeros after it.
; (The ROM's PRINT-FP output stage.) Preserves D.
; ---------------------------------------------------------------------------
FP_STR_DIGITS:
    PROC
    LOCAL FD_LOOP
    LOCAL FD_PAD
    LOCAL FD_AFTER
    LOCAL FD_DOT

    xor  a
    sub  b
    jp   m, FD_LOOP         ; B > 0
    ld   b, a
    jr   FD_AFTER
FD_LOOP:
    ld   a, c
    or   a
    jr   z, FD_PAD
    ld   a, (hl)
    inc  hl
    dec  c
FD_PAD:
    add  a, '0'
    call EMIT_CHAR
    djnz FD_LOOP
FD_AFTER:
    ld   a, c
    or   a
    ret  z
    inc  b
    ld   a, '.'
FD_DOT:
    call EMIT_CHAR
    ld   a, '0'
    djnz FD_DOT
    ld   b, c
    jr   FD_LOOP
    ENDP

; ---------------------------------------------------------------------------
; FP_TO_STR -- converts a FLOAT to decimal ASCII text
; Input:  A,E,D,C,B = FLOAT value (the runtime's usual convention)
; Output: HL = pointer to the text (no length prefix), BC = length
; ---------------------------------------------------------------------------
FP_TO_STR:
    PROC
    LOCAL POS
    LOCAL POS_DONE
    LOCAL ROUNDBIT
    LOCAL AGAIN
    LOCAL BIG
    LOCAL INTDIG
    LOCAL IDLOOP
    LOCAL IDSTORE
    LOCAL IDPOP
    LOCAL SMALLX
    LOCAL SMALLNZ
    LOCAL FRACPATH
    LOCAL SHLOOP
    LOCAL SHINC
    LOCAL SHZERO
    LOCAL SHDONE
    LOCAL DIGLOOP
    LOCAL MLOOP
    LOCAL ROUND
    LOCAL RLOOP
    LOCAL RZ
    LOCAL RE
    LOCAL FORMAT
    LOCAL FIXED
    LOCAL EFMT
    LOCAL EPLUS
    LOCAL ESIGN
    LOCAL ETENS
    LOCAL ETD
    LOCAL DONE

    ld   hl, FP_STR_X
    call STORE5

    ld   hl, FP_STR_BUF
    ld   (FP_STR_WR), hl

    ; Is it zero? (canonical form: A=0 and the whole mantissa 0)
    or   e
    or   d
    or   c
    or   b
    jr   nz, POS
    ld   a, '0'
    call EMIT_CHAR
    jp   DONE

POS:
    ; Bit 7 of E is the sign in both the small-integer and full-float formats.
    ld   a, (FP_STR_X + 1)
    bit  7, a
    jr   z, POS_DONE
    ld   a, '-'
    call EMIT_CHAR
    ld   hl, FP_STR_X
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $2A                ;;abs
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_X
    call STORE5
POS_DONE:
    xor  a
    ld   (FP_STR_NDIG), a
    ld   (FP_STR_DEXP), a

AGAIN:
    ; INT = INT(x), FRAC = x - INT
    ld   hl, FP_STR_X
    call LOAD5
    call __FPSTACK_PUSH
    rst  30h
    defb $31                ;;duplicate
    defb $27                ;;int
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_INT
    call STORE5
    call __FPSTACK_PUSH     ; [x, INT]
    rst  30h
    defb $03                ;;subtract
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_FRAC
    call STORE5

    ld   a, (FP_STR_INT)
    or   a
    jr   nz, BIG
    ld   hl, (FP_STR_INT + 2)   ; small integer: HL = value
    ld   a, h
    or   l
    jp   z, SMALLX
    jr   INTDIG

BIG:
    sub  $80
    cp   28
    jr   c, INTDIG          ; INT < 2^28: convert exactly
    ; Too large: x = INT / 10^(LG(n) - 7), counting the exponent; retry
    call FP_STR_LG2
    sub  7
    ld   b, a
    ld   hl, FP_STR_DEXP
    add  a, (hl)
    ld   (hl), a
    ld   a, b
    neg
    push af
    ld   hl, FP_STR_INT
    call LOAD5
    call __FPSTACK_PUSH
    pop  af
    call FP_STR_E2FP
    call __FPSTACK_POP
    ld   hl, FP_STR_X
    call STORE5
    jr   AGAIN

INTDIG:
    ; Digits of INT (1 <= INT < 2^28): at most 9, none leading zero
    ld   hl, FP_STR_INT
    call LOAD5
    call __FTOU32REG        ; DEHL
    ld   b, 0
IDLOOP:
    ld   a, h
    or   l
    or   d
    or   e
    jr   z, IDSTORE
    push bc
    ld   bc, 0
    push bc
    ld   bc, 10
    push bc
    call __DIVU32
    pop  bc
    exx
    ld   a, l               ; remainder
    push af
    exx
    inc  b
    jr   IDLOOP
IDSTORE:
    ld   a, b
    ld   (FP_STR_NDIG), a
    ld   hl, FP_STR_DEXP
    add  a, (hl)
    ld   (hl), a
    ld   hl, FP_STR_DIG
IDPOP:
    pop  af
    ld   (hl), a
    inc  hl
    djnz IDPOP
    ld   a, (FP_STR_NDIG)
    cp   9
    jp   c, FRACPATH
    ld   a, 8               ; 9 digits: keep 8, the 9th rounds
    ld   (FP_STR_NDIG), a
    ld   a, (FP_STR_DIG + 8)
    cp   5
    ccf                     ; carry = 9th digit > 4
    jp   ROUND

SMALLX:
    ; x < 1: scale x up by 10^d (d = -LG(exponent)) so it is about 0.1..1,
    ; then take the integer digit of the scaled value (0 or more)
    ld   a, (FP_STR_FRAC)   ; exponent byte
    sub  $7E
    call FP_STR_LG2
    push af
    ld   b, a
    ld   a, (FP_STR_DEXP)
    sub  b
    ld   (FP_STR_DEXP), a
    ld   hl, FP_STR_FRAC
    call LOAD5
    call __FPSTACK_PUSH
    pop  af
    call FP_STR_E2FP        ; [x']
    rst  30h
    defb $31                ;;duplicate
    defb $27                ;;int
    defb $38                ;;end-calc
    call __FPSTACK_POP      ; D = the integer digit
    ld   hl, FP_STR_DIG
    ld   (hl), d
    call __FPSTACK_PUSH
    rst  30h
    defb $03                ;;subtract
    defb $38                ;;end-calc
    call __FPSTACK_POP
    ld   hl, FP_STR_FRAC
    call STORE5
    ld   a, (FP_STR_DIG)
    or   a
    ld   a, 0
    jr   z, SMALLNZ
    ld   a, 1
SMALLNZ:
    ld   (FP_STR_NDIG), a
    ld   hl, FP_STR_DEXP
    add  a, (hl)
    ld   (hl), a

FRACPATH:
    ; FM = FRAC as a 32-bit binary fraction: the mantissa (implicit bit
    ; restored) shifted right by 128 - exponent bits, rounded up by the last
    ; bit shifted out.
    ld   hl, FP_STR_FRAC
    call LOAD5              ; A = exponent, E D C B = mantissa
    ld   (FP_STR_SC), a
    ld   a, e
    or   $80
    ld   (FP_STR_FM + 3), a
    ld   a, d
    ld   (FP_STR_FM + 2), a
    ld   a, c
    ld   (FP_STR_FM + 1), a
    ld   a, b
    ld   (FP_STR_FM), a
    ld   a, $80
    ld   hl, FP_STR_SC
    sub  (hl)
    jr   z, SHDONE
    cp   33
    jr   nc, SHZERO
    ld   b, a
SHLOOP:
    ld   hl, FP_STR_FM + 3
    srl  (hl)
    dec  hl
    rr   (hl)
    dec  hl
    rr   (hl)
    dec  hl
    rr   (hl)
    djnz SHLOOP
    jr   nc, SHDONE
    ld   hl, FP_STR_FM      ; round: FM = FM + 1
    ld   b, 4
SHINC:
    inc  (hl)
    jr   nz, SHDONE
    inc  hl
    djnz SHINC
    jr   SHDONE
SHZERO:
    ld   hl, FP_STR_FM
    xor  a
    ld   (hl), a
    inc  hl
    ld   (hl), a
    inc  hl
    ld   (hl), a
    inc  hl
    ld   (hl), a
SHDONE:

DIGLOOP:
    ld   a, (FP_STR_NDIG)
    cp   8
    jr   nc, ROUNDBIT
    ld   hl, FP_STR_FM      ; FM = FM * 10; C = the digit shifted out
    ld   c, 0
    ld   b, 4
MLOOP:
    ld   a, (hl)
    call FP_STR_MUL10
    ld   (hl), a
    inc  hl
    djnz MLOOP
    ld   a, (FP_STR_NDIG)
    ld   e, a
    ld   d, 0
    ld   hl, FP_STR_DIG
    add  hl, de
    ld   (hl), c
    inc  a
    ld   (FP_STR_NDIG), a
    jr   DIGLOOP

ROUNDBIT:
    ld   a, (FP_STR_FM + 3)
    rla                     ; carry = the next digit would be >= 5

ROUND:
    ; Add the carry to the digits (last first); trailing zeros and digits
    ; that overflowed are dropped from the count; all-9s becomes 1, n+1.
    push af
    ld   hl, FP_STR_DIG
    ld   a, (FP_STR_NDIG)
    ld   c, a
    ld   b, 0
    add  hl, bc
    ld   b, c
    pop  af
    inc  b
    dec  b
    jr   z, RE
RLOOP:
    dec  hl
    ld   a, (hl)
    adc  a, 0
    ld   (hl), a
    and  a
    jr   z, RZ
    cp   10
    ccf
    jr   nc, RE
RZ:
    djnz RLOOP
    ld   (hl), 1
    inc  b
    ld   hl, FP_STR_DEXP
    inc  (hl)
RE:
    ld   a, b
    ld   (FP_STR_NDIG), a

FORMAT:
    ld   a, (FP_STR_DEXP)
    ld   b, a
    ld   a, (FP_STR_NDIG)
    ld   c, a
    ld   hl, FP_STR_DIG
    ld   a, b
    cp   9
    jr   c, FIXED
    cp   $FC
    jr   c, EFMT
FIXED:
    and  a
    jr   nz, FIXED1
    ld   a, '0'
    call EMIT_CHAR
FIXED1:
    call FP_STR_DIGITS
    jr   DONE

EFMT:
    ld   d, b
    dec  d                  ; the exponent of d.ddd
    ld   b, 1
    call FP_STR_DIGITS
    ld   a, 'E'
    call EMIT_CHAR
    ld   a, d
    or   a
    jp   p, EPLUS
    neg
    ld   d, a
    ld   a, '-'
    jr   ESIGN
EPLUS:
    ld   a, '+'
ESIGN:
    call EMIT_CHAR
    ld   a, d
    ld   e, '0'
ETENS:
    cp   10
    jr   c, ETD
    sub  10
    inc  e
    jr   ETENS
ETD:
    ld   d, a
    ld   a, e
    cp   '0'
    jr   z, EUNITS
    call EMIT_CHAR
EUNITS:
    ld   a, d
    add  a, '0'
    call EMIT_CHAR

DONE:
    ld   hl, (FP_STR_WR)
    ld   de, FP_STR_BUF
    or   a
    sbc  hl, de              ; HL = text length
    ld   b, h
    ld   c, l
    ld   hl, FP_STR_BUF
    ret

    ENDP

    pop namespace
