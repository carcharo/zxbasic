; -----------------------------------------------------------------------
; Amstrad CPC -- Spectrum colours to pens, and the per-mode screen
; variables (cpcbuild/docs/notes.md, 2026-10-01, question 4)
;
; INK/PAPER/BORDER take Spectrum colours 0-7 (black, blue, red,
; magenta, green, cyan, yellow, white). A CPC mode has 2, 4 or 16 pens
; instead, so each colour goes through PEN_MAP, a fixed per-mode table
; picking the pen whose *firmware default* colour is nearest:
;
;   Spectrum   0  1  2  3  4  5  6  7
;   mode 0     5  6  3  7 12  2  1  4   exact: black, bright blue, bright
;                                       red, bright magenta, bright green,
;                                       bright cyan, bright yellow,
;                                       bright white
;   mode 1     0  0  3  3  2  2  1  1   blue, yellow, cyan, red palette
;   mode 2     0  0  0  0  1  1  1  1   blue, yellow palette (by brightness)
;
; So the default "white on black" is the CPC's own yellow on blue in
; mode 1. SetInk (cpc.bas) changes a pen's colour, not this table.
;
; The same mode switch also sets GFX_XSHIFT (mode pixels to firmware
; virtual coordinates, gfx.asm) and TXT_COLS (print.asm/sposn.asm), and
; forgets the graphics pen/write-mode cache (gfx.asm), since the
; firmware's mode change resets its graphics state.

#include once <sysvars.asm>

    push namespace core

; __CPC_SET_MODE_VARS -- A = screen mode (0-3; 3 is the undocumented
; 4-pen 160x200 hardware mode, treated as mode 0 geometry with mode 1
; pens). Loads PEN_MAP, GFX_XSHIFT and TXT_COLS for that mode and marks
; the graphics pen/mode cache unknown. Called by the bootstrap (mode 1)
; and by cpc.bas's Mode after SCR_SET_MODE.
; Firmware entry called: none (memory only).
; Registers clobbered: AF, BC, DE, HL.
__CPC_SET_MODE_VARS:
    PROC
    LOCAL __SMV_MAPS, __SMV_PARAMS

    and  3
    ld   l, a
    ld   h, 0
    add  hl, hl
    add  hl, hl
    add  hl, hl             ; HL = mode * 8
    ld   de, __SMV_MAPS
    add  hl, de
    ld   de, PEN_MAP
    ld   bc, 8
    ldir                    ; A (the mode) survives

    add  a, a
    ld   e, a
    ld   d, 0
    ld   hl, __SMV_PARAMS
    add  hl, de
    ld   a, (hl)
    ld   (GFX_XSHIFT), a
    inc  hl
    ld   a, (hl)
    ld   (TXT_COLS), a

    ld   a, $FF
    ld   (GRA_PEN_CUR), a
    ld   (GRA_MODE_CUR), a
    ret

__SMV_MAPS:
    DEFB 5, 6, 3, 7, 12, 2, 1, 4    ; mode 0
    DEFB 0, 0, 3, 3, 2, 2, 1, 1     ; mode 1
    DEFB 0, 0, 0, 0, 1, 1, 1, 1     ; mode 2
    DEFB 0, 0, 3, 3, 2, 2, 1, 1     ; mode 3

__SMV_PARAMS:                       ; GFX_XSHIFT, TXT_COLS
    DEFB 2, 20                      ; mode 0: 160 pixels, 20 columns
    DEFB 1, 40                      ; mode 1: 320 pixels, 40 columns
    DEFB 0, 80                      ; mode 2: 640 pixels, 80 columns
    DEFB 2, 20                      ; mode 3
    ENDP

; __INK_TO_PEN -- A = Spectrum colour (bits 0-2 used) -> A = pen of the
; current mode.
; Firmware entry called: none.
; Registers clobbered: AF.
__INK_TO_PEN:
    push hl
    and  7
    ld   hl, PEN_MAP
    add  a, l
    ld   l, a
    adc  a, h
    sub  l
    ld   h, a
    ld   a, (hl)
    pop  hl
    ret

    pop namespace
