; Phase-1 stub for zx48k/runtime/SP/CharRight.asm: moved HL one character
; right on the Spectrum's interleaved bitmap screen (hardcoded `cp $58`
; &5800 attribute-area boundary), with no firmware call -- pure Spectrum
; hardware layout, meaningless on the cpc's linear mode 1 bitmap. Only
; reached via zx48k stdlib .bas files that assume this addressing scheme
; (scroll.bas, SP/Fill.bas) if a program imports them.
; TODO(cpc): Phase 4a/4c -> cpc-native screen address stepping.

#include once <stub.asm>

    push namespace core

SP.CharRight:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
