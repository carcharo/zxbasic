	org 64
	.core.CPC_PRIV_BASE EQU 40448
	.core.CPC_PRIV_SIZE EQU 1024
	.core.CPC_STACK_TOP EQU 42496
	.core.CPC_MEM_TOP EQU 42619
.core.__START_PROGRAM:
	di
	ld sp, .core.CPC_STACK_TOP
	call .core.CPC_INIT_00_BOOTSTRAP
	jp .core.__MAIN_PROGRAM__
.core.ZXBASIC_USER_DATA:
	; Defines USER DATA Length in bytes
.core.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_END - .core.ZXBASIC_USER_DATA
	.core.__LABEL__.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_LEN
	.core.__LABEL__.ZXBASIC_USER_DATA EQU .core.ZXBASIC_USER_DATA
_a:
	DEFB 00, 00, 00, 00
_b:
	DEFB 00, 00, 00, 00
_c:
	DEFB 00, 00, 00, 00
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	ld de, 1
	ld hl, 34464
	ld (_a), hl
	ld (_a + 2), de
	ld de, 0
	ld hl, 7
	ld (_b), hl
	ld (_b + 2), de
	ld hl, (_a + 2)
	push hl
	ld hl, (_a)
	push hl
	ld hl, (_b)
	ld de, (_b + 2)
	call .core.__SWAP32
	call .core.__DIVU32
	ld (_c), hl
	ld (_c + 2), de
	call .core.COPY_ATTR
	ld hl, (_c)
	ld de, (_c + 2)
	call .core.__PRINTU32
	ld hl, (_a + 2)
	push hl
	ld hl, (_a)
	push hl
	ld hl, (_b)
	ld de, (_b + 2)
	call .core.__SWAP32
	call .core.__MODU32
	call .core.__PRINTU32
	call .core.PRINT_EOL
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	jp .core.__CPC_END
	;; --- end of user code ---
#line 1 "src/lib/arch/zx48k/runtime/arith/div32.asm"
#line 1 "src/lib/arch/zx48k/runtime/neg32.asm"
	    push namespace core
__ABS32:
	    bit 7, d
	    ret z
__NEG32: ; Negates DEHL (Two's complement)
	    ld a, l
	    cpl
	    ld l, a
	    ld a, h
	    cpl
	    ld h, a
	    ld a, e
	    cpl
	    ld e, a
	    ld a, d
	    cpl
	    ld d, a
	    inc l
	    ret nz
	    inc h
	    ret nz
	    inc de
	    ret
	    pop namespace
#line 2 "src/lib/arch/zx48k/runtime/arith/div32.asm"
	    ; ---------------------------------------------------------
	    push namespace core
__DIVU32:    ; 32 bit unsigned division
	    ; DEHL = Dividend, Stack Top = Divisor
	    ; OPERANDS P = Dividend, Q = Divisor => OPERATION => P / Q
	    ;
	    ; Changes A, BC DE HL B'C' D'E' H'L'
	    ; ---------------------------------------------------------
	    exx
	    pop hl   ; return address
	    pop de   ; low part
	    ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
__DIVU32START: ; Performs D'E'H'L' / HLDE
	    ; Now switch to DIVIDEND = B'C'BC / DIVISOR = D'E'DE (A / B)
	    push de ; push Lowpart(Q)
	    ex de, hl	; DE = HL
	    ld hl, 0
	    exx
	    ld b, h
	    ld c, l
	    pop hl
	    push de
	    ex de, hl
	    ld hl, 0        ; H'L'HL = 0
	    exx
	    pop bc          ; Pop HightPart(B) => B = B'C'BC
	    exx
	    ld a, 32 ; Loop count
__DIV32LOOP:
	    sll c  ; B'C'BC << 1 ; Output most left bit to carry
	    rl  b
	    exx
	    rl c
	    rl b
	    exx
	    adc hl, hl
	    exx
	    adc hl, hl
	    exx
	    sbc hl,de
	    exx
	    sbc hl,de
	    exx
	    jp nc, __DIV32NOADD	; use JP inside a loop for being faster
	    add hl, de
	    exx
	    adc hl, de
	    exx
	    dec bc
__DIV32NOADD:
	    dec a
	    jp nz, __DIV32LOOP	; use JP inside a loop for being faster
	    ; At this point, quotient is stored in B'C'BC and the reminder in H'L'HL
	    push hl
	    exx
	    pop de
	    ex de, hl ; D'E'H'L' = 32 bits modulus
	    push bc
	    exx
	    pop de    ; DE = B'C'
	    ld h, b
	    ld l, c   ; DEHL = quotient D'E'H'L' = Modulus
	    ret     ; DEHL = quotient, D'E'H'L' = Modulus
__MODU32:    ; 32 bit modulus for 32bit unsigned division
	    ; DEHL = Dividend, Stack Top = Divisor (DE, HL)
	    exx
	    pop hl   ; return address
	    pop de   ; low part
	    ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
	    call __DIVU32START	; At return, modulus is at D'E'H'L'
__MODU32START:
	    exx
	    push de
	    push hl
	    exx
	    pop hl
	    pop de
	    ret
__DIVI32:    ; 32 bit signed division
	    ; DEHL = Dividend, Stack Top = Divisor
	    ; A = Dividend, B = Divisor => A / B
	    exx
	    pop hl   ; return address
	    pop de   ; low part
	    ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
__DIVI32START:
	    exx
	    ld a, d	 ; Save sign
	    ex af, af'
	    bit 7, d ; Negative?
	    call nz, __NEG32 ; Negates DEHL
	    exx		; Now works with H'L'D'E'
	    ex af, af'
	    xor h
	    ex af, af'  ; Stores sign of the result for later
	    bit 7, h ; Negative?
	    ex de, hl ; HLDE = DEHL
	    call nz, __NEG32
	    ex de, hl
	    call __DIVU32START
	    ex af, af' ; Recovers sign
	    and 128	   ; positive?
	    ret z
	    jp __NEG32 ; Negates DEHL and returns from there
__MODI32:	; 32bits signed division modulus
	    exx
	    pop hl   ; return address
	    pop de   ; low part
	    ex (sp), hl ; CALLEE Convention ; H'L'D'E' => Dividend
	    call __DIVI32START
	    jp __MODU32START
	    pop namespace
#line 40 "tests/functional/arch/cpc/cpc_div32.bas"
#line 1 "src/lib/arch/cpc/runtime/bootstrap.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC bootstrap -- captures FW_BC, initialises the private
	; runtime block's sysvars, and sets the initial screen mode
	;
	; Registered with #init, so the compiler inserts
	; "call .core.CPC_INIT_00_BOOTSTRAP" in the prologue (src/arch/cpc/
	; backend/main.py's emit_prologue()).
	;
	; Forced into every program via common.REQUIRES (backend/main.py's
; Backend.init()) rather than pulled in transitively: this must run
	; even in programs with no PRINT/arrays/etc. that would otherwise never
	; #include sysvars.asm.
	;
; Naming: #init calls are emitted in sorted label order (sorted() over
	; the raw strings passed to every #init directive -- see
	; src/arch/z80/backend/main.py's emit_prologue and
	; src/zxbc/zxbparser.py's preproc_line_init). FW_BC must be captured from
	; the live BC' before anything else can disturb it (see fwcall.asm's
	; header), which means this routine must be the first #init call, full
	; stop -- not just first among the cpc runtime's own files, but first
	; against anything any future #include might add. ".core.CPC_INIT_FP_CALC"
	; (fp_calc.asm) would otherwise sort before ".core.CPC_INIT_SYSVARS" (F <
; S), so the routine is named CPC_INIT_00_BOOTSTRAP: the "00_" digit
	; prefix sorts before any plausible future "CPC_INIT_<LETTER>..." name
	; (digits are below uppercase letters in ASCII), which is a stronger
	; guarantee than just renaming past today's one clash. Nothing else
	; references the old CPC_INIT_SYSVARS name.
#line 33 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 1 "src/lib/arch/cpc/runtime/sysvars.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC system variables
	;
	; zx48k's own sysvars.asm and the runtime files ported from it hard-code
	; Spectrum sysvar addresses ($5C00-$5CB5), which are ordinary program RAM
	; on the CPC (inside the code/data area, $0040 up); using them as-is would
	; silently corrupt the compiled program. This file relocates them into the
	; private runtime block instead ($9E00-$A1FF, 1 KB -- see
	; .core.CPC_PRIV_BASE / CPC_PRIV_SIZE, emitted as EQUs by
	; src/arch/cpc/backend/main.py's prologue).
	;
	; This file only defines the *names and offsets*; CPC_INIT_00_BOOTSTRAP
	; (bootstrap.asm) fills them in at runtime.
	;
; Layout ($9E00 + offset), all byte offsets from SYSVAR_BASE:
	;
	;   Offset  Size  Name               Note
	;   ------  ----  -----------------  ---------------------------------
	;   $00     2     CHARS              pointer to charset (8x8 cells);
	;                                     unused by print.asm now (the
	;                                     firmware draws its own glyphs) but
	;                                     kept for zx48k source parity
	;   $02     2     UDG                pointer to UDG charset (ditto)
	;   $04     2     COORDS             last PLOT/graphics coords (X,Y)
	;   $06     1     FLAGS2             screen flags (OVER/BOLD/ITALIC)
	;   $07     1     ECHO_E             reserved, unused for now
	;   $08     2     DFCC               unused by print.asm now (no VRAM
	;                                     pointer to track -- the firmware
	;                                     owns screen addressing); kept so
	;                                     any stray reference still assembles
	;   $0A     2     DFCCL              ditto, unused
;   $0C     2     S_POSN             vestigial: __LOAD_S_POSN/
	;                                     __SAVE_S_POSN (sposn.asm) now read
	;                                     the firmware's own live cursor via
	;                                     TXT_GET_CURSOR/TXT_SET_CURSOR
	;                                     instead of caching it here. Kept
	;                                     zeroed by bootstrap.asm; nothing
	;                                     reads or writes it any more
	;   $0E     1     ATTR_P             permanent attribute (INK/PAPER/etc.)
	;   $0F     1     MASK_P             permanent transparency mask -- kept
	;                                     immediately after ATTR_P because
	;                                     ink.asm/paper.asm/bright.asm/
	;                                     flash.asm (byte-for-byte zx48k)
	;                                     reach it with a plain `inc de`/
	;                                     `inc hl` from ATTR_P
	;   $10     1     ATTR_T             temporary attribute (same encoding
	;                                     as ATTR_P; see the bit layout below)
	;   $11     1     MASK_T             temporary transparency mask, same
	;                                     adjacency rule as MASK_P
	;   $12     1     P_FLAG             permanent print flags (OVER/INVERSE)
	;   $13     1     TV_FLAG            flags controlling output to screen
	;   $14     8     MEM0               scratch buffer; print.asm reuses it
	;                                     to stash a control code's first
	;                                     parameter byte across two
	;                                     __PRINTCHAR calls (AT's row, TAB's
	;                                     first byte) now that it doesn't need
	;                                     it for character bitmap generation
	;   $1C     2     SCREEN_ADDR        pointer to the screen bitmap base
	;   $1E     2     SCREEN_ATTR_ADDR   placeholder -- the CPC has no
	;                                    per-cell attribute byte in memory
	;                                    the way the Spectrum does
	;   $20     1     ERR_NR             error code (-1 = no error)
	;   $21     2     FRAMES             software frame counter
	;   $23     2     RANDOM_SEED_LOW    RNG seed, low 16 bits
	;   $25     8     ARRAY_SCRATCH      LBOUND_PTR/UBOUND_PTR/RET_ADDR/
	;                                    TMP_ARR_PTR (2 bytes each)
	;   $2D     2     CHR_SCRATCH        return-address scratch for CHR$()
	;   $2F     4     DIVF_SCRATCH       TMP (2B) + ERR_SP (2B) for float
	;                                    division
	;   $33     2     FW_BC              firmware's BC' shadow (fwcall.asm's
	;                                    gate); seeded from the live BC' by
	;                                    CPC_INIT_00_BOOTSTRAP before
	;                                    anything else can disturb it
	;   $35     1     IN_FW              "inside the firmware gate" flag,
	;                                    set/cleared by fwcall.asm around
	;                                    every call; for a future IM1
	;                                    front-end (Sec6.1 stage 2) to tell
	;                                    a firmware call from user code
	;   $36     6     MODF16_SCRATCH     return addr + divider DE/HL for
	;                                    MOD16.16, kept separate from
	;                                    ARRAY_SCRATCH (the two must not alias)
	;   $3C     1     PRINT_STATE        print.asm's control-code state
;                                    machine: 0 = idle, nonzero = "the
	;                                    next __PRINTCHAR byte is a parameter
	;                                    for control code N" (see print.asm)
	;   $3D     2     PPC                current line number, for BREAK
	;                                    (break.asm); matches zx48k's PPC
	;                                    23621 by name/role only -- our
	;                                    error.asm doesn't print it (no ROM
	;                                    error formatter here), it's kept
	;                                    only so CHECK_BREAK's calling
	;                                    convention matches zx48k's exactly
	;                                    (see break.asm)
;   $3F     2     FP_STKBOT          fp_calc.asm: base of the FP number
	;                                    stack (ROM STKBOT $5C63)
;   $41     2     FP_STKEND          fp_calc.asm: next free slot in the
	;                                    FP number stack (ROM STKEND $5C65).
	;                                    MUST stay immediately followed by
	;                                    FP_BREG -- see the note in
	;                                    fp_calc.asm (ENT-TABLE loads both
	;                                    with one `ld bc,(FP_STKEND+1)`)
;   $43     1     FP_BREG            fp_calc.asm: literal currently being
	;                                    executed (ROM BREG $5C67)
;   $44     2     FP_MEM             fp_calc.asm: pointer to the MEM
	;                                    area, 6 cells of 5 bytes (ROM MEM
	;                                    $5C68)
;   $46     60    FP_CALC_STACK      fp_calc.asm: the FP number stack
	;                                    itself (12 numbers max)
;   $82     30    FP_MEM_AREA        fp_calc.asm: the MEM area (6 cells)
;   $A0     8     PEN_MAP            colour.asm: Spectrum colour 0-7 ->
	;                                    pen of the current screen mode
;   $A8     1     GFX_XSHIFT         colour.asm: mode pixel x -> firmware
;                                    virtual x shift (mode 0: 2, 1: 1,
;                                    2: 0)
;   $A9     1     TXT_COLS           colour.asm: text columns of the
	;                                    current mode (20/40/80)
;   $AA     1     GRA_PEN_CUR        gfx.asm: graphics pen last given to
	;                                    the firmware ($FF = unknown)
;   $AB     1     GRA_MODE_CUR       gfx.asm: graphics write mode last
	;                                    given to the firmware ($FF = unknown)
;   $AC     9     SOUND_BLK          beep.asm: SOUND_QUEUE block (the
	;                                    firmware reads it, so it must be in
	;                                    the central 32K -- it is)
;   $B5     10    CIRC_VARS          circle.asm: centre X/Y, x, y, d
;   $BF     1     PAUSE_TICK         pause.asm: last 300 Hz tick count
	;   $C0    17     (free)             was the cpcbuild library's state; the
	;                                    library now keeps it in its own storage
;   $D1     16    SND_ENV            fwsound.asm: volume envelope data
	;                                    buffer for SOUND_AMPL_ENVELOPE
;   $E1     2     GM_VEC             isr.asm: game-mode handler address
	;                                    (0 = normal mode; framehook.asm)
;   $E3     2     FH_ADDR            framehook.asm: frame hook routine
	;                                    (0 = none)
;   $E5     4     FH_FRAMES          framehook.asm: frames counted
;   $E9     1     GM_COUNT           framehook.asm: interrupts since the
	;                                    last frame (game mode)
;   $EA     9     FH_BLOCK           framehook.asm: KL_NEW_FRAME_FLY event
	;                                    block (must be in central RAM)
	;   ------  ----
	;   $F3     (243 bytes used)
	;
	; --- ATTR_P / ATTR_T bit layout (one byte, same shape as zx48k's) ------
	;
	;   bit   Meaning
	;   ---   ------------------------------------------------------------
;   0-2   ink: a Spectrum colour 0-7 (ink.asm, unchanged from zx48k),
	;         turned into a pen of the current mode through PEN_MAP
	;         (colour.asm) whenever it reaches the firmware
;   3-5   paper: a Spectrum colour 0-7, mapped the same way
	;   6     BRIGHT flag (bright.asm) -- accepted, ignored (notes.md Q5)
	;   7     FLASH flag (flash.asm) -- accepted, ignored (notes.md Q5)
	;
	; $F3 bytes used out of CPC_PRIV_SIZE ($400 = 1024). CPC_SYSVARS_USED
	; below lets it be compared against .core.CPC_PRIV_SIZE by eye whenever
	; this table grows.
	    push namespace core
	SYSVAR_BASE         EQU .core.CPC_PRIV_BASE
	CHARS               EQU SYSVAR_BASE + $00   ; DW -- pointer to charset (8x8 cells)
	UDG                 EQU SYSVAR_BASE + $02   ; DW -- pointer to UDG charset
	COORDS              EQU SYSVAR_BASE + $04   ; DW -- last PLOT/graphics coordinates (X,Y)
	FLAGS2              EQU SYSVAR_BASE + $06   ; DB -- screen flags (OVER/BOLD/ITALIC)
	ECHO_E              EQU SYSVAR_BASE + $07   ; DB -- (reserved, unused for now)
	DFCC                EQU SYSVAR_BASE + $08   ; DW -- unused (no VRAM pointer to track)
	DFCCL               EQU SYSVAR_BASE + $0A   ; DW -- unused (ditto)
	S_POSN              EQU SYSVAR_BASE + $0C   ; DW -- vestigial, see table above
	ATTR_P              EQU SYSVAR_BASE + $0E   ; DB -- permanent attribute (INK/PAPER/etc.)
	MASK_P              EQU SYSVAR_BASE + $0F   ; DB -- permanent transparency mask
	ATTR_T              EQU SYSVAR_BASE + $10   ; DB -- temporary attribute
	MASK_T              EQU SYSVAR_BASE + $11   ; DB -- temporary transparency mask
	P_FLAG              EQU SYSVAR_BASE + $12   ; DB -- permanent print flags (OVER/INVERSE)
	TV_FLAG             EQU SYSVAR_BASE + $13   ; DB -- flags controlling output to screen
	MEM0                EQU SYSVAR_BASE + $14   ; 8B -- scratch buffer, see table above
	SCREEN_ADDR         EQU SYSVAR_BASE + $1C   ; DW -- pointer to the screen bitmap base
	SCREEN_ATTR_ADDR    EQU SYSVAR_BASE + $1E   ; DW -- placeholder, see table above
	ERR_NR              EQU SYSVAR_BASE + $20   ; DB -- error code (-1 = no error)
	FRAMES              EQU SYSVAR_BASE + $21   ; DW -- software frame counter
	RANDOM_SEED_LOW     EQU SYSVAR_BASE + $23   ; DW -- RNG seed, low 16 bits
	ARRAY_SCRATCH       EQU SYSVAR_BASE + $25   ; 8B -- LBOUND_PTR/UBOUND_PTR/RET_ADDR/TMP_ARR_PTR
	CHR_SCRATCH         EQU SYSVAR_BASE + $2D   ; 2B -- return-address scratch for CHR$()
	DIVF_SCRATCH        EQU SYSVAR_BASE + $2F   ; 4B -- TMP (2B) + ERR_SP (2B) for float division
	FW_BC               EQU SYSVAR_BASE + $33   ; 2B -- firmware's BC' shadow (fwcall.asm)
	IN_FW               EQU SYSVAR_BASE + $35   ; 1B -- "inside firmware gate" flag (fwcall.asm)
	MODF16_SCRATCH      EQU SYSVAR_BASE + $36   ; 6B -- return addr + divider DE/HL for MOD16.16
	PRINT_STATE         EQU SYSVAR_BASE + $3C   ; 1B -- print.asm's control-code state machine
	PPC                 EQU SYSVAR_BASE + $3D   ; DW -- current line number (break.asm CHECK_BREAK)
	; --- fp_calc.asm's own sysvars (equivalent to the ROM's STKBOT/STKEND/
	; BREG/MEM $5C63-$5C69) -- kept contiguous and in this exact order, see
	; the table above and fp_calc.asm's own header.
	FP_STKBOT           EQU SYSVAR_BASE + $3F   ; DW -- base of the FP number stack
	FP_STKEND           EQU SYSVAR_BASE + $41   ; DW -- next free slot in the FP number stack
	FP_BREG             EQU SYSVAR_BASE + $43   ; DB -- literal currently being executed
	FP_MEM              EQU SYSVAR_BASE + $44   ; DW -- pointer to the MEM area (6 cells x 5B)
	FP_CALC_STACK       EQU SYSVAR_BASE + $46   ; 60B -- the FP number stack (12 numbers max)
	FP_CALC_STACK_END   EQU FP_CALC_STACK + 60
	FP_MEM_AREA         EQU SYSVAR_BASE + $82   ; 30B -- the MEM area (6 cells x 5B)
	PEN_MAP             EQU SYSVAR_BASE + $A0   ; 8B -- Spectrum colour -> pen (colour.asm)
	GFX_XSHIFT          EQU SYSVAR_BASE + $A8   ; DB -- mode pixel x -> virtual x shift
	TXT_COLS            EQU SYSVAR_BASE + $A9   ; DB -- text columns in the current mode
	GRA_PEN_CUR         EQU SYSVAR_BASE + $AA   ; DB -- cached graphics pen ($FF = unknown)
	GRA_MODE_CUR        EQU SYSVAR_BASE + $AB   ; DB -- cached graphics write mode ($FF = unknown)
	SOUND_BLK           EQU SYSVAR_BASE + $AC   ; 9B -- SOUND_QUEUE block (beep.asm)
	CIRC_VARS           EQU SYSVAR_BASE + $B5   ; 10B -- CIRCLE state (circle.asm)
	PAUSE_TICK          EQU SYSVAR_BASE + $BF   ; DB -- PAUSE's last tick count (pause.asm)
	; $C0-$D0 are free (17 bytes).
	SND_ENV             EQU SYSVAR_BASE + $D1   ; 16B -- envelope data buffer (fwsound.asm)
	GM_VEC              EQU SYSVAR_BASE + $E1   ; DW -- game-mode handler (0 = normal; isr.asm)
	FH_ADDR             EQU SYSVAR_BASE + $E3   ; DW -- frame hook routine (0 = none)
	FH_FRAMES           EQU SYSVAR_BASE + $E5   ; 4B -- frames counted (framehook.asm)
	GM_COUNT            EQU SYSVAR_BASE + $E9   ; DB -- interrupts since last frame (game mode)
	FH_BLOCK            EQU SYSVAR_BASE + $EA   ; 9B -- frame-flyback event block (framehook.asm)
; --- Bare-metal text (txtbare.asm, Phase 6 B2): $100-$13F and $200-$21F,
	; clear of the sysvars above so parallel additions there cannot collide.
	; PAL_SHADOW reuses the 17 free bytes at $C0 (bare mode keeps no firmware
	; ink table, so BORDER reads the pen colours from here).
	PAL_SHADOW          EQU SYSVAR_BASE + $C0   ; 17B -- colour (0-26) of pens 0-15 and the border
	BT_MODE             EQU SYSVAR_BASE + $100  ; DB -- current screen mode 0-3
	BT_BPC              EQU SYSVAR_BASE + $101  ; DB -- screen bytes per glyph row (4/2/1)
	BT_PPB              EQU SYSVAR_BASE + $102  ; DB -- pixels per screen byte (2/4/8)
	BT_MASK             EQU SYSVAR_BASE + $103  ; DB -- pen number mask (15/3/1)
	BT_FILL             EQU SYSVAR_BASE + $104  ; DB -- screen byte of an all-paper row (scroll fill)
BT_MX               EQU SYSVAR_BASE + $105  ; DB -- mode 2: ink mask xor paper mask
BT_MP               EQU SYSVAR_BASE + $106  ; DB -- mode 2: paper mask
	BT_BUF              EQU SYSVAR_BASE + $108  ; 8B -- SCREEN$ glyph bitmap being matched
	BT_TRAMP            EQU SYSVAR_BASE + $120  ; 32B -- font copy routine (runs with the lower ROM in)
	BT_PIX              EQU SYSVAR_BASE + $140  ; 64B -- SCREEN$ cell pixels (pen numbers)
	BT_TBL              EQU SYSVAR_BASE + $200  ; 16B, page aligned -- screen byte per glyph-bit group
; --- cpcbuild's cpcplus library (Phase 7 P3), both modes: $300-$37F. The
	; ASIC register page replaces RAM at &4000-&7FFF while it is paged in, so the
	; code that pages it in (page in, copy, page out) cannot live in the
	; program, which may reach into that range; the library copies its small
	; routines here at start-up (#init, lib/cpcplus/plus.asm) and bounces data
	; through PL_BUF. Free in both memory maps (the firmware layout's $9E00 block
	; and the bare layout's $BC00 block have no other users above $F3 / $21F).
; Free elsewhere: $F3-$FF, $220-$2FF and $380-$3FF in bare mode ($F3-$2FF
	; and $380-$3FF in firmware mode).
; CPC_EXIT_VEC (bare mode only, $1F0-$1F1): a routine __CPC_RESET calls
	; before it resets the machine (END), 0 = none. A library that leaves
; hardware state behind (cpcplus's raster interrupts: PRI stops the
	; firmware's six interrupts per frame) points it at its cleanup.
	CPC_EXIT_VEC        EQU SYSVAR_BASE + $1F0  ; DW -- cleanup routine called by END's reset (bare mode), 0 = none
	PL_TRAMP            EQU SYSVAR_BASE + $300  ; 64B -- paged-access routines (plus.asm copies them here)
	PL_BUF              EQU SYSVAR_BASE + $340  ; 64B -- bounce buffer for data between the ASIC page and RAM at &4000-&7FFF
	CPC_SYSVARS_USED    EQU $F3                 ; bytes used above; compare by eye against
	                                             ; .core.CPC_PRIV_SIZE when this table grows
; --- Screen constants (CPC mode 1: 40 columns x 25 rows) ----------------
; The column count follows the screen mode at run time (TXT_COLS above:
	; 20/40/80); these constants are the boot-time mode 1 values. Only the
	; row count is the same in every mode.
	; SCR_COLS keeps zx48k's own "columns + 1" convention (see zx48k's
; sysvars.asm: SCR_COLS EQU 33 for 32 visible columns). SCR_COLS_VISIBLE
	; is the plain visible-column count, used by print.asm/sposn.asm's
	; explicit 0-39 range checks and arithmetic, where the "+1" convention
	; would just have to be undone again.
	SCR_COLS            EQU 41      ; columns + 1 (40 columns visible)
	SCR_COLS_VISIBLE    EQU 40      ; columns visible (0-39, 0-based)
	SCR_ROWS            EQU 25      ; rows visible (0-24, 0-based)
	SCR_SIZE            EQU (SCR_ROWS << 8) + SCR_COLS
	    pop namespace
#line 35 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 1 "src/lib/arch/cpc/runtime/fwcall.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC firmware call gate
	;
	; Every firmware jumpblock entry goes through RST 1 LOW JUMP, which uses
	; B' = &7F (gate array port) and C' = current ROM/mode config, and the
	; 300 Hz interrupt handler also uses BC' and branches on AF' carry
	; ("already inside an interrupt"). Compiled code clobbers both freely
	; (SUB epilogues pop into BC'; div8/div16/float pushes use AF'). So every
; firmware call goes through this gate: with interrupts off it sets IN_FW,
	; restores BC' from the FW_BC shadow and clears AF' carry, makes the call
	; with interrupts on, then (off again) captures BC' back (mode/ROM
	; changes) and clears IN_FW. Outside the gate interrupts go through
	; isr.asm, which does the same register hand-over for the firmware's
	; interrupt handler; IN_FW tells it the firmware's registers are already
	; loaded. The gate always returns with interrupts on.
	;
	; Usage (A, F, BC, DE, HL go in as set and come back as the firmware left
; them, flags included):
	;
	;     call .core.__FW_CALL        ; or .core.__FW_CALL_IX for CAS_* entries,
	;     defw $BB5A                  ; which corrupt IX (Boriel's frame pointer)
	;
	; Clobbers BC', DE', HL', AF' (never meaningful to compiled code across a
	; call). Not re-entrant (the interrupt handler never calls it).
; Cost: about 220 T-states plus the firmware routine.
; Bare-metal mode (-D CPC_BAREMETAL): there is no firmware, so the gate is
	; not defined at all. Anything that still calls the firmware fails to
	; build with "undefined label __FW_CALL" -- that is how firmware-only
	; features (LOAD/SAVE, firmware sound, direct firmware calls in asm) are
	; refused in bare mode.
	    push namespace core
__FW_CALL:
	    PROC
	    di                  ; IN_FW and BC' must change together (isr.asm)
	    exx                 ; alternate bank is scratch; caller's regs stay put
	    pop  hl             ; HL -> defw after the call
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)        ; DE = firmware entry
	    inc  hl
	    push hl             ; return past the defw
	    ld   (__FW_CALL_TARGET + 1), de
	    ld   hl, IN_FW
	    ld   (hl), 1
	    ld   bc, (FW_BC)    ; becomes BC' after the exx below
	    ex   af, af'
	    or   a              ; AF' carry clear, or the ISR takes its nested path
	    ex   af, af'
	    exx
	    ei
__FW_CALL_TARGET:
	    call $FFFF          ; operand patched above
	    di
	    exx
	    ld   (FW_BC), bc    ; keep mode/ROM changes for the next call
	    ld   hl, IN_FW
	    ld   (hl), 0
	    exx
	    ei
	    ret
	    ENDP
__FW_CALL_IX:
	    PROC
	    di
	    exx
	    pop  hl
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)
	    inc  hl
	    push hl
	    ld   (__FW_CALL_IX_TARGET + 1), de
	    ld   hl, IN_FW
	    ld   (hl), 1
	    ld   bc, (FW_BC)
	    ex   af, af'
	    or   a
	    ex   af, af'
	    exx
	    ei
	    push ix
__FW_CALL_IX_TARGET:
	    call $FFFF
	    pop  ix
	    di
	    exx
	    ld   (FW_BC), bc
	    ld   hl, IN_FW
	    ld   (hl), 0
	    exx
	    ei
	    ret
	    ENDP
	    pop namespace
#line 104 "src/lib/arch/cpc/runtime/fwcall.asm"
#line 36 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 1 "src/lib/arch/cpc/runtime/isr.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC interrupt front-end
	;
	; Compiled code runs with interrupts on. The firmware's 300 Hz handler
	; needs BC' = its own value (B' = &7F, the Gate Array port; C' = the
	; ROM/mode configuration) and AF' carry clear (carry set means "interrupt
	; inside an interrupt"), but compiled code uses the alternate registers
	; freely (SUB epilogues, 32-bit/float pushes, the FP calculator). So the
; RAM vector at &0038 is pointed here: this handler saves both register
	; banks, hands the firmware its BC' (the FW_BC shadow, fwcall.asm) and a
	; clear AF' carry, runs the original handler, keeps any change it made
	; to BC', and restores everything.
	;
	; The RAM vector is only seen while the lower ROM is off, i.e. while our
	; code (or firmware code running from RAM) executes. With the lower ROM
	; on, the ROM's own &0038 goes straight to the firmware.
	;
	; Inside a firmware call (IN_FW = 1, set by the gate) the alternate
	; registers already hold the firmware's values, so the handler jumps
	; straight to the original. IN_FW also stays 1 while the original runs
; from here: it ends with "ei; ret", so an interrupt can arrive before
	; our "di", and the firmware's registers are still loaded then.
	;
	; The original handler (RAM &B941 on the 6128, &B939 on the 464; the
	; same code in both ROMs) is read from the vector at boot.
	;
; Game mode (framehook.asm, opt-in): when GM_VEC is non-zero, interrupts
	; outside firmware calls go to the handler it points to instead of the
	; firmware, which then only runs during firmware calls. GM_VEC is zero
	; (normal mode) unless a program switches game mode on.
	;
; Cost: about 250 T-states on top of the firmware's handler, 300 times
	; a second. See cpcbuild docs/phase4d-design.md.
#line 64 "src/lib/arch/cpc/runtime/isr.asm"
	    push namespace core
	; __CPC_ISR_INSTALL -- points the RAM vector at &0038 to __CPC_ISR,
	; keeping the original jump target. Call with interrupts off (the
	; bootstrap does, before its first firmware call).
; Firmware entries called: none. Registers clobbered: AF, HL.
__CPC_ISR_INSTALL:
	    ld   hl, ($0039)
	    ld   (__CPC_ISR_ORIG + 1), hl
	    ld   a, $C3             ; JP nn
	    ld   ($0038), a
	    ld   hl, __CPC_ISR
	    ld   ($0039), hl
	    ret
	; __CPC_ISR -- the IM 1 handler (entered with interrupts off).
; Registers clobbered: none.
__CPC_ISR:
	    push af
	    ld   a, (IN_FW)
	    or   a
	    jr   nz, __CPC_ISR_DIRECT
	    ld   a, (GM_VEC + 1)
	    or   a
    jr   nz, __CPC_ISR_GAME ; game mode (framehook.asm): skip the firmware
	    inc  a                  ; A = 1
	    ld   (IN_FW), a         ; an interrupt during the chain goes direct
	    push bc
	    push de
	    push hl
	    push ix                 ; event routines may use IX/IY
	    push iy
	    ex   af, af'
	    push af                 ; the program's AF'
	    exx
	    push bc                 ; the program's BC', DE', HL'
	    push de
	    push hl
	    ld   bc, (FW_BC)        ; the firmware's BC'
	    exx
	    or   a                  ; AF' (active now) carry clear
	    ex   af, af'
	    call __CPC_ISR_ORIG     ; returns with interrupts on
	    di
	    exx
	    ld   (FW_BC), bc        ; keep a ROM/mode change
	    pop  hl
	    pop  de
	    pop  bc
	    exx
	    pop  af
	    ex   af, af'            ; the program's AF' back
	    pop  iy
	    pop  ix
	    pop  hl
	    pop  de
	    pop  bc
	    xor  a
	    ld   (IN_FW), a
	    pop  af
	    ei
	    ret
; Game mode: jump to the handler in GM_VEC with HL as it was and the
	; program's AF still on the stack (the handler ends "pop af; ei; ret").
__CPC_ISR_GAME:
	    push hl
	    ld   hl, (GM_VEC)
	    ex   (sp), hl
	    ret
__CPC_ISR_DIRECT:
	    pop  af
__CPC_ISR_ORIG:
	    jp   $FFFF              ; patched by __CPC_ISR_INSTALL
	    pop namespace
#line 143 "src/lib/arch/cpc/runtime/isr.asm"
#line 37 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 1 "src/lib/arch/cpc/runtime/colour.asm"
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
#line 38 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    push namespace core
	; CPC_INIT_00_BOOTSTRAP -- captures FW_BC, zero-fills the private
	; runtime block ($9E00-$A1FF, .core.CPC_PRIV_BASE for
	; .core.CPC_PRIV_SIZE bytes), installs the interrupt front-end, sets the
	; few sysvars that need a non-zero default, then sets screen MODE 1
	; through the firmware gate (which turns interrupts on for good).
	;
	; FW_BC is captured first, before the zero-fill, but can't be written
	; to its sysvar slot yet -- that slot is about to be zeroed along with
; the rest of the block. So it's parked on the stack (already valid:
	; the prologue sets SP before calling #init routines) and only written
	; out to FW_BC once the zero-fill is done.
	;
; Firmware entry called: SCR_SET_MODE (&BC0E, via the gate, once
	; FW_BC/IN_FW exist) -- see fwcall.asm for what that call clobbers.
; Registers clobbered: AF, BC, DE, HL (and, transiently, BC'/DE'/HL').
CPC_INIT_00_BOOTSTRAP:
	    PROC
	    ; Capture the firmware's BC' immediately -- see the header above
	    ; and fwcall.asm's contract. Parked on the stack, not yet in FW_BC.
	    exx
	    push bc
	    exx
	    ; Zero-fill the whole private block; sysvars set below simply
	    ; overwrite their own zeroed slot. This also zeroes FW_BC's and
	    ; IN_FW's slots -- the captured value is still safe on the stack.
	    ld   hl, .core.CPC_PRIV_BASE
	    ld   (hl), 0
	    ld   de, .core.CPC_PRIV_BASE + 1
	    ld   bc, .core.CPC_PRIV_SIZE - 1
	    ldir
	    ; Now write the captured FW_BC out to its (freshly-zeroed) slot.
	    ; IN_FW stays 0, which the zero-fill already set.
	    pop  bc
	    ld   (FW_BC), bc
	    ; Our interrupt front-end (isr.asm) goes in before anything enables
    ; interrupts: the first firmware call below returns with them on,
	    ; and they stay on from then on.
	    call __CPC_ISR_INSTALL
    ; ERR_NR: -1 means "no error", not 0 (matches the ZX Spectrum manual's
	    ; convention).
	    ld   a, $FF
	    ld   (ERR_NR), a
    ; Initial permanent attribute: INK 7 / PAPER 0 (white on black), which
	    ; colour.asm maps to the firmware's own default pens, pen 1 on pen 0
	    ; in mode 1 (yellow on blue). Set here, not by print.asm, because
	    ; PLOT/DRAW/CIRCLE use it too in programs that never PRINT; left at 0
	    ; it would be black on black, i.e. invisible.
	    ld   a, 7
	    ld   (ATTR_P), a
    ; SCREEN_ADDR: mode 1 screen base. SCREEN_ATTR_ADDR is left zeroed --
	    ; see the placeholder note in sysvars.asm.
	    ld   hl, $C000
	    ld   (SCREEN_ADDR), hl
	    ; Cursor at the top-left of the text window.
	    ld   hl, 0
	    ld   (S_POSN), hl
	    ; Screen mode 1 (40x25, 4 colours). SCR_SET_MODE also resets the
	    ; text/graphics windows to full-screen, the graphics origin, and
	    ; the current stream -- and, confirmed in the emulator (see
	    ; cpc-port-notes.md Phase 2 results), clears the screen and homes
	    ; the firmware's own text cursor, even though the Firmware Guide's
	    ; own entry for &BC0E doesn't spell that out explicitly.
	    ld   a, 1
	    call .core.__FW_CALL
	    defw $BC0E
	    ld   a, 1
    call __CPC_SET_MODE_VARS    ; colour.asm: pen map, widths for mode 1
    ; Empty the key buffer: the RETURN that submitted RUN"<prog> can
	    ; still be in it, and the first INKEY$ or PAUSE would see it.
	    jp   __CPC_FLUSH_KEYS
	    ENDP
	; __CPC_FLUSH_KEYS -- discards every character waiting in the firmware's
	; key buffer. KM_FLUSH (&BD3D) does this on the 664/6128 only, so this
	; reads characters with KM_READ_CHAR (&BB09, every model) until it
	; reports none (Carry clear).
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__CPC_FLUSH_KEYS:
	    call .core.__FW_CALL
	    defw $BB09
	    jr   c, __CPC_FLUSH_KEYS
	    ret
	; __CPC_WAIT_KEY -- flushes stale keys, then waits for a new keypress
	; (KM_WAIT_KEY, &BB18). END and runtime errors use it so the program's
	; last screen stays visible until a key is pressed (notes.md question 1).
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__CPC_WAIT_KEY:
	    call __CPC_FLUSH_KEYS
	    call .core.__FW_CALL
	    defw $BB18
	    ret
	; __CPC_END -- the single choke point for a *clean* END (src/arch/cpc/
	; backend/generic.py's _end emits "jp .core.__CPC_END" for every END in
	; the program, instead of a bare RST 0). Reaching address 0 by itself
; doesn't prove the program reached END: a crash that happens to reset
	; the machine, or a runtime error (error.asm's __ERROR, also RST 0 after
	; printing "Error n"), lands there too. This is forced into every build
	; (bootstrap.asm is in common.REQUIRES unconditionally -- see the file
	; header), so it's the one place a distinguishing marker can live for
	; every program, not just ones that happen to #include some other file.
	;
	; Under -D __CPC_PRINTER_ECHO__ (cpcbuild's cpcrun.py test harness),
	; sends __CPC_END_MARKER -- a line containing only "\x04END" -- to the
	; printer via MC_PRINT_CHAR (&BD2B), through the gate, before the RST 0.
	; \x04 (ASCII EOT) as the first byte makes the line unlike anything a
	; Boriel program can PRINT (print.asm's control-code table drops or
	; diverts every code below 32 except 6/8/13-23) and unlike the
	; "NOT IMPLEMENTED" (stub.asm) / "Error n" (error.asm) text the same
	; transcript can otherwise contain, so cpcrun.py can grep for it
	; unambiguously and strip it from the reported transcript.
	;
	; Without the flag it waits for a key first (__CPC_WAIT_KEY), so the
	; program's output stays on screen (notes.md question 1), then resets.
	;
; Firmware entries called: MC_PRINT_CHAR (&BD2B) in printer-echo builds;
; KM_READ_CHAR/KM_WAIT_KEY otherwise. Registers clobbered: none (never
	; returns).
#line 176 "src/lib/arch/cpc/runtime/bootstrap.asm"
__CPC_END:
#line 203 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    call __CPC_WAIT_KEY
	    di
	    rst  0
#line 207 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    pop namespace
#line 210 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 41 "tests/functional/arch/cpc/cpc_div32.bas"
#line 1 "src/lib/arch/cpc/runtime/copy_attr.asm"
	; Copies the permanent attribute (ATTR_P/MASK_P/FLAGS2/P_FLAG) into the
	; temporary one (ATTR_T/MASK_T/...) at the start of every PRINT
	; statement, then pushes the resulting ink/paper pens (and INVERSE) to
	; the firmware -- see __SET_ATTR_MODE below, which does the actual
	; firmware call and is also the shared re-apply entry used whenever
	; INK_TMP/PAPER_TMP/INVERSE_TMP/OVER_TMP change the temporary attribute
	; mid-statement (e.g. `PRINT INK 2; "x"; PAPER 1; "y"`).
	;
	; zx48k's COPY_ATTR self-modifies a PRINT_MODE/INVERSE_MODE opcode pair
	; inside print.asm's VRAM writer, guarded by ___PRINT_IS_USED___ (which
	; zxbparser.py defines whenever a program uses PRINT at all). There is
	; no such opcode table here -- print.asm calls the firmware's
	; TXT_OUTPUT instead of writing VRAM directly, so applying an attribute
	; just means calling TXT_SET_PEN/TXT_SET_PAPER/TXT_INVERSE. That work
	; doesn't depend on whether PRINT is used elsewhere (if it isn't, this
	; file is never linked in at all), so the ___PRINT_IS_USED___ branch
	; zx48k has is dropped.
#line 25 "src/lib/arch/cpc/runtime/copy_attr.asm"
	    push namespace core
COPY_ATTR:
	    ; Copies current permanent attribs into temporary attribs, then
	    ; applies them to the firmware (pen/paper/inverse).
	    PROC
	    LOCAL __REFRESH_TMP
	    ld hl, (ATTR_P)      ; = ATTR_P (L) + MASK_P (H), adjacent bytes
	    ld (ATTR_T), hl      ; -> ATTR_T (L) + MASK_T (H)
	    ld hl, FLAGS2
	    call __REFRESH_TMP
	    ld hl, P_FLAG
	    call __REFRESH_TMP
	    jp __SET_ATTR_MODE
; zx48k's bit-shuffle: permanent flags live in the odd bits (1,3,5,7),
	; temporary ones in the even bits (0,2,4,6) of the same byte; this
	; copies one into the other. Pure bit manipulation, no CPC-specific
	; change needed.
__REFRESH_TMP:
	    ld a, (hl)
	    and 0b10101010
	    ld c, a
	    rra
	    or c
	    ld (hl), a
	    ret
	    ENDP
#line 70 "src/lib/arch/cpc/runtime/copy_attr.asm"
	; Applies ATTR_T's ink/paper (Spectrum colours, mapped to pens of the
	; current mode by colour.asm's __INK_TO_PEN) and P_FLAG's temporary INVERSE bit
	; (bit 2) to the firmware's current pen/paper. Always re-derives both
	; pens from ATTR_T first (rather than tracking whether they're already
	; inverted), so it's safe to call repeatedly as flags change mid-PRINT.
	;
; Entry: none (rereads ATTR_T/P_FLAG directly; unlike zx48k's version,
	; A is not significant on entry).
; Firmware entries called (via the gate): TXT_SET_PEN (&BB90, A = ink
	; pen), TXT_SET_PAPER (&BB96, A = paper pen), and, only when the
	; temporary INVERSE flag is set, TXT_INVERSE (&BB9C, swaps the current
	; pen/paper for the stream -- simpler than computing the swap here).
; Registers clobbered: AF, HL (main); BC', DE', HL', AF' (the gate,
	; once per firmware call above).
__SET_ATTR_MODE:
	    PROC
	    LOCAL __SAM_NOINV
    ld a, (ATTR_T)       ; ink: bits 0-2, a Spectrum colour
	    call __INK_TO_PEN     ; -> pen of the current mode (colour.asm)
	    call .core.__FW_CALL
	    defw $BB90            ; TXT_SET_PEN
	    ld a, (ATTR_T)
	    rrca
	    rrca
    rrca                  ; paper: bits 3-5 -> bits 0-2
	    call __INK_TO_PEN
	    call .core.__FW_CALL
	    defw $BB96             ; TXT_SET_PAPER
	    ld a, (P_FLAG)
	    and 4                 ; temporary INVERSE bit (bit 2 -- see inverse.asm)
	    jr z, __SAM_NOINV
	    call .core.__FW_CALL
    defw $BB9C              ; TXT_INVERSE: swap current pen/paper
__SAM_NOINV:
	    ret
	    ENDP
#line 111 "src/lib/arch/cpc/runtime/copy_attr.asm"
	    pop namespace
#line 42 "tests/functional/arch/cpc/cpc_div32.bas"
#line 1 "src/lib/arch/cpc/runtime/print.asm"
	; PRINT command routine
	; Does not print attribute. Use PRINT_STR or PRINT_NUM for that
	;
; Amstrad CPC: zx48k's version writes characters directly into Spectrum
	; VRAM (interleaved-row bitmap, self-modifying PRINT_MODE/INVERSE_MODE
	; opcodes, CHARS/UDG as the font source). There is no VRAM to write here
	; -- printable characters go through the firmware's TXT_OUTPUT (&BB5A),
	; which draws its own glyphs and handles wrap/scroll by itself. What
	; this file has to do instead is keep the *external* contract exactly
	; as zx48k's callers expect it (PRINT_AT/PRINT_COMMA/PRINT_EOL/PRINT_TAB,
	; and __PRINTCHAR's "prints A, preserves BC and HL" contract that
	; printstr.asm's loop relies on -- see printnum.asm/printi8/16/32.asm/
	; printf16.asm for the other, self-protecting callers), and translate
	; Boriel's embedded control codes (0-31, the same ones a Spectrum
	; PRINT stream can carry) into firmware calls instead of raw bytes.
	;
; Translation table (control code -> action):
	;   0-5,7,9-12,24-31  dropped (7 = BEEP, 12 = CLS on the real CPC
	;                      firmware -- dropping them here is what keeps them
	;                      from ever reaching TXT_OUTPUT raw, see below)
	;   6   PRINT comma -> next half-screen zone (column 20, or a newline if
	;       already at or past column 20 -- half of the 40-column screen)
	;   8   DEL -> cursor back one column (wraps to the end of the previous
	;       row; no VRAM erase, matching zx48k)
	;   13  newline (also what PRINT_EOL emits) -> CR (13) then LF (10) via
	;       TXT_OUTPUT; the firmware wraps/scrolls by itself
	;   14  BOLD, 15 ITALIC, 18 FLASH, 19 BRIGHT, 21 OVER -> consume their
	;       parameter byte and update ATTR_T/FLAGS2 (memory only) via the
	;       matching *_TMP setter, same as zx48k; no firmware effect yet
;       TODO(cpc): Phase 4a
	;   16  INK, 17 PAPER -> consume the pen number and call INK_TMP/
	;       PAPER_TMP, which (on the CPC, unlike zx48k) push the pen to the
	;       firmware immediately -- see ink.asm/paper.asm
	;   20  INVERSE -> consume the flag and call INVERSE_TMP, which pushes
	;       it to the firmware immediately (pen/paper swap, via
	;       copy_attr.asm's __SET_ATTR_MODE)
	;   22  AT -> consumes ROW then COL and calls TXT_SET_CURSOR (via
	;       __SAVE_S_POSN); no bounds check, matching zx48k's own embedded
	;       AT (only the *statement* form, PRINT_AT below, checks bounds)
	;   23  TAB -> consumes 2 bytes (only the first is used, matching
	;       zx48k) and pads with spaces up to that column, modulo the
;       screen width (TXT_COLS: 20/40/80 by mode)
	;   32-255  printed via TXT_OUTPUT; 128-143 (Spectrum block graphics)
	;           translated to the CPC's own quadrant characters first
	;
; Phase-3 printer echo (-D __CPC_PRINTER_ECHO__, cpcbuild's cpcrun.py):
	; every character actually sent to TXT_OUTPUT is mirrored to the
	; printer via MC_PRINT_CHAR (&BD2B), through the gate (__PRN_ECHO
	; below), so a program compiled with the flag produces a plain-text
	; transcript of its PRINT output that cpcrun.py can capture headlessly
	; (Caprice32's printer_file) and diff against expected output.
;   - Newline (code 13) reaches the printer as a bare LF, not CR+LF:
	;     the screen still gets CR+LF (the firmware's own convention), but
	;     the printer file only needs one line-ending byte to be a clean,
	;     diffable text file, and LF is what every host tool expects.
;   - PRINT_COMMA and PRINT_TAB need no special-casing: both work by
	;     calling __PRINTCHAR with spaces (see below), which already go
	;     through the normal >=32 path and get echoed like any other
	;     character.
	;   - AT (both the embedded control code and the PRINT_AT statement
	;     entry point below) moves the cursor without emitting any
	;     character, so nothing would reach the printer at all; a bare LF
	;     is emitted instead, on the theory that starting a fresh printer
	;     line is more useful for a text transcript than staying silent.
	;
; A note on why this doesn't use zx48k's exx-based state machine: zx48k
	; switches to the alternate register bank across the whole of
	; __PRINTCHAR to get itself a private BC'/DE'/HL' scratch area,
	; protecting the *caller's* main-bank registers, and switches back
	; before returning. That's safe on the Spectrum because __PRINTCHAR
	; never calls anything that itself uses exx. Here it would call the
	; firmware gate (fwcall.asm), which *does* use exx internally to reach
	; FW_BC/IN_FW -- nesting the two would have the gate's exx land on
	; whatever __PRINTCHAR's own exx had swapped OUT of (the real caller's
	; live registers, e.g. printstr.asm's string pointer/length), not on
	; scratch. So the "which control code came next" state lives in a plain
	; memory byte (PRINT_STATE, sysvars.asm) instead, and BC/HL are
	; protected with an ordinary push/pop around the whole routine (bare-metal
; mode also keeps DE: the firmware's TXT_OUTPUT preserved it and callers use that).
#line 1 "src/lib/arch/cpc/runtime/sposn.asm"
	; Print cursor positioning, via the firmware's own live cursor
	; (TXT_GET_CURSOR / TXT_SET_CURSOR) instead of the Spectrum VRAM/attribute
	; address formula zx48k's version computes. The firmware is the only
; source of truth for the cursor: it moves the cursor itself on every
	; TXT_OUTPUT (wrap, scroll), so there is nothing useful to cache
	; locally (S_POSN, sysvars.asm, is left vestigial). Used internally by
	; print.asm and directly by the stdlib POS()/CSRLIN() functions (see
; zx48k's pos.bas/csrlin.bas: `call __LOAD_S_POSN` then `ld a,e`/`ld a,d`).
	;
; Register convention kept identical to zx48k: __LOAD_S_POSN returns
	; D = row, E = column, both 0-based; __SAVE_S_POSN takes the same in D, E.
	;
	; zx48k's __LOAD_S_POSN never happens to touch A (its body is just
	; `ld de,(S_POSN) / ld hl,SCR_SIZE / or a / sbc hl,de / ex de,hl / ret`,
	; and `or a` leaves A's value alone) -- so PRINT_TAB (below), inherited
; from zx48k unchanged, relies on A surviving the call: it loads the
	; target column into A, calls __LOAD_S_POSN, and only then does `sub e`
	; against the *original* A. This version has to read the firmware's
	; cursor through A (TXT_GET_CURSOR returns the column/row in H/L, but
	; getting them into D/E goes via A), so it preserves the caller's AF
	; across the call explicitly instead of getting it for free.
#line 28 "src/lib/arch/cpc/runtime/sposn.asm"
	; Printing positioning library.
	    push namespace core
#line 84 "src/lib/arch/cpc/runtime/sposn.asm"
	; Reads the firmware's cursor into D = row, E = column (both 0-based).
	;
; Firmware entry called (via the gate): TXT_GET_CURSOR (&BB78). Per the
	; Firmware Guide, H = logical column, L = logical line (both 1-based),
	; A = roll count; BC and DE are preserved by the firmware itself, only
	; the flags are corrupt -- so the gate's own alternate-bank clobbering
	; is the only thing to account for here.
	;
	; TXT_GET_CURSOR can report column 41 (1-based) when a wrap is pending
	; (the last character printed reached column 40 but hasn't scrolled
; yet): that has no representation in the 0-39 range, so it's folded
	; forward here to column 0 of the next row (clamped at the last row,
	; since printing one more character would scroll rather than move past
	; it).
; Registers clobbered: HL (main; AF is saved/restored, see the file
	; header); BC', DE', HL', AF' (the gate).
__LOAD_S_POSN:
	    PROC
	    LOCAL __LSP_WRAP, __LSP_CLAMP, __LSP_DONE
	    push af             ; preserve the caller's A -- see the file header
	    call .core.__FW_CALL
	    defw $BB78
	    ld a, l           ; L = logical line, 1-based
	    dec a
	    ld d, a           ; D = row, 0-based
    ld a, (TXT_COLS)  ; H = logical column, 1-based: up to TXT_COLS + 1
	    inc a             ; when a wrap is pending
	    cp h
	    ld a, h
	    jr z, __LSP_WRAP
	    dec a
	    ld e, a
	    jr __LSP_DONE
__LSP_WRAP:           ; pending wrap: next char goes to (row+1, 0)
	    ld e, 0
	    ld a, d
	    inc a
	    cp SCR_ROWS
	    jr c, __LSP_CLAMP
    ld a, SCR_ROWS - 1  ; clamp: already on the last row
__LSP_CLAMP:
	    ld d, a
__LSP_DONE:
	    pop af
	    ret
	    ENDP
	; Sets the firmware's cursor from D = row, E = column (both 0-based).
; Does not range-check (matches zx48k: callers that need bounds
	; checking, e.g. PRINT_AT, do it themselves before calling this).
	;
; Firmware entry called (via the gate): TXT_SET_CURSOR (&BB75), H =
	; logical column, L = logical line (both 1-based).
; Registers clobbered: AF, HL (main); BC', DE', HL', AF' (the gate).
__SAVE_S_POSN:
	    PROC
	    ld a, e
	    inc a
	    ld h, a           ; H = column, 1-based
	    ld a, d
	    inc a
	    ld l, a           ; L = row, 1-based
	    call .core.__FW_CALL
	    defw $BB75
	    ret
	    ENDP
#line 162 "src/lib/arch/cpc/runtime/sposn.asm"
	    pop namespace
#line 82 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/error.asm"
	; Simple error control routines
	;
; Phase-2 (cpc-port-notes.md Phase 2 decisions / docs/notes.md): a
	; runtime error prints "Error n" (n = the ERROR_* code below, in
	; decimal) through the firmware, starting on a fresh line, then waits
	; for a key, then resets to BASIC's Ready prompt. This replaces the
	; Phase 1 hang-in-place trap for real errors; __CPC_NOT_IMPLEMENTED
	; (stub.asm) still hangs, unchanged, for genuinely unimplemented
	; stubs -- those two cases must stay visibly different. __STOP keeps
; the zx48k contract: store the code in ERR_NR and return. ERROR_*
	; constants keep their zx48k values (just numbers, not addresses).
	;
	; The message is printed with TXT_OUTPUT (&BB5A) directly, through the
	; gate (fwcall.asm) -- not print.asm, which isn't implemented yet
	; (print.asm's own TODO) and shouldn't be a dependency of the error
	; path anyway. TXT_OUTPUT's entry/exit are the same as far as this file
; needs: A = the character/control code to output, and (confirmed
	; against the Firmware Guide, cpc-port-notes.md Sec6.4) *all* registers
	; preserved -- so BC/DE/HL survive every call below without saving them
	; around each one.
	;
; Phase-3 printer echo (-D __CPC_PRINTER_ECHO__, cpcbuild's cpcrun.py):
	; every character this file sends to the screen is mirrored to the
	; printer via MC_PRINT_CHAR (&BD2B), through the gate, same as
	; print.asm's __PRN_ECHO (duplicated here as __ERR_PRN_ECHO rather than
	; including print.asm -- see the paragraph above). The screen still gets
	; CR+LF for a fresh line; the printer gets a bare LF (print.asm's
; decision: a clean, diffable text file). And in this mode the whole
	; point is that a *failing* test still reaches END, so __ERROR must not
; block on a keypress: it skips the key flush/wait and goes straight
	; to `rst 0` once "Error n" has been echoed.
#line 39 "src/lib/arch/cpc/runtime/error.asm"
	    push namespace core
	; Error code definitions (as in ZX spectrum manual)
; Set error code with:
	;    ld a, ERROR_CODE
	;    ld (ERR_NR), a
	ERROR_Ok                EQU    -1
	ERROR_SubscriptWrong    EQU     2
	ERROR_OutOfMemory       EQU     3
	ERROR_OutOfScreen       EQU     4
	ERROR_NumberTooBig      EQU     5
	ERROR_InvalidArg        EQU     9
	ERROR_IntOutOfRange     EQU    10
	ERROR_NonsenseInBasic   EQU    11
	ERROR_InvalidFileName   EQU    14
	ERROR_InvalidColour     EQU    19
	ERROR_BreakIntoProgram  EQU    20
	ERROR_TapeLoadingErr    EQU    26
__ERR_STR: DEFB "Error ", 0
#line 87 "src/lib/arch/cpc/runtime/error.asm"
#line 88 "src/lib/arch/cpc/runtime/error.asm"
; Raises a runtime error: stores the code, prints "Error n" on a fresh
	; line, waits for a keypress, then resets to BASIC's Ready prompt (END's
	; own reset, generic.py's _end -- see cpc-port-notes.md Sec6.5).
	;
	; This never returns to the caller.
	;
; Firmware entries called (all through the gate): TXT_OUTPUT (&BB5A),
	; KM_READ_CHAR (&BB09) until the key buffer is empty, then KM_WAIT_KEY
; (&BB18), both via bootstrap.asm's __CPC_WAIT_KEY. (Not KM_FLUSH: that
	; is 664/6128 only, and the 464 is supported.) The flush discards
	; whatever is in the key buffer first -- most obviously the RETURN that submitted
	; RUN"<prog>" itself, which would otherwise satisfy KM_WAIT_KEY without
	; a real keypress -- so the wait below is for a new key, not a stale
	; one. Verified end to end in the emulator (cpc-port-notes.md Phase 2
; results): "Error n" prints, the machine sits at KM_WAIT_KEY, and a
	; keypress resets it to BASIC's Ready prompt. The firmware's own
	; key-scan interrupt handler fills in the keypress while we're blocked
	; inside KM_WAIT_KEY. Interrupts go off just before the reset, so our
	; &0038 vector (isr.asm) is never used while the firmware rebuilds it.
; Registers clobbered: none (never returns).
	; __ERR_SCR -- A = character to the screen only; __ERR_OUT -- to the
	; screen and, under -D __CPC_PRINTER_ECHO__, the printer. Both preserve
	; BC, DE, HL (the callers keep the error number and digits there).
	; __ERR_RESET -- the machine reset after an error.
#line 239 "src/lib/arch/cpc/runtime/error.asm"
; Firmware: TXT_OUTPUT (&BB5A, preserves every register) through the gate.
__ERR_SCR:
	    call .core.__FW_CALL
	    defw $BB5A
	    ret
__ERR_OUT:
	    call .core.__FW_CALL
	    defw $BB5A
#line 250 "src/lib/arch/cpc/runtime/error.asm"
	    ret
__ERR_RESET:
	    di
	    rst  0
#line 255 "src/lib/arch/cpc/runtime/error.asm"
__ERROR:
	    PROC
	    ld   (ERR_NR), a
	    ld   c, a           ; stash the error number (survives TXT_OUTPUT
	                        ; and the gate -- see the file header)
    ; Fresh line: CR then LF (cpc-port-notes.md Phase 2 decisions --
	    ; the same translation print.asm applies to Boriel's newline code
	    ; 13, spelled out here since the error path doesn't use print.asm).
	    ; Printer echo gets the LF only, not the CR (print.asm's decision).
	    ld   a, 13
	    call __ERR_SCR
	    ld   a, 10
	    call __ERR_OUT
	    ; "Error "
	    ld   hl, __ERR_STR
__ERROR_MSG_LOOP:
	    ld   a, (hl)
	    or   a
	    jr   z, __ERROR_MSG_DONE
	    inc  hl
	    call __ERR_OUT
	    jr   __ERROR_MSG_LOOP
__ERROR_MSG_DONE:
	    ld   a, c
	    call __PRINT_DECIMAL_A
#line 291 "src/lib/arch/cpc/runtime/error.asm"
	    ; Flush stale keys, then wait for a real one (bootstrap.asm).
	    call __CPC_WAIT_KEY
	    jp   __ERR_RESET    ; reset to BASIC's Ready prompt
#line 295 "src/lib/arch/cpc/runtime/error.asm"
	    ENDP
	; Sets the error system variable, but keeps running.
	; Usually this instruction if followed by the END intermediate instruction.
__STOP:
	    ld (ERR_NR), a
	    ret
	; __PRINT_DECIMAL_A -- prints A (0-255) in decimal via TXT_OUTPUT,
	; through the gate, with no leading zeros ("0" alone for zero). A tiny
; local printer: error.asm deliberately doesn't pull in print.asm (see
	; the file header), and the alternative -- str.asm's %d-style formatter
	; -- is built on print.asm too.
	;
	; TXT_OUTPUT (and the gate around it) preserve every register, so B/C/D/E
	; are usable as plain scratch across each individual call below.
; Registers clobbered: AF, BC, DE, HL.
__PRINT_DECIMAL_A:
	    PROC
	    LOCAL __PDA_DIGIT, __PDA_SUB, __PDA_DONE, __PDA_SKIP
	    ld   d, 0            ; D = 1 once a non-zero digit has been printed
	    ld   b, 100
	    call __PDA_DIGIT
	    ld   b, 10
	    call __PDA_DIGIT
	    ld   b, 1
	    ld   d, 1            ; the units digit always prints, even if 0
	    call __PDA_DIGIT
	    ret
	; A = remaining value (in/out), B = place value (in), D = "seen a
	; digit yet" flag (in/out). C is scratch.
__PDA_DIGIT:
	    ld   c, 0
__PDA_SUB:
	    cp   b
	    jr   c, __PDA_DONE
	    sub  b
	    inc  c
	    jr   __PDA_SUB
__PDA_DONE:
	    ld   e, a            ; stash the remainder (survives the gate call)
	    ld   a, c
	    or   d
	    jr   z, __PDA_SKIP    ; no digit seen yet and this one is 0 -- skip
	    ld   d, 1
	    ld   a, c
	    add  a, '0'
	    call __ERR_OUT
__PDA_SKIP:
	    ld   a, e             ; remainder becomes the input for the next digit
	    ret
	    ENDP
	    pop namespace
#line 84 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/zx48k/runtime/table_jump.asm"
	    push namespace core
JUMP_HL_PLUS_2A: ; Does JP (HL + A*2) Modifies DE. Modifies A
	    add a, a
JUMP_HL_PLUS_A:	 ; Does JP (HL + A) Modifies DE
	    ld e, a
	    ld d, 0
JUMP_HL_PLUS_DE: ; Does JP (HL + DE)
	    add hl, de
	    ld e, (hl)
	    inc hl
	    ld d, (hl)
	    ex de, hl
CALL_HL:
	    jp (hl)
	    pop namespace
#line 85 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/ink.asm"
	; Sets ink color in ATTR_P permanently
; Parameter: Ink color in A register
	;
; Amstrad CPC: byte-for-byte zx48k's version for the permanent entry
	; (INK) -- it only touches ATTR_P/MASK_P by name via sysvars.asm, which
	; cpc's own sysvars.asm relocates into the private runtime block, so a
	; plain INK statement just updates memory (it takes effect at the next
	; PRINT's COPY_ATTR, exactly like zx48k). INK_TMP additionally pushes
	; the new pen to the firmware immediately (via __SET_ATTR_MODE,
	; copy_attr.asm) -- unlike the Spectrum, where SET_ATTR re-reads ATTR_T
	; per character, the CPC firmware's pen is persistent state, so a
	; mid-PRINT `PRINT INK n;...` has to update it right away.
	    push namespace core
INK:
	    PROC
	    LOCAL __SET_INK
	    LOCAL __SET_INK2
	    ld de, ATTR_P
__SET_INK:
	    cp 8
	    jr nz, __SET_INK2
	    inc de ; Points DE to MASK_T or MASK_P
	    ld a, (de)
	    or 7 ; Set bits 0,1,2 to enable transparency
	    ld (de), a
	    ret
__SET_INK2:
	    ; Another entry. This will set the ink color at location pointer by DE
	    and 7	; # Gets color mod 8
	    ld b, a	; Saves the color
	    ld a, (de)
	    and 0F8h ; Clears previous value
	    or b
	    ld (de), a
	    inc de ; Points DE to MASK_T or MASK_P
	    ld a, (de)
	    and 0F8h ; Reset bits 0,1,2 sign to disable transparency
	    ld (de), a ; Store new attr
	    ret
	; Sets the INK color passed in A register in the ATTR_T variable, and
	; pushes it to the firmware right away (see the file header).
INK_TMP:
	    ld de, ATTR_T
	    call __SET_INK
	    jp __SET_ATTR_MODE
	    ENDP
	    pop namespace
#line 86 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/paper.asm"
	; Sets paper color in ATTR_P permanently
; Parameter: Paper color in A register
	;
; Amstrad CPC: byte-for-byte zx48k's version for the permanent entry
	; (PAPER). PAPER_TMP additionally pushes the new pen to the firmware
	; right away, via __SET_ATTR_MODE -- see ink.asm's header for why.
	    push namespace core
PAPER:
	    PROC
	    LOCAL __SET_PAPER
	    LOCAL __SET_PAPER2
	    ld de, ATTR_P
__SET_PAPER:
	    cp 8
	    jr nz, __SET_PAPER2
	    inc de
	    ld a, (de)
	    or 038h
	    ld (de), a
	    ret
	    ; Another entry. This will set the paper color at location pointer by DE
__SET_PAPER2:
	    and 7	; # Remove
	    rlca
	    rlca
	    rlca		; a *= 8
	    ld b, a	; Saves the color
	    ld a, (de)
	    and 0C7h ; Clears previous value
	    or b
	    ld (de), a
	    inc de ; Points to MASK_T or MASK_P accordingly
	    ld a, (de)
	    and 0C7h  ; Resets bits 3,4,5
	    ld (de), a
	    ret
	; Sets the PAPER color passed in A register in the ATTR_T variable, and
	; pushes it to the firmware right away (see the file header).
PAPER_TMP:
	    ld de, ATTR_T
	    call __SET_PAPER
	    jp __SET_ATTR_MODE
	    ENDP
	    pop namespace
#line 87 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/flash.asm"
	; Sets flash flag in ATTR_P permanently
; Parameter: Paper color in A register
	;
; Amstrad CPC: only touches ATTR_P/ATTR_T by name (no ROM/HW), kept
	; byte-for-byte identical to zx48k's since sysvars.asm already relocates
	; those names.
	    push namespace core
FLASH:
	    ld hl, ATTR_P
	    PROC
	    LOCAL IS_TR
	    LOCAL IS_ZERO
__SET_FLASH:
	    ; Another entry. This will set the flash flag at location pointer by DE
	    cp 8
	    jr z, IS_TR
	    ; # Convert to 0/1
	    or a
	    jr z, IS_ZERO
	    ld a, 0x80
IS_ZERO:
	    ld b, a	; Saves the color
	    ld a, (hl)
	    and 07Fh ; Clears previous value
	    or b
	    ld (hl), a
	    inc hl
	    res 7, (hl)  ;Reset bit 7 to disable transparency
	    ret
IS_TR:  ; transparent
	    inc hl ; Points DE to MASK_T or MASK_P
	    set 7, (hl)  ;Set bit 7 to enable transparency
	    ret
	; Sets the FLASH flag passed in A register in the ATTR_T variable
FLASH_TMP:
	    ld hl, ATTR_T
	    jr __SET_FLASH
	    ENDP
	    pop namespace
#line 88 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/bright.asm"
	; Sets bright flag in ATTR_P permanently
; Parameter: Paper color in A register
	;
; Amstrad CPC: only touches ATTR_P/ATTR_T by name (no ROM/HW), kept
	; byte-for-byte identical to zx48k's since sysvars.asm already relocates
	; those names.
	    push namespace core
BRIGHT:
	    ld hl, ATTR_P
	    PROC
	    LOCAL IS_TR
	    LOCAL IS_ZERO
__SET_BRIGHT:
	    ; Another entry. This will set the bright flag at location pointer by DE
	    cp 8
	    jr z, IS_TR
	    ; # Convert to 0/1
	    or a
	    jr z, IS_ZERO
	    ld a, 0x40
IS_ZERO:
	    ld b, a	; Saves the color
	    ld a, (hl)
	    and 0BFh ; Clears previous value
	    or b
	    ld (hl), a
	    inc hl
	    res 6, (hl)  ;Reset bit 6 to disable transparency
	    ret
IS_TR:  ; transparent
	    inc hl ; Points DE to MASK_T or MASK_P
	    set 6, (hl)  ;Set bit 6 to enable transparency
	    ret
	; Sets the BRIGHT flag passed in A register in the ATTR_T variable
BRIGHT_TMP:
	    ld hl, ATTR_T
	    jr __SET_BRIGHT
	    ENDP
	    pop namespace
#line 89 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/over.asm"
	; Sets OVER flag in P_FLAG permanently
; Parameter: OVER flag in bit 0 of A register
	;
; Amstrad CPC: same as inverse.asm -- OVER only touches FLAGS2/P_FLAG by
	; name (no ROM/HW), kept byte-for-byte identical. OVER 1 is XOR for
	; PLOT/DRAW/CIRCLE (gfx.asm, the firmware's graphics write mode) and is
; ignored for text: the firmware has no XOR text mode (notes.md Q5).
	    push namespace core
OVER:
	    PROC
	    ld c, a ; saves it for later
	    and 2
	    ld hl, FLAGS2
	    res 1, (HL)
	    or (hl)
	    ld (hl), a
	    ld a, c	; Recovers previous value
	    and 1	; # Convert to 0/1
	    add a, a; # Shift left 1 bit for permanent
	    ld hl, P_FLAG
	    res 1, (hl)
	    or (hl)
	    ld (hl), a
	    ret
	; Sets OVER flag in P_FLAG temporarily
OVER_TMP:
	    ld c, a ; saves it for later
	    and 2	; gets bit 1; clears carry
	    rra
	    ld hl, FLAGS2
	    res 0, (hl)
	    or (hl)
	    ld (hl), a
	    ld a, c	; Recovers previous value
	    and 1
	    ld hl, P_FLAG
	    res 0, (hl)
	    or (hl)
	    ld (hl), a
	    jp __SET_ATTR_MODE
	    ENDP
	    pop namespace
#line 90 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/inverse.asm"
	; Sets INVERSE flag in P_FLAG permanently
; Parameter: INVERSE flag in bit 0 of A register
	;
; Amstrad CPC: INVERSE only touches P_FLAG by name (no ROM/HW), kept
	; byte-for-byte identical to zx48k's. INVERSE_TMP tail-calls into
	; copy_attr.asm's __SET_ATTR_MODE, which applies it to the text pens at
	; once; PLOT/DRAW/CIRCLE read it in gfx.asm (plot in the paper colour).
	    push namespace core
INVERSE:
	    PROC
	    and 1	; # Convert to 0/1
	    add a, a; # Shift left 3 bits for permanent
	    add a, a
	    add a, a
	    ld hl, P_FLAG
	    res 3, (hl)
	    or (hl)
	    ld (hl), a
	    ret
	; Sets INVERSE flag in P_FLAG temporarily
INVERSE_TMP:
	    and 1
	    add a, a
	    add a, a; # Shift left 2 bits for temporary
	    ld hl, P_FLAG
	    res 2, (hl)
	    or (hl)
	    ld (hl), a
	    jp __SET_ATTR_MODE
	    ENDP
	    pop namespace
#line 91 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/bold.asm"
	; Sets BOLD flag in P_FLAG permanently
; Parameter: BOLD flag in bit 0 of A register
	;
; Amstrad CPC: only touches FLAGS2 by name (no ROM/HW), kept
	; byte-for-byte identical to zx48k's.
	    push namespace core
BOLD:
	    PROC
	    and 1
	    rlca
	    rlca
	    rlca
	    ld hl, FLAGS2
	    res 3, (HL)
	    or (hl)
	    ld (hl), a
	    ret
	; Sets BOLD flag in P_FLAG temporarily
BOLD_TMP:
	    and 1
	    rlca
	    rlca
	    ld hl, FLAGS2
	    res 2, (hl)
	    or (hl)
	    ld (hl), a
	    ret
	    ENDP
	    pop namespace
#line 92 "src/lib/arch/cpc/runtime/print.asm"
#line 1 "src/lib/arch/cpc/runtime/italic.asm"
	; Sets ITALIC flag in P_FLAG permanently
; Parameter: ITALIC flag in bit 0 of A register
	;
; Amstrad CPC: only touches FLAGS2 by name (no ROM/HW), kept
	; byte-for-byte identical to zx48k's.
	    push namespace core
ITALIC:
	    PROC
	    and 1
	    rrca
	    rrca
	    rrca
	    ld hl, FLAGS2
	    res 5, (HL)
	    or (hl)
	    ld (hl), a
	    ret
	; Sets ITALIC flag in P_FLAG temporarily
ITALIC_TMP:
	    and 1
	    rrca
	    rrca
	    rrca
	    rrca
	    ld hl, FLAGS2
	    res 4, (hl)
	    or (hl)
	    ld (hl), a
	    ret
	    ENDP
	    pop namespace
#line 93 "src/lib/arch/cpc/runtime/print.asm"
#line 97 "src/lib/arch/cpc/runtime/print.asm"
	    push namespace core
#line 136 "src/lib/arch/cpc/runtime/print.asm"
; __PRINTCHAR: prints the character/control code in A.
	; Preserves BC and HL (printstr.asm's loop does `call __PRINTCHAR`
	; then `inc hl` / `dec bc` with no push/pop of its own); clobbers AF,
	; DE, and, for the special codes, calls the firmware gate (which
	; clobbers BC'/DE'/HL'/AF').
__PRINTCHAR:
	    PROC
	    LOCAL __PC_NORMAL, __PC_OUT, __PC_STATE_DISPATCH, __PC_DONE
	    LOCAL __PC_TABLE, __PC_STATE_TABLE
	    LOCAL __PC_NOP, __PC_COMMA, __PC_DEL, __PC_DEL_COL, __PC_DEL_SAVE, __PC_DEL_RET
	    LOCAL __PC_NEWLINE_CODE
	    LOCAL __PC_ARM_AT, __PC_ARM_INK, __PC_ARM_PAPER, __PC_ARM_FLASH
	    LOCAL __PC_ARM_BRIGHT, __PC_ARM_INVERSE, __PC_ARM_OVER
	    LOCAL __PC_ARM_BOLD, __PC_ARM_ITALIC, __PC_ARM_TAB
	    LOCAL __PC_S_AT_ROW, __PC_S_AT_COL, __PC_S_INK, __PC_S_PAPER, __PC_S_FLASH
	    LOCAL __PC_S_BRIGHT, __PC_S_INVERSE, __PC_S_OVER, __PC_S_BOLD, __PC_S_ITALIC
	    LOCAL __PC_S_TAB1, __PC_S_TAB2
	    push hl
	    push bc
#line 162 "src/lib/arch/cpc/runtime/print.asm"
	    ld hl, PRINT_STATE
	    ld c, (hl)          ; C = pending state (0 = none)
	    ld (hl), 0          ; consumed; handlers below re-arm as needed
	    ld b, a             ; B = the char/code for this call
	    ld a, c
	    or a
	    jr nz, __PC_STATE_DISPATCH
	    ld a, b
	    cp 32
	    jr nc, __PC_NORMAL
	    ld hl, __PC_TABLE
	    ld a, b
	    call JUMP_HL_PLUS_2A
	    jr __PC_DONE
__PC_NORMAL:            ; printable char (32-255) -> TXT_OUTPUT
#line 195 "src/lib/arch/cpc/runtime/print.asm"
	    cp 144
	    jr nc, __PC_OUT
	    cp 128
	    jr c, __PC_OUT
	    ; Spectrum block graphics 128-143 are the CPC's 128-143 quadrant
    ; characters with the quadrants numbered differently (Spectrum bits:
    ; 0 top right, 1 top left, 2 bottom right, 3 bottom left; CPC: 0 top
	    ; left, 1 top right, 2 bottom left, 3 bottom right -- checked in the
	    ; emulator), so swap bits 0<->1 and 2<->3. No glyph table needed.
	    ld c, a
	    and $0A
	    rrca                ; bits 1, 3 -> 0, 2
	    ld b, a
	    ld a, c
	    and $05
	    rlca                ; bits 0, 2 -> 1, 3
	    or b
	    or $80
__PC_OUT:
	    call .core.__FW_CALL
	    defw $BB5A
#line 219 "src/lib/arch/cpc/runtime/print.asm"
	    jr __PC_DONE
#line 221 "src/lib/arch/cpc/runtime/print.asm"
__PC_STATE_DISPATCH:    ; C held a pending state -> this byte is its parameter
	    ld hl, __PC_STATE_TABLE
	    ld a, c
	    call JUMP_HL_PLUS_2A
__PC_DONE:
#line 231 "src/lib/arch/cpc/runtime/print.asm"
	    pop bc
	    pop hl
	    ret
	; ---- state-0 handlers (dispatched on the code itself, table below) ----
__PC_NOP:
	    ret
__PC_COMMA:
	    call PRINT_COMMA
	    ret
__PC_DEL:               ; cursor back one column, no VRAM erase
	    call __LOAD_S_POSN  ; D = row, E = column
	    ld a, e
	    or a
	    jr nz, __PC_DEL_COL
	    ld a, d
	    or a
    jr z, __PC_DEL_RET  ; already at (0,0): nothing to do
	    dec a
	    ld d, a
	    ld a, (TXT_COLS)
	    dec a
	    ld e, a             ; last column of the current mode
	    jr __PC_DEL_SAVE
__PC_DEL_COL:
	    dec e
__PC_DEL_SAVE:
	    call __SAVE_S_POSN
__PC_DEL_RET:
	    ret
__PC_NEWLINE_CODE:      ; CHR$(13): newline
	    call __PRINT_NEWLINE
	    ret
	; Shared by CHR$(13) and PRINT_EOL (end of a PRINT statement with no
	; trailing ";"). CR then LF, exactly like a Spectrum newline; the
	; firmware wraps/scrolls by itself.
; Firmware entry called (via the gate, twice): TXT_OUTPUT (&BB5A),
	; which preserves all registers.
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__PRINT_NEWLINE:
#line 283 "src/lib/arch/cpc/runtime/print.asm"
	    ld a, 13
	    call .core.__FW_CALL
	    defw $BB5A
	    ld a, 10
	    call .core.__FW_CALL
	    defw $BB5A
#line 290 "src/lib/arch/cpc/runtime/print.asm"
#line 293 "src/lib/arch/cpc/runtime/print.asm"
	    ret
__PC_ARM_AT:
	    ld a, 1
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_INK:
	    ld a, 3
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_PAPER:
	    ld a, 4
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_FLASH:
	    ld a, 5
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_BRIGHT:
	    ld a, 6
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_INVERSE:
	    ld a, 7
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_OVER:
	    ld a, 8
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_BOLD:
	    ld a, 9
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_ITALIC:
	    ld a, 10
	    ld (PRINT_STATE), a
	    ret
__PC_ARM_TAB:
	    ld a, 11
	    ld (PRINT_STATE), a
	    ret
__PC_TABLE:             ; codes 0-31, state 0 (fresh dispatch)
	    DW __PC_NOP         ;  0
	    DW __PC_NOP         ;  1
	    DW __PC_NOP         ;  2
	    DW __PC_NOP         ;  3
	    DW __PC_NOP         ;  4
	    DW __PC_NOP         ;  5
	    DW __PC_COMMA       ;  6 comma
	    DW __PC_NOP         ;  7 (BEEP on the CPC -- dropped)
	    DW __PC_DEL         ;  8 DEL
	    DW __PC_NOP         ;  9
	    DW __PC_NOP         ; 10
	    DW __PC_NOP         ; 11
	    DW __PC_NOP         ; 12 (CLS on the CPC -- dropped)
	    DW __PC_NEWLINE_CODE; 13 newline
	    DW __PC_ARM_BOLD    ; 14
	    DW __PC_ARM_ITALIC  ; 15
	    DW __PC_ARM_INK     ; 16
	    DW __PC_ARM_PAPER   ; 17
	    DW __PC_ARM_FLASH   ; 18
	    DW __PC_ARM_BRIGHT  ; 19
	    DW __PC_ARM_INVERSE ; 20
	    DW __PC_ARM_OVER    ; 21
	    DW __PC_ARM_AT      ; 22 AT
	    DW __PC_ARM_TAB     ; 23 TAB
	    DW __PC_NOP         ; 24
	    DW __PC_NOP         ; 25
	    DW __PC_NOP         ; 26
	    DW __PC_NOP         ; 27
	    DW __PC_NOP         ; 28
	    DW __PC_NOP         ; 29
	    DW __PC_NOP         ; 30
	    DW __PC_NOP         ; 31
	; ---- state-N handlers (dispatched on the pending state; B = param byte) ----
__PC_S_AT_ROW:          ; state 1: B = ROW, stash it, arm state 2
	    ld a, b
	    ld (MEM0), a
	    ld a, 2
	    ld (PRINT_STATE), a
	    ret
__PC_S_AT_COL:          ; state 2: B = COL; D = stashed ROW, E = COL
	    ld a, (MEM0)
	    ld d, a
	    ld e, b
	    call __SAVE_S_POSN  ; no bounds check -- matches zx48k's embedded AT
#line 388 "src/lib/arch/cpc/runtime/print.asm"
	    ret
__PC_S_INK:
	    ld a, b
	    call INK_TMP
	    ret
__PC_S_PAPER:
	    ld a, b
	    call PAPER_TMP
	    ret
__PC_S_FLASH:
	    ld a, b
	    call FLASH_TMP
	    ret
__PC_S_BRIGHT:
	    ld a, b
	    call BRIGHT_TMP
	    ret
__PC_S_INVERSE:
	    ld a, b
	    call INVERSE_TMP
	    ret
__PC_S_OVER:
	    ld a, b
	    call OVER_TMP
	    ret
__PC_S_BOLD:
	    ld a, b
	    call BOLD_TMP
	    ret
__PC_S_ITALIC:
	    ld a, b
	    call ITALIC_TMP
	    ret
__PC_S_TAB1:            ; state 11: B = 1st TAB byte, stash it, arm state 12
	    ld a, b
	    ld (MEM0), a
	    ld a, 12
	    ld (PRINT_STATE), a
	    ret
__PC_S_TAB2:            ; state 12: B = 2nd TAB byte, ignored (matches zx48k)
	    ld a, (MEM0)
	    call PRINT_TAB
	    ret
__PC_STATE_TABLE:       ; indexed by PRINT_STATE (1-12; entry 0 unused)
	    DW __PC_NOP         ;  0 (never dispatched)
	    DW __PC_S_AT_ROW    ;  1
	    DW __PC_S_AT_COL    ;  2
	    DW __PC_S_INK       ;  3
	    DW __PC_S_PAPER     ;  4
	    DW __PC_S_FLASH     ;  5
	    DW __PC_S_BRIGHT    ;  6
	    DW __PC_S_INVERSE   ;  7
	    DW __PC_S_OVER      ;  8
	    DW __PC_S_BOLD      ;  9
	    DW __PC_S_ITALIC    ; 10
	    DW __PC_S_TAB1      ; 11
	    DW __PC_S_TAB2      ; 12
	    ENDP
	; Called whenever a PRINT statement ends without a trailing ";".
PRINT_EOL:
	    jp __PRINT_NEWLINE
; PRINT comma: tabs to the next half-screen zone (column 20), or to
	; column 0 of the next line if already at or past column 20 -- half of
	; the 40-column screen, the CPC-sized equivalent of zx48k's 16-column
	; zones on its 32-column screen.
PRINT_COMMA:
	    PROC
	    LOCAL __PCM_HIGH, __PCM_TARGET
	    call __LOAD_S_POSN   ; E = current column (0-based)
	    ld a, (TXT_COLS)
    srl a                ; half the screen width: 10/20/40
	    cp e
	    jr z, __PCM_HIGH
    jr nc, __PCM_TARGET  ; left half: tab to the middle
__PCM_HIGH:
    ld a, (TXT_COLS)     ; right half: PRINT_TAB's modulo wraps this to
	                         ; a newline
__PCM_TARGET:
	    jp PRINT_TAB
	    ENDP
; Tabulates: prints spaces (via __PRINTCHAR, so the firmware's own
	; wrap/scroll applies normally) until the column reaches A, modulo the
	; current mode's width (TXT_COLS, colour.asm). If already there, does
	; nothing.
	;
	; zx48k's own PRINT_TAB computes the same thing with `sub e` then `and
; 31`: on its 32-column screen that's a valid mod-32 (32 is a power of
	; 2, so AND-masking a two's-complement negative difference gives the
	; correct positive modulo too). 40 is not a power of 2, so the
	; equivalent `and 39` mask is *wrong* here -- e.g. a raw delta of 10
; (0x0A) survives it unchanged (10 AND 39 = 2, not 10: 39 is 0b0100111,
	; not 0b0100111...1, so it clears bit 3 too). Reduce the target
	; explicitly modulo the width first, then wrap a negative difference by
	; adding the width instead.
PRINT_TAB:
	    PROC
	    LOCAL __PT_LOOP, __PT_REDUCE, __PT_GOTTARGET, __PT_POS
	    ld hl, TXT_COLS
__PT_REDUCE:            ; A (target column, as passed) mod TXT_COLS
	    cp (hl)
	    jr c, __PT_GOTTARGET
	    sub (hl)
	    jr __PT_REDUCE
__PT_GOTTARGET:
	    call __LOAD_S_POSN  ; E = current column (0-based); A (the reduced
	                         ; target) survives the call -- see sposn.asm
	    sub e                ; A = target - current, signed (|A| < 80)
	    jp p, __PT_POS
	    ld hl, TXT_COLS
	    add a, (hl)           ; wrap a negative difference into the line
__PT_POS:
	    or a
	    ret z
	    ld b, a
__PT_LOOP:
	    ld a, ' '
	    call __PRINTCHAR
	    djnz __PT_LOOP
	    ret
	    ENDP
; PRINT_AT: changes the cursor to ROW, COL (COL in A, ROW pushed on the
	; stack -- the compiler's own calling convention for `PRINT AT r,c`,
	; unchanged from zx48k). Row 0-24, column 0 to TXT_COLS-1 (0-19, 0-39
; or 0-79 by mode; Boriel's 0-based convention). Out of range: __STOP (error.asm) sets ERR_NR and
	; returns without moving the cursor -- the same "soft" behaviour
	; zx48k's own in_screen.asm gives PRINT AT (unlike a hard runtime
	; error, this does not print "Error n" or reset; the rest of the PRINT
	; statement continues from wherever the cursor already was).
PRINT_AT:
	    PROC
	    LOCAL __PA_ERR
	    pop hl        ; return address
	    ex (sp), hl   ; HL = pushed ROW word (H = ROW); stack top = return address
	    ld l, a       ; L = COL
	    ex de, hl     ; D = ROW, E = COL
	    ld a, d
	    cp SCR_ROWS
	    jr nc, __PA_ERR
	    ld a, (TXT_COLS)
	    dec a
	    cp e
	    jr c, __PA_ERR        ; column > last column of the current mode
	    call __SAVE_S_POSN
#line 562 "src/lib/arch/cpc/runtime/print.asm"
	    ret
__PA_ERR:
	    ld a, ERROR_OutOfScreen
	    jp __STOP
	    ENDP
	    pop namespace
#line 43 "tests/functional/arch/cpc/cpc_div32.bas"
#line 1 "src/lib/arch/zx48k/runtime/printu32.asm"
#line 1 "src/lib/arch/zx48k/runtime/printi32.asm"
#line 1 "src/lib/arch/zx48k/runtime/printnum.asm"
#line 1 "src/lib/arch/cpc/runtime/attr.asm"
; Phase-1 stub for zx48k/runtime/attr.asm (was: computing a Spectrum
	; attribute cell address from screen coordinates and mixing a byte into
	; it). The CPC has no per-cell attribute byte in memory (mode 1 colour
	; comes from the palette + pixel bits), so this needs a real design, not
	; just a relocated address -- SCREEN_ATTR_ADDR in sysvars.asm is only a
	; placeholder until then. Reached from the ATTR()/SETATTR()/ATTRADDR()
	; stdlib functions, and internally by sposn.asm, set_pixel_addr_attr.asm
	; and print.asm.
; TODO(cpc): Phase 4a -> a CPC-native colour-cell design.
#line 1 "src/lib/arch/cpc/runtime/stub.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC -- shared "not implemented yet" target
	;
	; Runtime files ported from zx48k that are not yet implemented for the
	; CPC (print.asm, plot.asm, error.asm, load.asm, ...) `jp
	; .core.__CPC_NOT_IMPLEMENTED` instead of leaving a dangling reference or
	; emitting incorrect Spectrum-specific code.
	;
	; This hangs the machine visibly (di + halt) rather than doing something
	; wrong silently. It is deliberately distinct from END's `rst 0` (a full
; firmware reset back to BASIC, see src/arch/cpc/backend/generic.py): a
	; reset would look like the program finished normally, which would hide
	; the bug this is meant to surface.
	;
; Phase-3 printer echo (-D __CPC_PRINTER_ECHO__): a hang looks the same
	; from outside as a real timeout, so cpcbuild's cpcrun.py can only tell
	; the two apart (both time out) unless the stub leaves a clue. Cheap to
; do: print "NOT IMPLEMENTED" to the printer (MC_PRINT_CHAR &BD2B,
	; direct gate calls -- print.asm isn't necessarily linked in) before the
	; di/halt. Interrupts are still enabled at this point (the prologue's
	; own `di` is long past, and nothing here disables them), so the gate's
	; own `ei`/`di` bracket around each character is safe.
#line 30 "src/lib/arch/cpc/runtime/stub.asm"
	    push namespace core
	; __CPC_NOT_IMPLEMENTED -- hangs the CPU. Nothing calls or returns from
	; this; it is a dead end reached only by a `jp` from an unfinished stub.
; Firmware entry called: none. Registers clobbered: none (never returns).
__CPC_NOT_IMPLEMENTED:
#line 70 "src/lib/arch/cpc/runtime/stub.asm"
	    di
	    halt
#line 73 "src/lib/arch/cpc/runtime/stub.asm"
	    pop namespace
#line 12 "src/lib/arch/cpc/runtime/attr.asm"
	    push namespace core
__ATTR_ADDR:
	    jp __CPC_NOT_IMPLEMENTED
SET_ATTR:
	    jp __CPC_NOT_IMPLEMENTED
__SET_ATTR:
	    jp __CPC_NOT_IMPLEMENTED
__SET_ATTR2:
	    jp __CPC_NOT_IMPLEMENTED
	    pop namespace
#line 3 "src/lib/arch/zx48k/runtime/printnum.asm"
	    push namespace core
__PRINTU_START:
	    PROC
	    LOCAL __PRINTU_CONT
	    ld a, b
	    or a
	    jp nz, __PRINTU_CONT
	    ld a, '0'
	    jp __PRINT_DIGIT
__PRINTU_CONT:
	    pop af
	    push bc
	    call __PRINT_DIGIT
	    pop bc
	    djnz __PRINTU_CONT
	    ret
	    ENDP
__PRINT_MINUS: ; PRINT the MINUS (-) sign. CALLER must preserve registers
	    ld a, '-'
	    jp __PRINT_DIGIT
	__PRINT_DIGIT EQU __PRINTCHAR ; PRINTS the char in A register, and puts its attrs
	    pop namespace
#line 2 "src/lib/arch/zx48k/runtime/printi32.asm"
	    push namespace core
__PRINTI32:
	    ld a, d
	    or a
	    jp p, __PRINTU32
	    call __PRINT_MINUS
	    call __NEG32
__PRINTU32:
	    PROC
	    LOCAL __PRINTU_LOOP
	    ld b, 0 ; Counter
__PRINTU_LOOP:
	    ld a, h
	    or l
	    or d
	    or e
	    jp z, __PRINTU_START
	    push bc
	    ld bc, 0
	    push bc
	    ld bc, 10
	    push bc		  ; Push 00 0A (10 Dec) into the stack = divisor
	    call __DIVU32 ; Divides by 32. D'E'H'L' contains modulo (L' since < 10)
	    pop bc
	    exx
	    ld a, l
	    or '0'		  ; Stores ASCII digit (must be print in reversed order)
	    push af
	    exx
	    inc b
	    jp __PRINTU_LOOP ; Uses JP in loops
	    ENDP
	    pop namespace
#line 2 "src/lib/arch/zx48k/runtime/printu32.asm"
#line 44 "tests/functional/arch/cpc/cpc_div32.bas"
#line 1 "src/lib/arch/cpc/runtime/swap32.asm"
	; Exchanges current DE HL with the
	; ones in the stack
	; cpc override of zx48k/runtime/swap32.asm. The original moves SP up
	; over the stacked value (INC SP x2) and back (DEC SP x2) while it swaps
	; the high words, so for those few instructions the stacked low word
	; sits BELOW SP, where an interrupt's pushes overwrite it. Harmless-ish
	; on the Spectrum (one interrupt per frame), but compiled cpc code runs
	; with interrupts on at 300 Hz and that window corrupted about one
	; 32-bit division in 200 (a / 120 with a ULONG, MOD, anything the
	; compiler swaps operands for). This version only ever PUSHes and POPs, so
	; everything live is at or above SP at every instruction. The alternate
	; bank is used as scratch (the 32-bit operations this precedes clobber it
	; anyway); AF is preserved, as in the original.
; Registers clobbered: BC', DE', HL'.
	    push namespace core
__SWAP32:
	    exx
	    pop hl              ; HL' = return address
	    pop bc              ; BC' = stacked low word
	    exx
	    ex de, hl           ; HL = old DE, DE = old HL
	    ex (sp), hl         ; HL = stacked high word; stacked high word = old DE
	    push de             ; stacked low word = old HL
	    ex de, hl           ; DE = stacked high word
	    exx
	    push bc
	    exx
	    pop hl              ; HL = stacked low word
	    exx
	    push hl             ; return address
	    exx
	    ret
	    pop namespace
#line 45 "tests/functional/arch/cpc/cpc_div32.bas"
	END
