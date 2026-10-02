; Exchanges current DE HL with the
; ones in the stack

; cpc override of zx48k/runtime/swap32.asm. The original moves SP up
; over the stacked value (INC SP x2) and back (DEC SP x2) while it swaps
; the high words, so for those few instructions the stacked low word
; sits BELOW SP, where an interrupt's pushes overwrite it. Harmless-ish
; on the Spectrum (one interrupt per frame), but compiled cpc code runs
; with interrupts on at 300 Hz and that window corrupted about one
; 32-bit division in 200 (a / 120 with a ULONG, MOD, anything the
; compiler swaps operands for). This version only ever PUSHes and POPs, so
; everything live is at or above SP at every instruction. The alternate
; bank is used as scratch (the 32-bit operations this precedes clobber it
; anyway); AF is preserved, as in the original.
; Registers clobbered: BC', DE', HL'.

    push namespace core

__SWAP32:
    exx
    pop hl              ; HL' = return address
    pop bc              ; BC' = stacked low word
    exx
    ex de, hl           ; HL = old DE, DE = old HL
    ex (sp), hl         ; HL = stacked high word; stacked high word = old DE
    push de             ; stacked low word = old HL
    ex de, hl           ; DE = stacked high word
    exx
    push bc
    exx
    pop hl              ; HL = stacked low word
    exx
    push hl             ; return address
    exx
    ret

    pop namespace
