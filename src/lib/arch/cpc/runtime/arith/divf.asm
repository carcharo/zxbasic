; Phase-1 stub for zx48k/runtime/arith/divf.asm (was: floating point
; division via the Spectrum ROM FP calculator, installing a div-by-zero
; trap by pointing ERR_SP at a local handler and using the DEST sysvar as
; longjmp-style scratch on every division). Needs a real float engine
; first; its own scratch would need relocating the same way
; arith/modf16.asm's was, but there is no point doing that before the
; ROM-calculator dependency itself is replaced.
; TODO(cpc): Phase 3, together with fp_calc.asm.

#include once <stub.asm>

    push namespace core

__DIVF:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
