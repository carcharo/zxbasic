; -----------------------------------------------------------------------
; Amstrad CPC bare-metal text output (-D CPC_BAREMETAL, Phase 6 B2)
;
; Written from scratch for this project (MIT). Draws 8x8 glyphs straight
; into screen memory, with no firmware, with the same behaviour and
; appearance as the firmware's text in firmware mode:
;   - a character cell is 8 mode pixels wide in every mode: 4 bytes in
;     mode 0 (20 columns), 2 in mode 1 (40), 1 in mode 2 (80); 25 rows;
;   - ink and paper are pens of the current mode (colour.asm's pen map),
;     INVERSE swaps them, and the cell is written whole (paper in the
;     unset pixels), so there is no transparency; OVER and the
;     BOLD/ITALIC/FLASH/BRIGHT attributes are accepted and ignored for
;     text, exactly as in firmware mode;
;   - the cursor wraps lazily: after the last column's character the
;     column is TXT_COLS (a wrap pending), and the next character, CR or
;     LF resolves it, like the firmware's;
;   - a line feed on the bottom row moves the cursor to row 25 (below the
;     screen); the next character drawn there scrolls the screen up 8 lines
;     first (a software scroll, so the CRTC start address is never touched)
;     and clears the new row to the paper pen -- the firmware is lazy too;
; The renderer assumes the CRTC screen start is the SCREEN_ADDR page with
; no hardware-scroll offset (bareboot.asm programs it that way).
;
; Entry points (all in namespace core):
;   __BT_PUTC      A = character: 13 CR, 10 LF, 32-255 drawn at the cursor
;                  (other codes ignored). Clobbers AF, BC, DE, HL.
;   __BT_CR/__BT_LF  carriage return / line feed (LF scrolls at the bottom).
;   __BT_CLEAR     A = screen byte to fill with; clears the screen (the 25
;                  text rows only) and homes the cursor.
;   __BT_PENMASKS  recomputes the draw tables from ATTR_T and the temporary
;                  INVERSE bit of P_FLAG (copy_attr.asm calls it).
;   __BT_SET_MODE  A = mode 0-3: Gate Array mode, pen map and widths,
;                  tables, clear to PAPER, cursor home (cpc.bas Mode).
;   __BT_RDCHAR    D = row, E = column: the character in that cell
;                  (SCREEN$): A = code, carry set if recognised.
;   __CPC_FONT     the glyph table: characters 32-255, 8 bytes each (1792
;                  bytes), 8-byte aligned. CHARS = __CPC_FONT - 256 and
;                  UDG = the glyph of character 144, as on the Spectrum, so
;                  POKE USR "a"+n, SetFont and PRINT CHR$ 128-255 all work.
; Hardware touched: the Gate Array's mode register (&7Fxx) in
; __BT_SET_MODE and, once at start-up, with the lower ROM paged in to copy
; the font; screen memory. No firmware is called.
;
; Font: on a disc boot (the firmware ran first) the CPC's own font is in
; the lower ROM at &3800 (characters 0-255, 8 bytes each); characters 32-255
; are copied into the glyph table at start-up by a 25-byte routine that
; runs from the private block (so it is not itself paged out) with
; interrupts off, which keeps bare text pixel-identical to firmware text.
; Build with -D CPC_OWNFONT for a cold start (a cartridge: the lower ROM
; is not the CPC firmware): the table then holds a bundled font instead
; (below), characters 32-127, with the Spectrum block graphics 128-143
; generated and UDG 144-164 starting as copies of A-U. Characters 144-255
; are blank in that case, except the UDGs.
; Block graphics 128-143 are always generated, in the Spectrum's numbering
; (bit 0 top right, 1 top left, 2 bottom right, 3 bottom left), so no
; translation is needed anywhere.
;
; Memory: 1792 bytes of glyph table in the program image (plus 768
; bytes less zero fill with CPC_OWNFONT: the font data is the table), about
; 700 bytes of code; sysvars in the private block (see sysvars.asm).
; -----------------------------------------------------------------------
;
; Phase 6 B6 split: this file is the part every bare program that sets a
; mode, clears the screen or sets attributes needs (cpc.bas Mode, CLS, the
; pen tables) -- about 0.8 KB. The glyph table, the text cursor's line feed
; and scroll, __BT_PUTC and SCREEN$ (__BT_RDCHAR) are in txtglyph.asm,
; which print.asm, udg.asm, stdlib/font.bas and stdlib/screen.bas include;
; a program that never prints no longer carries the 1.8 KB font. A runtime
; error draws "Error n" with its own 14-glyph font (error.asm) through
; __BT_DRAW below.
; -----------------------------------------------------------------------

#ifdef CPC_BAREMETAL

#include once <sysvars.asm>
#include once <colour.asm>

#init .core.CPC_INIT_10_TEXT

    push namespace core

; The glyph renderer's address, 0 until txtglyph.asm's start-up sets it:
; error.asm draws "Error n" with __BT_PUTC when the program has the glyph
; table (same output as PRINT), else with its own mini font.
__BT_PUTC_VEC:
    DEFW 0

; ---- start-up ------------------------------------------------------------
; CPC_INIT_10_TEXT -- runs after bareboot.asm's CPC_INIT_00_BOOTSTRAP
; (mode 1, screen cleared, private block set up): the mode variables and
; the draw tables for the default attribute. (The glyph table is
; txtglyph.asm's.) Registers clobbered: AF, BC, DE, HL.
CPC_INIT_10_TEXT:
    ld   a, 1
    call __BT_MODE_VARS      ; BT_MODE = 1 and the width variables
    ; the draw tables for the default attributes (ATTR_P: INK 7 / PAPER 0)
    ld   a, (ATTR_P)
    ld   (ATTR_T), a
    jp   __BT_PENMASKS

; ---- mode variables ------------------------------------------------------
; __BT_MODE_VARS -- A = mode: BT_MODE, and the width variables derived
; from the mode's pen depth: bytes per glyph row, pixels per byte, pen mask.
; Registers clobbered: AF, BC.
__BT_MODE_VARS:
    PROC
    LOCAL __BMV_M1, __BMV_M2, __BMV_SET
    and  3
    ld   (BT_MODE), a
    cp   1
    jr   z, __BMV_M1
    cp   2
    jr   z, __BMV_M2
    ld   bc, $0F02          ; mode 0 and 3: 4 bytes, 2 pixels, pens 0-15
    ld   a, 4
    jr   __BMV_SET
__BMV_M1:
    ld   bc, $0304
    ld   a, 2
    jr   __BMV_SET
__BMV_M2:
    ld   bc, $0108
    ld   a, 1
__BMV_SET:
    ld   (BT_BPC), a
    ld   a, c
    ld   (BT_PPB), a
    ld   a, b
    ld   (BT_MASK), a
    ret
    ENDP

; __BT_SET_MODE -- A = mode 0-3. Gate Array mode (the ROMs stay off), pen
; map and widths, draw tables, screen cleared to PAPER, cursor home.
; Registers clobbered: AF, BC, DE, HL.
__BT_SET_MODE:
    and  3
    push af
    or   $8C                ; lower and upper ROM off, mode in bits 0-1
    ld   c, a
    ld   b, $7F
    out  (c), c
    pop  af
    push af
    call __CPC_SET_MODE_VARS ; pen map, GFX_XSHIFT, TXT_COLS
    pop  af
    call __BT_MODE_VARS
    call __BT_PENMASKS
    ; CLS clears to the permanent PAPER
    ld   a, (ATTR_P)
    rrca
    rrca
    rrca
    call __INK_TO_PEN
    call __BT_PENMASK
    jp   __BT_CLEAR

; ---- pens -> screen bytes ------------------------------------------------
; __BT_PENMASK -- A = pen -> A = the screen byte with every pixel of the
; current mode set to that pen (mode 2: &00/&FF; mode 1: plane bits
; &F0 and &0F; mode 0: &C0, &0C, &30, &03 for pen bits 0-3).
; Registers clobbered: AF, D.
__BT_PENMASK:
    PROC
    LOCAL __BPM_M1, __BPM_M2, __BPM_1, __BPM_2, __BPM_3, __BPM_4
    ld   d, a
    ld   a, (BT_BPC)
    cp   1
    jr   z, __BPM_M2
    cp   2
    jr   z, __BPM_M1
    xor  a                  ; mode 0
    bit  0, d
    jr   z, __BPM_1
    or   $C0
__BPM_1:
    bit  1, d
    jr   z, __BPM_2
    or   $0C
__BPM_2:
    bit  2, d
    jr   z, __BPM_3
    or   $30
__BPM_3:
    bit  3, d
    ret  z
    or   $03
    ret
__BPM_M1:
    xor  a
    bit  0, d
    jr   z, __BPM_4
    or   $F0
__BPM_4:
    bit  1, d
    ret  z
    or   $0F
    ret
__BPM_M2:
    ld   a, d
    and  1
    neg
    ret
    ENDP

; __BT_PENMASKS -- from ATTR_T (ink bits 0-2, paper bits 3-5, Spectrum
; colours) and the temporary INVERSE bit (P_FLAG bit 2): works out the ink
; and paper screen bytes (Mi, Mp) and fills the draw tables. A glyph byte S
; (its bits spread over the pixels of one screen byte) becomes
; (S & Mi) | (~S & Mp) = Mp ^ (S & (Mi ^ Mp)):
;   mode 2: BT_MX = Mi ^ Mp, BT_MP = Mp (the loop computes it);
;   mode 1: BT_TBL[n] for a glyph nibble n (S = n*17);
;   mode 0: BT_TBL[p] for a glyph bit pair p (S = 0, &55, &AA, &FF).
; BT_FILL = Mp, the screen byte of an all-paper row.
; Registers clobbered: none (AF, BC, DE, HL preserved).
__BT_PENMASKS:
    PROC
    LOCAL __BPS_NOINV, __BPS_M2, __BPS_M1, __BPS_M1L, __BPS_DONE

    push af
    push bc
    push de
    push hl
    ld   a, (ATTR_T)
    call __INK_TO_PEN
    call __BT_PENMASK
    ld   b, a               ; B = Mi
    ld   a, (ATTR_T)
    rrca
    rrca
    rrca
    call __INK_TO_PEN
    call __BT_PENMASK
    ld   c, a               ; C = Mp
    ld   a, (P_FLAG)
    and  4
    jr   z, __BPS_NOINV
    ld   a, b
    ld   b, c
    ld   c, a
__BPS_NOINV:
    ld   a, c
    ld   (BT_FILL), a
    ld   a, b
    xor  c
    ld   d, a               ; D = Mi ^ Mp
    ld   a, (BT_BPC)
    cp   1
    jr   z, __BPS_M2
    cp   2
    jr   z, __BPS_M1
    ld   hl, BT_TBL         ; mode 0: four entries
    xor  a
    and  d
    xor  c
    ld   (hl), a
    inc  hl
    ld   a, $55
    and  d
    xor  c
    ld   (hl), a
    inc  hl
    ld   a, $AA
    and  d
    xor  c
    ld   (hl), a
    inc  hl
    ld   a, $FF
    and  d
    xor  c
    ld   (hl), a
    jr   __BPS_DONE
__BPS_M2:
    ld   a, d
    ld   (BT_MX), a
    ld   a, c
    ld   (BT_MP), a
    jr   __BPS_DONE
__BPS_M1:                   ; mode 1: sixteen entries
    ld   hl, BT_TBL
    ld   b, 0
__BPS_M1L:
    ld   a, b
    ld   e, a
    rlca
    rlca
    rlca
    rlca
    or   e                  ; S = n*17
    and  d
    xor  c
    ld   (hl), a
    inc  hl
    inc  b
    ld   a, b
    cp   16
    jr   nz, __BPS_M1L
__BPS_DONE:
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret
    ENDP

; ---- cursor and text -----------------------------------------------------
; The cursor is S_POSN: low byte = column (0 to TXT_COLS; TXT_COLS is the
; pending wrap), high byte = row (0-24).

; __BT_CR -- column 0. Registers clobbered: AF.
__BT_CR:
    xor  a
    ld   (S_POSN), a
    ret

; __BT_CLEAR -- A = fill byte. Fills the 25 text rows of the screen and
; homes the cursor (the 384 spare bytes between the rows' lines are left
; alone). Registers clobbered: AF, BC, HL, DE.
__BT_CLEAR:
    PROC
    LOCAL __BC_PAGE
    ld   c, a
    ld   a, (SCREEN_ADDR + 1)
    ld   h, a
    ld   l, 0
    ld   b, 8
__BC_PAGE:
    push bc
    ld   (hl), c
    ld   d, h
    ld   e, l
    inc  de
    ld   bc, 25 * 80 - 1
    ldir
    ld   de, $0800 - (25 * 80 - 1)
    add  hl, de             ; HL was start + 1999: next page's start
    pop  bc
    djnz __BC_PAGE
    ld   hl, 0
    ld   (S_POSN), hl
    ret
    ENDP

; __BT_CELLADDR -- D = row (0-24), E = column -> HL = address of the
; cell's top pixel line (SCREEN_ADDR page + row * 80 + column * bytes per
; cell). Registers clobbered: AF, BC, DE.
__BT_CELLADDR:
    PROC
    LOCAL __BCA_SHIFT, __BCA_DONE
    ld   l, d
    ld   h, 0
    ld   c, l
    ld   b, h               ; BC = row
    add  hl, hl
    add  hl, hl
    add  hl, bc             ; 5 * row
    add  hl, hl
    add  hl, hl
    add  hl, hl
    add  hl, hl             ; 80 * row (at most 1920)
    ld   a, (BT_BPC)
    ld   b, a
    ld   a, e
__BCA_SHIFT:
    srl  b
    jr   z, __BCA_DONE
    add  a, a               ; bytes per cell 4 -> x4, 2 -> x2, 1 -> x1
    jr   __BCA_SHIFT
__BCA_DONE:
    ld   e, a
    ld   d, 0
    add  hl, de
    ld   a, (SCREEN_ADDR + 1)
    add  a, h
    ld   h, a
    ret
    ENDP

; __BT_DRAW -- BC = a glyph (8 bytes, 8-aligned: the loops end a glyph on
; C & 7 = 0), HL = the cell's top-left screen address: writes the glyph
; whole, the unset pixels in the paper pen, one pixel line at a time (&800
; apart), in the current mode. Used by __BT_PUTC and by the error screen's
; own mini font (error.asm).
; Registers clobbered: AF, BC, DE, HL.
__BT_DRAW:
    PROC
    LOCAL __BP_M1, __BP_M2, __BP_ROW0, __BP_ROW1, __BP_ROW2
    ld   a, (BT_BPC)
    cp   2
    jr   z, __BP_M1
    jr   c, __BP_M2

    ; ---- mode 0 (and 3): 4 bytes per row, a table entry per bit pair
    ld   d, BT_TBL >> 8
__BP_ROW0:
    ld   a, (bc)
    rlca
    rlca
    and  3
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    inc  hl
    ld   a, (bc)
    rrca
    rrca
    rrca
    rrca
    and  3
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    inc  hl
    ld   a, (bc)
    rrca
    rrca
    and  3
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    inc  hl
    ld   a, (bc)
    inc  bc
    and  3
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    dec  hl
    dec  hl
    dec  hl
    ld   a, h
    add  a, 8
    ld   h, a
    ld   a, c
    and  7
    jr   nz, __BP_ROW0
    ret

    ; ---- mode 1: 2 bytes per row, a table entry per glyph nibble
__BP_M1:
    ld   d, BT_TBL >> 8
__BP_ROW1:
    ld   a, (bc)
    rrca
    rrca
    rrca
    rrca
    and  15
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    inc  hl
    ld   a, (bc)
    inc  bc
    and  15
    ld   e, a
    ld   a, (de)
    ld   (hl), a
    dec  hl
    ld   a, h
    add  a, 8
    ld   h, a
    ld   a, c
    and  7
    jr   nz, __BP_ROW1
    ret

    ; ---- mode 2: 1 byte per row, Mp ^ (glyph & (Mi ^ Mp))
__BP_M2:
    ld   a, (BT_MX)
    ld   d, a
    ld   a, (BT_MP)
    ld   e, a
__BP_ROW2:
    ld   a, (bc)
    inc  bc
    and  d
    xor  e
    ld   (hl), a
    ld   a, h
    add  a, 8
    ld   h, a
    ld   a, c
    and  7
    jr   nz, __BP_ROW2
    ret
    ENDP

    pop namespace

#endif
