; -----------------------------------------------------------------------
; cpcbuild library -- sprites: put, put masked, get block (all clipped)
;
; Written from scratch for this project (MIT); see core.asm.
;
; Sprite data is already in screen-byte format (2 pixels per byte in mode
; 0, 4 in mode 1, 8 in mode 2), row-major, top row first, w bytes per
; row; masked data is (mask, pixels) byte pairs. x is in bytes, y in
; lines, from the top-left, and may be off the screen: the part outside
; 0-79 / 0-199 is clipped away (the source bytes and rows are skipped,
; the data keeps its full w-byte row layout). The clip itself is
; __CB_CLIP_RECT in fill.asm.
;
; Each routine reads its parameters from the calling sub's IX frame:
; x = (ix+4), y = (ix+6) (16-bit), w = (ix+9), h = (ix+11), data or
; buffer address = (ix+12) (16-bit). Rows that don't wrap around the end
; of their 2 KB block (hardware-scroll offset) use LDIR / plain
; increments; rows that do use __CB_INC_X per byte.

#include once <cpcbuild/fill.asm>

    push namespace core

; __CB_SPR_PREP -- common set-up. A = bytes per item in the data (1, or
; 2 for masked pairs). Clips the rectangle; returns Carry set if nothing
; is visible. Otherwise Carry clear, HL = screen address of the first
; visible byte, DE = address in the data/buffer of the first visible item
; (data + (SY*w + SX) * A), and __CBS_SKIP = bytes to add to the data
; pointer after each row ((w - visible width) * A); __CBC_CH is the
; row count.
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_SPR_PREP:
    PROC
    LOCAL __CSP_ONE1, __CSP_ONE2, __CSP_NOSY, __CSP_MUL

    ld   (__CBS_K), a
    ld   l, (ix+4)
    ld   h, (ix+5)
    ld   e, (ix+6)
    ld   d, (ix+7)
    ld   b, (ix+9)
    ld   c, (ix+11)
    call __CB_CLIP_RECT
    ret  c
    push hl                 ; screen address
    ld   a, (ix+9)
    ld   hl, __CBC_CW
    sub  (hl)               ; w - visible width
    ld   l, a
    ld   h, 0
    ld   a, (__CBS_K)
    dec  a
    jr   z, __CSP_ONE1
    add  hl, hl
__CSP_ONE1:
    ld   (__CBS_SKIP), hl
    ld   hl, 0              ; offset = SY * w + SX
    ld   a, (__CBC_SY)
    or   a
    jr   z, __CSP_NOSY
    ld   e, (ix+9)
    ld   d, 0
    ld   b, a
__CSP_MUL:
    add  hl, de
    djnz __CSP_MUL
__CSP_NOSY:
    ld   a, (__CBC_SX)
    ld   e, a
    ld   d, 0
    add  hl, de
    ld   a, (__CBS_K)
    dec  a
    jr   z, __CSP_ONE2
    add  hl, hl
__CSP_ONE2:
    ld   e, (ix+12)
    ld   d, (ix+13)
    add  hl, de
    ex   de, hl             ; DE = data pointer
    pop  hl                 ; HL = screen address
    or   a
    ret
    ENDP

; __CB_NOWRAP -- Carry set if no row on the screen can wrap around the
; end of its 2 KB block, i.e. the hardware-scroll offset is 48 or less
; (the last row's last byte is then at offset + 24*80 + 79 < 2048). True
; whenever the text hasn't scrolled, so then the routines can skip the
; per-row __CB_ROW_WRAPS test.
; Firmware entry called: none. Registers clobbered: AF.
__CB_NOWRAP:
    ld   a, (CB_OFFSET + 1)
    or   a
    ret  nz                 ; 256 or more: Carry clear
    ld   a, (CB_OFFSET)
    cp   49                 ; Carry set if 48 or less
    ret

; __CB_PUT_SPRITE -- PutSprite's body: copies the visible part of the
; w*h bytes at data onto the screen, overwriting.
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_PUT_SPRITE:
    PROC
    LOCAL __CPS_ROW, __CPS_SLOW, __CPS_SLOWLP, __CPS_TAIL, __CPS_FAST, __CPS_FSAME

    ld   a, 1
    call __CB_SPR_PREP
    ret  c
    call __CB_NOWRAP
    jr   nc, __CPS_ROW
__CPS_FAST:                 ; no row can wrap: no per-row test
    push hl
    ex   de, hl             ; HL = data, DE = screen
    ld   bc, (__CBC_CW)
    ldir
    ex   de, hl             ; DE = data after the row
    ld   hl, (__CBS_SKIP)
    add  hl, de
    ex   de, hl
    pop  hl
    ld   a, (__CBC_CH)
    dec  a
    ret  z
    ld   (__CBC_CH), a
    ld   a, h               ; next line: usually just the next 2 KB block
    add  a, 8
    ld   h, a
    and  $38
    jr   nz, __CPS_FSAME
    ld   a, h               ; crossed into the next character row
    sub  8
    ld   h, a
    call __CB_NEXT_LINE
__CPS_FSAME:
    jr   __CPS_FAST
__CPS_ROW:
    push hl                 ; row start
    push de                 ; data
    ld   bc, (__CBC_CW)
    call __CB_ROW_WRAPS
    pop  de
    jr   c, __CPS_SLOW
    ex   de, hl             ; HL = data, DE = screen
    ldir
    ex   de, hl             ; DE = data after the row
    jr   __CPS_TAIL
__CPS_SLOW:
    ld   b, c
__CPS_SLOWLP:
    ld   a, (de)
    inc  de
    ld   (hl), a
    call __CB_INC_X         ; keeps B
    djnz __CPS_SLOWLP
__CPS_TAIL:
    ld   hl, (__CBS_SKIP)
    add  hl, de
    ex   de, hl             ; DE = data at the next row
    pop  hl                 ; row start
    ld   a, (__CBC_CH)
    dec  a
    ret  z
    ld   (__CBC_CH), a
    call __CB_NEXT_LINE
    jr   __CPS_ROW
    ENDP

; __CB_PUT_MASKED -- PutSpriteMasked's body: data is (mask, pixels)
; pairs; each screen byte becomes (screen AND mask) OR pixels.
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_PUT_MASKED:
    PROC
    LOCAL __CPM_ROW, __CPM_SLOW, __CPM_SLOWLP, __CPM_FASTLP, __CPM_TAIL, __CPM_FAST, __CPM_FLP, __CPM_FSAME

    ld   a, 2
    call __CB_SPR_PREP
    ret  c
    call __CB_NOWRAP
    jr   nc, __CPM_ROW
__CPM_FAST:                 ; no row can wrap: no per-row test
    push hl
    ex   de, hl             ; HL = data, DE = screen
    ld   a, (__CBC_CW)
    ld   b, a
__CPM_FLP:
    ld   a, (de)
    and  (hl)
    inc  hl
    or   (hl)
    inc  hl
    ld   (de), a
    inc  de
    djnz __CPM_FLP
    ex   de, hl             ; DE = data after the row
    ld   hl, (__CBS_SKIP)
    add  hl, de
    ex   de, hl
    pop  hl
    ld   a, (__CBC_CH)
    dec  a
    ret  z
    ld   (__CBC_CH), a
    ld   a, h               ; next line: usually just the next 2 KB block
    add  a, 8
    ld   h, a
    and  $38
    jr   nz, __CPM_FSAME
    ld   a, h               ; crossed into the next character row
    sub  8
    ld   h, a
    call __CB_NEXT_LINE
__CPM_FSAME:
    jr   __CPM_FAST
__CPM_ROW:
    push hl                 ; row start
    push de                 ; data
    ld   bc, (__CBC_CW)
    call __CB_ROW_WRAPS
    pop  de
    jr   c, __CPM_SLOW
    ex   de, hl             ; HL = data, DE = screen
    ld   b, c
__CPM_FASTLP:
    ld   a, (de)            ; screen
    and  (hl)               ; AND mask
    inc  hl
    or   (hl)               ; OR pixels
    inc  hl
    ld   (de), a
    inc  de
    djnz __CPM_FASTLP
    ex   de, hl             ; DE = data after the row
    jr   __CPM_TAIL
__CPM_SLOW:
    ld   b, c
__CPM_SLOWLP:
    ld   a, (de)            ; mask
    inc  de
    and  (hl)               ; AND screen
    ld   c, a
    ld   a, (de)            ; pixels
    inc  de
    or   c
    ld   (hl), a
    call __CB_INC_X         ; keeps B and C
    djnz __CPM_SLOWLP
__CPM_TAIL:
    ld   hl, (__CBS_SKIP)
    add  hl, de
    ex   de, hl
    pop  hl
    ld   a, (__CBC_CH)
    dec  a
    ret  z
    ld   (__CBC_CH), a
    call __CB_NEXT_LINE
    jr   __CPM_ROW
    ENDP

; __CB_GET_BLOCK -- GetBlock's body: copies the visible part of the
; screen area into the buffer, keeping the buffer's w-byte row layout
; (bytes that would come from off-screen are left as they were).
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_GET_BLOCK:
    PROC
    LOCAL __CGB_ROW, __CGB_SLOW, __CGB_SLOWLP, __CGB_TAIL, __CGB_FAST, __CGB_FSAME

    ld   a, 1
    call __CB_SPR_PREP
    ret  c
    call __CB_NOWRAP
    jr   nc, __CGB_ROW
__CGB_FAST:                 ; no row can wrap: no per-row test
    push hl
    ld   bc, (__CBC_CW)
    ldir                    ; HL = screen, DE = buffer
    ld   hl, (__CBS_SKIP)
    add  hl, de
    ex   de, hl
    pop  hl
    ld   a, (__CBC_CH)
    dec  a
    ret  z
    ld   (__CBC_CH), a
    ld   a, h               ; next line: usually just the next 2 KB block
    add  a, 8
    ld   h, a
    and  $38
    jr   nz, __CGB_FSAME
    ld   a, h               ; crossed into the next character row
    sub  8
    ld   h, a
    call __CB_NEXT_LINE
__CGB_FSAME:
    jr   __CGB_FAST
__CGB_ROW:
    push hl                 ; row start
    push de                 ; buffer
    ld   bc, (__CBC_CW)
    call __CB_ROW_WRAPS
    pop  de
    jr   c, __CGB_SLOW
    ldir                    ; HL = screen, DE = buffer
    jr   __CGB_TAIL
__CGB_SLOW:
    ld   b, c
__CGB_SLOWLP:
    ld   a, (hl)
    ld   (de), a
    inc  de
    call __CB_INC_X
    djnz __CGB_SLOWLP
__CGB_TAIL:
    ld   hl, (__CBS_SKIP)
    add  hl, de
    ex   de, hl
    pop  hl
    ld   a, (__CBC_CH)
    dec  a
    ret  z
    ld   (__CBC_CH), a
    call __CB_NEXT_LINE
    jr   __CGB_ROW
    ENDP

__CBS_K:    DEFB 0
__CBS_SKIP: DEFW 0

    pop namespace
