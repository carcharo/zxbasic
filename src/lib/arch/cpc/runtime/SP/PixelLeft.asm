; Phase-1 stub for zx48k/runtime/SP/PixelLeft.asm: moved a screen address
; and pixel bit mask one pixel left within the Spectrum's interleaved
; bitmap layout (rotate-and-test against SCREEN_ADDR, AF' used to flag
; "attribute cell changed"). Meaningless on the cpc's linear mode 1
; bitmap. Used internally by draw.asm (also a Phase 1 stub). Replaced in
; Phase 4a/4c by cpc-native pixel address stepping.

#include once <stub.asm>
#include once <sysvars.asm>

    push namespace core

SP.PixelLeft:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
