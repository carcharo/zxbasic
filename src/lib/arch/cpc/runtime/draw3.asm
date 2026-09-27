; Phase-1 stub for zx48k/runtime/draw3.asm (was: DRAW x,y,r arc drawing,
; inline ROM FP calculator bytecode for the sin/cos rotation steps plus
; direct calls to ROM helpers, reading COORDS directly). None of that
; exists on the CPC.
; TODO(cpc): Phase 4a/4c -> together with draw.asm, once a CPC-native
; float/arc pipeline exists.

#include once <stub.asm>

    push namespace core

DRAW3:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
