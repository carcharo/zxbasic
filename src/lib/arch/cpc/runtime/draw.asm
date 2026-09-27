; Phase-1 stub for zx48k/runtime/draw.asm (was: Bresenham line drawing
; straight into Spectrum VRAM with self-modifying opcodes, via the ROM's
; PIXEL_ADDR &22AC). No CPC equivalent at a fixed address.
; TODO(cpc): Phase 4a/4c -> a CPC-native Bresenham implementation over
; GRA_PLOT_ABSOLUTE (&BBEA) or direct mode-1 pixel addressing, same as
; PLOT.

#include once <stub.asm>

    push namespace core

DRAW:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
