' ----------------------------------------------------------------
' point.bas -- Amstrad CPC version
'
' POINT(x, y): the pen of the pixel at x, y, in the same coordinates as
' PLOT (the current mode's pixels, origin bottom-left). 0 for a point
' off the screen. The Spectrum version returns 1 for ink and 0 for
' paper; with the default colours the paper is pen 0 here too, so
' "IF POINT(x, y) THEN" keeps working.
' ----------------------------------------------------------------

#ifndef __LIBRARY_POINT__
#define __LIBRARY_POINT__

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE

' Firmware: GRA_TEST_ABSOLUTE (&BBF0, DE = x, HL = y virtual -> A = pen;
' the graphics paper pen if off the window). It also moves the graphics
' cursor, which the Spectrum's POINT doesn't, so the cursor is saved
' with GRA_ASK_CURSOR (&BBC6) and put back with GRA_MOVE_ABSOLUTE
' (&BBC0): a DRAW after POINT continues from the last PLOT/DRAW.
' Bare-metal mode (-D CPC_BAREMETAL): the pixel is read from screen memory
' (gfxbare.asm's __GR_POINT) and nothing moves the graphics cursor.
function point(x as integer, y as integer) as ubyte
    asm
    push namespace core
#ifdef CPC_BAREMETAL
    ld e, (ix+4)
    ld d, (ix+5)
    ld l, (ix+6)
    ld h, (ix+7)
    call __GR_POINT
#else
    call .core.__FW_CALL
    defw $BBC6
    push de
    push hl
    ld e, (ix+4)
    ld d, (ix+5)
    ld l, (ix+6)
    ld h, (ix+7)
    call __GRA_XY
    call .core.__FW_CALL
    defw $BBF0
    pop hl
    pop de
    push af
    call .core.__FW_CALL
    defw $BBC0
    pop af
#endif
    pop namespace
    end asm
end function

#pragma pop(case_insensitive)

#require "gfx.asm"

#endif
