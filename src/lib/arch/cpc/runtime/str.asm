; Phase-1 stub for zx48k/runtime/str.asm (was: the STR$() function,
; entering the Spectrum ROM FP calculator to render a float as a
; string). Needs a real float engine first.
; TODO(cpc): replace together with fp_calc.asm by porting zx81sd's own
; fp_tostr.asm-based str.asm (no exponent notation).

#include once <stub.asm>

    push namespace core

__STR:
    jp __CPC_NOT_IMPLEMENTED

__STR_FAST:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
