; -----------------------------------------------------------------------
; Amstrad CPC -- DRAW dx, dy (straight line from the last point)
;
; zx48k's draw.asm ran its own Bresenham over Spectrum VRAM. Here the
; firmware's GRA_LINE_RELATIVE draws from its graphics cursor (where the
; last PLOT/DRAW/CIRCLE point left it), clipped, in every mode.
; Coordinates, colour and OVER/INVERSE are as described in gfx.asm.
;
; The firmware also plots the line's first point, which the Spectrum's
; DRAW doesn't (that point is already lit by the previous PLOT/DRAW).
; It makes no difference normally, but under OVER 1 that point would be
; XORed twice and disappear, so in XOR mode DRAW plots it once more to
; put it back. (The 664/6128's GRA_SET_FIRST could switch the first
; point off, but the 464 doesn't have it.)
;
; Calling convention (unchanged from zx48k): dx pushed, dy in HL, both
; 16-bit signed.

#include once <gfx.asm>

    push namespace core

DRAW:
    pop  bc                 ; return address
    pop  de                 ; DE = dx
    push bc

; __DRAW -- DE = dx, HL = dy (mode pixels, signed).
; Firmware entries called: GRA_LINE_RELATIVE (&BBF9, DE/HL = virtual
; offsets); under OVER 1 also GRA_ASK_CURSOR (&BBC6), GRA_PLOT_ABSOLUTE
; (&BBEA) and GRA_MOVE_ABSOLUTE (&BBC0); plus __GRA_PREP's.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).
__DRAW:
    PROC
    LOCAL __DRAW_XOR

    call __GRA_PREP
    call __GRA_XY
    ld   a, (GRA_MODE_CUR)
    or   a
    jr   nz, __DRAW_XOR
    call .core.__FW_CALL
    defw $BBF9              ; GRA_LINE_RELATIVE
    ret

__DRAW_XOR:
    push de                 ; dx
    push hl                 ; dy
    call .core.__FW_CALL
    defw $BBC6              ; GRA_ASK_CURSOR: DE = x0, HL = y0
    pop  bc                 ; BC = dy
    ex   (sp), hl           ; HL = dx; stack: y0
    push de                 ; stack: y0, x0
    ex   de, hl             ; DE = dx
    ld   h, b
    ld   l, c               ; HL = dy
    call .core.__FW_CALL
    defw $BBF9              ; GRA_LINE_RELATIVE (XORs the start point too)
    call .core.__FW_CALL
    defw $BBC6              ; GRA_ASK_CURSOR: DE = x1, HL = y1
    pop  bc                 ; BC = x0
    ex   (sp), hl           ; HL = y0; stack: y1
    push de                 ; stack: y1, x1
    ld   d, b
    ld   e, c               ; DE = x0
    call .core.__FW_CALL
    defw $BBEA              ; GRA_PLOT_ABSOLUTE: XOR the start point back
    pop  de                 ; DE = x1
    pop  hl                 ; HL = y1
    call .core.__FW_CALL
    defw $BBC0              ; GRA_MOVE_ABSOLUTE: continue from the end
    ret
    ENDP

    pop namespace
