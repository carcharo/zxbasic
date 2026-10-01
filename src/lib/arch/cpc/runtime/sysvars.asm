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
;   ------  ----
;   $D1     (209 bytes used)
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
; $D1 bytes used out of CPC_PRIV_SIZE ($400 = 1024). CPC_SYSVARS_USED
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

CPC_SYSVARS_USED    EQU $D1                 ; bytes used above; compare by eye against
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
