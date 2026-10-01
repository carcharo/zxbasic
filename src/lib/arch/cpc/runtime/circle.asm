; -----------------------------------------------------------------------
; Amstrad CPC -- CIRCLE x, y, r
;
; The midpoint circle algorithm, as in zx48k's circle.asm, but with
; 16-bit signed coordinates (mode pixels, see gfx.asm) and each point
; plotted by the firmware. Every pixel is
; plotted exactly once (the axis and diagonal points that the 8-way
; symmetry would repeat are plotted only once), so OVER 1 draws and
; erases cleanly. In mode 0 and mode 2 the pixels aren't square, so the
; circle is stretched horizontally (mode 0) or squashed (mode 2).
;
; A negative radius draws nothing, and radius 0 plots the centre.
;
; Calling convention: x pushed, then y; r in HL (all 16-bit; the cpc
; parser widens the Spectrum's bytes, see src/arch/cpc/__init__.py).
;
; Firmware entries called: GRA_PLOT_ABSOLUTE (&BBEA) per point;
; __GRA_PREP's once.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).

#include once <gfx.asm>

    push namespace core

CIRC_CX     EQU CIRC_VARS + 0       ; centre x
CIRC_CY     EQU CIRC_VARS + 2       ; centre y
CIRC_X      EQU CIRC_VARS + 4       ; x offset, 0 up
CIRC_Y      EQU CIRC_VARS + 6       ; y offset, r down
CIRC_D      EQU CIRC_VARS + 8       ; midpoint decision value

CIRCLE:
    PROC
    LOCAL __C_LOOP, __C_DPOS, __C_DSET, __C_8, __C_R

    ld   (CIRC_Y), hl       ; r
    pop  bc                 ; return address
    pop  hl
    ld   (CIRC_CY), hl
    pop  hl
    ld   (CIRC_CX), hl
    push bc

    call __GRA_PREP         ; pen and write mode, once for all points
    ld   hl, (CIRC_Y)
    bit  7, h
    ret  nz                 ; negative radius: nothing
    ld   a, h
    or   l
    jr   nz, __C_R
    ld   d, h
    ld   e, l
    jp   __CIRC_PT          ; radius 0: just the centre

__C_R:
    ld   de, 0
    ld   (CIRC_X), de
    ex   de, hl             ; DE = r
    ld   hl, 1
    or   a
    sbc  hl, de
    ld   (CIRC_D), hl       ; d = 1 - r

    ld   hl, (CIRC_Y)
    ld   de, 0
    call __CIRC_2           ; (0, r), (0, -r)
    ex   de, hl
    call __CIRC_2           ; (r, 0), (-r, 0)

__C_LOOP:
    ld   hl, (CIRC_D)
    bit  7, h
    jr   z, __C_DPOS
    ld   de, (CIRC_X)       ; d < 0: d += 2x + 3
    ex   de, hl
    add  hl, hl
    inc  hl
    inc  hl
    inc  hl
    add  hl, de
    jr   __C_DSET
__C_DPOS:                   ; d >= 0: d += 2(x - y) + 5, y -= 1
    ld   hl, (CIRC_X)
    ld   de, (CIRC_Y)
    or   a
    sbc  hl, de
    add  hl, hl
    ld   de, 5
    add  hl, de
    ld   de, (CIRC_D)
    add  hl, de
    ld   de, (CIRC_Y)
    dec  de
    ld   (CIRC_Y), de
__C_DSET:
    ld   (CIRC_D), hl
    ld   hl, (CIRC_X)
    inc  hl
    ld   (CIRC_X), hl

    ex   de, hl             ; DE = x
    ld   hl, (CIRC_Y)
    or   a
    sbc  hl, de             ; y - x (both 0..32767)
    ret  c                  ; x > y: done
    ld   hl, (CIRC_Y)
    jr   nz, __C_8
    ld   h, d               ; x == y: the 4 diagonal points, then done
    ld   l, e
    jp   __CIRC_4

__C_8:
    call __CIRC_4           ; (+-x, +-y)
    ex   de, hl
    call __CIRC_4           ; (+-y, +-x)
    jr   __C_LOOP
    ENDP

; __CIRC_4 -- plots the centre + (a, b), (-a, -b), (-a, b), (a, -b), for
; DE = a, HL = b. Preserves DE, HL.
__CIRC_4:
    call __CIRC_2
    call __CIRC_NEG_DE
    call __CIRC_2
    ; fall through to restore DE

; __CIRC_NEG_DE -- DE = -DE. Clobbers AF.
__CIRC_NEG_DE:
    xor  a
    sub  e
    ld   e, a
    sbc  a, a
    sub  d
    ld   d, a
    ret

; __CIRC_2 -- plots the centre + (a, b) and (-a, -b), for DE = a,
; HL = b. Preserves DE, HL.
__CIRC_2:
    call __CIRC_PT
    call __CIRC_NEG_DE
    call __CIRC_NEG_HL
    call __CIRC_PT
    call __CIRC_NEG_DE
    ; fall through to restore HL

; __CIRC_NEG_HL -- HL = -HL. Clobbers AF.
__CIRC_NEG_HL:
    xor  a
    sub  l
    ld   l, a
    sbc  a, a
    sub  h
    ld   h, a
    ret

; __CIRC_PT -- plots the centre + (DE, HL). Preserves DE, HL.
__CIRC_PT:
    push de
    push hl
    ld   bc, (CIRC_CY)
    add  hl, bc
    ex   de, hl
    ld   bc, (CIRC_CX)
    add  hl, bc
    ex   de, hl             ; DE = x, HL = y
    call __GRA_XY
    call .core.__FW_CALL
    defw $BBEA              ; GRA_PLOT_ABSOLUTE
    pop  hl
    pop  de
    ret

    pop namespace
