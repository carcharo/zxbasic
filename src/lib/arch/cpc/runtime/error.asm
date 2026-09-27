; Simple error control routines
;
; Phase-1 stub for zx48k/runtime/error.asm (was: raising errors with
; `rst 8`, the Spectrum ROM's error-trap vector; on the CPC that's RST 1
; LOW JUMP, firmware jumpblock dispatch, not an error trap). __STOP
; stores the error code in ERR_NR (sysvars.asm's relocated slot) and
; returns, same as zx48k; __ERROR does the same but then traps via
; .core.__CPC_NOT_IMPLEMENTED instead of `rst 8`. ERROR_* constants keep
; their zx48k values (just numbers, not addresses).
; TODO(cpc): Phase 2/3 -> a real CPC error handler.

#include once <stub.asm>
#include once <sysvars.asm>

    push namespace core

; Error code definitions (as in ZX spectrum manual)

; Set error code with:
;    ld a, ERROR_CODE
;    ld (ERR_NR), a

ERROR_Ok                EQU    -1
ERROR_SubscriptWrong    EQU     2
ERROR_OutOfMemory       EQU     3
ERROR_OutOfScreen       EQU     4
ERROR_NumberTooBig      EQU     5
ERROR_InvalidArg        EQU     9
ERROR_IntOutOfRange     EQU    10
ERROR_NonsenseInBasic   EQU    11
ERROR_InvalidFileName   EQU    14
ERROR_InvalidColour     EQU    19
ERROR_BreakIntoProgram  EQU    20
ERROR_TapeLoadingErr    EQU    26


; Raises error: stores the code, then traps (Phase 1 -- see header)
__ERROR:
    ld (ERR_NR), a
    jp __CPC_NOT_IMPLEMENTED

; Sets the error system variable, but keeps running.
; Usually this instruction if followed by the END intermediate instruction.
__STOP:
    ld (ERR_NR), a
    ret

    pop namespace
