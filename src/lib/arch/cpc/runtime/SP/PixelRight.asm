; Phase-1 stub for zx48k/runtime/SP/PixelRight.asm: moved a screen address
; and pixel bit mask one pixel right within the Spectrum's interleaved
; bitmap layout. Meaningless on the cpc's linear mode 1 bitmap. Used
; internally by draw.asm (also a stub).
; TODO(cpc): Phase 4a/4c -> cpc-native pixel address stepping.

#include once <stub.asm>
#include once <sysvars.asm>

    push namespace core

SP.PixelRight:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
