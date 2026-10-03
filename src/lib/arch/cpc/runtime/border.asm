; -----------------------------------------------------------------------
; Amstrad CPC -- BORDER colour
;
; zx48k's BORDER calls the Spectrum ROM (&229B). Here BORDER c shows the
; same colour as PAPER c: the Spectrum colour goes through colour.asm's
; pen map, and the border is set to that pen's current colour. (Any of
; the 27 hardware colours: cpc.bas's SetBorder.)
;
; Parameter: Spectrum colour 0-7 in A.
; Firmware entries called (via the gate): SCR_GET_INK (&BC35, A = pen ->
; B, C = its two colours), SCR_SET_BORDER (&BC38, B, C).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).

#include once <colour.asm>
#include once <fwcall.asm>
#ifdef CPC_BAREMETAL
#include once <gacolour.asm>
#include once <sysvars.asm>
#endif

    push namespace core

#ifdef CPC_BAREMETAL
; Bare-metal mode: the pen's colour comes from PAL_SHADOW (gacolour.asm
; keeps every colour it writes) and goes to the Gate Array's border.
; Firmware entries called: none. Registers clobbered: AF, BC, HL.
BORDER:
    call __INK_TO_PEN
    ld   hl, PAL_SHADOW
    add  a, l
    ld   l, a
    ld   a, (hl)            ; the pen's firmware colour 0-26
    jp   __CPC_SET_BORDER
#else
BORDER:
    call __INK_TO_PEN
    call .core.__FW_CALL
    defw $BC35              ; SCR_GET_INK
    call .core.__FW_CALL
    defw $BC38              ; SCR_SET_BORDER
    ret
#endif

    pop namespace
