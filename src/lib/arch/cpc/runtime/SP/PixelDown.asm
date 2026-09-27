; Phase-1 stub for zx48k/runtime/SP/PixelDown.asm: moved a screen address
; one pixel down using the Spectrum's non-linear interleaved-row bitmap
; math (`ld de,(SCREEN_ADDR)`, `and $07`/`add $20` row-wrap tricks, AF'
; used to flag "attribute cell changed"). Meaningless on the cpc's linear
; mode 1 bitmap. Used internally by draw.asm (also a stub).
; TODO(cpc): Phase 4a/4c -> cpc-native pixel address stepping.

#include once <stub.asm>
#include once <sysvars.asm>

    push namespace core

SP.PixelDown:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
