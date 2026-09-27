; Phase-1 stub for zx48k/runtime/val.asm (was: the VAL() function --
; installs a custom ROM error handler via ERR_SP, points CH_ADD at the
; string, and enters the Spectrum ROM FP calculator to parse it). The
; most ROM-entangled file in the runtime, and needs a real float engine
; besides.
; TODO(cpc): replace together with fp_calc.asm by porting zx81sd's own
; val.asm (single numeric literal only).

#include once <stub.asm>

    push namespace core

VAL:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
