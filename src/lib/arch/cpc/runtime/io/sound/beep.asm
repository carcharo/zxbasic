; -----------------------------------------------------------------------
; Amstrad CPC -- BEEP duration, pitch with run-time values
;
; zx48k's BEEP hands both floats to the Spectrum ROM's BEEP (&03F8).
; Here they are turned into the firmware sound manager's units with the
; float calculator (RST 6, fp_calc.asm), using the same formulas as the
; compiler's constant case (src/arch/cpc/beep.py):
;
;   period   = 62500 / (261.6256 * 2^(pitch / 12))
;            = 238.891 * e^(-pitch * ln 2 / 12)
;   duration = seconds * 100
;
; both rounded to the nearest integer, then played by beeper.asm's
; __CPC_TONE. A negative duration plays nothing; periods outside the
; AY's range (pitch below about -48 or above 69) are clamped.
;
; Calling convention (unchanged from zx48k): pitch pushed (5 bytes),
; duration in A, E, D, C, B.

#include once <fp_calc.asm>
#include once <stackf.asm>
#include once <ftou32reg.asm>
#include once <io/sound/beeper.asm>

    push namespace core

BEEP:
    PROC
    LOCAL __B_ROUND, __B_DUR_OK, __B_DUR_SET

    call __FPSTACK_PUSH         ; duration
    pop  hl                     ; return address
    pop  af
    pop  de
    pop  bc                     ; pitch
    push hl
    call __FPSTACK_PUSH         ; duration, pitch

    ld   a, 07Ch
    ld   de, 098ECh
    ld   bc, 0F51Fh             ; -ln 2 / 12
    call __FPSTACK_PUSH
    rst  30h
    defb $04                    ; multiply      d, -p*ln2/12
    defb $26                    ; exp           d, 2^(-p/12)
    defb $38                    ; end-calc

    ld   a, 088h
    ld   de, 0E46Eh
    ld   bc, 0591Ah             ; 62500 / 261.6256
    call __FPSTACK_PUSH
    rst  30h
    defb $04                    ; multiply      d, period
    defb $01                    ; exchange      period, d
    defb $38                    ; end-calc

    ld   a, 087h
    ld   de, 00048h
    ld   bc, 00000h             ; 100
    call __FPSTACK_PUSH
    rst  30h
    defb $04                    ; multiply      period, d*100
    defb $38                    ; end-calc
    call __B_ROUND              ; DE = duration in 1/100 s
    push de
    call __B_ROUND              ; DE = period
    ex   de, hl
    pop  de
    jp   __CPC_TONE

; __B_ROUND -- pops the top of the calculator stack, adds 0.5 and
; truncates it into DE: 0 if negative, 65535 if too big.
__B_ROUND:
    ld   a, 080h
    ld   de, 00000h
    ld   bc, 00000h             ; 0.5
    call __FPSTACK_PUSH
    rst  30h
    defb $0F                    ; addition
    defb $38                    ; end-calc
    call __FPSTACK_POP
    call __FTOU32REG            ; DEHL = the integer, signed
    bit  7, d
    jr   z, __B_DUR_OK
    ld   hl, 0                  ; negative: 0
    jr   __B_DUR_SET
__B_DUR_OK:
    ld   a, d
    or   e
    jr   z, __B_DUR_SET
    ld   hl, 65535              ; over 16 bits: clamp
__B_DUR_SET:
    ex   de, hl
    ret
    ENDP

    pop namespace
