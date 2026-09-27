#include once <stackf.asm>
#include once <error.asm>
#include once <sysvars.asm>

; -------------------------------------------------------------
; Floating point library using the FP calculator (ported ROM engine)

; All of them uses C EDHL registers as 1st paramter.
; For binary operators, the 2n operator must be pushed into the
; stack, in the order BC DE HL (B not used).
;
; Uses CALLEE convention
; -------------------------------------------------------------
;
; cpc override: ported from src/lib/arch/zx81sd/runtime/arith/divf.asm.
; The only change from zx48k's version is where TMP/ERR_SP live. The
; original uses the Spectrum ROM's DEST (23629) and ERR_SP (23613) system
; variables to save/restore a stack recovery point around the division (a
; "longjmp" trick for divide-by-zero) -- on the cpc those addresses would
; fall inside the program's own compiled code, so DIVF_SCRATCH
; (sysvars.asm) is dedicated scratch space instead (same mechanism, just
; relocated). In practice this trap is never actually taken: the
; calculator's own division literal (fp_calc.asm, L31AF) raises
; ERROR_NumberTooBig directly via `jp __ERROR` on a zero divisor, and
; __ERROR here never returns (it prints "Error n" and resets), so
; __DIVBYZERO below is unreachable dead code, kept only for parity with
; zx48k/zx81sd's own copy.

    push namespace core

__DIVF:	; Division
    PROC
    LOCAL __DIVBYZERO
    LOCAL TMP, ERR_SP

TMP         EQU DIVF_SCRATCH       ; cpc: dedicated scratch, not DEST
ERR_SP      EQU DIVF_SCRATCH + 2   ; cpc: dedicated scratch, not ERR_SP

    call __FPSTACK_PUSH2

    ld hl, (ERR_SP)
    ld (TMP), hl
    ld hl, __DIVBYZERO
    push hl
    ld (ERR_SP), sp

    ; ------------- DIV via the FP calculator
    rst 30h
    defb 01h	; EXCHANGE
    defb 05h	; DIV
    defb 38h;   ; END CALC

    pop hl
    ld hl, (TMP)
    ld (ERR_SP), hl

    jp __FPSTACK_POP

__DIVBYZERO:
    ld hl, (TMP)
    ld (ERR_SP), hl

    ld a, ERROR_NumberTooBig
    ld (ERR_NR), a

    ; Returns 0 on DIV BY ZERO error
    xor a
    ld b, a
    ld c, a
    ld d, a
    ld e, a
    ret

    ENDP

    pop namespace
