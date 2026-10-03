	org 4096
	.core.CPC_PRIV_BASE EQU 40448
	.core.CPC_PRIV_SIZE EQU 1024
	.core.CPC_STACK_TOP EQU 42496
	.core.CPC_MEM_TOP EQU 42619
.core.__START_PROGRAM:
	di
	ld sp, .core.CPC_STACK_TOP
	call .core.CPC_INIT_00_BOOTSTRAP
	call .core.CPC_INIT_CB_CORE
	jp .core.__MAIN_PROGRAM__
.core.ZXBASIC_USER_DATA:
	; Defines USER DATA Length in bytes
.core.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_END - .core.ZXBASIC_USER_DATA
	.core.__LABEL__.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_LEN
	.core.__LABEL__.ZXBASIC_USER_DATA EQU .core.ZXBASIC_USER_DATA
_ts:
	DEFW .LABEL.__LABEL0
_ts.__DATA__.__PTR__:
	DEFW _ts.__DATA__
	DEFW 0
	DEFW 0
_ts.__DATA__:
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
.LABEL.__LABEL0:
	DEFW 0000h
	DEFB 01h
_map:
	DEFW .LABEL.__LABEL1
_map.__DATA__.__PTR__:
	DEFW _map.__DATA__
	DEFW 0
	DEFW 0
_map.__DATA__:
	DEFB 00h
	DEFB 01h
	DEFB 01h
	DEFB 00h
.LABEL.__LABEL1:
	DEFW 0000h
	DEFB 01h
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	ld hl, _ts.__DATA__
	call _SetTileSet
	xor a
	push af
	ld a, 2
	push af
	ld a, 1
	push af
	call _DoTile8
	xor a
	push af
	ld a, 3
	push af
	ld a, 2
	push af
	call _DoTile16
	ld a, 2
	push af
	ld a, 2
	push af
	xor a
	push af
	xor a
	push af
	ld hl, _map.__DATA__
	push hl
	call _TileMap
	ld a, 2
	push af
	ld a, 1
	push af
	ld a, 4
	push af
	ld a, 4
	push af
	ld a, 2
	push af
	ld hl, _map.__DATA__
	push hl
	call _TileMapPart
	ld a, 8
	push af
	ld a, 4
	push af
	xor a
	push af
	xor a
	push af
	ld a, 2
	push af
	ld hl, _map.__DATA__
	push hl
	call _TileRestore
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	jp .core.__CPC_END
_SetTileSet:
#line 48 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
		ld (.core.CB_TILESET), hl
#line 51 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
_SetTileSet__leave:
	ret
_DoTile8:
	push ix
	ld ix, 0
	add ix, sp
#line 54 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
		push namespace core
		ld c, (ix+5)
		ld b, (ix+7)
		ld l, (ix+9)
		ld h, 0
		call __CB_TILE_AT
		pop namespace
#line 63 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
_DoTile8__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	pop bc
	ex (sp), hl
	exx
	ret
_DoTile16:
	push ix
	ld ix, 0
	add ix, sp
#line 66 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
		push namespace core
		ld c, (ix+5)
		ld b, (ix+7)
		ld a, (ix+9)
		call __CB_TILE16
		pop namespace
#line 74 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
_DoTile16__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	pop bc
	ex (sp), hl
	exx
	ret
_TileMap:
	push ix
	ld ix, 0
	add ix, sp
#line 77 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
		push namespace core
		ld l, (ix+4)
		ld h, (ix+5)
		ld e, (ix+7)
		ld d, (ix+9)
		ld c, (ix+11)
		ld b, (ix+13)
		call __CB_TILEMAP
		pop namespace
#line 88 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
_TileMap__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	pop bc
	pop bc
	pop bc
	ex (sp), hl
	exx
	ret
_TileMapPart:
	push ix
	ld ix, 0
	add ix, sp
#line 91 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
		push namespace core
		ld l, (ix+4)
		ld h, (ix+5)
		ld e, (ix+9)
		ld d, (ix+11)
		ld c, (ix+13)
		ld b, (ix+15)
		ld a, (ix+7)
		call __CB_TILEMAP_S
		pop namespace
#line 103 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
_TileMapPart__leave:
	exx
	ld hl, 12
__EXIT_FUNCTION:
	ld sp, ix
	pop ix
	pop de
	add hl, sp
	ld sp, hl
	push de
	exx
	ret
_TileRestore:
	push ix
	ld ix, 0
	add ix, sp
#line 106 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
		push namespace core
		ld l, (ix+4)
		ld h, (ix+5)
		ld e, (ix+9)
		ld d, (ix+11)
		ld c, (ix+13)
		ld b, (ix+15)
		ld a, (ix+7)
		call __CB_TILE_RESTORE
		pop namespace
#line 118 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
_TileRestore__leave:
	exx
	ld hl, 12
	jp __EXIT_FUNCTION
	;; --- end of user code ---
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
#line 1 "src/lib/arch/cpc/runtime/sysvars.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC system variables
	;
	; zx48k's own sysvars.asm and the runtime files ported from it hard-code
	; Spectrum sysvar addresses ($5C00-$5CB5), which are ordinary program RAM
	; on the CPC (inside the code/data area, $1000 up); using them as-is would
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
;   $C0     1     CB_BASE            cpcbuild/core.asm: high byte of the
	;                                    screen the library draws on (&C0, or
	;                                    &40 for the double-buffer back screen)
;   $C1     1     CB_SHOWN           cpcbuild/core.asm: high byte of the
	;                                    screen being displayed
;   $C2     2     CB_OFFSET          cpcbuild/core.asm: the firmware's
	;                                    hardware-scroll offset, 0-&7FE bytes
;   $C4     1     CB_DBUF            cpcbuild/core.asm: 1 = double buffering
;   $C5     2     CB_TILESET         cpcbuild tiles: current tileset
;   $C7     10    CB_KEYS            cpcbuild keyboard: the last matrix
;                                    scan, rows 0-9 (bit = 0: pressed)
;   $D1     16    SND_ENV            fwsound.asm: volume envelope data
	;                                    buffer for SOUND_AMPL_ENVELOPE
	;   ------  ----
	;   $E1     (225 bytes used)
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
	; $E1 bytes used out of CPC_PRIV_SIZE ($400 = 1024). CPC_SYSVARS_USED
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
	CB_BASE             EQU SYSVAR_BASE + $C0   ; DB -- screen the library draws on (high byte)
	CB_SHOWN            EQU SYSVAR_BASE + $C1   ; DB -- screen displayed (high byte)
	CB_OFFSET           EQU SYSVAR_BASE + $C2   ; DW -- hardware-scroll offset (bytes)
	CB_DBUF             EQU SYSVAR_BASE + $C4   ; DB -- 1 = double buffering on
	CB_TILESET          EQU SYSVAR_BASE + $C5   ; DW -- current tileset address
	CB_KEYS             EQU SYSVAR_BASE + $C7   ; 10B -- keyboard matrix scan
	SND_ENV             EQU SYSVAR_BASE + $D1   ; 16B -- envelope data buffer (fwsound.asm)
	CPC_SYSVARS_USED    EQU $E1                 ; bytes used above; compare by eye against
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
#line 30 "src/lib/arch/cpc/runtime/bootstrap.asm"
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
#line 31 "src/lib/arch/cpc/runtime/bootstrap.asm"
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
; Cost: about 250 T-states on top of the firmware's handler, 300 times
	; a second. See cpcbuild docs/phase4d-design.md.
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
	    inc  a
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
__CPC_ISR_DIRECT:
	    pop  af
__CPC_ISR_ORIG:
	    jp   $FFFF              ; patched by __CPC_ISR_INSTALL
	    pop namespace
#line 32 "src/lib/arch/cpc/runtime/bootstrap.asm"
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
#line 33 "src/lib/arch/cpc/runtime/bootstrap.asm"
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
#line 171 "src/lib/arch/cpc/runtime/bootstrap.asm"
__CPC_END:
#line 198 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    call __CPC_WAIT_KEY
	    di
	    rst  0
#line 202 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    pop namespace
#line 125 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
#line 1 "src/lib/arch/cpc/runtime/cpcbuild/tiles.asm"
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
#line 1 "src/lib/arch/cpc/runtime/cpcbuild/core.asm"
	; -----------------------------------------------------------------------
	; cpcbuild library core -- screen addressing for direct screen writes
	;
	; Written from scratch for this project (MIT, like Boriel's runtime),
	; from public documentation of the CPC's screen layout; no code from
	; CPCtelera or other libraries (cpcbuild/docs/notes.md, 2026-10-01).
	;
; Library coordinates (notes.md, Q-4c.2): x in BYTES (0-79), y in pixel
	; lines (0-199), from the top-left. A byte is 2 pixels in mode 0, 4 in
	; mode 1, 8 in mode 2, in every mode 80 bytes per line.
	;
; Screen layout: 16 KB at CB_BASE*256 (&C000, or &4000 for the
	; double-buffer back screen), as eight 2 KB blocks, one per pixel line
; within a character row: line y is in block (y AND 7), at byte
	; (y >> 3) * 80 + x of that block -- plus the hardware-scroll offset
	; (below), wrapping within the 2 KB block.
	;
; Hardware scroll (Q-4c.3): when the firmware scrolls text it moves the
	; CRTC's start address rather than copying the screen, so after a
	; scroll the top-left byte is at CB_OFFSET (0-&7FE) into each block.
	; __CB_SYNC reads it from the firmware (SCR_GET_LOCATION); the library
	; calls it in ScreenInit and after every WaitRetrace/FlipBuffer. All
	; addresses below include it, and wrap at the end of the 2 KB block.
	; Because of the offset, a row of bytes can cross the end of its block
; (it continues at the block's start): __CB_ROW_WRAPS tells a drawing
	; routine when to use the careful per-byte path (__CB_INC_X).
	;
	; The CB_* variables are in the private runtime block (sysvars.asm).
	    push namespace core
; CPC_INIT_CB_CORE -- start-up defaults: draw on and show &C000, no
	; scroll offset yet (the bootstrap's SCR_SET_MODE has just reset it).
; Firmware entry called: none. Registers clobbered: AF.
CPC_INIT_CB_CORE:
	    ld   a, $C0
	    ld   (CB_BASE), a
	    ld   (CB_SHOWN), a
	    ret
	; __CB_SYNC -- reads the firmware's screen base and hardware-scroll
	; offset. Outside double buffering, the library draws on the screen the
	; firmware shows; with double buffering on, CB_BASE/CB_SHOWN are kept
	; by FlipBuffer and only the offset is read.
; Firmware entry called: SCR_GET_LOCATION (&BC0B, -> A = base high
	; byte, HL = offset in bytes).
; Registers clobbered: AF, HL (main); BC', DE', HL', AF' (the gate).
__CB_SYNC:
	    call .core.__FW_CALL
	    defw $BC0B
	    ld   (CB_OFFSET), hl
	    ld   l, a
	    ld   a, (CB_DBUF)
	    or   a
	    ret  nz
	    ld   a, l
	    ld   (CB_BASE), a
	    ld   (CB_SHOWN), a
	    ret
	; __CB_ADDR -- B = y (pixel line 0-199), C = x (byte 0-79) -> HL = its
	; address on the screen the library draws on. No range check.
; Firmware entry called: none.
; Registers clobbered: AF, DE, HL. B and C are preserved.
__CB_ADDR:
	    ld   a, b
	    and  $F8                ; 8 * (y >> 3)
	    ld   l, a
	    ld   h, 0
	    add  hl, hl             ; 16 * (y >> 3)
	    ld   d, h
	    ld   e, l
	    add  hl, hl
	    add  hl, hl             ; 64 * (y >> 3)
	    add  hl, de             ; 80 * (y >> 3)
	    ld   e, c
	    ld   d, 0
	    add  hl, de             ; + x
	    ld   de, (CB_OFFSET)
	    add  hl, de             ; + scroll offset
	    ld   a, h
	    and  $07                ; wrap within the 2 KB block
	    ld   h, a
	    ld   a, b
	    and  $07
	    add  a, a
	    add  a, a
	    add  a, a               ; block (y AND 7) * 8 (high byte)
	    or   h
	    ld   h, a
	    ld   a, (CB_BASE)
	    or   h
	    ld   h, a
	    ret
	; __CB_NEXT_LINE -- HL = an address on line y -> the same x on line
	; y + 1. Line 199 goes on to an address past the bottom of the screen;
	; callers clip before that.
; Firmware entry called: none.
; Registers clobbered: AF, HL.
__CB_NEXT_LINE:
	    ld   a, h
	    add  a, 8               ; next block = next pixel line
	    ld   h, a
	    and  $38
	    ret  nz                 ; same character row
    ld   a, l               ; crossed into the next character row:
	    add  a, 80              ; block 0, 80 bytes on, wrapping within it
	    ld   l, a
	    ld   a, h
	    adc  a, 0
	    and  $07
	    ld   h, a
	    ld   a, (CB_BASE)
	    or   h
	    ld   h, a
	    ret
	; __CB_INC_X -- HL = HL + 1 within its 2 KB block (the byte after the
	; block's last one is its first). The slow path for rows that wrap.
; Firmware entry called: none.
; Registers clobbered: AF, HL.
__CB_INC_X:
	    inc  l
	    ret  nz
	    inc  h
	    ld   a, h
	    and  $07
	    ret  nz
	    ld   a, h
	    sub  8
	    ld   h, a
	    ret
	; __CB_ROW_WRAPS -- HL = the first byte of a row, C = its width in bytes
	; (1-80) -> Carry set if the row crosses the end of its 2 KB block (use
	; __CB_INC_X), clear if plain INC HL / LDI work for the whole row.
; Firmware entry called: none.
; Registers clobbered: AF, DE.
__CB_ROW_WRAPS:
	    PROC
	    LOCAL __CRW_FITS, __CRW_WRAPS
	    ld   a, h
	    and  $07
	    ld   d, a
	    ld   a, l
	    add  a, c
	    ld   e, a
	    ld   a, d
    adc  a, 0               ; A:E = position in block + width
	    cp   $08
	    jr   c, __CRW_FITS      ; < &800
	    jr   nz, __CRW_WRAPS
	    ld   a, e
	    or   a
    jr   z, __CRW_FITS      ; exactly &800: ends on the block's last byte
__CRW_WRAPS:
	    scf
	    ret
__CRW_FITS:
	    or   a
	    ret
	    ENDP
	    pop namespace
#line 21 "src/lib/arch/cpc/runtime/cpcbuild/tiles.asm"
#line 1 "src/lib/arch/cpc/runtime/cpcbuild/nowrap.asm"
	; -----------------------------------------------------------------------
	; cpcbuild library -- the "no row can wrap" test used by the fast paths
	;
	; Written from scratch for this project (MIT); see core.asm. Kept in a
	; file of its own (not core.asm) so that programs that use only the
	; display and keyboard routines don't carry it.
	; -----------------------------------------------------------------------
	    push namespace core
	; __CB_NOWRAP -- Carry set if no row on the screen can wrap around the
	; end of its 2 KB block, i.e. the hardware-scroll offset is 48 or less
	; (the last row's last byte is then at offset + 24*80 + 79 < 2048). True
	; whenever the text hasn't scrolled, so then the routines can skip the
	; per-row __CB_ROW_WRAPS test and use their unrolled fast paths.
; Firmware entry called: none. Registers clobbered: AF.
__CB_NOWRAP:
	    ld   a, (CB_OFFSET + 1)
	    or   a
    ret  nz                 ; 256 or more: Carry clear
	    ld   a, (CB_OFFSET)
	    cp   49                 ; Carry set if 48 or less
	    ret
	    pop namespace
#line 22 "src/lib/arch/cpc/runtime/cpcbuild/tiles.asm"
	    push namespace core
	; __CB_TILE_PTR -- HL = tile number (0-1023) -> DE = its data address.
; Firmware entry called: none.
; Registers clobbered: AF, DE, HL.
__CB_TILE_PTR:
	    PROC
	    LOCAL __CTP_DONE
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl             ; * 8
	    ld   a, (GFX_XSHIFT)
	    or   a
	    jr   z, __CTP_DONE
	    add  hl, hl             ; * 16 (mode 1)
	    dec  a
	    jr   z, __CTP_DONE
	    add  hl, hl             ; * 32 (mode 0)
__CTP_DONE:
	    ld   de, (CB_TILESET)
	    add  hl, de
	    ex   de, hl
	    ret
	    ENDP
	; Unrolled tile drawers, one per width W (4, 2, 1 bytes). The tile's 8 rows
	; are copied with LDI chains; the screen address is stepped to the next
	; row (+2 KB) between rows through HL (ADD HL,BC), so no page-crossing
	; care is needed. The caller guarantees no row wraps in its 2 KB block.
; __CTD_Gn: HL = the tile's data, DE = its screen address (on pixel line 0
	; of a character row). On return DE = screen address + 7 * 2 KB + W (so
	; the tile's address plus W is D - $38) and HL = the data after the tile.
; __CTD_Un: HL = screen address, DE = data (swaps, then as Gn).
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CTD_U4:
	    ex   de, hl
__CTD_G4:
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 4
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ldi
	    ldi
	    ret
__CTD_U2:
	    ex   de, hl
__CTD_G2:
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 2
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ldi
	    ret
__CTD_U1:
	    ex   de, hl
__CTD_G1:
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ex   de, hl
	    ld   bc, $800 - 1
	    add  hl, bc
	    ex   de, hl
	    ldi
	    ret
	; __CB_TILE_DRAW -- HL = screen address of the tile's first byte (on
	; pixel line 0 of a character row), DE = its data -> draws the tile.
	; The row-wrap test is only needed in the last 256 bytes of a block; a
	; tile that can't wrap goes to the unrolled drawer for the mode.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILE_DRAW:
	    PROC
	    LOCAL __CTD_FAST, __CTD_F1, __CTD_F2
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
	    or   a
	    jr   z, __CTD_F1
	    dec  a
	    jr   z, __CTD_F2
	    jp   __CTD_U4
__CTD_F2:
	    jp   __CTD_U2
__CTD_F1:
	    jp   __CTD_U1
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
	; y >= 25). One branch per mode, each with its own shifts (data address =
	; TILESET + n * 8 W, byte column = W x) and straight to its unrolled
	; drawer unless the tile is in the last 256 bytes of the block (where it
; could wrap: __CB_TILE_DRAW does the checking).
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILE_AT:
	    PROC
	    LOCAL __CTA_M1, __CTA_M2
	    ld   a, b
	    cp   25
	    ret  nc                 ; below the screen
	    ld   a, (GFX_XSHIFT)
	    or   a
	    jr   z, __CTA_M2
	    dec  a
	    jr   z, __CTA_M1
    ld   a, c               ; mode 0: 20 cells of 4 bytes
	    cp   20
	    ret  nc
	    add  a, a
	    add  a, a
	    ld   c, a               ; C = byte column
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl             ; * 32
	    ld   de, (CB_TILESET)
	    add  hl, de
	    ex   de, hl             ; DE = the tile's data
	    call __CB_CELL_ADDR     ; HL = its screen address
	    ld   a, h
	    and  $07
	    cp   $07
	    jp   nz, __CTD_U4
	    jp   __CB_TILE_DRAW
__CTA_M1:
    ld   a, c               ; mode 1: 40 cells of 2 bytes
	    cp   40
	    ret  nc
	    add  a, a
	    ld   c, a
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl             ; * 16
	    ld   de, (CB_TILESET)
	    add  hl, de
	    ex   de, hl
	    call __CB_CELL_ADDR
	    ld   a, h
	    and  $07
	    cp   $07
	    jp   nz, __CTD_U2
	    jp   __CB_TILE_DRAW
__CTA_M2:
    ld   a, c               ; mode 2: 80 cells of 1 byte
	    cp   80
	    ret  nc
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl             ; * 8
	    ld   de, (CB_TILESET)
	    add  hl, de
	    ex   de, hl
	    call __CB_CELL_ADDR
	    ld   a, h
	    and  $07
	    cp   $07
	    jp   nz, __CTD_U1
	    jp   __CB_TILE_DRAW
	    ENDP
	; __CB_CELL_ADDR -- B = cell y (0-24), C = byte column (0-79) -> HL = the
	; address of that byte on pixel line 0 of the character row, i.e. in
; block 0: BASE | ((OFFSET + 80 y + x) AND &7FF), with 5 y as a byte and
	; 80 y as 16 times that. DE is preserved.
; Firmware entry called: none. Registers clobbered: AF, BC, HL.
__CB_CELL_ADDR:
	    ld   a, b
	    add  a, a
	    add  a, a
	    add  a, b               ; 5 y (at most 120)
	    ld   l, a
	    ld   h, 0
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl             ; 80 y
	    ld   b, 0
	    add  hl, bc             ; + byte column
	    ld   bc, (CB_OFFSET)
	    add  hl, bc             ; + scroll offset
	    ld   a, h
	    and  $07                ; wrap within the 2 KB block
	    ld   h, a
	    ld   a, (CB_BASE)
	    or   h
	    ld   h, a
	    ret
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
; row). __CB_TILEMAP_S: the same with A = the map's row length in bytes
	; (>= C), for a block out of a wider map. Draws the block of 8x8 tiles with its top-left at cell (x, y),
	; skipping cells off the screen. Per row the first address comes from
; __CB_ADDR, then each tile's is the previous plus W. Two row loops:
	; when no row of the screen can wrap in its block (__CB_NOWRAP) the fast
	; one (__CTM_F4/F2/F1, one per mode, see below) draws each tile with the
	; unrolled drawer and no wrap handling; otherwise the general one wraps
	; at the block end by clearing bit 3 of H (valid because a tile starts in
	; block 0, so a carry out of the block is the only way that bit gets set)
	; and draws through __CB_TILE_DRAW, which checks the tile for a wrap.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILEMAP:
	    PROC
	    LOCAL __CTM_LIM, __CTM_LIMD, __CTM_SH, __CTM_SHD, __CTM_ROW
	    LOCAL __CTM_TILE, __CTM_V1, __CTM_R1, __CTM_FROW, __CTM_RS, __CTM_RD
	    LOCAL __CTM_FM2, __CTM_FM1, __CTM_FNEXT, __CTM_TAIL
	    ld   a, c               ; map rows are as long as the block
__CB_TILEMAP_S:             ; (entry with A = map row length)
	    ld   (__CTM_ROWMAP), hl
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
	    ld   a, (GFX_XSHIFT)    ; run length in bytes = visible tiles * W
	    ld   b, a
	    ld   a, (__CTM_VIS)
	    inc  b
__CTM_RS:
	    dec  b
	    jr   z, __CTM_RD
	    add  a, a
	    jr   __CTM_RS
__CTM_RD:
	    ld   (__CTM_RUNB), a
    call __CB_NOWRAP        ; Carry set: no row can wrap
	    ld   a, 0
	    adc  a, 0
	    ld   (__CTM_FAST), a
__CTM_ROW:
	    ld   a, (__CTM_FAST)
	    or   a
	    jr   nz, __CTM_FROW
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
__CTM_TAIL:
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
__CTM_FROW:                 ; fast row: the whole run of tiles
	    ld   a, (__CTM_Y)
	    add  a, a
	    add  a, a
	    add  a, a
	    ld   b, a
	    ld   a, (__CTM_XB)
	    ld   c, a
	    call __CB_ADDR
	    ex   de, hl             ; DE = address of the first tile
	    ld   a, (__CTM_RUNB)
	    add  a, e
	    ld   (__CTM_END), a     ; the low byte the run ends at
	    ld   hl, (__CTM_ROWMAP)
	    ld   a, (GFX_XSHIFT)
	    or   a
	    jr   z, __CTM_FM1
	    dec  a
	    jr   z, __CTM_FM2
	    call __CTM_F4
	    jr   __CTM_FNEXT
__CTM_FM2:
	    call __CTM_F2
	    jr   __CTM_FNEXT
__CTM_FM1:
	    call __CTM_F1
__CTM_FNEXT:
	    jp   __CTM_TAIL
	    ENDP
; The fast row loops, one per width W = 4, 2, 1 (modes 0, 1, 2): HL = the
	; map row, DE = screen address of the first tile; draws tiles until the
	; screen address' low byte reaches __CTM_END (the run is at most 80 bytes,
; so the low byte is unambiguous). Per tile: its data address is
	; TILESET + n * 8 W (the shift by 3 + log2 W is done by rotating the
	; byte, which is shorter than shifting a pair); the drawer leaves DE at
	; the tile's address + 7 * 2 KB + W, so the next tile's address is DE - 7 * 2 KB.
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CTM_F4:
	    ld   a, (hl)
	    inc  hl
	    push hl
	    rrca
	    rrca
    rrca                    ; n * 32 as a pair: high = n >> 3, low = n << 5
	    ld   l, a
	    and  $1F
	    ld   h, a
	    ld   a, l
	    and  $E0
	    ld   l, a
	    ld   bc, (CB_TILESET)
	    add  hl, bc
	    call __CTD_G4
	    ld   a, d
	    sub  $38
	    ld   d, a
	    pop  hl
	    ld   a, (__CTM_END)
	    cp   e
	    jr   nz, __CTM_F4
	    ret
__CTM_F2:
	    ld   a, (hl)
	    inc  hl
	    push hl
	    rrca
	    rrca
	    rrca
    rrca                    ; n * 16: high = n >> 4, low = n << 4
	    ld   l, a
	    and  $0F
	    ld   h, a
	    ld   a, l
	    and  $F0
	    ld   l, a
	    ld   bc, (CB_TILESET)
	    add  hl, bc
	    call __CTD_G2
	    ld   a, d
	    sub  $38
	    ld   d, a
	    pop  hl
	    ld   a, (__CTM_END)
	    cp   e
	    jr   nz, __CTM_F2
	    ret
__CTM_F1:
	    ld   a, (hl)
	    inc  hl
	    push hl
	    rlca
	    rlca
    rlca                    ; n * 8: high = n >> 5, low = n << 3
	    ld   l, a
	    and  $07
	    ld   h, a
	    ld   a, l
	    and  $F8
	    ld   l, a
	    ld   bc, (CB_TILESET)
	    add  hl, bc
	    call __CTD_G1
	    ld   a, d
	    sub  $38
	    ld   d, a
	    pop  hl
	    ld   a, (__CTM_END)
	    cp   e
	    jr   nz, __CTM_F1
	    ret
	; Working storage of __CB_TILEMAP (never executed; in the code stream).
	; __CB_TILE_RESTORE -- redraws the tiles under a screen rectangle, from
; a map laid out from screen cell (0, 0): HL = map, A = its row length
	; in bytes, E = x (byte column), D = y (pixel line), C = width in bytes
	; (>= 1), B = height in lines (>= 1). Draws every 8x8 cell the rectangle
	; touches (cells x >> s .. (x + w - 1) >> s and y >> 3 .. (y + h - 1) >> 3,
	; where the tile is 2^s bytes wide). Meant for erasing a sprite in one
; call, so the usual case is short: when every cell is on the screen and
	; no row can wrap (__CB_NOWRAP) it works out the first screen address
	; and map byte once and runs the fast row loop of the mode (__CTM_F4/F2/
	; F1) row by row, stepping 80 bytes and one map row. Otherwise it goes
	; through __CB_TILEMAP_S, which clips and wraps.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_TILE_RESTORE:
	    PROC
	    LOCAL __CTR_SH, __CTR_SHD, __CTR_CL, __CTR_CLD, __CTR_XS, __CTR_XSD
	    LOCAL __CTR_RS, __CTR_RSD, __CTR_FS, __CTR_MUL, __CTR_MULN
	    LOCAL __CTR_ROW, __CTR_CALL, __CTR_SLOW, __CTR_SM, __CTR_SMD
	    ld   (__CTR_STRIDE), a
	    ld   (__CTR_MAP), hl
	    ld   a, d               ; last cell row = (y + h - 1) >> 3
	    add  a, b
	    dec  a
	    rrca
	    rrca
	    rrca
	    and  $1F
	    ld   b, a
	    ld   a, d               ; first cell row = y >> 3
	    rrca
	    rrca
	    rrca
	    and  $1F
	    ld   d, a
	    ld   a, b
	    sub  d
	    inc  a
	    ld   b, a               ; B = cell rows
	    ld   a, e               ; C = last byte column, x + w - 1
	    add  a, c
	    dec  a
	    ld   c, a
	    ld   a, (GFX_XSHIFT)
__CTR_SH:                   ; to cell columns: C = last, E = first
	    or   a
	    jr   z, __CTR_SHD
	    srl  c
	    srl  e
	    dec  a
	    jr   __CTR_SH
__CTR_SHD:
	    ld   a, c
	    sub  e
	    inc  a
	    ld   c, a               ; C = cell columns
    ; --- the short way: every cell on the screen, no row can wrap ---
	    ld   a, d
	    add  a, b
	    cp   26
	    jp   nc, __CTR_SLOW     ; below the last cell row
	    push bc
    ld   a, (GFX_XSHIFT)    ; cells per screen row: 80 >> s
	    ld   b, a
	    inc  b
	    ld   a, 80
__CTR_CL:
	    dec  b
	    jr   z, __CTR_CLD
	    srl  a
	    jr   __CTR_CL
__CTR_CLD:
	    ld   b, a
	    ld   a, e
	    add  a, c
	    dec  a                  ; last cell column
	    cp   b
	    pop  bc
	    jp   nc, __CTR_SLOW     ; off the right edge
    call __CB_NOWRAP        ; Carry set: no row can wrap (A only)
	    jp   nc, __CTR_SLOW
	    ld   a, b
	    ld   (__CTR_ROWS), a
	    push de
	    push bc
	    ld   a, d               ; screen address of cell (E, D)
	    add  a, a
	    add  a, a
	    add  a, a
	    ld   b, a               ; B = pixel line
	    ld   c, e
	    ld   a, (GFX_XSHIFT)
__CTR_XS:
	    or   a
	    jr   z, __CTR_XSD
	    sla  c                  ; C = byte column
	    dec  a
	    jr   __CTR_XS
__CTR_XSD:
	    call __CB_ADDR
	    ld   (__CTR_SCR), hl
	    pop  bc
	    ld   a, (GFX_XSHIFT)    ; run length in bytes = columns << s
	    ld   h, a
	    ld   a, c
__CTR_RS:
	    dec  h
	    jp   m, __CTR_RSD
	    add  a, a
	    jr   __CTR_RS
__CTR_RSD:
	    ld   (__CTR_RUNB), a
	    ld   a, (GFX_XSHIFT)    ; the mode's fast row loop
	    ld   hl, __CTM_F1
	    or   a
	    jr   z, __CTR_FS
	    ld   hl, __CTM_F2
	    dec  a
	    jr   z, __CTR_FS
	    ld   hl, __CTM_F4
__CTR_FS:
	    ld   (__CTR_CALL + 1), hl
	    pop  de
    ld   a, (__CTR_STRIDE)  ; HL = first row * stride (row < 32: 5 steps)
	    ld   c, e               ; C = first column
	    ld   e, a
	    ld   a, d
	    add  a, a
	    add  a, a
	    add  a, a               ; row in the top 5 bits
	    ld   d, 0
	    ld   hl, 0
	    ld   b, 5
__CTR_MUL:
	    add  hl, hl
	    add  a, a
	    jr   nc, __CTR_MULN
	    add  hl, de
__CTR_MULN:
	    djnz __CTR_MUL
	    ld   b, 0
	    add  hl, bc             ; + first column
	    ld   de, (__CTR_MAP)
	    add  hl, de             ; HL = map byte of the first cell
__CTR_ROW:
	    push hl
	    ld   de, (__CTR_SCR)
	    ld   a, (__CTR_RUNB)
	    add  a, e
	    ld   (__CTM_END), a
__CTR_CALL:
	    call __CTM_F4           ; operand set above
	    pop  hl
	    ld   de, (__CTR_STRIDE) ; the next map row (high byte always 0)
	    add  hl, de
	    ex   de, hl
    ld   hl, (__CTR_SCR)    ; the next cell row: 80 on, nothing wraps
	    ld   bc, 80
	    add  hl, bc
	    ld   (__CTR_SCR), hl
	    ex   de, hl
	    ld   a, (__CTR_ROWS)
	    dec  a
	    ld   (__CTR_ROWS), a
	    jr   nz, __CTR_ROW
	    ret
	    ; --- the general way, through __CB_TILEMAP_S ---
__CTR_SLOW:
	    push bc
	    push de
	    ld   a, d               ; HL = map + first row * stride + first column
	    ld   d, 0
	    ld   hl, (__CTR_MAP)
	    add  hl, de
	    ld   de, (__CTR_STRIDE)
__CTR_SM:
	    or   a
	    jr   z, __CTR_SMD
	    add  hl, de
	    dec  a
	    jr   __CTR_SM
__CTR_SMD:
	    pop  de
	    pop  bc
	    ld   a, (__CTR_STRIDE)
	    jp   __CB_TILEMAP_S
	    ENDP
__CTR_STRIDE:  defw 0       ; low byte only; the high byte stays 0
__CTR_MAP:     defw 0
__CTR_SCR:     defw 0
__CTR_RUNB:    defb 0
__CTR_ROWS:    defb 0
__CTM_ROWMAP:  defw 0
__CTM_MPTR:    defw 0
__CTM_WB:      defw 0
__CTM_W:       defb 0
__CTM_VIS:     defb 0
__CTM_CNT:     defb 0
__CTM_Y:       defb 0
__CTM_ROWS:    defb 0
__CTM_XB:      defb 0
__CTM_RUNB:    defb 0
__CTM_END:     defb 0
__CTM_FAST:    defb 0
	    pop namespace
#line 126 "src/lib/arch/cpc/stdlib/cpcbuild/tiles.bas"
	END
