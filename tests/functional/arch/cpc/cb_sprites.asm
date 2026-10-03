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
_spr:
	DEFW .LABEL.__LABEL0
_spr.__DATA__.__PTR__:
	DEFW _spr.__DATA__
	DEFW 0
	DEFW 0
_spr.__DATA__:
	DEFB 01h
	DEFB 02h
	DEFB 03h
	DEFB 04h
.LABEL.__LABEL0:
	DEFW 0000h
	DEFB 01h
_buf:
	DEFW .LABEL.__LABEL1
_buf.__DATA__.__PTR__:
	DEFW _buf.__DATA__
	DEFW 0
	DEFW 0
_buf.__DATA__:
	DEFB 00h
	DEFB 00h
	DEFB 00h
	DEFB 00h
.LABEL.__LABEL1:
	DEFW 0000h
	DEFB 01h
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	ld hl, _spr.__DATA__
	push hl
	ld a, 2
	push af
	ld a, 2
	push af
	ld hl, 20
	push hl
	ld hl, 10
	push hl
	call _PutSprite
	ld hl, _spr.__DATA__
	push hl
	ld a, 2
	push af
	ld a, 1
	push af
	ld hl, 20
	push hl
	ld hl, 12
	push hl
	call _PutSpriteMasked
	ld hl, _buf.__DATA__
	push hl
	ld a, 2
	push af
	ld a, 2
	push af
	ld hl, 20
	push hl
	ld hl, 10
	push hl
	call _GetBlock
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	jp .core.__CPC_END
_PutSprite:
	push ix
	ld ix, 0
	add ix, sp
#line 34 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
		push namespace core
		call __CB_PUT_SPRITE
		pop namespace
#line 39 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
_PutSprite__leave:
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
_PutSpriteMasked:
	push ix
	ld ix, 0
	add ix, sp
#line 42 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
		push namespace core
		call __CB_PUT_MASKED
		pop namespace
#line 47 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
_PutSpriteMasked__leave:
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
_GetBlock:
	push ix
	ld ix, 0
	add ix, sp
#line 50 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
		push namespace core
		call __CB_GET_BLOCK
		pop namespace
#line 55 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
_GetBlock__leave:
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
#line 70 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
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
#line 71 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
#line 1 "src/lib/arch/cpc/runtime/cpcbuild/sprite.asm"
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
; buffer address = (ix+12) (16-bit). Three tiers: a sprite of width 1, 2,
	; 4 or 8 that is not clipped at its sides, when no row of the screen can
	; wrap (__CB_NOWRAP), takes the unrolled loops further down; otherwise
	; rows that don't wrap around the end of their 2 KB block (hardware-scroll
	; offset) use LDIR / plain increments; rows that do use __CB_INC_X per
	; byte. __CB_SPR_PREP skips the clipper for a sprite entirely on the
	; screen.
#line 1 "src/lib/arch/cpc/runtime/cpcbuild/fill.asm"
	; -----------------------------------------------------------------------
	; cpcbuild library -- clipping, pen bytes, rectangle fill, clear screen
	;
	; Written from scratch for this project (MIT); see core.asm. Screen byte
	; layouts are from the public CPC documentation (cpcwiki.eu, "Video
; modes"): the tables below are checked against the firmware's
	; SCR_INK_ENCODE by tests/conformance/cb_fill.bas.
	;
	; Also holds the rectangle clipping shared with sprite.asm (which
	; includes this file), because the clip is needed by both and this file
	; is the smaller one to link.
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
#line 15 "src/lib/arch/cpc/runtime/cpcbuild/fill.asm"
	    push namespace core
	; __CB_PENBYTE -- A = pen -> A = the screen byte with all its pixels in
; that pen, for the current mode (from GFX_XSHIFT: 2 = mode 0, 1 = mode
	; 1, 0 = mode 2). The pen is masked to the mode's range (16/4/2 pens).
; Mode 0: pen bits 0-3 sit in screen bits 7,3,5,1 (left pixel) and
; 6,2,4,0 (right pixel). Mode 1: pen bit 0 in bits 7-4, bit 1 in 3-0
; (left pixel is bits 7 and 3). Mode 2: one bit per pixel. Mode 3 (not
	; a library mode) is treated as mode 0.
; Firmware entry called: none.
; Registers clobbered: AF, DE, HL.
__CB_PENBYTE:
	    PROC
	    LOCAL __PB_M0, __PB_M1, __PB_M2, __PB_T0, __PB_T1, __PB_LOOKUP
	    ld   l, a
	    ld   a, (GFX_XSHIFT)
	    or   a
	    jr   z, __PB_M2
	    dec  a
	    jr   z, __PB_M1
__PB_M0:
	    ld   a, l
	    and  $0F
	    ld   de, __PB_T0
	    jr   __PB_LOOKUP
__PB_M1:
	    ld   a, l
	    and  $03
	    ld   de, __PB_T1
__PB_LOOKUP:
	    ld   l, a
	    ld   h, 0
	    add  hl, de
	    ld   a, (hl)
	    ret
__PB_M2:
	    ld   a, l
	    rra                     ; pen bit 0 -> carry
	    sbc  a, a               ; &FF or 0
	    ret
__PB_T0:
	    DEFB $00, $C0, $0C, $CC, $30, $F0, $3C, $FC
	    DEFB $03, $C3, $0F, $CF, $33, $F3, $3F, $FF
__PB_T1:
	    DEFB $00, $F0, $0F, $FF
	    ENDP
	; __CB_CLIP1 -- clips one axis. HL = position (signed 16-bit), A = size
	; (0-255), E = the axis limit (80 bytes across, 200 lines down).
	; Returns Carry set if nothing is visible. Otherwise Carry clear,
	; L = first visible position (0 if the start was off the left/top),
	; D = how many items were cut off at the start, C = the visible count.
; Firmware entry called: none. Registers clobbered: AF, C, D, HL
	; (E is preserved).
__CB_CLIP1:
	    PROC
	    LOCAL __CC1_POS, __CC1_LIMIT, __CC1_EMPTY, __CC1_OK
	    or   a
	    jr   z, __CC1_EMPTY
	    ld   c, a
	    bit  7, h
	    jr   z, __CC1_POS
    xor  a                  ; negative: HL = -HL
	    sub  l
	    ld   l, a
	    sbc  a, a
    sub  h                  ; (0 - L borrow) folded: A = -H - borrow
	    ld   h, a
	    or   a
    jr   nz, __CC1_EMPTY    ; cut off 256 or more: more than any size
	    ld   a, l
	    cp   c
	    jr   nc, __CC1_EMPTY    ; cut off all of it
	    ld   d, a
	    ld   a, c
	    sub  d
	    ld   c, a               ; visible = size - cut
	    ld   l, 0
	    jr   __CC1_LIMIT
__CC1_POS:
	    ld   a, h
	    or   a
	    jr   nz, __CC1_EMPTY
	    ld   a, l
	    cp   e
	    jr   nc, __CC1_EMPTY    ; starts at or past the limit
	    ld   d, 0
__CC1_LIMIT:
	    ld   a, e
	    sub  l                  ; room left before the limit (>= 1)
	    cp   c
	    jr   nc, __CC1_OK
	    ld   c, a               ; cut at the far edge
__CC1_OK:
	    or   a
	    ret
__CC1_EMPTY:
	    scf
	    ret
	    ENDP
	; __CB_CLIP_RECT -- clips a rectangle to the screen. HL = x, DE = y
	; (signed 16-bit, in bytes and lines), B = width (bytes), C = height
	; (lines). Returns Carry set if nothing is visible. Otherwise Carry
	; clear, HL = the screen address of the visible top-left byte, and
	; the variables __CBC_CW (visible width), __CBC_CH (visible height),
	; __CBC_SX (bytes cut off at the left) and __CBC_SY (rows cut off at the
	; top) are set.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_CLIP_RECT:
	    PROC
	    LOCAL __CCR_EMPTY
	    ld   a, c
	    ld   (__CBC_H), a
	    push de                 ; y
	    ld   a, b
	    ld   e, 80
	    call __CB_CLIP1
	    jr   c, __CCR_EMPTY
	    ld   a, l
	    ld   (__CBC_X0), a
	    ld   a, d
	    ld   (__CBC_SX), a
	    ld   a, c
	    ld   (__CBC_CW), a
	    pop  hl                 ; y
	    ld   a, (__CBC_H)
	    ld   e, 200
	    call __CB_CLIP1
	    ret  c
	    ld   a, d
	    ld   (__CBC_SY), a
	    ld   a, c
	    ld   (__CBC_CH), a
	    ld   b, l               ; first visible line
	    ld   a, (__CBC_X0)
	    ld   c, a
	    jp   __CB_ADDR          ; leaves Carry clear
__CCR_EMPTY:
	    pop  hl
	    scf
	    ret
	    ENDP
	; Clip results (word-sized where a "ld bc,(...)" wants the high byte 0).
__CBC_CW:  DEFW 0
__CBC_CH:  DEFB 0
__CBC_SX:  DEFB 0
__CBC_SY:  DEFB 0
__CBC_X0:  DEFB 0
__CBC_H:   DEFB 0
__CBF_BYTE: DEFB 0
__CBF_SP:  DEFW 0
	; __CB_FILL_RECT -- FillRect's body; reads its parameters from the
; caller's IX frame: x = (ix+4), y = (ix+6) (16-bit), w = (ix+9),
	; h = (ix+11), pen = (ix+13). Fills the clipped rectangle with the pen's
; byte, one row at a time: a seeded LDIR for a row that doesn't wrap
	; around the end of its 2 KB block, a byte at a time (__CB_INC_X) for
	; one that does. When no row on the screen can wrap (__CB_NOWRAP) the
	; per-row wrap test is skipped.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_FILL_RECT:
	    PROC
	    LOCAL __CFR_ROW, __CFR_SLOW, __CFR_NEXT, __CFR_SLOWLP, __CFR_FAST, __CFR_FL1
	    ld   l, (ix+4)
	    ld   h, (ix+5)
	    ld   e, (ix+6)
	    ld   d, (ix+7)
	    ld   b, (ix+9)
	    ld   c, (ix+11)
	    call __CB_CLIP_RECT
	    ret  c
	    push hl
	    ld   a, (ix+13)
	    call __CB_PENBYTE
	    ld   (__CBF_BYTE), a
	    pop  hl
	    call __CB_NOWRAP
	    jr   nc, __CFR_ROW
__CFR_FAST:                 ; no row can wrap
	    ld   a, (__CBF_BYTE)
	    ld   bc, (__CBC_CW)
	    push hl
	    ld   (hl), a
	    dec  c                  ; B is 0
	    jr   z, __CFR_FL1       ; one byte only (LDIR with BC=0 would run 64K)
	    ld   d, h
	    ld   e, l
	    inc  de
	    ldir
__CFR_FL1:
	    pop  hl
	    ld   a, (__CBC_CH)
	    dec  a
	    ret  z
	    ld   (__CBC_CH), a
    ld   a, h               ; next line: usually just the next 2 KB block
	    add  a, 8
	    ld   h, a
	    and  $38
	    jr   nz, __CFR_FAST
	    ld   a, h               ; crossed into the next character row
	    sub  8
	    ld   h, a
	    call __CB_NEXT_LINE
	    jr   __CFR_FAST
__CFR_ROW:
	    push hl                 ; row start
	    ld   bc, (__CBC_CW)
	    call __CB_ROW_WRAPS
	    ld   a, (__CBF_BYTE)
	    jr   c, __CFR_SLOW
	    ld   (hl), a
	    dec  c                  ; B is 0
	    jr   z, __CFR_NEXT      ; one byte only (LDIR with BC=0 would run 64K)
	    ld   d, h
	    ld   e, l
	    inc  de
	    ldir
	    jr   __CFR_NEXT
__CFR_SLOW:
	    ld   b, c
__CFR_SLOWLP:
	    ld   (hl), a
	    call __CB_INC_X         ; keeps B, but not A
	    ld   a, (__CBF_BYTE)
	    djnz __CFR_SLOWLP
__CFR_NEXT:
	    pop  hl
	    ld   a, (__CBC_CH)
	    dec  a
	    ret  z
	    ld   (__CBC_CH), a
	    call __CB_NEXT_LINE
	    jr   __CFR_ROW
	    ENDP
	; __CB_CLEAR -- A = byte -> fills the whole 16 KB drawing screen with
; it, using the stack pointer as a fast fill pointer: 256 chunks of 32
	; PUSHes (64 bytes), each with interrupts off and the real SP back
	; before they go on again, so the interrupt handler always finds a
	; proper stack (about 25 ms in all). Returns with interrupts on.
; Firmware entry called: none.
; Registers clobbered: AF, BC, DE, HL.
__CB_CLEAR:
	    ld   d, a
	    ld   e, a
	    ld   (__CBF_SP), sp
	    ld   a, (CB_BASE)
	    add  a, $40             ; end of the screen (&0000 for &C000)
	    ld   h, a
	    ld   l, 0
	    ld   b, 0               ; 256 chunks of 64 bytes = 16384 bytes
__CCL_LOOP:
	    di
	    ld   sp, hl
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    push de
	    ld   hl, 0
	    add  hl, sp             ; HL = where the next chunk ends
	    ld   sp, (__CBF_SP)
	    ei
	    djnz __CCL_LOOP
	    ret
	    pop namespace
#line 25 "src/lib/arch/cpc/runtime/cpcbuild/sprite.asm"
	    push namespace core
	; __CB_SPR_PREP -- common set-up. A = bytes per item in the data (1, or
	; 2 for masked pairs). Clips the rectangle; returns Carry set if nothing
	; is visible. Otherwise Carry clear, HL = screen address of the first
	; visible byte, DE = address in the data/buffer of the first visible item
	; (data + (SY*w + SX) * A), and __CBS_SKIP = bytes to add to the data
	; pointer after each row ((w - visible width) * A); __CBC_CH is the
	; row count. A sprite entirely on the screen (x, y in 0-255, 1-80 wide, 1-200
; high, fitting) skips the clipper: its address is computed directly and
	; __CBS_SKIP is 0.
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_SPR_PREP:
	    PROC
	    LOCAL __CSP_ONE1, __CSP_ONE2, __CSP_NOSY, __CSP_MUL, __CSP_CLIP
	    ld   e, a               ; (kept in E for the clipper path)
	    ld   a, (ix+5)
	    or   (ix+7)
    jr   nz, __CSP_CLIP     ; x or y outside 0-255: needs the clipper
	    ld   c, (ix+4)          ; C = x
	    ld   b, (ix+6)          ; B = y
	    ld   l, (ix+9)          ; L = w
	    ld   h, (ix+11)         ; H = h
	    ld   a, l
	    dec  a
	    cp   80
	    jr   nc, __CSP_CLIP     ; w is not 1-80
	    ld   a, 80
    sub  l                  ; 80 - w: the last x that fits
	    cp   c
	    jr   c, __CSP_CLIP
	    ld   a, h
	    dec  a
	    cp   200
	    jr   nc, __CSP_CLIP     ; h is not 1-200
	    ld   a, 200
    sub  h                  ; 200 - h: the last y that fits
	    cp   b
	    jr   c, __CSP_CLIP
    ld   a, l               ; entirely on screen: nothing to clip
	    ld   (__CBC_CW), a
	    ld   a, h
	    ld   (__CBC_CH), a
	    call __CB_ADDR
	    ld   de, 0
	    ld   (__CBS_SKIP), de
	    ld   e, (ix+12)
	    ld   d, (ix+13)
	    or   a
	    ret
__CSP_CLIP:
	    ld   a, e
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
; __CB_PUT_SPRITE -- PutSprite's body: copies the visible part of the
	; w*h bytes at data onto the screen, overwriting.
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_PUT_SPRITE:
	    PROC
	    LOCAL __CPS_ROW, __CPS_SLOW, __CPS_SLOWLP, __CPS_TAIL, __CPS_FAST, __CPS_FSAME
	    ld   a, 1
	    call __CB_SPR_PREP
	    ret  c
	    ld   bc, __CPS_TAB
    call __CB_SPR_UNROLLED  ; width 1/2/4/8, unclipped, no wrap: done
	    ret  nc
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
	    ld   bc, __CPM_TAB
    call __CB_SPR_UNROLLED  ; width 1/2/4/8, unclipped, no wrap: done
	    ret  nc
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
	    ld   bc, __CGB_TAB
    call __CB_SPR_UNROLLED  ; width 1/2/4/8, unclipped, no wrap: done
	    ret  nc
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
	; ---------------------------------------------------------------------
	; Unrolled fast paths (PutSprite, PutSpriteMasked, GetBlock)
	;
	; Used when the whole sprite is drawn without clipping at its sides
	; (visible width = w), no row can wrap in its 2 KB block (__CB_NOWRAP)
	; and the width is 1, 2, 4 or 8 bytes; anything else takes the generic
	; loops above. The choice is made once per call (__CB_SPR_UNROLLED), then
	; __CB_FAST_ROWS walks the rows one character row at a time (a "group" of
	; up to 8 rows, which are 2 KB apart) and calls the width's inner loop.
	; An inner loop gets A = rows in the group (1-8), HL = screen address of
	; its first row, DE = data/buffer address; it returns with HL = the first
	; row's address + 2 KB per row (the row after the group, in block terms)
	; and DE = data after the group. It may clobber AF, BC, DE, HL.
	;
	; The copy loops are LDI chains (20 CPC T-states a byte, the cheapest way
	; to move a byte); the stepping to the next 2 KB block is done with the
	; screen address in HL (ADD HL,BC), so it needs no page-crossing care. The
	; masked loops come in two forms, chosen per group by the width's gate
; (__CMWn): "F" steps with INC L / INC E and needs the screen row (low
	; byte <= 256 - n) and the data of the group (low byte <= 255 - 16 n,
	; i.e. 8 rows of 2n bytes) not to cross a 256-byte page; "S" uses
	; INC HL / INC DE and handles any address.
	; ---------------------------------------------------------------------
	; __CB_SPR_UNROLLED -- HL = screen address of the first visible byte,
	; DE = data address (as returned by __CB_SPR_PREP), BC = the routine's
	; table (the inner loops for widths 1, 2, 4, 8 as four DEFWs). Draws the
	; whole sprite and returns Carry clear, or, if this draw does not qualify
	; (rows can wrap, clipped at a side, or a width other than 1/2/4/8),
	; returns Carry set having drawn nothing (HL, DE preserved).
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_SPR_UNROLLED:
	    PROC
	    LOCAL __CSU_NO, __CSU_GO
	    push hl
	    push de
	    push bc
	    call __CB_NOWRAP        ; Carry set if no row can wrap
	    pop  hl                 ; HL = table (flags kept)
	    jr   nc, __CSU_NO
	    ld   de, (__CBS_SKIP)
	    ld   a, d
	    or   e
	    jr   nz, __CSU_NO       ; clipped at a side (leaves D = 0 otherwise)
	    ld   a, (__CBC_CW)
	    cp   1
	    jr   z, __CSU_GO
	    ld   e, 2
	    cp   2
	    jr   z, __CSU_GO
	    ld   e, 4
	    cp   4
	    jr   z, __CSU_GO
	    ld   e, 6
	    cp   8
	    jr   nz, __CSU_NO
__CSU_GO:
	    add  hl, de
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)
	    ld   (__CBS_INN), de
	    pop  de
	    pop  hl
	    call __CB_FAST_ROWS
	    or   a
	    ret
__CSU_NO:
	    pop  de
	    pop  hl
	    scf
	    ret
	    ENDP
; __CB_FAST_ROWS -- the row driver: HL = screen address of the first
	; row, DE = data, __CBC_CH = rows (>= 1), __CBS_INN = the inner loop.
	; Draws all the rows, group by group (the first group ends at the end of
	; the character row it starts in, the others have 8 rows). Each inner
	; loop is entered by a RET (its address pushed) and ends by jumping to
	; __CFR_NEXT, which returns to the driver's caller when no rows are left;
	; otherwise HL (= the group's first row + 2 KB per row, i.e. in "block 8")
; becomes the first row of the next character row: back 16 KB to block 0
	; and on 80 bytes (nothing wraps on this path, so a plain add is right).
; Firmware entry called: none. Registers clobbered: AF, BC, DE, HL.
__CB_FAST_ROWS:
	    PROC
	    LOCAL __CFR_GRP, __CFR_CMP, __CFR_FULL, __CFR_GO
	    ld   a, h
	    cpl
	    and  $38
	    rrca
	    rrca
    rrca                    ; 7 - block: this line's place in its character row
	    inc  a                  ; A = rows left in this character row (1-8)
	    jr   __CFR_CMP
__CFR_GRP:
	    ld   a, 8
__CFR_CMP:
	    ld   c, a
	    ld   a, (__CBC_CH)      ; rows left
	    cp   c
	    jr   c, __CFR_FULL
	    sub  c
    ld   (__CBC_CH), a      ; this group: C rows, then A are left
	    ld   a, c
	    jr   __CFR_GO
__CFR_FULL:                 ; fewer than a full group left: all of them
	    ld   c, a               ; (A = rows left, 1-7)
	    xor  a
	    ld   (__CBC_CH), a
	    ld   a, c
__CFR_GO:
	    ld   bc, (__CBS_INN)
	    push bc
	    ret
__CFR_NEXT:
	    ld   a, (__CBC_CH)
	    or   a
	    ret  z
	    ld   a, h
	    sub  $40
	    ld   h, a
	    ld   bc, 80
	    add  hl, bc
	    jr   __CFR_GRP
	    ENDP
; PutSprite inner loops, width N: per row, LDI x N, then on to the next 2 KB block.
__CPI1:
__CPI1L:
	    ex   de, hl             ; HL = data, DE = screen
	    ldi
	    ex   de, hl             ; HL = screen + N, DE = data
	    ld   bc, $800 - 1
	    add  hl, bc
	    dec  a
	    jr   nz, __CPI1L
	    jp   __CFR_NEXT
__CPI2:
__CPI2L:
	    ex   de, hl             ; HL = data, DE = screen
	    ldi
	    ldi
	    ex   de, hl             ; HL = screen + N, DE = data
	    ld   bc, $800 - 2
	    add  hl, bc
	    dec  a
	    jr   nz, __CPI2L
	    jp   __CFR_NEXT
__CPI4:
__CPI4L:
	    ex   de, hl             ; HL = data, DE = screen
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl             ; HL = screen + N, DE = data
	    ld   bc, $800 - 4
	    add  hl, bc
	    dec  a
	    jr   nz, __CPI4L
	    jp   __CFR_NEXT
__CPI8:
__CPI8L:
	    ex   de, hl             ; HL = data, DE = screen
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ex   de, hl             ; HL = screen + N, DE = data
	    ld   bc, $800 - 8
	    add  hl, bc
	    dec  a
	    jr   nz, __CPI8L
	    jp   __CFR_NEXT
__CPS_TAB:
	    DEFW __CPI1, __CPI2, __CPI4, __CPI8
; GetBlock inner loops, width N: per row, LDI x N (screen to buffer).
__CGI1:
	    ldi
	    ld   bc, $800 - 1
	    add  hl, bc
	    dec  a
	    jr   nz, __CGI1
	    jp   __CFR_NEXT
__CGI2:
	    ldi
	    ldi
	    ld   bc, $800 - 2
	    add  hl, bc
	    dec  a
	    jr   nz, __CGI2
	    jp   __CFR_NEXT
__CGI4:
	    ldi
	    ldi
	    ldi
	    ldi
	    ld   bc, $800 - 4
	    add  hl, bc
	    dec  a
	    jr   nz, __CGI4
	    jp   __CFR_NEXT
__CGI8:
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ldi
	    ld   bc, $800 - 8
	    add  hl, bc
	    dec  a
	    jr   nz, __CGI8
	    jp   __CFR_NEXT
__CGB_TAB:
	    DEFW __CGI1, __CGI2, __CGI4, __CGI8
; PutSpriteMasked inner loops, width N: the gate __CMWn (A = rows) picks F or
	; S; both swap to HL = data, DE = screen (AND (HL) / OR (HL) read the
	; data) and come back swapped. F keeps the screen row's low byte in C and
	; restores it per row; S steps the screen address back N with the borrow.
__CMW1:
	    ld   b, a               ; rows
	    ld   a, 255
	    cp   l
	    jr   c, __CMS1         ; the screen row could cross a page
	    ld   a, 239
	    cp   e
	    jr   c, __CMS1         ; the data could cross a page
__CMF1:
	    ex   de, hl             ; HL = data, DE = screen
	    ld   c, e               ; screen row start (low byte)
__CMF1L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   e, c
	    ld   a, d
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMF1L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMS1:
	    ex   de, hl             ; HL = data, DE = screen
__CMS1L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, e
	    sub  1
	    ld   e, a
	    ld   a, d
	    sbc  a, 0               ; borrow from the low byte
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMS1L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMW2:
	    ld   b, a               ; rows
	    ld   a, 254
	    cp   l
	    jr   c, __CMS2         ; the screen row could cross a page
	    ld   a, 223
	    cp   e
	    jr   c, __CMS2         ; the data could cross a page
__CMF2:
	    ex   de, hl             ; HL = data, DE = screen
	    ld   c, e               ; screen row start (low byte)
__CMF2L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   e, c
	    ld   a, d
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMF2L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMS2:
	    ex   de, hl             ; HL = data, DE = screen
__CMS2L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, e
	    sub  2
	    ld   e, a
	    ld   a, d
	    sbc  a, 0               ; borrow from the low byte
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMS2L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMW4:
	    ld   b, a               ; rows
	    ld   a, 252
	    cp   l
	    jr   c, __CMS4         ; the screen row could cross a page
	    ld   a, 191
	    cp   e
	    jr   c, __CMS4         ; the data could cross a page
__CMF4:
	    ex   de, hl             ; HL = data, DE = screen
	    ld   c, e               ; screen row start (low byte)
__CMF4L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   e, c
	    ld   a, d
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMF4L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMS4:
	    ex   de, hl             ; HL = data, DE = screen
__CMS4L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, e
	    sub  4
	    ld   e, a
	    ld   a, d
	    sbc  a, 0               ; borrow from the low byte
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMS4L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMW8:
	    ld   b, a               ; rows
	    ld   a, 248
	    cp   l
	    jr   c, __CMS8         ; the screen row could cross a page
	    ld   a, 127
	    cp   e
	    jr   c, __CMS8         ; the data could cross a page
__CMF8:
	    ex   de, hl             ; HL = data, DE = screen
	    ld   c, e               ; screen row start (low byte)
__CMF8L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  l
	    or   (hl)               ; OR pixels
	    inc  l
	    ld   (de), a
	    inc  e
	    ld   e, c
	    ld   a, d
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMF8L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CMS8:
	    ex   de, hl             ; HL = data, DE = screen
__CMS8L:
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, (de)            ; screen
	    and  (hl)               ; AND mask
	    inc  hl
	    or   (hl)               ; OR pixels
	    inc  hl
	    ld   (de), a
	    inc  de
	    ld   a, e
	    sub  8
	    ld   e, a
	    ld   a, d
	    sbc  a, 0               ; borrow from the low byte
	    add  a, 8               ; next 2 KB block
	    ld   d, a
	    djnz __CMS8L
	    ex   de, hl             ; HL = screen + 2 KB, DE = data
	    jp   __CFR_NEXT
__CPM_TAB:
	    DEFW __CMW1, __CMW2, __CMW4, __CMW8
__CBS_INN: DEFW 0
__CBS_K:    DEFB 0
__CBS_SKIP: DEFW 0
	    pop namespace
#line 72 "src/lib/arch/cpc/stdlib/cpcbuild/sprites.bas"
	END
