; -----------------------------------------------------------------------
; Amstrad CPC -- PLOT x, y
;
; zx48k's plot.asm wrote a pixel mask into Spectrum VRAM via the ROM's
; PIXEL_ADDR (&22AC). Here the firmware plots it: GRA_PLOT_ABSOLUTE
; does the screen addressing for every mode, clips, and moves the
; graphics cursor that DRAW continues from. Coordinates, colour and
; OVER/INVERSE are as described in gfx.asm.
;
; Calling convention: the cpc parser makes both coordinates 16-bit
; (src/arch/cpc/__init__.py GRAPHICS_COORD_TYPE), so X is pushed and Y
; arrives in HL (zx48k: X byte pushed, Y byte in A).

#include once <gfx.asm>

    push namespace core

PLOT:
    pop  bc                 ; return address
    pop  de                 ; DE = x
    push bc

; __PLOT -- DE = x, HL = y (mode pixels).
; Firmware entry called: GRA_PLOT_ABSOLUTE (&BBEA, DE = x, HL = y
; virtual), plus __GRA_PREP's.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).
#ifdef CPC_BAREMETAL
; Bare-metal mode: gfxbare.asm's __PLOT (DE = x, HL = y, mode pixels; moves
; the graphics cursor, writes the pixel straight into screen memory).
    jp   __PLOT
#else
__PLOT:
    call __GRA_PREP
    call __GRA_XY
    call .core.__FW_CALL
    defw $BBEA              ; GRA_PLOT_ABSOLUTE
    ret
#endif

    pop namespace
