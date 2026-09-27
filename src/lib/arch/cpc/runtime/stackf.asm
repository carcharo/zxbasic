; Phase-1 stub for zx48k/runtime/stackf.asm (was: Spectrum ROM FP
; calculator stack, via fixed entry points __FPSTACK_PUSH &2AB6 /
; __FPSTACK_POP &2BF1). Those addresses don't exist on the CPC. Every
; `rst 30h` FP runtime file and draw3.asm/io/sound/beep.asm call into
; these, so they must all be defined even though real float support
; doesn't exist yet (fp_calc.asm's own RST 6 target already traps first
; anyway -- see its header).
; TODO(cpc): replace together with fp_calc.asm by porting zx81sd's own
; relocatable stackf.asm, which needs no fixed ROM addresses.

#include once <stub.asm>

    push namespace core

__FPSTACK_PUSH:
    jp __CPC_NOT_IMPLEMENTED

__FPSTACK_POP:
    jp __CPC_NOT_IMPLEMENTED

__FPSTACK_PUSH2:
    jp __CPC_NOT_IMPLEMENTED

__FPSTACK_I16:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
