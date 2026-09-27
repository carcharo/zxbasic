	org 4096
	.core.CPC_PRIV_BASE EQU 40448
	.core.CPC_PRIV_SIZE EQU 1024
	.core.CPC_STACK_TOP EQU 42496
	.core.CPC_MEM_TOP EQU 42619
.core.__START_PROGRAM:
	di
	ld sp, .core.CPC_STACK_TOP
	call .core.CPC_INIT_SYSVARS
	jp .core.__MAIN_PROGRAM__
.core.ZXBASIC_USER_DATA:
	; Defines USER DATA Length in bytes
.core.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_END - .core.ZXBASIC_USER_DATA
	.core.__LABEL__.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_LEN
	.core.__LABEL__.ZXBASIC_USER_DATA EQU .core.ZXBASIC_USER_DATA
_a:
	DEFB 01h
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	ld hl, _a
	inc (hl)
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	rst 0
	;; --- end of user code ---
#line 1 "src/lib/arch/cpc/runtime/bootstrap.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC bootstrap -- initialises the private runtime block's sysvars
	;
	; Registered with #init, so the compiler inserts
	; `call .core.CPC_INIT_SYSVARS` in the prologue (src/arch/cpc/backend/
	; main.py's emit_prologue()).
	;
	; Forced into every program via common.REQUIRES (backend/main.py's
; Backend.init()) rather than pulled in transitively: CPC_INIT_SYSVARS
	; must run even in programs with no PRINT/arrays/etc. that would
	; otherwise never #include sysvars.asm.
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
	; This file only defines the *names and offsets*; CPC_INIT_SYSVARS
	; (bootstrap.asm) fills them in at runtime.
	;
; Layout ($9E00 + offset), all byte offsets from SYSVAR_BASE:
	;
	;   Offset  Size  Name               Note
	;   ------  ----  -----------------  ---------------------------------
	;   $00     2     CHARS              pointer to charset (8x8 cells)
	;   $02     2     UDG                pointer to UDG charset
	;   $04     2     COORDS             last PLOT/graphics coords (X,Y)
	;   $06     1     FLAGS2             screen flags (OVER/INVERSE/etc.)
	;   $07     1     ECHO_E             reserved, unused for now
	;   $08     2     DFCC               next screen bitmap addr for PRINT
	;   $0A     2     DFCCL              next screen attr addr for PRINT
	;   $0C     2     S_POSN             cursor position (H=row, L=column)
	;   $0E     1     ATTR_P             permanent attribute (INK/PAPER/etc.)
	;   $0F     1     ATTR_T             temporary attribute
	;   $10     1     P_FLAG             permanent print flags (OVER/INVERSE)
	;   $11     1     TV_FLAG            flags controlling output to screen
	;   $12     8     MEM0               scratch buffer, character bitmap gen.
	;   $1A     2     SCREEN_ADDR        pointer to the screen bitmap base
	;   $1C     2     SCREEN_ATTR_ADDR   placeholder -- the CPC has no
	;                                    per-cell attribute byte in memory
	;                                    the way the Spectrum does
	;   $1E     1     ERR_NR             error code (-1 = no error)
	;   $1F     2     FRAMES             software frame counter
	;   $21     2     RANDOM_SEED_LOW    RNG seed, low 16 bits
	;   $23     8     ARRAY_SCRATCH      LBOUND_PTR/UBOUND_PTR/RET_ADDR/
	;                                    TMP_ARR_PTR (2 bytes each)
	;   $2B     2     CHR_SCRATCH        return-address scratch for CHR$()
	;   $2D     4     DIVF_SCRATCH       TMP (2B) + ERR_SP (2B) for float
	;                                    division
;   $31     2     FW_BC              TODO(cpc): firmware BC' shadow, for
	;                                    a firmware call gate
;   $33     1     IN_FW              TODO(cpc): "inside firmware gate"
	;                                    flag
	;   $34     6     MODF16_SCRATCH     return addr + divider DE/HL for
	;                                    MOD16.16, kept separate from
	;                                    ARRAY_SCRATCH (the two must not alias)
	;   ------  ----
	;   $3A     (58 bytes used)
	;
	; $3A bytes used out of CPC_PRIV_SIZE ($400 = 1024). CPC_SYSVARS_USED
	; below lets it be compared against .core.CPC_PRIV_SIZE by eye whenever
	; this table grows.
	    push namespace core
	SYSVAR_BASE         EQU .core.CPC_PRIV_BASE
	CHARS               EQU SYSVAR_BASE + $00   ; DW -- pointer to charset (8x8 cells)
	UDG                 EQU SYSVAR_BASE + $02   ; DW -- pointer to UDG charset
	COORDS              EQU SYSVAR_BASE + $04   ; DW -- last PLOT/graphics coordinates (X,Y)
	FLAGS2              EQU SYSVAR_BASE + $06   ; DB -- screen flags (OVER/INVERSE/etc.)
	ECHO_E              EQU SYSVAR_BASE + $07   ; DB -- (reserved, unused for now)
	DFCC                EQU SYSVAR_BASE + $08   ; DW -- next screen bitmap address for PRINT
	DFCCL               EQU SYSVAR_BASE + $0A   ; DW -- next screen attribute address for PRINT
	S_POSN              EQU SYSVAR_BASE + $0C   ; DW -- cursor position (H=row, L=column)
	ATTR_P              EQU SYSVAR_BASE + $0E   ; DB -- permanent attribute (INK/PAPER/etc.)
	ATTR_T              EQU SYSVAR_BASE + $0F   ; DB -- temporary attribute
	P_FLAG              EQU SYSVAR_BASE + $10   ; DB -- permanent print flags (OVER/INVERSE)
	TV_FLAG             EQU SYSVAR_BASE + $11   ; DB -- flags controlling output to screen
	MEM0                EQU SYSVAR_BASE + $12   ; 8B -- scratch buffer for character bitmap generation
	SCREEN_ADDR         EQU SYSVAR_BASE + $1A   ; DW -- pointer to the screen bitmap base
	SCREEN_ATTR_ADDR    EQU SYSVAR_BASE + $1C   ; DW -- placeholder, see table above
	ERR_NR              EQU SYSVAR_BASE + $1E   ; DB -- error code (-1 = no error)
	FRAMES              EQU SYSVAR_BASE + $1F   ; DW -- software frame counter
	RANDOM_SEED_LOW     EQU SYSVAR_BASE + $21   ; DW -- RNG seed, low 16 bits
	ARRAY_SCRATCH       EQU SYSVAR_BASE + $23   ; 8B -- LBOUND_PTR/UBOUND_PTR/RET_ADDR/TMP_ARR_PTR
	CHR_SCRATCH         EQU SYSVAR_BASE + $2B   ; 2B -- return-address scratch for CHR$()
	DIVF_SCRATCH        EQU SYSVAR_BASE + $2D   ; 4B -- TMP (2B) + ERR_SP (2B) for float division
FW_BC               EQU SYSVAR_BASE + $31   ; 2B -- TODO(cpc): firmware BC' shadow
IN_FW               EQU SYSVAR_BASE + $33   ; 1B -- TODO(cpc): "inside firmware gate" flag
	MODF16_SCRATCH      EQU SYSVAR_BASE + $34   ; 6B -- return addr + divider DE/HL for MOD16.16
	CPC_SYSVARS_USED    EQU $3A                 ; bytes used above; compare by eye against
	                                             ; .core.CPC_PRIV_SIZE when this table grows
; --- Screen constants (CPC mode 1: 40 columns x 25 rows) ----------------
	; SCR_COLS keeps zx48k's own "columns + 1" convention (see zx48k's
; sysvars.asm: SCR_COLS EQU 33 for 32 visible columns).
	SCR_COLS            EQU 41      ; columns + 1 (40 columns visible)
	SCR_ROWS            EQU 25      ; rows visible
	SCR_SIZE            EQU (SCR_ROWS << 8) + SCR_COLS
	    pop namespace
#line 14 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    push namespace core
	; CPC_INIT_SYSVARS -- zero-fills the private runtime block
	; ($9E00-$A1FF, .core.CPC_PRIV_BASE for .core.CPC_PRIV_SIZE bytes) and then
	; sets the few sysvars that need a non-zero default.
	;
; Firmware entry called: none (interrupts are off; this runs before any
	; firmware call is possible).
; Registers clobbered: AF, BC, DE, HL.
CPC_INIT_SYSVARS:
	    PROC
	    ; Zero-fill the whole private block first; sysvars set below simply
	    ; overwrite their own zeroed slot.
	    ld   hl, .core.CPC_PRIV_BASE
	    ld   (hl), 0
	    ld   de, .core.CPC_PRIV_BASE + 1
	    ld   bc, .core.CPC_PRIV_SIZE - 1
	    ldir
    ; ERR_NR: -1 means "no error", not 0 (matches the ZX Spectrum manual's
	    ; convention).
	    ld   a, $FF
	    ld   (ERR_NR), a
    ; SCREEN_ADDR: mode 1 screen base. SCREEN_ATTR_ADDR is left zeroed --
	    ; see the placeholder note in sysvars.asm.
	    ld   hl, $C000
	    ld   (SCREEN_ADDR), hl
	    ; Cursor at the top-left of the text window.
	    ld   hl, 0
	    ld   (S_POSN), hl
	    ret
	    ENDP
	    pop namespace
#line 10 "tests/functional/arch/cpc/intbyte.bas"
	END
