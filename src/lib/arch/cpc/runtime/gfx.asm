; -----------------------------------------------------------------------
; Amstrad CPC -- shared helpers for PLOT, DRAW and CIRCLE
;
; Coordinates are the current mode's pixels, origin bottom-left (mode 1
; 320x200, mode 0 160x200, mode 2 640x200; cpcbuild/docs/notes.md,
; 2026-10-01). The firmware's graphics VDU works in 640x400 virtual
; coordinates in every mode, so __GRA_XY scales them; off-screen points
; are clipped by the firmware, silently (the Spectrum stops with "out of
; screen" instead).
;
; Colour comes from the temporary attribute, like the Spectrum: the ink
; (ATTR_T bits 0-2, through colour.asm's pen map) is the graphics pen,
; or the paper under INVERSE 1. OVER 1 selects the firmware's XOR write
; mode (notes.md question 5).

#include once <colour.asm>
#include once <fwcall.asm>
#include once <sysvars.asm>

; Bare-metal mode (-D CPC_BAREMETAL): gfxbare.asm has __GRA_PREP (the pen
; and write mode as bytes for the pixel writer) and the pixel routines; the
; firmware's graphics VDU is not used, so there is no __GRA_XY.
#ifdef CPC_BAREMETAL
#include once <gfxbare.asm>
#else

    push namespace core

; __GRA_PREP -- gives the firmware the graphics pen and write mode the
; temporary attributes ask for. Each is cached (GRA_PEN_CUR,
; GRA_MODE_CUR) so repeated PLOTs don't pay for the firmware calls;
; colour.asm resets the cache on a mode change.
; Firmware entries called (via the gate, only on a change): GRA_SET_PEN
; (&BBDE, A = pen), SCR_ACCESS (&BC59, A = 0 normal, 1 XOR). SCR_ACCESS
; corrupts DE/HL as well as AF on the 6128 (measured: the next PLOT went
; astray), so both are saved here rather than trusting the Guide's
; register lists.
; Registers clobbered: AF, BC (main); BC', DE', HL', AF' (the gate).
; DE and HL are preserved.
__GRA_PREP:
    PROC
    LOCAL __GP_INK, __GP_PEN_OK, __GP_DONE

    push de
    push hl

    ld   a, (P_FLAG)
    and  4                  ; temporary INVERSE (bit 2)
    ld   a, (ATTR_T)
    jr   z, __GP_INK
    rrca
    rrca
    rrca                    ; INVERSE 1: plot in the paper colour
__GP_INK:
    call __INK_TO_PEN
    ld   b, a
    ld   a, (GRA_PEN_CUR)
    cp   b
    jr   z, __GP_PEN_OK
    ld   a, b
    ld   (GRA_PEN_CUR), a
    call .core.__FW_CALL
    defw $BBDE              ; GRA_SET_PEN
__GP_PEN_OK:
    ld   a, (P_FLAG)
    and  1                  ; temporary OVER (bit 0)
    ld   b, a
    ld   a, (GRA_MODE_CUR)
    cp   b
    jr   z, __GP_DONE
    ld   a, b
    ld   (GRA_MODE_CUR), a
    call .core.__FW_CALL
    defw $BC59              ; SCR_ACCESS: 0 = normal, 1 = XOR
__GP_DONE:
    pop  hl
    pop  de
    ret
    ENDP

; __GRA_XY -- DE = x, HL = y in mode pixels (signed; a point or a
; relative offset) -> DE, HL in firmware virtual units: y * 2, and
; x << GFX_XSHIFT (mode 0: * 4, mode 1: * 2, mode 2: * 1).
; Firmware entry called: none.
; Registers clobbered: AF, DE, HL.
__GRA_XY:
    PROC
    LOCAL __GX_LOOP

    add  hl, hl
    ld   a, (GFX_XSHIFT)
    or   a
    ret  z
    ex   de, hl
__GX_LOOP:
    add  hl, hl
    dec  a
    jr   nz, __GX_LOOP
    ex   de, hl
    ret
    ENDP

    pop namespace
#endif
