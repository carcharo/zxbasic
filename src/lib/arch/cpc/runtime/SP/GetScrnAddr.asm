; Phase-1 stub for zx48k/runtime/SP/GetScrnAddr.asm: computed a Spectrum
; screen address from a pixel coordinate via the ROM's interleaved
; bitmap formula (rotate/mask against SCREEN_ADDR). Meaningless on the
; cpc's linear mode 1 bitmap. Only reached via zx48k stdlib .bas files
; that assume this addressing scheme (scroll.bas, SP/Fill.bas) if a
; program imports them.
; TODO(cpc): Phase 4a/4c -> cpc-native pixel address calculation (bespoke
; code; no single firmware entry matches this granularity).

#include once <stub.asm>
#include once <sysvars.asm>

    push namespace core

SPGetScrnAddr:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
