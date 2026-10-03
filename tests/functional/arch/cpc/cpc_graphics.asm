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
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	call .core.COPY_ATTR
	ld hl, 10
	push hl
	ld hl, 10
	call .core.PLOT
	call .core.COPY_ATTR
	ld hl, 50
	push hl
	ld hl, 20
	call .core.DRAW
	call .core.COPY_ATTR
	ld hl, 100
	push hl
	ld hl, 100
	push hl
	ld hl, 20
	call .core.CIRCLE
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	jp .core.__CPC_END
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
; Game mode (framehook.asm, opt-in): when GM_VEC is non-zero, interrupts
	; outside firmware calls go to the handler it points to instead of the
	; firmware, which then only runs during firmware calls. GM_VEC is zero
	; (normal mode) unless a program switches game mode on.
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
#line 25 "tests/functional/arch/cpc/cpc_graphics.bas"
#line 1 "src/lib/arch/cpc/runtime/circle.asm"
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
#line 1 "src/lib/arch/cpc/runtime/gfx.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC -- shared helpers for PLOT, DRAW and CIRCLE
	;
	; Coordinates are the current mode's pixels, origin bottom-left (mode 1
	; 320x200, mode 0 160x200, mode 2 640x200; cpcbuild/docs/notes.md,
	; 2026-10-01). The firmware's graphics VDU works in 640x400 virtual
	; coordinates in every mode, so __GRA_XY scales them; off-screen points
	; are clipped by the firmware, silently (the Spectrum stops with "out of
	; screen" instead).
	;
; Colour comes from the temporary attribute, like the Spectrum: the ink
	; (ATTR_T bits 0-2, through colour.asm's pen map) is the graphics pen,
	; or the paper under INVERSE 1. OVER 1 selects the firmware's XOR write
	; mode (notes.md question 5).
	    push namespace core
	; __GRA_PREP -- gives the firmware the graphics pen and write mode the
	; temporary attributes ask for. Each is cached (GRA_PEN_CUR,
	; GRA_MODE_CUR) so repeated PLOTs don't pay for the firmware calls;
	; colour.asm resets the cache on a mode change.
; Firmware entries called (via the gate, only on a change): GRA_SET_PEN
	; (&BBDE, A = pen), SCR_ACCESS (&BC59, A = 0 normal, 1 XOR). SCR_ACCESS
; corrupts DE/HL as well as AF on the 6128 (measured: the next PLOT went
	; astray), so both are saved here rather than trusting the Guide's
	; register lists.
; Registers clobbered: AF, BC (main); BC', DE', HL', AF' (the gate).
	; DE and HL are preserved.
__GRA_PREP:
	    PROC
	    LOCAL __GP_INK, __GP_PEN_OK, __GP_DONE
	    push de
	    push hl
	    ld   a, (P_FLAG)
	    and  4                  ; temporary INVERSE (bit 2)
	    ld   a, (ATTR_T)
	    jr   z, __GP_INK
	    rrca
	    rrca
    rrca                    ; INVERSE 1: plot in the paper colour
__GP_INK:
	    call __INK_TO_PEN
	    ld   b, a
	    ld   a, (GRA_PEN_CUR)
	    cp   b
	    jr   z, __GP_PEN_OK
	    ld   a, b
	    ld   (GRA_PEN_CUR), a
	    call .core.__FW_CALL
	    defw $BBDE              ; GRA_SET_PEN
__GP_PEN_OK:
	    ld   a, (P_FLAG)
	    and  1                  ; temporary OVER (bit 0)
	    ld   b, a
	    ld   a, (GRA_MODE_CUR)
	    cp   b
	    jr   z, __GP_DONE
	    ld   a, b
	    ld   (GRA_MODE_CUR), a
	    call .core.__FW_CALL
    defw $BC59              ; SCR_ACCESS: 0 = normal, 1 = XOR
__GP_DONE:
	    pop  hl
	    pop  de
	    ret
	    ENDP
	; __GRA_XY -- DE = x, HL = y in mode pixels (signed; a point or a
; relative offset) -> DE, HL in firmware virtual units: y * 2, and
; x << GFX_XSHIFT (mode 0: * 4, mode 1: * 2, mode 2: * 1).
; Firmware entry called: none.
; Registers clobbered: AF, DE, HL.
__GRA_XY:
	    PROC
	    LOCAL __GX_LOOP
	    add  hl, hl
	    ld   a, (GFX_XSHIFT)
	    or   a
	    ret  z
	    ex   de, hl
__GX_LOOP:
	    add  hl, hl
	    dec  a
	    jr   nz, __GX_LOOP
	    ex   de, hl
	    ret
	    ENDP
	    pop namespace
#line 23 "src/lib/arch/cpc/runtime/circle.asm"
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
#line 26 "tests/functional/arch/cpc/cpc_graphics.bas"
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
	    pop namespace
#line 27 "tests/functional/arch/cpc/cpc_graphics.bas"
#line 1 "src/lib/arch/cpc/runtime/draw.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC -- DRAW dx, dy (straight line from the last point)
	;
	; zx48k's draw.asm ran its own Bresenham over Spectrum VRAM. Here the
	; firmware's GRA_LINE_RELATIVE draws from its graphics cursor (where the
	; last PLOT/DRAW/CIRCLE point left it), clipped, in every mode.
	; Coordinates, colour and OVER/INVERSE are as described in gfx.asm.
	;
	; The firmware also plots the line's first point, which the Spectrum's
	; DRAW doesn't (that point is already lit by the previous PLOT/DRAW).
	; It makes no difference normally, but under OVER 1 that point would be
	; XORed twice and disappear, so in XOR mode DRAW plots it once more to
	; put it back. (The 664/6128's GRA_SET_FIRST could switch the first
	; point off, but the 464 doesn't have it.)
	;
; Calling convention (unchanged from zx48k): dx pushed, dy in HL, both
	; 16-bit signed.
	    push namespace core
DRAW:
	    pop  bc                 ; return address
	    pop  de                 ; DE = dx
	    push bc
	; __DRAW -- DE = dx, HL = dy (mode pixels, signed).
; Firmware entries called: GRA_LINE_RELATIVE (&BBF9, DE/HL = virtual
	; offsets); under OVER 1 also GRA_ASK_CURSOR (&BBC6), GRA_PLOT_ABSOLUTE
	; (&BBEA) and GRA_MOVE_ABSOLUTE (&BBC0); plus __GRA_PREP's.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
	; gate).
__DRAW:
	    PROC
	    LOCAL __DRAW_XOR
	    call __GRA_PREP
	    call __GRA_XY
	    ld   a, (GRA_MODE_CUR)
	    or   a
	    jr   nz, __DRAW_XOR
	    call .core.__FW_CALL
	    defw $BBF9              ; GRA_LINE_RELATIVE
	    ret
__DRAW_XOR:
	    push de                 ; dx
	    push hl                 ; dy
	    call .core.__FW_CALL
    defw $BBC6              ; GRA_ASK_CURSOR: DE = x0, HL = y0
	    pop  bc                 ; BC = dy
    ex   (sp), hl           ; HL = dx; stack: y0
    push de                 ; stack: y0, x0
	    ex   de, hl             ; DE = dx
	    ld   h, b
	    ld   l, c               ; HL = dy
	    call .core.__FW_CALL
	    defw $BBF9              ; GRA_LINE_RELATIVE (XORs the start point too)
	    call .core.__FW_CALL
    defw $BBC6              ; GRA_ASK_CURSOR: DE = x1, HL = y1
	    pop  bc                 ; BC = x0
    ex   (sp), hl           ; HL = y0; stack: y1
    push de                 ; stack: y1, x1
	    ld   d, b
	    ld   e, c               ; DE = x0
	    call .core.__FW_CALL
    defw $BBEA              ; GRA_PLOT_ABSOLUTE: XOR the start point back
	    pop  de                 ; DE = x1
	    pop  hl                 ; HL = y1
	    call .core.__FW_CALL
    defw $BBC0              ; GRA_MOVE_ABSOLUTE: continue from the end
	    ret
	    ENDP
	    pop namespace
#line 28 "tests/functional/arch/cpc/cpc_graphics.bas"
#line 1 "src/lib/arch/cpc/runtime/plot.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC -- PLOT x, y
	;
	; zx48k's plot.asm wrote a pixel mask into Spectrum VRAM via the ROM's
; PIXEL_ADDR (&22AC). Here the firmware plots it: GRA_PLOT_ABSOLUTE
	; does the screen addressing for every mode, clips, and moves the
	; graphics cursor that DRAW continues from. Coordinates, colour and
	; OVER/INVERSE are as described in gfx.asm.
	;
; Calling convention: the cpc parser makes both coordinates 16-bit
	; (src/arch/cpc/__init__.py GRAPHICS_COORD_TYPE), so X is pushed and Y
; arrives in HL (zx48k: X byte pushed, Y byte in A).
	    push namespace core
PLOT:
	    pop  bc                 ; return address
	    pop  de                 ; DE = x
	    push bc
	; __PLOT -- DE = x, HL = y (mode pixels).
; Firmware entry called: GRA_PLOT_ABSOLUTE (&BBEA, DE = x, HL = y
	; virtual), plus __GRA_PREP's.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
	; gate).
__PLOT:
	    call __GRA_PREP
	    call __GRA_XY
	    call .core.__FW_CALL
	    defw $BBEA              ; GRA_PLOT_ABSOLUTE
	    ret
	    pop namespace
#line 29 "tests/functional/arch/cpc/cpc_graphics.bas"
	END
