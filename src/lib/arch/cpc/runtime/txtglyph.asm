; -----------------------------------------------------------------------
; Amstrad CPC bare-metal text: the glyph part (-D CPC_BAREMETAL, Phase 6 B6
; split of txtbare.asm, whose header describes the whole). Included by what
; prints or reads characters: the glyph table (__CPC_FONT, characters 32-255,
; CHARS and UDG), the line feed with its software scroll, __BT_PUTC and
; SCREEN$'s __BT_RDCHAR. Font: see txtbare.asm's description (copied from
; the lower ROM at start-up on a disc boot, or -D CPC_OWNFONT's bundled one).
; -----------------------------------------------------------------------

#ifdef CPC_BAREMETAL

#include once <txtbare.asm>

#init .core.CPC_INIT_11_GLYPHS

    push namespace core

; ---- the glyph table (characters 32-255) --------------------------------
__CPC_FONT_PAD:
    DEFS (8 - (__CPC_FONT_PAD & 7)) & 7     ; 8-byte alignment (the draw loops
                                             ; end a glyph on L & 7 = 0)
__CPC_FONT:
#ifdef CPC_OWNFONT
    DEFB $00, $00, $00, $00, $00, $00, $00, $00    ; 32
    DEFB $10, $10, $10, $10, $10, $00, $10, $00    ; 33 !
    DEFB $28, $28, $28, $00, $00, $00, $00, $00    ; 34 "
    DEFB $28, $28, $7C, $28, $7C, $28, $28, $00    ; 35 #
    DEFB $10, $3C, $50, $38, $14, $78, $10, $00    ; 36 $
    DEFB $64, $64, $08, $10, $20, $4C, $4C, $00    ; 37 %
    DEFB $30, $48, $50, $20, $54, $48, $34, $00    ; 38 &
    DEFB $10, $10, $20, $00, $00, $00, $00, $00    ; 39 '
    DEFB $08, $10, $20, $20, $20, $10, $08, $00    ; 40 (
    DEFB $20, $10, $08, $08, $08, $10, $20, $00    ; 41 )
    DEFB $00, $10, $54, $38, $54, $10, $00, $00    ; 42 *
    DEFB $00, $10, $10, $7C, $10, $10, $00, $00    ; 43 +
    DEFB $00, $00, $00, $00, $00, $10, $10, $20    ; 44 ,
    DEFB $00, $00, $00, $7C, $00, $00, $00, $00    ; 45 -
    DEFB $00, $00, $00, $00, $00, $30, $30, $00    ; 46 .
    DEFB $04, $08, $08, $10, $20, $20, $40, $00    ; 47 /
    DEFB $38, $44, $4C, $54, $64, $44, $38, $00    ; 48 0
    DEFB $10, $30, $10, $10, $10, $10, $38, $00    ; 49 1
    DEFB $38, $44, $04, $08, $10, $20, $7C, $00    ; 50 2
    DEFB $38, $44, $04, $18, $04, $44, $38, $00    ; 51 3
    DEFB $08, $18, $28, $48, $7C, $08, $08, $00    ; 52 4
    DEFB $7C, $40, $78, $04, $04, $44, $38, $00    ; 53 5
    DEFB $38, $40, $40, $78, $44, $44, $38, $00    ; 54 6
    DEFB $7C, $04, $08, $10, $20, $20, $20, $00    ; 55 7
    DEFB $38, $44, $44, $38, $44, $44, $38, $00    ; 56 8
    DEFB $38, $44, $44, $3C, $04, $04, $38, $00    ; 57 9
    DEFB $00, $30, $30, $00, $30, $30, $00, $00    ; 58 :
    DEFB $00, $30, $30, $00, $30, $10, $20, $00    ; 59 ;
    DEFB $08, $10, $20, $40, $20, $10, $08, $00    ; 60 <
    DEFB $00, $00, $7C, $00, $7C, $00, $00, $00    ; 61 =
    DEFB $20, $10, $08, $04, $08, $10, $20, $00    ; 62 >
    DEFB $38, $44, $04, $08, $10, $00, $10, $00    ; 63 ?
    DEFB $38, $44, $5C, $54, $5C, $40, $38, $00    ; 64 @
    DEFB $38, $44, $44, $7C, $44, $44, $44, $00    ; 65 A
    DEFB $78, $44, $44, $78, $44, $44, $78, $00    ; 66 B
    DEFB $38, $44, $40, $40, $40, $44, $38, $00    ; 67 C
    DEFB $70, $48, $44, $44, $44, $48, $70, $00    ; 68 D
    DEFB $7C, $40, $40, $78, $40, $40, $7C, $00    ; 69 E
    DEFB $7C, $40, $40, $78, $40, $40, $40, $00    ; 70 F
    DEFB $38, $44, $40, $5C, $44, $44, $38, $00    ; 71 G
    DEFB $44, $44, $44, $7C, $44, $44, $44, $00    ; 72 H
    DEFB $38, $10, $10, $10, $10, $10, $38, $00    ; 73 I
    DEFB $1C, $08, $08, $08, $08, $48, $30, $00    ; 74 J
    DEFB $44, $48, $50, $60, $50, $48, $44, $00    ; 75 K
    DEFB $40, $40, $40, $40, $40, $40, $7C, $00    ; 76 L
    DEFB $44, $6C, $54, $54, $44, $44, $44, $00    ; 77 M
    DEFB $44, $64, $54, $4C, $44, $44, $44, $00    ; 78 N
    DEFB $38, $44, $44, $44, $44, $44, $38, $00    ; 79 O
    DEFB $78, $44, $44, $78, $40, $40, $40, $00    ; 80 P
    DEFB $38, $44, $44, $44, $54, $48, $34, $00    ; 81 Q
    DEFB $78, $44, $44, $78, $50, $48, $44, $00    ; 82 R
    DEFB $3C, $40, $40, $38, $04, $04, $78, $00    ; 83 S
    DEFB $7C, $10, $10, $10, $10, $10, $10, $00    ; 84 T
    DEFB $44, $44, $44, $44, $44, $44, $38, $00    ; 85 U
    DEFB $44, $44, $44, $44, $44, $28, $10, $00    ; 86 V
    DEFB $44, $44, $44, $54, $54, $6C, $44, $00    ; 87 W
    DEFB $44, $44, $28, $10, $28, $44, $44, $00    ; 88 X
    DEFB $44, $44, $28, $10, $10, $10, $10, $00    ; 89 Y
    DEFB $7C, $04, $08, $10, $20, $40, $7C, $00    ; 90 Z
    DEFB $38, $20, $20, $20, $20, $20, $38, $00    ; 91 [
    DEFB $40, $20, $20, $10, $08, $08, $04, $00    ; 92
    DEFB $38, $08, $08, $08, $08, $08, $38, $00    ; 93 ]
    DEFB $10, $28, $44, $00, $00, $00, $00, $00    ; 94 ^
    DEFB $00, $00, $00, $00, $00, $00, $00, $7C    ; 95 _
    DEFB $20, $10, $08, $00, $00, $00, $00, $00    ; 96 `
    DEFB $00, $00, $38, $04, $3C, $44, $3C, $00    ; 97 a
    DEFB $40, $40, $78, $44, $44, $44, $78, $00    ; 98 b
    DEFB $00, $00, $38, $40, $40, $44, $38, $00    ; 99 c
    DEFB $04, $04, $3C, $44, $44, $44, $3C, $00    ; 100 d
    DEFB $00, $00, $38, $44, $7C, $40, $38, $00    ; 101 e
    DEFB $18, $24, $20, $70, $20, $20, $20, $00    ; 102 f
    DEFB $00, $00, $3C, $44, $44, $3C, $04, $38    ; 103 g
    DEFB $40, $40, $78, $44, $44, $44, $44, $00    ; 104 h
    DEFB $10, $00, $30, $10, $10, $10, $38, $00    ; 105 i
    DEFB $08, $00, $18, $08, $08, $08, $48, $30    ; 106 j
    DEFB $40, $40, $48, $50, $60, $50, $48, $00    ; 107 k
    DEFB $30, $10, $10, $10, $10, $10, $38, $00    ; 108 l
    DEFB $00, $00, $68, $54, $54, $54, $54, $00    ; 109 m
    DEFB $00, $00, $78, $44, $44, $44, $44, $00    ; 110 n
    DEFB $00, $00, $38, $44, $44, $44, $38, $00    ; 111 o
    DEFB $00, $00, $78, $44, $44, $78, $40, $40    ; 112 p
    DEFB $00, $00, $3C, $44, $44, $3C, $04, $04    ; 113 q
    DEFB $00, $00, $58, $64, $40, $40, $40, $00    ; 114 r
    DEFB $00, $00, $3C, $40, $38, $04, $78, $00    ; 115 s
    DEFB $20, $20, $70, $20, $20, $24, $18, $00    ; 116 t
    DEFB $00, $00, $44, $44, $44, $44, $3C, $00    ; 117 u
    DEFB $00, $00, $44, $44, $44, $28, $10, $00    ; 118 v
    DEFB $00, $00, $44, $44, $54, $54, $28, $00    ; 119 w
    DEFB $00, $00, $44, $28, $10, $28, $44, $00    ; 120 x
    DEFB $00, $00, $44, $44, $44, $3C, $04, $38    ; 121 y
    DEFB $00, $00, $7C, $08, $10, $20, $7C, $00    ; 122 z
    DEFB $18, $20, $20, $40, $20, $20, $18, $00    ; 123 {
    DEFB $10, $10, $10, $10, $10, $10, $10, $00    ; 124 |
    DEFB $30, $08, $08, $04, $08, $08, $30, $00    ; 125 }
    DEFB $00, $34, $58, $00, $00, $00, $00, $00    ; 126 ~
    DEFB $7C, $44, $44, $44, $44, $44, $7C, $00    ; 127
    DEFS 1024                               ; 128-255: filled in at start-up
#else
    DEFS 1792                               ; copied from the lower ROM at start-up
#endif

; CPC_INIT_11_GLYPHS -- runs after bareboot.asm's CPC_INIT_00_BOOTSTRAP
; and txtbare.asm's CPC_INIT_10_TEXT (mode 1, screen cleared, private block
; set up, draw tables). Fills the glyph table, sets CHARS/UDG.
; Registers clobbered: AF, BC, DE, HL.
CPC_INIT_11_GLYPHS:
    PROC
    LOCAL __CT_BLK, __CT_FILL4, __CT_TQ

    ld   hl, __BT_PUTC
    ld   (__BT_PUTC_VEC), hl
    ld   hl, __CPC_FONT - 256
    ld   (CHARS), hl
    ld   hl, __CPC_FONT + (144 - 32) * 8
    ld   (UDG), hl

#ifndef CPC_OWNFONT
    ; the font: lower ROM &3900-&3FFF (characters 32-255) -> the table
    ld   hl, __BT_TRAMP
    ld   de, BT_TRAMP
    ld   bc, __BT_TRAMP_END - __BT_TRAMP
    ldir
    call BT_TRAMP
#else
    ; UDG 144-164 start as copies of A-U (as on the Spectrum)
    ld   hl, __CPC_FONT + ('A' - 32) * 8
    ld   de, __CPC_FONT + (144 - 32) * 8
    ld   bc, 21 * 8
    ldir
#endif

    ; block graphics 128-143 (Spectrum numbering): top half from bits 0-1
    ; (1 = right, 2 = left), bottom half from bits 2-3
    ld   hl, __CPC_FONT + (128 - 32) * 8
    ld   c, 0
__CT_BLK:
    ld   a, c
    and  3
    call __CT_TQ
    call __CT_FILL4
    ld   a, c
    rrca
    rrca
    and  3
    call __CT_TQ
    call __CT_FILL4
    inc  c
    ld   a, c
    cp   16
    jr   nz, __CT_BLK

    ret

__CT_TQ:                    ; A = 0-3 (bit 0 right, bit 1 left) -> A = half row byte
    ld   e, a
    ld   d, 0
    push hl
    ld   hl, __CT_TQTAB
    add  hl, de
    ld   a, (hl)
    pop  hl
    ret
__CT_TQTAB:
    DEFB $00, $0F, $F0, $FF
__CT_FILL4:                 ; A written to (HL) four times
    ld   (hl), a
    inc  hl
    ld   (hl), a
    inc  hl
    ld   (hl), a
    inc  hl
    ld   (hl), a
    inc  hl
    ret
    ENDP

#ifndef CPC_OWNFONT
; The font copy, run from the private block (BT_TRAMP) because the lower
; ROM replaces the code at &0040-&3FFF while it is paged in. Gate Array
; &89 = mode 1, upper ROM off, lower ROM ON; &8D = both off (boot mode 1).
; Interrupts are off while the ROM is in and on again afterwards (the
; start-up runs with them on). Position independent (no relative jumps).
__BT_TRAMP:
    di
    ld   bc, $7F89
    out  (c), c
    ld   hl, $3900
    ld   de, __CPC_FONT
    ld   bc, 1792
    ldir
    ld   bc, $7F8D
    out  (c), c
    ei
    ret
__BT_TRAMP_END:
#endif

; __BT_LF -- next row. Like the firmware's, the scroll is lazy: a line feed
; on the last row (24) only moves the cursor to row 25, below the screen;
; the screen scrolls when the next character is drawn there (or on another
; line feed with the cursor already on row 25). Keeps the column.
; Registers clobbered: AF (and BC, DE, HL when it scrolls).
__BT_LF:
    ld   a, (S_POSN + 1)
    cp   SCR_ROWS
    jp   nc, __BT_SCROLL    ; already on row 25: scroll, stay there
    inc  a
    ld   (S_POSN + 1), a
    ret

; __BT_SCROLL -- moves the 24 lower text rows up one row and fills the
; last row with BT_FILL (the paper). The screen is eight 2 KB pages of one
; pixel line per character row each (&800 apart): each is moved by 80
; bytes. Interruptible. About 60 ms for the 15360 bytes (the firmware scrolls
; with the CRTC start address; this costs more but leaves the screen base
; alone, which the graphics routines and libraries rely on).
; Registers clobbered: AF, BC, DE, HL.
__BT_SCROLL:
    PROC
    LOCAL __BS_PAGE, __BS_COPY
    ld   a, (SCREEN_ADDR + 1)
    ld   d, a
    ld   h, a
    ld   e, 0
    ld   l, 80              ; HL = source (row 1), DE = destination (row 0)
    ld   b, 8
__BS_PAGE:
    push bc
    push hl
    push de
    ld   bc, 24 * 80
__BS_COPY:                  ; 16 LDIs per pass (4 NOPs a byte on the CPC against
    ldi                     ; LDIR's 6); 1920 is a multiple of 16
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    jp   pe, __BS_COPY      ; BC <> 0; DE ends at the last row's line
    ld   a, (BT_FILL)
    ld   (de), a
    ld   h, d
    ld   l, e
    inc  de
    ld   bc, 79
    ldir
    pop  de
    pop  hl
    ld   a, h
    add  a, 8
    ld   h, a
    ld   a, d
    add  a, 8
    ld   d, a
    pop  bc
    djnz __BS_PAGE
    ret
    ENDP

; __BT_PUTC -- A = character. 13 = CR, 10 = LF, 32-255 drawn at the cursor
; (a pending wrap is resolved first), then the cursor moves right; other
; codes are ignored. The glyph comes from the table (the glyph of
; character c is at __CPC_FONT + (c - 32) * 8) and is written whole, the
; unset pixels in the paper pen, one pixel line at a time (&800 apart).
; The cursor row may be 25 (a pending scroll, see __BT_LF).
; Registers clobbered: AF, BC, DE, HL.
__BT_PUTC:
    PROC
    LOCAL __BP_DRAW, __BP_NOWRAP, __BP_ONSCREEN

    cp   32
    jr   nc, __BP_DRAW
    cp   13
    jp   z, __BT_CR
    cp   10
    jp   z, __BT_LF
    ret

__BP_DRAW:
    push af
    ld   a, (TXT_COLS)
    ld   hl, S_POSN
    cp   (hl)
    jr   c, __BP_WRAP       ; column > TXT_COLS (should not happen): wrap too, don't run off the screen
    jr   nz, __BP_NOWRAP    ; column < TXT_COLS: no wrap pending
__BP_WRAP:
    call __BT_CR
    call __BT_LF
__BP_NOWRAP:
    ld   a, (S_POSN + 1)
    cp   SCR_ROWS
    jr   c, __BP_ONSCREEN   ; a line feed left the cursor on row 25: scroll now
    call __BT_SCROLL
    ld   a, SCR_ROWS - 1
    ld   (S_POSN + 1), a
__BP_ONSCREEN:
    pop  af
    ld   l, a
    ld   h, 0
    add  hl, hl
    add  hl, hl
    add  hl, hl             ; char * 8
    ld   bc, __CPC_FONT - 256
    add  hl, bc
    push hl                 ; the glyph
    ld   de, (S_POSN)       ; E = column, D = row
    call __BT_CELLADDR      ; HL = screen address
    pop  bc                 ; BC = glyph
    ld   a, (S_POSN)
    inc  a
    ld   (S_POSN), a        ; cursor right (TXT_COLS = wrap pending)
    jp   __BT_DRAW
    ENDP

; ---- SCREEN$ ---------------------------------------------------------------
; __BT_RDCHAR -- D = row (0-24), E = column (0 to TXT_COLS-1) -> A =
; character code, carry set if the cell holds a recognisable character.
; The cell is decoded into pen numbers; a cell holds at most two pens (more
; = not recognised). The paper is the permanent PAPER's pen when the cell
; has it, else the pen at the cell's top left pixel; the pixels in the
; other pen are the glyph. It is matched against the table from character
; 32 up (so a blank cell reads as 32, a full one as 143), then with the
; glyph inverted (INVERSE text). A cell with one pen only reads as a space,
; unless it is the permanent INK's pen (then 143). Unlike the firmware's
; TXT_RD_CHAR, a cell printed in colours other than the permanent ones is
; read through its own two pens, so it reads back correctly (as on the
; Spectrum, whose SCREEN$ ignores colours). Pixels drawn over a character
; make it unrecognisable.
; Registers clobbered: AF, BC, DE, HL (and BC', DE', HL').
__BT_RDCHAR:
    PROC
    LOCAL __RC_ROW, __RC_DEC, __RC_BYTE, __RC_PIX, __RC_P1, __RC_P2, __RC_P3, __RC_P4
    LOCAL __RC_SCAN, __RC_NEXT, __RC_FAIL, __RC_UNI_SP, __RC_2PEN
    LOCAL __RC_PAPER_OK, __RC_ROW2, __RC_PX, __RC_FIND, __RF_CHAR, __RF_CMP, __RF_NEXT

    call __BT_CELLADDR
    ld   de, BT_PIX
    ld   b, 8
__RC_ROW:
    push bc
    push hl
    call __RC_DEC           ; one pixel line -> 8 pen numbers at (DE)
    pop  hl
    ld   a, h
    add  a, 8
    ld   h, a
    pop  bc
    djnz __RC_ROW

    ; the (at most two) pens: B = the first pixel's, C = the other (= B if none)
    ld   hl, BT_PIX
    ld   a, (hl)
    ld   b, a
    ld   c, a
    ld   d, 64
__RC_SCAN:
    ld   a, (hl)
    inc  hl
    cp   b
    jr   z, __RC_NEXT
    cp   c
    jr   z, __RC_NEXT
    ld   e, a               ; a pen that is neither: the second, if none yet
    ld   a, b
    cp   c
    jr   nz, __RC_FAIL      ; two already: a third pen
    ld   c, e
__RC_NEXT:
    dec  d
    jr   nz, __RC_SCAN

    ld   a, (ATTR_P)
    rrca
    rrca
    rrca
    call __INK_TO_PEN
    ld   d, a               ; D = the permanent paper's pen
    ld   a, (ATTR_P)
    call __INK_TO_PEN
    ld   e, a               ; E = the permanent ink's pen

    ld   a, b
    cp   c
    jr   nz, __RC_2PEN
    ; one pen only: a space, or a full block if it is the ink's pen
    cp   d
    jr   z, __RC_UNI_SP
    cp   e
    jr   nz, __RC_UNI_SP
    ld   a, 143
    scf
    ret
__RC_UNI_SP:
    ld   a, 32
    scf
    ret

__RC_2PEN:                  ; B, C differ: make B the paper, C the ink
    ld   a, c
    cp   d
    jr   nz, __RC_PAPER_OK  ; C is not the paper pen (B is, or neither: B)
    ld   c, b
    ld   b, a               ; swap: B = paper pen, C = the other
__RC_PAPER_OK:
    ; glyph bitmap into BT_BUF: a bit is set where the pixel is the ink (C)
    exx
    ld   hl, BT_BUF
    ld   b, 8
    exx
    ld   hl, BT_PIX
__RC_ROW2:
    ld   b, 8
    ld   d, 0
__RC_PX:
    ld   a, (hl)
    inc  hl
    xor  c
    sub  1                  ; carry = this pixel is the ink
    rl   d
    djnz __RC_PX
    ld   a, d
    exx
    ld   (hl), a
    inc  hl
    dec  b
    exx
    jr   nz, __RC_ROW2
    ld   b, 0
    call __RC_FIND
    ret  c
    ld   b, $FF             ; INVERSE text: the glyph's complement
    jp   __RC_FIND

__RC_FAIL:
    xor  a
    ret

; __RC_FIND -- B = xor mask for the bitmap (0 or &FF): A = the first
; character 32-255 whose glyph equals it, carry set; carry clear if none.
__RC_FIND:
    ld   hl, __CPC_FONT
    ld   c, 32
__RF_CHAR:
    ld   de, BT_BUF
__RF_CMP:
    ld   a, (de)
    xor  b
    cp   (hl)
    jr   nz, __RF_NEXT
    inc  hl
    inc  de
    ld   a, l
    and  7
    jr   nz, __RF_CMP
    ld   a, c
    scf
    ret
__RF_NEXT:
    ld   a, l
    or   7
    ld   l, a
    inc  hl                 ; the next glyph (the table is 8-byte aligned)
    inc  c
    jr   nz, __RF_CHAR
    xor  a
    ret

; __RC_DEC -- HL = a pixel line of the cell, DE = destination: writes the
; line's 8 pen numbers (one byte each) at (DE) and advances DE by 8.
; Pixel pens in a byte: bit 7 is pen bit 0 of the leftmost pixel, then bits
; 3, 5, 1 are pen bits 1, 2, 3 (mode 0; mode 1 uses bits 7/3, mode 2 bit 7),
; and shifting the byte left moves the next pixel into place.
__RC_DEC:
    exx
    ld   a, (BT_BPC)
    ld   b, a               ; B' = bytes in the line
    ld   a, (BT_MASK)
    ld   c, a               ; C' = pen mask
    exx
__RC_BYTE:
    ld   c, (hl)
    inc  hl
    ld   a, (BT_PPB)
    ld   b, a               ; B = pixels in this byte
__RC_PIX:
    xor  a
    bit  7, c
    jr   z, __RC_P1
    or   1
__RC_P1:
    bit  3, c
    jr   z, __RC_P2
    or   2
__RC_P2:
    bit  5, c
    jr   z, __RC_P3
    or   4
__RC_P3:
    bit  1, c
    jr   z, __RC_P4
    or   8
__RC_P4:
    exx
    and  c
    exx
    ld   (de), a
    inc  de
    sla  c
    djnz __RC_PIX
    exx
    dec  b
    exx
    jr   nz, __RC_BYTE
    ret
    ENDP


    pop namespace

#endif
