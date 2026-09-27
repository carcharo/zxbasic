; Phase-1 stub for zx48k/runtime/plot.asm (was: PLOT x,y wrote a pixel
; mask directly into Spectrum VRAM, via the ROM's PIXEL_ADDR &22AC and
; the ROM sysvars COORDS/P_FLAG). None of that exists on the CPC. __PLOT
; is exported too: circle.asm (inherited unchanged, pure Bresenham circle
; math) calls it directly with the __FASTCALL__ (B,C)=(y,x) convention.
; TODO(cpc): Phase 4a/4c -> firmware's GRA_PLOT_ABSOLUTE (&BBEA) or direct
; mode-1 pixel addressing (design TBD).

#include once <stub.asm>

    push namespace core

PLOT:
    jp __CPC_NOT_IMPLEMENTED

__PLOT:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
