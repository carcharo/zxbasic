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
_r:
	DEFB 00
_decay:
	DEFW .LABEL.__LABEL0
_decay.__DATA__.__PTR__:
	DEFW _decay.__DATA__
	DEFW 0
	DEFW 0
_decay.__DATA__:
	DEFB 0Fh
	DEFB 0FFh
	DEFB 02h
.LABEL.__LABEL0:
	DEFW 0000h
	DEFB 01h
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	ld a, 1
	push af
	ld hl, _decay.__DATA__
	push hl
	ld a, 1
	push af
	call _SoundEnvelope
	ld a, 1
	push af
	ld a, 12
	push af
	ld hl, 50
	push hl
	ld hl, 239
	push hl
	ld a, 1
	push af
	call _SoundQueue
	ld (_r), a
	ld a, 1
	call _SoundFree
	push af
	ld a, 1
	call _SoundBusy
	ld h, a
	pop af
	add a, h
	ld (_r), a
	call _SoundStop
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	jp .core.__CPC_END
_Mode:
#line 120 "src/lib/arch/cpc/stdlib/cpc.bas"
		push namespace core
		and 3
		push af
		call .core.__FW_CALL
		defw $BC0E
		pop af
		call __CPC_SET_MODE_VARS
		call CLS
		pop namespace
#line 131 "src/lib/arch/cpc/stdlib/cpc.bas"
_Mode__leave:
	ret
_GetMode:
#line 143 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__FW_CALL
		defw $BC11
#line 147 "src/lib/arch/cpc/stdlib/cpc.bas"
_GetMode__leave:
	ret
_SetInk:
	push ix
	ld ix, 0
	add ix, sp
#line 155 "src/lib/arch/cpc/stdlib/cpc.bas"
		ld a, (ix+5)
		ld c, (ix+7)
		call .core.__CPC_SET_INK
#line 160 "src/lib/arch/cpc/stdlib/cpc.bas"
_SetInk__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	ex (sp), hl
	exx
	ret
_SetBorder:
#line 165 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__CPC_SET_BORDER
#line 168 "src/lib/arch/cpc/stdlib/cpc.bas"
_SetBorder__leave:
	ret
_WaitVsync:
#line 186 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__FW_CALL
		defw $BD19
#line 190 "src/lib/arch/cpc/stdlib/cpc.bas"
_WaitVsync__leave:
	ret
_AyWrite:
	push ix
	ld ix, 0
	add ix, sp
#line 197 "src/lib/arch/cpc/stdlib/cpc.bas"
		ld a, (ix+5)
		ld c, (ix+7)
		call .core.__CPC_AY_WRITE_DI
#line 202 "src/lib/arch/cpc/stdlib/cpc.bas"
_AyWrite__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	ex (sp), hl
	exx
	ret
_AyRead:
#line 208 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__CPC_AY_READ_DI
#line 211 "src/lib/arch/cpc/stdlib/cpc.bas"
_AyRead__leave:
	ret
_SoundQueue:
	push ix
	ld ix, 0
	add ix, sp
#line 253 "src/lib/arch/cpc/stdlib/cpc.bas"
		ld l, (ix+6)
		ld h, (ix+7)
		ld e, (ix+8)
		ld d, (ix+9)
		ld a, (ix+5)
		ld b, (ix+11)
		ld c, (ix+13)
		call .core.__CPC_SND_QUEUE
#line 263 "src/lib/arch/cpc/stdlib/cpc.bas"
_SoundQueue__leave:
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
_SoundFree:
#line 268 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__CPC_SND_CHECK
		and 7
#line 272 "src/lib/arch/cpc/stdlib/cpc.bas"
_SoundFree__leave:
	ret
_SoundBusy:
#line 277 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__CPC_SND_BUSY
#line 280 "src/lib/arch/cpc/stdlib/cpc.bas"
_SoundBusy__leave:
	ret
_SoundEnvelope:
	push ix
	ld ix, 0
	add ix, sp
#line 285 "src/lib/arch/cpc/stdlib/cpc.bas"
		ld a, (ix+5)
		ld l, (ix+6)
		ld h, (ix+7)
		ld b, (ix+9)
		call .core.__CPC_SND_ENV
#line 292 "src/lib/arch/cpc/stdlib/cpc.bas"
_SoundEnvelope__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	pop bc
	ex (sp), hl
	exx
	ret
_SoundStop:
	push ix
	ld ix, 0
	add ix, sp
#line 297 "src/lib/arch/cpc/stdlib/cpc.bas"
		call .core.__CPC_SND_RESET
#line 300 "src/lib/arch/cpc/stdlib/cpc.bas"
_SoundStop__leave:
	ld sp, ix
	pop ix
	ret
	;; --- end of user code ---
#line 1 "src/lib/arch/cpc/runtime/ay.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC AY-3-8912 register access
	;
	; Written from scratch for this project (MIT); see core.asm. From the
	; public documentation of the 8255 PPI and the AY-3-8912 as wired in the
	; CPC (cpcwiki.eu, CPC Firmware Guide); no library code.
	;
; The AY sits behind the PPI: port A (&F4xx) is the AY's data bus, and
	; port C (&F6xx) bits 7-6 are the AY's BDIR and BC1 lines (11 = latch a
	; register number, 10 = write data, 01 = read data, 00 = inactive). Port C
	; bits 5-4 are the cassette write data and motor (kept as they are) and
	; bits 3-0 select the keyboard row, which the firmware's own scan (inside
	; its 300 Hz interrupt handler) changes. So every access here has to run
	; with interrupts off, or the handler could slip a keyboard scan between
	; two of the OUTs. The raw routines do not touch the interrupt flag (a
	; caller that already has interrupts off, like the Play library, pays for
	; neither DI nor EI); the _DI variants wrap them and return with
	; interrupts on, as every compiled-code routine does.
	;
	; The PPI must be as the firmware leaves it, control word &82 (port A
	; output, B input, C output).
	;
; Who owns the sound chip: the firmware's sound manager (SOUND/BEEP) runs
	; from the interrupt handler and writes the AY by itself whenever a note
	; is queued, so a program that uses these routines directly must not
	; also queue firmware sounds. Call SOUND_RESET (&BCA7) once first to make
	; the manager idle (Play does).
	;
; Bare-metal mode (-D CPC_BAREMETAL): there is no firmware sound manager,
	; so nothing else writes the AY; BEEP, Play, the music player and these
	; routines are the only users (one at a time).
	;
	; Cost (CPC "NOP" units of 1 us, every instruction rounded up to a whole
; number of them; IN/OUT are 4): __CPC_AY_WRITE 53 us plus 5 for the CALL,
	; 58 us measured (tests/stress/play_tempo.bas). The DI variants add the
; DI, EI, CALL and RET: 12 us.
	    push namespace core
	; __CPC_AY_WRITE -- writes AY register A with the value in C. Interrupts
	; must be off on entry; they are left as they were. Port C is left as it
	; was (cassette bits kept, AY inactive, keyboard row 0). The AY's
	; register select is left on A.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE (HL is not touched).
__CPC_AY_WRITE:
	    ld   e, c               ; E = value
	    ld   d, a               ; D = register
	    ld   b, $F6
	    in   a, (c)             ; port C (the low byte of the port is not decoded)
	    and  $30                ; cassette bits
	    ld   c, a               ; C = port C "inactive" value
	    ld   a, d
	    ld   b, $F4
	    out  (c), a             ; port A = register number
	    ld   b, $F6
	    ld   a, c
	    or   $C0
    out  (c), a             ; AY: latch register
    out  (c), c             ; AY: inactive
	    ld   b, $F4
	    out  (c), e             ; port A = value
	    ld   b, $F6
	    ld   a, c
	    or   $80
    out  (c), a             ; AY: write
    out  (c), c             ; AY: inactive
	    ret
; __CPC_AY_WRITE_DI -- as __CPC_AY_WRITE, for code that has interrupts on:
	; di, write, ei. Returns with interrupts on, whatever they were on entry.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_WRITE_DI:
	    di
	    call __CPC_AY_WRITE
	    ei
	    ret
	; __CPC_AY_READ -- A = AY register -> A = its value (bits the register
	; doesn't implement read as 0). Interrupts must be off on entry; they are
	; left as they were. Port A is switched to input for the read and back
	; to output, which clears the PPI's output latches, so the cassette bits
	; are written back at once (the motor is off for a few microseconds only,
	; and only if it was on). Port C is left as in __CPC_AY_WRITE. Reading
	; register 14 (the keyboard port) gives the keyboard row selected by port
	; C bits 3-0, which is row 0 here.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_READ:
	    ld   d, a               ; D = register
	    ld   b, $F6
	    in   a, (c)
	    and  $30
	    ld   e, a               ; E = port C "inactive" value
	    ld   b, $F4
	    out  (c), d             ; port A = register number
	    ld   b, $F6
	    ld   a, e
	    or   $C0
    out  (c), a             ; AY: latch register
    out  (c), e             ; AY: inactive
	    ld   bc, $F792
	    out  (c), c             ; port A becomes an input
	    ld   a, e
	    or   $40
	    ld   b, $F6
    out  (c), a             ; AY: read
	    ld   b, $F4
	    in   a, (c)             ; the value
	    ld   d, a
	    ld   b, $F6
    out  (c), e             ; AY: inactive (before port A drives the bus again)
	    ld   bc, $F782
	    out  (c), c             ; port A back to output (clears the latches)
	    ld   b, $F6
	    out  (c), e             ; cassette bits back
	    ld   a, d
	    ret
; __CPC_AY_READ_DI -- as __CPC_AY_READ, for code that has interrupts on:
	; di, read, ei. Returns with interrupts on.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_READ_DI:
	    di
	    call __CPC_AY_READ
	    ei
	    ret
#line 159 "src/lib/arch/cpc/runtime/ay.asm"
	    pop namespace
#line 307 "src/lib/arch/cpc/stdlib/cpc.bas"
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
#line 308 "src/lib/arch/cpc/stdlib/cpc.bas"
#line 1 "src/lib/arch/cpc/runtime/cls.asm"
	;; Clears the text screen and homes the cursor, via the firmware.
	;;
	;; zx48k's CLS clears the Spectrum bitmap and attribute areas directly
	;; and resets its own cursor/VRAM-pointer sysvars; there is no VRAM to
	;; touch here, and no local cursor cache to reset (see sposn.asm). The
;; one thing that needs doing by hand is the *colour* to clear to:
	;; TXT_CLEAR_WINDOW clears using the firmware's *current* PAPER, and
	;; Sinclair BASIC's CLS always clears to the permanent attribute's
	;; paper (not any temporary one left over from the last PRINT), so the
	;; permanent paper is pushed to the firmware first.
#line 18 "src/lib/arch/cpc/runtime/cls.asm"
	    push namespace core
CLS:
	    PROC
#line 35 "src/lib/arch/cpc/runtime/cls.asm"
    ; Firmware entries called (via the gate): TXT_SET_PAPER (&BB96, A =
	    ; paper pen) then TXT_CLEAR_WINDOW (&BB6C), which clears the
	    ; current window with that paper and homes the cursor to its
	    ; top-left corner (0,0 for the default full-screen window).
    ; Registers clobbered: AF, HL (main); BC', DE', HL', AF' (the gate).
	    ld a, (ATTR_P)
	    rrca
	    rrca
    rrca                   ; paper: bits 3-5 of ATTR_P -> bits 0-2
	    call __INK_TO_PEN      ; -> pen of the current mode (colour.asm)
	    call .core.__FW_CALL
	    defw $BB96              ; TXT_SET_PAPER
	    call .core.__FW_CALL
	    defw $BB6C               ; TXT_CLEAR_WINDOW
	    ret
#line 54 "src/lib/arch/cpc/runtime/cls.asm"
	    ENDP
	    pop namespace
#line 309 "src/lib/arch/cpc/stdlib/cpc.bas"
#line 1 "src/lib/arch/cpc/runtime/fwsound.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC firmware sound manager, non-blocking entries
	;
	; The firmware's sound manager plays queued notes from its 300 Hz
	; interrupt handler, which is always running in compiled code (isr.asm),
	; so a note can be queued and the program carries on. BEEP (beeper.asm)
	; queues one and then waits; these routines never wait. The sound block
	; (SOUND_BLK) and the envelope buffer (SND_ENV) live in the private block
	; (central 32K), where the firmware can read them with the ROMs enabled.
; The firmware copies both (checked: tests/conformance/sound.bas), so
	; they can be reused at once.
	;
	; All firmware calls go through the IX-preserving gate (the sound manager
	; corrupts IX, which is the BASIC frame pointer).
	;
; Sound block (9 bytes): 0 channels (bit 0-2: A/B/C), rendezvous (3-5),
	; hold (6), flush (7); 1 volume envelope; 2 tone envelope; 3-4 tone
	; period; 5 noise period; 6 start volume; 7-8 duration in 1/100 s.
	    push namespace core
	; __CPC_SND_QUEUE -- queue one note without waiting.
; In: A = channel byte (bits 0-2 channels, 3-5 rendezvous, 7 flush; bit 6
	; hold is cleared, nothing would release it), HL = tone period (clamped
	; to 4095), DE = duration in 1/100 s (0 = one run of the volume
	; envelope), B = start volume (0-15), C = volume envelope (0 = none).
	; With no envelope the 464's firmware (1.0, found from its interrupt
	; handler's address, isr.asm) takes volumes 0-7 and doubles them, so v
; is passed as min(7, (v + 1) / 2) there: the AY gets the even volume
	; nearest v (15 -> 14, 1 -> 2), as close as that firmware can get.
; Out: A = 1 if queued, 0 if the channel's queue was full.
; Firmware entries called: SOUND_QUEUE (&BCAA, HL = block; Carry =
	; queued; corrupts IX, so via __FW_CALL_IX).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (gate).
__CPC_SND_QUEUE:
	    and  $BF
	    ld   (SOUND_BLK + 0), a
	    ld   a, h
	    and  $F0
	    jr   z, __SND_PER_OK
	    ld   hl, 4095
__SND_PER_OK:
	    ld   (SOUND_BLK + 3), hl
	    ld   (SOUND_BLK + 7), de
	    ld   a, b
	    and  $0F
	    ld   b, a
	    ld   a, c
	    or   a
	    jr   nz, __SND_VOL_OK       ; with an envelope every model takes 0-15
	    ld   a, (__CPC_ISR_ORIG + 1)
    cp   $39                    ; firmware 1.0 (the 464): handler at &B939
	    jr   nz, __SND_VOL_OK
	    ld   a, b                   ; its volumes are 0-7 (doubled into the AY's
    inc  a                      ; 0-15): nearest = min(7, (v + 1) / 2)
	    srl  a
	    cp   8
	    jr   c, __SND_VOL_464
	    ld   a, 7
__SND_VOL_464:
	    ld   b, a
__SND_VOL_OK:
	    ld   a, b
	    ld   (SOUND_BLK + 6), a
	    ld   a, c
	    ld   (SOUND_BLK + 1), a
	    xor  a
	    ld   (SOUND_BLK + 2), a     ; no tone envelope
	    ld   (SOUND_BLK + 5), a     ; no noise
	    ld   hl, SOUND_BLK
	    call .core.__FW_CALL_IX
    defw $BCAA                  ; SOUND_QUEUE: Carry = queued
	    sbc  a, a                   ; A = 0 or $FF
	    and  1
	    ret
	; __CPC_SND_CHECK -- A = channel bit (1, 2 or 4) -> A = SOUND_CHECK
; status: bits 0-2 free queue slots (0-4), bit 3-5 rendezvous waiting
	; for A/B/C, bit 6 held, bit 7 a sound is playing.
; Firmware entries called: SOUND_CHECK (&BCAD).
; Registers clobbered: AF, BC, DE, HL (as the firmware leaves them);
	; BC', DE', HL', AF' (the gate).
__CPC_SND_CHECK:
	    call .core.__FW_CALL_IX
	    defw $BCAD
	    ret
	; __CPC_SND_BUSY -- A = channel bit -> A = 1 if that channel is playing
	; or has anything queued (fewer than 4 free slots, or status bit 7), else 0.
; Registers clobbered: as __CPC_SND_CHECK, and C.
__CPC_SND_BUSY:
	    PROC
	    LOCAL __SB_DONE
	    call __CPC_SND_CHECK
	    ld   c, a
	    and  7
	    cp   4
	    ld   a, 1
	    jr   c, __SB_DONE
	    bit  7, c
	    jr   nz, __SB_DONE
	    xor  a
__SB_DONE:
	    ret
	    ENDP
	; __CPC_SND_ENV -- A = envelope number (1-15), HL = user data of B
	; sections (3 bytes each, 1-5), copied after a section count into SND_ENV
	; and given to SOUND_AMPL_ENVELOPE.
; Firmware entries called: SOUND_AMPL_ENVELOPE (&BCBC, A = number,
	; HL = 16 byte data).
; Registers clobbered: AF, BC, DE, HL; BC', DE', HL', AF' (the gate).
__CPC_SND_ENV:
	    PROC
	    LOCAL __SE_OK
	    ex   af, af'            ; keep the envelope number
	    ld   a, b
	    or   a
	    ret  z                  ; no sections
	    cp   6
	    jr   c, __SE_OK
	    ld   a, 5
__SE_OK:
	    ld   de, SND_ENV
	    ld   (de), a
	    inc  de
	    ld   b, a
	    add  a, a
	    add  a, b               ; 3 * sections
	    ld   c, a
	    ld   b, 0
	    ldir
	    ex   af, af'
	    ld   hl, SND_ENV
	    call .core.__FW_CALL_IX
	    defw $BCBC              ; SOUND_AMPL_ENVELOPE
	    ret
	    ENDP
; __CPC_SND_RESET -- SOUND_RESET (&BCA7): empties every queue, silences
	; the chip.
; Registers clobbered: AF, BC, DE, HL; BC', DE', HL', AF' (the gate).
__CPC_SND_RESET:
	    call .core.__FW_CALL_IX
	    defw $BCA7
	    ret
	    pop namespace
#line 312 "src/lib/arch/cpc/stdlib/cpc.bas"
#line 1 "src/lib/arch/cpc/runtime/gacolour.asm"
	; -----------------------------------------------------------------------
	; Colours -- firmware and Gate Array together (SetInk, SetBorder)
	;
	; Written from scratch for this project (MIT); see cpc.bas. From the
	; public documentation of the Gate Array's colour registers and colour
	; numbers (cpcwiki.eu), checked in the emulator (cpcbuild's
	; tools/palette_check.py).
	;
; A colour change goes two ways (notes.md, Q-4c palette decision): through
	; the firmware (SCR_SET_INK / SCR_SET_BORDER), so its own ink tables stay
	; right, and straight to the Gate Array, so it shows at once instead of
	; at the firmware's next ink update.
	;
; Gate Array write (port &7Fxx): first a pen-select byte (0-15, or &10
	; for the border), then a colour byte &40 + hardware colour code (0-31).
	; The firmware numbers colours 0-26; __CPC_HWCOL maps them to the codes.
	    push namespace core
	; Firmware colour number (0-26) -> Gate Array colour byte (&40 + code).
__CPC_HWCOL:
	    defb $54, $44, $55, $5C, $58, $5D, $4C, $45, $4D     ;  0- 8
	    defb $56, $46, $57, $5E, $40, $5F, $4E, $47, $4F     ;  9-17
	    defb $52, $42, $53, $5A, $59, $5B, $4A, $43, $4B     ; 18-26
	; __CPC_GA_SET -- writes one colour to the Gate Array only (the firmware's
	; tables are not touched). A = pen 0-15, or 16 for the border; C =
	; firmware colour 0-26. Out-of-range values are ignored. The two writes
	; are made with interrupts off (the firmware's interrupt handler selects
	; pens too, for flashing inks), and it returns with interrupts on.
; Firmware entries called: none. In bare-metal mode the colour is also kept
	; in PAL_SHADOW (the pen's colour, for BORDER).
; Registers clobbered: AF, BC, HL.
__CPC_GA_SET:
	    PROC
	    LOCAL __CGS_NOADD
	    cp   17
	    ret  nc
	    ld   b, a               ; B = pen select byte
	    ld   a, c
	    cp   27
	    ret  nc
#line 55 "src/lib/arch/cpc/runtime/gacolour.asm"
	    ld   hl, __CPC_HWCOL
	    add  a, l
	    ld   l, a
	    jr   nc, __CGS_NOADD
	    inc  h
__CGS_NOADD:
	    ld   c, (hl)            ; C = colour byte
	    ld   a, b
	    ld   b, $7F             ; port &7Fxx; the low byte is ignored
	    di
	    out  (c), a             ; select the pen
    out  (c), c             ; colour: data = C
	    ei
	    ret
	    ENDP
; __CPC_SET_INK -- A = pen (0-15), C = firmware colour 0-26: sets it in
; the firmware (not flashing: both inks the same) and on the Gate Array.
	; Colours above 26 and pens above 15 are ignored (the firmware itself
	; wraps pen 16 round to pen 0, so it is not passed on).
; Firmware entry called: SCR_SET_INK (&BC32, A = pen, B and C = colour).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the gate).
__CPC_SET_INK:
	    cp   16
	    ret  nc
	    ld   b, a
	    ld   a, c
	    cp   27
	    ret  nc
	    ld   a, b
	    ld   b, c
	    push af
	    push bc
	    call .core.__FW_CALL
	    defw $BC32
	    pop  bc
	    pop  af
#line 94 "src/lib/arch/cpc/runtime/gacolour.asm"
    jp   __CPC_GA_SET           ; bare-metal mode: the Gate Array only
; __CPC_SET_BORDER -- A = firmware colour 0-26: sets the border in the
	; firmware and on the Gate Array. Colours above 26 are ignored.
; Firmware entry called: SCR_SET_BORDER (&BC38, B and C = colour).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the gate).
__CPC_SET_BORDER:
	    cp   27
	    ret  nc
	    ld   b, a
	    ld   c, a
	    push bc
	    call .core.__FW_CALL
	    defw $BC38
	    pop  bc
#line 111 "src/lib/arch/cpc/runtime/gacolour.asm"
	    ld   a, 16
    jp   __CPC_GA_SET           ; bare-metal mode: the Gate Array only
	    pop namespace
#line 313 "src/lib/arch/cpc/stdlib/cpc.bas"
	END
