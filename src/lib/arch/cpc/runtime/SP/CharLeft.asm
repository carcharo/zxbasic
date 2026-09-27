; Phase-1 stub for zx48k/runtime/SP/CharLeft.asm: moved HL one character
; left on the Spectrum's interleaved bitmap screen (`sub $08`/`cp $40`,
; hardcoded &4000 screen-boundary math) with no firmware call at all --
; pure Spectrum hardware layout, meaningless on the cpc's linear mode 1
; bitmap. Only reached via zx48k stdlib .bas files that assume this
; addressing scheme (scroll.bas, SP/Fill.bas) if a program imports them.
; TODO(cpc): Phase 4a/4c -> cpc-native screen address stepping (no direct
; firmware equivalent; bespoke code, like the rest of SP/*.asm).

#include once <stub.asm>

    push namespace core

SP.CharLeft:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
