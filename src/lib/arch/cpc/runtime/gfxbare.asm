; -----------------------------------------------------------------------
; Amstrad CPC bare-metal graphics (-D CPC_BAREMETAL, Phase 6 B5)
;
; PLOT, DRAW, CIRCLE and POINT straight into screen memory, with no
; firmware, pixel for pixel what the firmware's GRA_* calls draw in
; firmware mode. Coordinates are the current mode's pixels, origin
; bottom-left (mode 0 160x200, mode 1 320x200, mode 2 640x200), 16-bit
; signed; the screen is at SCREEN_ADDR (bare text and the cpcbuild double
; buffer move it) with no hardware scroll, 80 bytes per character row and
; 8 lines 2 KB apart. Everything outside the window (the whole screen) is
; clipped silently, as the firmware does.
;
; Pixels in a byte (the pixel mask Pm, bits of the byte the pixel owns):
;   mode 2: 8 pixels, Pm = &80 >> i
;   mode 1: 4 pixels, Pm = &88 >> i (pen bit 0 in the high nibble)
;   mode 0: 2 pixels, Pm = &AA >> i
; so the next pixel to the right is the mask rotated right (a carry out
; means the next byte); the pen's screen byte (every pixel set to that
; pen, from txtbare.asm's __BT_PENMASK) is I, and a pixel is written as
;   byte ^ (((byte & KEEP) ^ I) & Pm)
; where KEEP = &FF replaces the pixel with the pen and KEEP = 0 (OVER 1)
; XORs the pen onto it, as the firmware's SCR_ACCESS write mode does.
;
; Pen: the temporary ink (paper under INVERSE 1) through colour.asm's pen
; map, exactly as gfx.asm's firmware version. OVER 1 = XOR.
;
; Lines: the firmware's GRA_LINE (ROM &183C on the 464) works on the pixel
; coordinates like this, and so does this code, so the pixels are the
; same ones:
;   - the end points are swapped so the start has the smaller x (equal x
;     swaps too);
;   - the line is y-major if |dy| >= |dx|, else x-major; the major axis has
;     N = extent + 1 pixels, the minor axis M = extent + 1 steps;
;   - it is drawn as M runs along the major axis, run i being Q or Q + 1
;     pixels (Q = N div M, R = N mod M; an accumulator starting at M / 2
;     gains R per run and a run is one longer when it passes M), with a
;     minor-axis step of one pixel between runs;
;   - an x-major line starts at the (left) start point; a y-major line
;     starts at its lower end and draws upwards.
; The firmware also plots the first point; draw.asm re-plots it under
; OVER 1 so the net effect is the same as the Spectrum's DRAW.
; Clipping the line pixel by pixel is the same as the firmware clipping
; each run.
;
; A line with both ends on the screen takes the fast path: a screen
; pointer and pixel mask step along the line. Otherwise every pixel
; goes through __GR_PIXEL (address, clip, write).
;
; The graphics cursor (GR_CX, GR_CY: where DRAW continues, set by PLOT,
; DRAW and each CIRCLE point, as the firmware's) and the pen are in
; the program image, like kbare.asm's state.
; Registers: every routine says which it clobbers; the shadow registers
; are used as scratch (compiled code never keeps anything in them).
; No firmware is called.
; -----------------------------------------------------------------------

#ifdef CPC_BAREMETAL

#include once <sysvars.asm>
#include once <colour.asm>
#include once <txtbare.asm>
#include once <arith/div16.asm>

    push namespace core

; ---- state (program image) -------------------------------------------------
GR_CX:      defw 0              ; graphics cursor
GR_CY:      defw 0
GR_I:       defb 0              ; pen byte
GR_KEEP:    defb $FF            ; $FF set, 0 XOR
L_X0:       defw 0              ; DRAW: old cursor, new cursor
L_Y0:       defw 0
L_X1:       defw 0
L_Y1:       defw 0
L_SX:       defw 0              ; where the raster starts
L_SY:       defw 0
L_NMIN:     defw 0              ; minor steps (M)
L_Q:        defw 0
L_R:        defw 0
L_ACC:      defw 0
L_MC:       defw 0              ; runs left
L_RN:       defw 0              ; pixels left in the run (clipped path)
L_MIN:      defw 0              ; the 664/6128 rasteriser: minor extent m,
L_MD:       defw 0              ; m - M,
L_E:        defw 0              ; the error term,
L_IXV:      defw 0              ; r * m,
L_RB:       defw 0              ; the last run r,
L_REM:      defw 0              ; pixels left
#ifdef CPC_LINE_464
GR_LINEB:   defb 0              ; -D CPC_LINE_464 forces the 464's line algorithm
#else
GR_LINEB:   defb 1              ; 1 = 664/6128 line algorithm, 0 = 464's
#endif
L_XMAJ:     defb 0              ; 1 = x-major
L_MINOR:    defb 0              ; minor step: 0 up, 1 down, 2 right, 3 left

; -D CPC_LINE_464 / -D CPC_LINE_6128 fix the algorithm at compile time (a
; cold start on a 464 cannot tell: the test harness's --cold --model 464
; passes -D CPC_LINE_464); with neither the start-up code looks.
#ifndef CPC_LINE_464
#ifndef CPC_LINE_6128
#init .core.CPC_INIT_12_GFX

; CPC_INIT_12_GFX -- picks the line algorithm: the 464's firmware draws
; slightly different lines from the 664's and 6128's (see the header), so
; look for the 464 in the firmware's RAM jumpblock (still there on a disc
; start; &BBC0 is GRA_MOVE_ABSOLUTE, and only the 464's ends up at &15F4).
; Anything else -- the 664/6128, or a cold start where there is no
; firmware and the bytes are junk -- gets the 664/6128 algorithm.
; Clobbers AF, DE, HL.
CPC_INIT_12_GFX:
    ld   a, ($BBC0)
    cp   $CF                ; RST 1 (low jump)
    ret  nz
    ld   hl, ($BBC1)
    ld   de, $95F4          ; ROM &15F4 with the lower-ROM select bits
    or   a
    sbc  hl, de
    ret  nz
    xor  a
    ld   (GR_LINEB), a
    ret
#endif
#endif

; __GRA_PREP -- the pen byte and write mode for the temporary attributes.
; Preserves DE, HL. Clobbers AF, BC.
__GRA_PREP:
    push de
    push hl
    ld   a, (P_FLAG)
    and  4                  ; temporary INVERSE (bit 2)
    ld   a, (ATTR_T)
    jr   z, __GP_INK
    rrca
    rrca
    rrca                    ; INVERSE 1: the paper colour
__GP_INK:
    call __INK_TO_PEN
    call __BT_PENMASK       ; clobbers AF, D
    ld   (GR_I), a
    ld   a, (P_FLAG)
    and  1                  ; temporary OVER (bit 0)
    dec  a                  ; 0 -> $FF (replace), 1 -> 0 (XOR)
    ld   (GR_KEEP), a
    pop  hl
    pop  de
    ret

; __GR_ADDR -- DE = x, HL = y (mode pixels, signed) -> HL = screen address
; of the pixel's byte, D = its pixel mask, carry clear; or carry set (and
; the other registers meaningless) if the point is off the screen.
; Clobbers AF, BC, DE, HL.
__GR_ADDR:
    PROC
    LOCAL __GA_M1, __GA_M2, __GA_X, __GA_OFF, __GA_OFF2, __GA_SHIFT, __GA_LOW, __GA_BASE

    ld   a, h
    or   a
    jr   nz, __GA_OFF
    ld   a, l
    cp   200
    jr   nc, __GA_OFF
    push hl                 ; y
    ld   a, (GFX_XSHIFT)
    or   a
    jr   z, __GA_M2
    dec  a
    jr   z, __GA_M1
    ld   a, e               ; mode 0: byte = x >> 1, pixel = x & 1
    and  1
    ld   b, a
    ld   c, $AA
    srl  d
    rr   e
    jr   __GA_X
__GA_M1:
    ld   a, e               ; mode 1: x >> 2, x & 3
    and  3
    ld   b, a
    ld   c, $88
    srl  d
    rr   e
    srl  d
    rr   e
    jr   __GA_X
__GA_M2:
    ld   a, e               ; mode 2: x >> 3, x & 7
    and  7
    ld   b, a
    ld   c, $80
    srl  d
    rr   e
    srl  d
    rr   e
    srl  d
    rr   e
__GA_X:
    ld   a, d               ; byte index < 80 (a negative x shifts to a big one)
    or   a
    jr   nz, __GA_OFF2
    ld   a, e
    cp   80
    jr   nc, __GA_OFF2
    ld   a, c               ; Pm = first mask >> pixel
    inc  b
    jr   __GA_SHIFT
__GA_LOW:
    srl  a
__GA_SHIFT:
    djnz __GA_LOW
    ld   d, a               ; D = Pm, E = byte index
    pop  hl                 ; y
    ld   a, 199
    sub  l
    ld   b, a               ; B = screen row 0..199
    and  7                  ; line in the character row: 2 KB each
    add  a, a
    add  a, a
    add  a, a
    ld   h, a
    ld   a, b
    rrca
    rrca
    rrca
    and  $1F                ; character row
    ld   c, a
    add  a, a
    add  a, a
    add  a, c               ; row * 5
    ld   c, a               ; row * 80 = (row * 5) << 4
    rrca
    rrca
    rrca
    rrca
    ld   c, a               ; nibbles swapped
    and  $0F
    add  a, h
    ld   h, a               ; high byte: line * 8 + (row * 5) >> 4
    ld   a, c
    and  $F0
    add  a, e               ; low byte: ((row * 5) << 4) + byte index
    ld   l, a
    jr   nc, __GA_BASE
    inc  h
__GA_BASE:
    ld   a, (SCREEN_ADDR + 1)
    add  a, h               ; the screen page is 16 KB aligned: no carry
    ld   h, a
    or   a                  ; carry clear
    ret
__GA_OFF2:
    pop  hl
__GA_OFF:
    scf
    ret
    ENDP

; __GR_PIXEL -- plots the pen at DE = x, HL = y (clipped).
; Clobbers AF, BC, DE, HL.
__GR_PIXEL:
    call __GR_ADDR
    ret  c

; __GR_PUT -- HL = byte address, D = pixel mask: writes the pen.
; Clobbers AF, BC, E.
__GR_PUT:
    ld   a, (GR_KEEP)
    ld   b, a
    ld   a, (GR_I)
    ld   c, a
    ld   a, (hl)
    ld   e, a
    and  b
    xor  c
    and  d
    xor  e
    ld   (hl), a
    ret

; __PLOT -- DE = x, HL = y: moves the cursor there and plots.
; Clobbers AF, BC, DE, HL.
__PLOT:
    ld   (GR_CX), de
    ld   (GR_CY), hl
    call __GRA_PREP
    jp   __GR_PIXEL

; __GR_POINT -- DE = x, HL = y -> A = the pen of that pixel (0 off the
; screen, like the firmware's graphics paper). Does not move the cursor.
; Clobbers AF, BC, DE, HL.
__GR_POINT:
    PROC
    LOCAL __GPT_M1, __GPT_M2, __GPT_1, __GPT_2, __GPT_3, __GPT_4, __GPT_5
    call __GR_ADDR
    jr   nc, __GPT_ON
    xor  a
    ret
__GPT_ON:
    ld   a, (hl)
    and  d                  ; the pixel's bits
    ld   e, a
    ld   a, (GFX_XSHIFT)
    or   a
    jr   z, __GPT_M2
    dec  a
    jr   z, __GPT_M1
    ld   d, 0               ; mode 0 (and 3): planes C0 0C 30 03 = pen bits 0-3
    ld   a, e
    and  $C0
    jr   z, __GPT_1
    inc  d
__GPT_1:
    ld   a, e
    and  $0C
    jr   z, __GPT_2
    set  1, d
__GPT_2:
    ld   a, e
    and  $30
    jr   z, __GPT_3
    set  2, d
__GPT_3:
    ld   a, e
    and  $03
    jr   z, __GPT_4
    set  3, d
__GPT_4:
    ld   a, d
    ret
__GPT_M1:                   ; planes F0 0F = pen bits 0, 1
    ld   d, 0
    ld   a, e
    and  $F0
    jr   z, __GPT_5
    inc  d
__GPT_5:
    ld   a, e
    and  $0F
    ld   a, d
    ret  z
    or   2
    ret
__GPT_M2:
    ld   a, e
    or   a
    ret  z
    ld   a, 1
    ret
    ENDP

; ---- moving the screen pointer (HL = address, D = pixel mask) ------------
; Clobber A only.
__GR_RIGHT:
    rrc  d
    ret  nc
    inc  hl
    ret
__GR_LEFT:
    rlc  d
    ret  nc
    dec  hl
    ret
__GR_UP:                    ; y + 1: one screen line up
    ld   a, h
    sub  8
    ld   h, a
    and  $38
    cp   $38
    ret  nz                 ; (line 0 -> 7 of the row above)
    ld   a, h
    add  a, $40             ; undo the borrow into the page bits
    ld   h, a
    ld   a, l
    sub  $50
    ld   l, a
    ret  nc
    dec  h
    ret
__GR_DOWN:                  ; y - 1
    ld   a, h
    add  a, 8
    ld   h, a
    and  $38
    ret  nz                 ; (line 7 -> 0 of the row below)
    ld   a, h
    sub  $40
    ld   h, a
    ld   a, l
    add  a, $50
    ld   l, a
    ret  nc
    inc  h
    ret

; __GR_MINOR -- one minor-axis step (L_MINOR) of the screen pointer.
__GR_MINOR:
    ld   a, (L_MINOR)
    or   a
    jr   z, __GR_UP
    dec  a
    jr   z, __GR_DOWN
    dec  a
    jr   z, __GR_RIGHT
    jr   __GR_LEFT

; __GR_NEXTRUN -- BC = the length of the next run (Q, or Q + 1). Updates
; the accumulator. Clobbers AF, BC, DE, HL (of whichever bank is current).
__GR_NEXTRUN:
    PROC
    LOCAL __NR_NEG, __NR_ST
    ld   a, (GR_LINEB)
    or   a
    jp   nz, __GR_NEXTRUN_B
    ld   hl, (L_ACC)
    ld   de, (L_R)
    add  hl, de
    ld   de, (L_NMIN)
    ld   bc, (L_Q)
    or   a
    sbc  hl, de
    jr   c, __NR_NEG
    jr   z, __NR_NEG
    inc  bc                 ; acc passed M: a longer run
    jr   __NR_ST
__NR_NEG:
    add  hl, de
__NR_ST:
    ld   (L_ACC), hl
    ret
    ENDP

; __GR_NEXTRUN_B -- the 664/6128 firmware's rasteriser (ROM &17B4 on the
; 6128), taken over as it is: with the major extent M, the minor extent m,
; and an error term E (starting at -M/2), each run is found by adding m to
; E (and 1 to the run r, the loop below keeping IX = r * m) until E >= 0
; and taking m back off while it is >= m, then E - M is kept for the next
; run. Run k ends at ceil(((k - 1) M + ceil(M / 2)) / m), the usual
; rounded Bresenham; the last run is cut to the pixels still to draw.
; m = 0 is a straight line of all of them. IX is saved.
; BC = the run length. Clobbers AF, BC, DE, HL.
__GR_NEXTRUN_B:
    PROC
    LOCAL __NB_STRAIGHT, __NB_1, __NB_2, __NB_3, __NB_4, __NB_CUT
    push ix
    ld   hl, (L_MIN)
    ld   a, h
    or   l
    jr   z, __NB_STRAIGHT
    ld   ix, (L_IXV)
    ld   hl, (L_E)
    ld   bc, (L_RB)
    push ix
    pop  de
    or   a
    adc  hl, de             ; E += r * m (adc: it sets the sign flag)
    ld   de, (L_MIN)
    jp   p, __NB_2
__NB_1:
    inc  bc                 ; E < 0: one more pixel in this run
    add  ix, de
    add  hl, de
    jr   nc, __NB_1
__NB_2:
    xor  a                  ; DE = -m
    sub  e
    ld   e, a
    sbc  a, a
    sub  d
    ld   d, a
__NB_3:
    add  hl, de             ; E >= m: one pixel too many
    jr   nc, __NB_4
    add  ix, de
    dec  bc
    jr   __NB_3
__NB_4:
    ld   de, (L_MD)
    add  hl, de             ; (the failed subtraction above already took m)
    ld   (L_E), hl
    ld   (L_IXV), ix
    ld   (L_RB), bc
    ld   hl, (L_REM)
    or   a
    sbc  hl, bc
    jr   nc, __NB_CUT
    add  hl, bc             ; fewer left than the run: take what is left
    ld   b, h
    ld   c, l
    ld   hl, 0
__NB_CUT:
    ld   (L_REM), hl
    pop  ix
    ret
__NB_STRAIGHT:
    ld   bc, (L_REM)
    ld   hl, 0
    ld   (L_REM), hl
    pop  ix
    ret
    ENDP

; __GR_ADDW -- the word at HL += DE. Clobbers AF, HL.
__GR_ADDW:
    ld   a, (hl)
    add  a, e
    ld   (hl), a
    inc  hl
    ld   a, (hl)
    adc  a, d
    ld   (hl), a
    ret

; __DRAW -- DE = dx, HL = dy (signed): a line from the cursor to the cursor
; + (dx, dy), which becomes the cursor. The start point is plotted too,
; but under OVER 1 plotted twice (so it is left alone), as in firmware
; mode. Clobbers AF, BC, DE, HL, shadow registers, nothing else.
__DRAW:
    ld   (L_Y1), hl         ; dy for now
    ld   hl, (GR_CX)
    ld   (L_X0), hl
    add  hl, de
    ld   (GR_CX), hl
    ld   (L_X1), hl
    ld   hl, (GR_CY)
    ld   (L_Y0), hl
    ld   de, (L_Y1)
    add  hl, de
    ld   (GR_CY), hl
    ld   (L_Y1), hl
    call __GRA_PREP
    call __GR_LINE
    ld   a, (GR_KEEP)
    or   a
    ret  nz
    ld   de, (L_X0)
    ld   hl, (L_Y0)
    jp   __GR_PIXEL

; __GR_LINE -- draws the line L_X0,L_Y0 -> L_X1,L_Y1 as the firmware does.
; Clobbers AF, BC, DE, HL, AF', BC', DE', HL'.
__GR_LINE:
    PROC
    LOCAL __GL_NOSWAP, __GL_OTHER, __GL_DOWN, __GL_CMP, __GL_XM, __GL_YM1
    LOCAL __GL_N, __GL_A, __GL_GO, __GL_C1, __GL_C2, __GL_SLOW, __GL_SRUN, __GL_SPX, __GL_SMAJ
    LOCAL __GL_SMX, __GL_SMGO, __GL_FRUN, __GL_FX, __GL_FY
    LOCAL __GL_FM, __GL_FNX, __GL_FUP

    ld   hl, (L_X0)
    ld   de, (L_X1)
    or   a
    sbc  hl, de
    ld   b, h
    ld   c, l               ; BC = x0 - x1
    jp   m, __GL_NOSWAP
    ld   hl, (L_X1)         ; x0 >= x1: the start is the new point
    ld   (L_SX), hl
    ld   hl, (L_Y1)
    ld   (L_SY), hl
    ld   hl, (L_Y0)         ; the other end's y; BC = adx
    jr   __GL_OTHER
__GL_NOSWAP:
    ld   hl, 0
    or   a
    sbc  hl, bc
    ld   b, h
    ld   c, l               ; BC = adx = x1 - x0
    ld   hl, (L_X0)
    ld   (L_SX), hl
    ld   hl, (L_Y0)
    ld   (L_SY), hl
    ld   hl, (L_Y1)
__GL_OTHER:
    ex   de, hl             ; DE = other end's y
    ld   hl, (L_SY)
    or   a
    sbc  hl, de             ; start y - other y
    ex   de, hl             ; DE = that
    xor  a                  ; minor step up
    bit  7, d
    jr   z, __GL_DOWN
    ld   hl, 0
    or   a
    sbc  hl, de
    ex   de, hl             ; DE = ady
    jr   __GL_CMP
__GL_DOWN:
    ld   a, 1               ; the line goes down: minor step down
__GL_CMP:
    ld   (L_MINOR), a       ; (0 up, 1 down for now)
    ld   h, d
    ld   l, e
    or   a
    sbc  hl, bc             ; ady - adx
    jr   c, __GL_XM
    xor  a                  ; y-major: runs along y, x is the minor axis
    ld   (L_XMAJ), a
    ld   a, (L_MINOR)
    or   a
    ld   a, 2               ; going up as x grows: minor step right
    jr   z, __GL_YM1
    ld   hl, (L_SX)         ; going down: draw from the lower (right) end
    add  hl, bc
    ld   (L_SX), hl
    ld   hl, (L_SY)
    or   a
    sbc  hl, de
    ld   (L_SY), hl
    ld   a, 3               ; minor step left
__GL_YM1:
    ld   (L_MINOR), a
    ld   h, d
    ld   l, e               ; major extent = ady
    ld   d, b
    ld   e, c               ; minor extent = adx
    jr   __GL_N
__GL_XM:
    ld   a, 1
    ld   (L_XMAJ), a
    ld   h, b
    ld   l, c               ; major extent = adx, minor = ady (DE)
__GL_N:                     ; HL = major extent M, DE = minor extent m
    ld   a, (GR_LINEB)
    or   a
    jr   z, __GL_A
    ld   (L_MIN), de        ; the 664/6128 rasteriser: m + 1 runs, the last
    inc  de                 ; one cut short when the M + 1 pixels are out
    ld   (L_MC), de
    push hl
    inc  hl
    ld   (L_REM), hl
    pop  hl
    ex   de, hl             ; DE = M
    ld   hl, (L_MIN)
    or   a
    sbc  hl, de
    ld   (L_MD), hl         ; m - M
    ld   hl, 0
    or   a
    sbc  hl, de
    sra  h
    rr   l
    ld   (L_E), hl          ; -M / 2 (rounded down)
    ld   hl, 0
    ld   (L_IXV), hl
    ld   (L_RB), hl
    jr   __GL_GO
__GL_A:
    inc  hl                 ; pixel counts: extent + 1 (kept below 32768)
    bit  7, h
    jr   z, __GL_C1
    ld   hl, $7FFF
__GL_C1:
    inc  de
    bit  7, d
    jr   z, __GL_C2
    ld   de, $7FFF
__GL_C2:
    ld   (L_NMIN), de
    ld   (L_MC), de
    call __DIVU16_FAST      ; HL = N div M, DE = N mod M
    ld   (L_Q), hl
    ld   (L_R), de
    ld   hl, (L_NMIN)
    srl  h
    rr   l
    ld   (L_ACC), hl
__GL_GO:
    ; both ends on the screen: the fast path
    ld   de, (L_X0)
    ld   hl, (L_Y0)
    call __GR_ADDR
    jr   c, __GL_SLOW
    ld   de, (L_X1)
    ld   hl, (L_Y1)
    call __GR_ADDR
    jr   c, __GL_SLOW
    ld   de, (L_SX)
    ld   hl, (L_SY)
    call __GR_ADDR          ; HL = address, D = mask
    ld   a, (GR_KEEP)
    ld   b, a
    ld   a, (GR_I)
    ld   c, a
__GL_FRUN:
    exx
    call __GR_NEXTRUN       ; BC' = run length
    exx
    ld   a, (L_XMAJ)
    or   a
    jr   z, __GL_FY
__GL_FX:                    ; a run along x
    ld   a, (hl)
    ld   e, a
    and  b
    xor  c
    and  d
    xor  e
    ld   (hl), a
    rrc  d
    jr   nc, __GL_FNX
    inc  hl
__GL_FNX:
    exx
    dec  bc
    ld   a, b
    or   c
    exx
    jr   nz, __GL_FX
    jr   __GL_FM
__GL_FY:                    ; a run along y (upwards)
    ld   a, (hl)
    ld   e, a
    and  b
    xor  c
    and  d
    xor  e
    ld   (hl), a
    ld   a, h
    sub  8
    ld   h, a
    and  $38
    cp   $38
    call z, __GL_FUP        ; crossed into the character row above
    exx
    dec  bc
    ld   a, b
    or   c
    exx
    jr   nz, __GL_FY
__GL_FM:
    call __GR_MINOR
    push hl
    ld   hl, (L_MC)
    dec  hl
    ld   (L_MC), hl
    ld   a, h
    or   l
    pop  hl
    jp   nz, __GL_FRUN
    ret
__GL_FUP:                   ; H was lowered by 8 already (line 0 -> 7)
    ld   a, h
    add  a, $40
    ld   h, a
    ld   a, l
    sub  $50
    ld   l, a
    ret  nc
    dec  h
    ret

__GL_SLOW:                  ; some pixels may be off the screen
__GL_SRUN:
    call __GR_NEXTRUN
    ld   (L_RN), bc
__GL_SPX:
    ld   de, (L_SX)
    ld   hl, (L_SY)
    call __GR_PIXEL
    ld   hl, L_SX
    ld   a, (L_XMAJ)
    or   a
    jr   nz, __GL_SMAJ
    ld   hl, L_SY
__GL_SMAJ:
    ld   de, 1
    call __GR_ADDW          ; the major coordinate + 1
    ld   hl, (L_RN)
    dec  hl
    ld   (L_RN), hl
    ld   a, h
    or   l
    jr   nz, __GL_SPX
    ld   hl, L_SY           ; the minor step
    ld   de, 1
    ld   a, (L_MINOR)
    or   a
    jr   z, __GL_SMGO       ; up: y + 1
    dec  a
    jr   nz, __GL_SMX
    ld   de, -1             ; down: y - 1
    jr   __GL_SMGO
__GL_SMX:
    ld   hl, L_SX
    dec  a
    jr   z, __GL_SMGO       ; right: x + 1
    ld   de, -1             ; left: x - 1
__GL_SMGO:
    call __GR_ADDW
    ld   hl, (L_MC)
    dec  hl
    ld   (L_MC), hl
    ld   a, h
    or   l
    jp   nz, __GL_SRUN
    ret
    ENDP

    pop namespace

#endif
