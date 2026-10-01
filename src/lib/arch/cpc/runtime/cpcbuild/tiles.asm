; -----------------------------------------------------------------------
; cpcbuild library -- 8x8 tiles drawn straight into screen memory
;
; Written from scratch for this project (MIT); see core.asm.
;
; A tile is 8x8 pixels: 1 byte x 8 lines in mode 2, 2 x 8 in mode 1,
; 4 x 8 in mode 0 (width in bytes W = 1 << GFX_XSHIFT, colour.asm). Tile
; data: per tile its 8 rows top first, each row's bytes left to right,
; so a tile is 8 * W bytes. Tile n is at CB_TILESET + n * 8 * W.
; Tile cell (cx, cy) is byte column cx * W, pixel line cy * 8, so a tile
; starts on pixel line 0 of a character row: its 8 lines are in the 8
; successive 2 KB blocks, i.e. the next line is H + 8, with no
; character-row crossing. With a hardware-scroll offset a tile's row can
; still cross the end of its block (core.asm): that is checked once per
; tile and a per-byte path (__CB_INC_X) is used then.
;
; None of these routines calls the firmware, and none uses IX, IY or the
; shadow registers. Cells off the screen draw nothing.

#include once <cpcbuild/core.asm>

    push namespace core

; __CB_TILE_PTR -- HL = tile number (0-1023) -> DE = its data address.
; Firmware entry called: none.
; Registers clobbered: AF, B, DE, HL.
__CB_TILE_PTR:
    ld   a, (GFX_XSHIFT)
    add  a, 3
    ld   b, a
__CTP_LOOP:
    add  hl, hl             ; * 8 * W
    djnz __CTP_LOOP
    ld   de, (CB_TILESET)
    add  hl, de
    ex   de, hl
    ret

; __CB_TILE_DRAW -- HL = screen address of the tile's first byte (on
; pixel line 0 of a character row), DE = its data -> draws the tile.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILE_DRAW:
    PROC
    LOCAL __CTD_FAST, __CTD_F1, __CTD_F2, __CTD_F4
    LOCAL __CTD_L4, __CTD_SLOW, __CTD_SL, __CTD_SI, __CTD_W

    ld   a, h
    and  $07
    cp   $07
    jr   nz, __CTD_FAST     ; only the block's last 256 bytes can wrap
    ld   a, (GFX_XSHIFT)
    ld   c, 1
    or   a
    jr   z, __CTD_W
__CTD_SL:
    sla  c
    dec  a
    jr   nz, __CTD_SL
__CTD_W:                    ; C = width in bytes
    push de
    call __CB_ROW_WRAPS
    pop  de
    jr   c, __CTD_SLOW
__CTD_FAST:
    ld   a, (GFX_XSHIFT)
    ld   b, 8
    or   a
    jr   z, __CTD_F1
    dec  a
    jr   z, __CTD_F2
__CTD_F4:
    ld   a, (de)
    ld   (hl), a
    inc  de
    inc  hl
    ld   a, (de)
    ld   (hl), a
    inc  de
    inc  hl
    ld   a, (de)
    ld   (hl), a
    inc  de
    inc  hl
    ld   a, (de)
    ld   (hl), a
    inc  de
    dec  hl
    dec  hl
    dec  hl
    ld   a, h
    add  a, 8
    ld   h, a
    djnz __CTD_F4
    ret
__CTD_F2:
    ld   a, (de)
    ld   (hl), a
    inc  de
    inc  hl
    ld   a, (de)
    ld   (hl), a
    inc  de
    dec  hl
    ld   a, h
    add  a, 8
    ld   h, a
    djnz __CTD_F2
    ret
__CTD_F1:
    ld   a, (de)
    ld   (hl), a
    inc  de
    ld   a, h
    add  a, 8
    ld   h, a
    djnz __CTD_F1
    ret
__CTD_SLOW:                 ; C = width; per-byte, wrapping in the block
    ld   b, 8
__CTD_SI:
    push hl
    push bc
__CTD_L4:
    ld   a, (de)
    ld   (hl), a
    inc  de
    call __CB_INC_X
    dec  c
    jr   nz, __CTD_L4
    pop  bc
    pop  hl
    ld   a, h
    add  a, 8
    ld   h, a
    djnz __CTD_SI
    ret
    ENDP

; __CB_TILE_AT -- C = cell x, B = cell y, HL = tile number (0-1023):
; draws it, or nothing if the cell is off the screen (x * W >= 80 or
; y >= 25).
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILE_AT:
    PROC
    LOCAL __CTA_LIM, __CTA_LIMD, __CTA_SH, __CTA_SHD, __CTA_OFF

    push hl
    ld   a, (GFX_XSHIFT)
    ld   d, a
    ld   a, 80
__CTA_LIM:                  ; A = 80 >> shift = cells per row
    dec  d
    jp   m, __CTA_LIMD
    srl  a
    jr   __CTA_LIM
__CTA_LIMD:
    cp   c
    jr   z, __CTA_OFF
    jr   c, __CTA_OFF       ; limit <= x
    ld   a, b
    cp   25
    jr   nc, __CTA_OFF
    add  a, a
    add  a, a
    add  a, a
    ld   b, a               ; line = cell y * 8
    ld   a, (GFX_XSHIFT)
    ld   d, a
__CTA_SH:
    dec  d
    jp   m, __CTA_SHD
    sla  c                  ; byte column = cell x * W
    jr   __CTA_SH
__CTA_SHD:
    call __CB_ADDR          ; HL = screen address
    ex   (sp), hl           ; HL = tile number, stack = address
    call __CB_TILE_PTR
    pop  hl
    jp   __CB_TILE_DRAW
__CTA_OFF:
    pop  hl
    ret
    ENDP

; __CB_TILE16 -- C = x, B = y, A = tile: a 16x16 tile at 16x16 cell
; (x, y), drawn as the 8x8 tiles 4*tile .. 4*tile+3 (top-left,
; top-right, bottom-left, bottom-right) at 8x8 cells (2x, 2y) ...
; (2x+1, 2y+1); the parts off the screen are skipped.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILE16:
    ld   l, a
    ld   h, 0
    add  hl, hl
    add  hl, hl             ; first 8x8 tile number
    ld   a, c
    cp   128
    ret  nc                 ; off the screen anyway (and 2x would overflow)
    ld   a, b
    cp   128
    ret  nc
    sla  c
    sla  b
    push bc
    push hl
    call __CB_TILE_AT       ; top-left
    pop  hl
    pop  bc
    inc  hl
    inc  c
    push bc
    push hl
    call __CB_TILE_AT       ; top-right
    pop  hl
    pop  bc
    inc  hl
    dec  c
    inc  b
    push bc
    push hl
    call __CB_TILE_AT       ; bottom-left
    pop  hl
    pop  bc
    inc  hl
    inc  c
    jp   __CB_TILE_AT       ; bottom-right

; __CB_TILEMAP -- HL = map (row-major bytes), D = cell
; y, E = cell x, B = height, C = width (in tiles; the map is C bytes per
; row): draws the block of 8x8 tiles with its top-left at cell (x, y),
; skipping cells off the screen. Per row the first address comes from
; __CB_ADDR, then each tile's is the previous plus W, wrapped at the
; block end by clearing bit 3 of H (valid because a tile starts in
; block 0, so a carry out of the block is the only way that bit gets set).
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILEMAP:
    PROC
    LOCAL __CTM_LIM, __CTM_LIMD, __CTM_SH, __CTM_SHD, __CTM_ROW
    LOCAL __CTM_TILE, __CTM_V1, __CTM_R1

    ld   (__CTM_ROWMAP), hl
    ld   a, c
    ld   (__CTM_W), a
    ld   a, d
    cp   25
    ret  nc
    ld   (__CTM_Y), a
    ld   a, 25
    sub  d                  ; rows left on the screen
    cp   b
    jr   nc, __CTM_R1
    ld   b, a
__CTM_R1:
    ld   a, b
    or   a
    ret  z
    ld   (__CTM_ROWS), a
    ld   a, (GFX_XSHIFT)
    ld   d, a
    ld   a, 80
__CTM_LIM:                  ; A = cells per screen row
    dec  d
    jp   m, __CTM_LIMD
    srl  a
    jr   __CTM_LIM
__CTM_LIMD:
    ld   d, a
    ld   a, e
    cp   d
    ret  nc                 ; x off the right edge
    ld   a, d
    sub  e                  ; cells left in the row
    cp   c
    jr   c, __CTM_V1
    ld   a, c
__CTM_V1:
    or   a
    ret  z                  ; width 0
    ld   (__CTM_VIS), a
    ld   a, (GFX_XSHIFT)
    ld   d, a
    ld   a, e               ; x * W: first byte column
    ld   e, 1               ; E = W
__CTM_SH:
    dec  d
    jp   m, __CTM_SHD
    add  a, a
    sla  e
    jr   __CTM_SH
__CTM_SHD:
    ld   (__CTM_XB), a
    ld   d, 0
    ld   (__CTM_WB), de
__CTM_ROW:
    ld   a, (__CTM_Y)
    add  a, a
    add  a, a
    add  a, a
    ld   b, a
    ld   a, (__CTM_XB)
    ld   c, a
    call __CB_ADDR
    ld   a, (__CTM_VIS)
    ld   (__CTM_CNT), a
    ld   de, (__CTM_ROWMAP)
    ld   (__CTM_MPTR), de
__CTM_TILE:
    push hl
    ld   hl, (__CTM_MPTR)
    ld   a, (hl)
    inc  hl
    ld   (__CTM_MPTR), hl
    ld   l, a
    ld   h, 0
    call __CB_TILE_PTR
    pop  hl
    push hl
    call __CB_TILE_DRAW
    pop  hl
    ld   de, (__CTM_WB)
    add  hl, de
    res  3, h               ; wrap at the block end
    ld   a, (__CTM_CNT)
    dec  a
    ld   (__CTM_CNT), a
    jr   nz, __CTM_TILE
    ld   a, (__CTM_W)
    ld   e, a
    ld   d, 0
    ld   hl, (__CTM_ROWMAP)
    add  hl, de
    ld   (__CTM_ROWMAP), hl
    ld   a, (__CTM_Y)
    inc  a
    ld   (__CTM_Y), a
    ld   a, (__CTM_ROWS)
    dec  a
    ld   (__CTM_ROWS), a
    jr   nz, __CTM_ROW
    ret
    ENDP

; Working storage of __CB_TILEMAP (never executed; in the code stream).
__CTM_ROWMAP:  defw 0
__CTM_MPTR:    defw 0
__CTM_WB:      defw 0
__CTM_W:       defb 0
__CTM_VIS:     defb 0
__CTM_CNT:     defb 0
__CTM_Y:       defb 0
__CTM_ROWS:    defb 0
__CTM_XB:      defb 0

    pop namespace
