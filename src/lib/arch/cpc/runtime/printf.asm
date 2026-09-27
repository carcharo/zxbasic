; Phase-1 stub for zx48k/runtime/printf.asm (was: PRINT of a fixed point
; number, entering the Spectrum ROM FP calculator to render it). Needs a
; real float engine first.
; TODO(cpc): replace together with fp_calc.asm and str.asm/printstr.asm.

#include once <stub.asm>

    push namespace core

__PRINTF:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
