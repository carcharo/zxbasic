	org 4096
	.core.CPC_PRIV_BASE EQU 40448
	.core.CPC_PRIV_SIZE EQU 1024
	.core.CPC_STACK_TOP EQU 42496
	.core.CPC_MEM_TOP EQU 42619
.core.__START_PROGRAM:
	di
	ld sp, .core.CPC_STACK_TOP
	call .core.CPC_INIT_SYSVARS
	call .core.__MEM_INIT
	jp .core.__MAIN_PROGRAM__
.core.ZXBASIC_USER_DATA:
	; Defines HEAP SIZE
.core.ZXBASIC_HEAP_SIZE EQU 4768
	; Defines HEAP ADDRESS
.core.ZXBASIC_MEM_HEAP EQU 35680
	; Defines USER DATA Length in bytes
.core.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_END - .core.ZXBASIC_USER_DATA
	.core.__LABEL__.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_LEN
	.core.__LABEL__.ZXBASIC_USER_DATA EQU .core.ZXBASIC_USER_DATA
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	call .core.COPY_ATTR
	ld hl, .LABEL.__LABEL0
	xor a
	call .core.__PRINTSTR
	call .core.PRINT_EOL
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	rst 0
.LABEL.__LABEL0:
	DEFW 0009h
	DEFB 48h
	DEFB 45h
	DEFB 4Ch
	DEFB 4Ch
	DEFB 4Fh
	DEFB 20h
	DEFB 43h
	DEFB 50h
	DEFB 43h
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
#line 24 "tests/functional/arch/cpc/print_hello.bas"
#line 1 "src/lib/arch/cpc/runtime/copy_attr.asm"
; Phase-1 stub for zx48k/runtime/copy_attr.asm (was: copying ATTR_P into
	; ATTR_T and, via __SET_ATTR_MODE, self-modifying a PRINT_MODE/
	; INVERSE_MODE opcode pair inside print.asm's __PRINTCHAR). Whenever a
	; program uses PRINT, the compiler defines ___PRINT_IS_USED___, which
	; turns on the branch of __SET_ATTR_MODE that pokes those opcodes, so
; this can't be reduced to a plain ATTR_P->ATTR_T copy: its real
	; behaviour is inseparable from print.asm's internals. Reached from
	; inverse.asm's INVERSE_TMP, over.asm's OVER_TMP and print_eol_attr.asm.
; TODO(cpc): Phase 2/4a -> together with print.asm.
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
	    push namespace core
	; __CPC_NOT_IMPLEMENTED -- hangs the CPU. Nothing calls or returns from
	; this; it is a dead end reached only by a `jp` from an unfinished stub.
; Firmware entry called: none. Registers clobbered: none (never returns).
__CPC_NOT_IMPLEMENTED:
	    di
	    halt
	    pop namespace
#line 12 "src/lib/arch/cpc/runtime/copy_attr.asm"
	    push namespace core
COPY_ATTR:
	    jp __CPC_NOT_IMPLEMENTED
__SET_ATTR_MODE:
	    jp __CPC_NOT_IMPLEMENTED
	    pop namespace
#line 25 "tests/functional/arch/cpc/print_hello.bas"
#line 1 "src/lib/arch/cpc/runtime/print.asm"
; Phase-1 stub for zx48k/runtime/print.asm (was: the PRINT character
	; writer, writing directly into Spectrum VRAM using the ROM's
	; interleaved-row bitmap layout, self-modifying a PRINT_MODE/INVERSE_MODE
	; opcode pair per call, reading CHARS/UDG as the font source, testing
	; `bit n,(iy+$47)` against a fixed Spectrum sysvar IY convention the CPC
	; doesn't have, and calling the ROM's PO_GR_1 &0B38 / SCROLL &0DFE). None
	; of that has a CPC equivalent yet. __PRINTCHAR is exported because
	; printnum.asm/printstr.asm (both inherited unchanged) call it directly
	; per character; PRINT_EOL is exported because print_eol_attr.asm
	; (inherited unchanged) calls it before COPY_ATTR.
; TODO(cpc): Phase 2/4a -> a CPC-native character writer, either
	; bitmap-blit into the linear mode 1 screen directly, or through the
	; firmware's TXT_OUTPUT (&BB5A) / TXT_WR_CHAR (&BB5D).
	    push namespace core
PRINT_AT:
	    jp __CPC_NOT_IMPLEMENTED
PRINT_COMMA:
	    jp __CPC_NOT_IMPLEMENTED
PRINT_EOL:
	    jp __CPC_NOT_IMPLEMENTED
PRINT_TAB:
	    jp __CPC_NOT_IMPLEMENTED
__PRINTCHAR:
	    jp __CPC_NOT_IMPLEMENTED
	    pop namespace
#line 26 "tests/functional/arch/cpc/print_hello.bas"
#line 1 "src/lib/arch/zx48k/runtime/printstr.asm"
#line 1 "src/lib/arch/cpc/runtime/sposn.asm"
; Phase-1 stub for zx48k/runtime/sposn.asm (was: print cursor
	; positioning, converting between S_POSN and a Spectrum VRAM/attribute
	; address via the ROM's interleaved-bitmap formula). Meaningless on the
	; CPC's linear mode 1 layout. Used internally by print.asm and directly
	; by the stdlib POS()/CSRLIN() functions.
; TODO(cpc): Phase 2/4a -> together with print.asm and attr.asm.
	    push namespace core
__LOAD_S_POSN:
	    jp __CPC_NOT_IMPLEMENTED
__SAVE_S_POSN:
	    jp __CPC_NOT_IMPLEMENTED
__SET_SCR_PTR:
	    jp __CPC_NOT_IMPLEMENTED
	    pop namespace
#line 3 "src/lib/arch/zx48k/runtime/printstr.asm"
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
#line 4 "src/lib/arch/zx48k/runtime/printstr.asm"
#line 1 "src/lib/arch/zx48k/runtime/mem/free.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	;
	; This ASM library is licensed under the BSD license
	; you can use it for any purpose (even for commercial
	; closed source programs).
	;
	; Please read the BSD license on the internet
	; ----- IMPLEMENTATION NOTES ------
	; The heap is implemented as a linked list of free blocks.
; Each free block contains this info:
	;
	; +----------------+ <-- HEAP START
	; | Size (2 bytes) |
	; |        0       | <-- Size = 0 => DUMMY HEADER BLOCK
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   | <-- If Size > 4, then this contains (size - 4) bytes
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+   |
	;   <Allocated>        | <-- This zone is in use (Already allocated)
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Next (2 bytes) |--> NULL => END OF LIST
	; |    0 = NULL    |
	; +----------------+
	; | <free bytes...>|
	; | (0 if Size = 4)|
	; +----------------+
	; When a block is FREED, the previous and next pointers are examined to see
	; if we can defragment the heap. If the block to be breed is just next to the
	; previous, or to the next (or both) they will be converted into a single
	; block (so defragmented).
	;   MEMORY MANAGER
	;
	; This library must be initialized calling __MEM_INIT with
	; HL = BLOCK Start & DE = Length.
	; An init directive is useful for initialization routines.
	; They will be added automatically if needed.
#line 1 "src/lib/arch/zx48k/runtime/mem/heapinit.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	;
	; This ASM library is licensed under the BSD license
	; you can use it for any purpose (even for commercial
	; closed source programs).
	;
	; Please read the BSD license on the internet
	; ----- IMPLEMENTATION NOTES ------
	; The heap is implemented as a linked list of free blocks.
; Each free block contains this info:
	;
	; +----------------+ <-- HEAP START
	; | Size (2 bytes) |
	; |        0       | <-- Size = 0 => DUMMY HEADER BLOCK
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   | <-- If Size > 4, then this contains (size - 4) bytes
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+   |
	;   <Allocated>        | <-- This zone is in use (Already allocated)
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Next (2 bytes) |--> NULL => END OF LIST
	; |    0 = NULL    |
	; +----------------+
	; | <free bytes...>|
	; | (0 if Size = 4)|
	; +----------------+
	; When a block is FREED, the previous and next pointers are examined to see
	; if we can defragment the heap. If the block to be breed is just next to the
	; previous, or to the next (or both) they will be converted into a single
	; block (so defragmented).
	;   MEMORY MANAGER
	;
	; This library must be initialized calling __MEM_INIT with
	; HL = BLOCK Start & DE = Length.
	; An init directive is useful for initialization routines.
	; They will be added automatically if needed.
	; ---------------------------------------------------------------------
	;  __MEM_INIT must be called to initalize this library with the
	; standard parameters
	; ---------------------------------------------------------------------
	    push namespace core
__MEM_INIT: ; Initializes the library using (RAMTOP) as start, and
	    ld hl, ZXBASIC_MEM_HEAP  ; Change this with other address of heap start
	    ld de, ZXBASIC_HEAP_SIZE ; Change this with your size
	; ---------------------------------------------------------------------
	;  __MEM_INIT2 initalizes this library
; Parameters:
;   HL : Memory address of 1st byte of the memory heap
;   DE : Length in bytes of the Memory Heap
	; ---------------------------------------------------------------------
__MEM_INIT2:
	    ; HL as TOP
	    PROC
	    dec de
	    dec de
	    dec de
	    dec de        ; DE = length - 4; HL = start
	    ; This is done, because we require 4 bytes for the empty dummy-header block
	    xor a
	    ld (hl), a
	    inc hl
    ld (hl), a ; First "free" block is a header: size=0, Pointer=&(Block) + 4
	    inc hl
	    ld b, h
	    ld c, l
	    inc bc
	    inc bc      ; BC = starts of next block
	    ld (hl), c
	    inc hl
	    ld (hl), b
	    inc hl      ; Pointer to next block
	    ld (hl), e
	    inc hl
	    ld (hl), d
	    inc hl      ; Block size (should be length - 4 at start); This block contains all the available memory
	    ld (hl), a ; NULL (0000h) ; No more blocks (a list with a single block)
	    inc hl
	    ld (hl), a
	    ld a, 201
	    ld (__MEM_INIT), a; "Pokes" with a RET so ensure this routine is not called again
	    ret
	    ENDP
	    pop namespace
#line 69 "src/lib/arch/zx48k/runtime/mem/free.asm"
	; ---------------------------------------------------------------------
	; MEM_FREE
	;  Frees a block of memory
	;
; Parameters:
	;  HL = Pointer to the block to be freed. If HL is NULL (0) nothing
	;  is done
	; ---------------------------------------------------------------------
	    push namespace core
MEM_FREE:
__MEM_FREE: ; Frees the block pointed by HL
	    ; HL DE BC & AF modified
	    PROC
	    LOCAL __MEM_LOOP2
	    LOCAL __MEM_LINK_PREV
	    LOCAL __MEM_JOIN_TEST
	    LOCAL __MEM_BLOCK_JOIN
	    ld a, h
	    or l
	    ret z       ; Return if NULL pointer
	    dec hl
	    dec hl
	    ld b, h
	    ld c, l    ; BC = Block pointer
	    ld hl, ZXBASIC_MEM_HEAP  ; This label point to the heap start
__MEM_LOOP2:
	    inc hl
	    inc hl     ; Next block ptr
	    ld e, (hl)
	    inc hl
	    ld d, (hl) ; Block next ptr
	    ex de, hl  ; DE = &(block->next); HL = block->next
	    ld a, h    ; HL == NULL?
	    or l
	    jp z, __MEM_LINK_PREV; if so, link with previous
	    or a       ; Clear carry flag
	    sbc hl, bc ; Carry if BC > HL => This block if before
	    add hl, bc ; Restores HL, preserving Carry flag
	    jp c, __MEM_LOOP2 ; This block is before. Keep searching PASS the block
	;------ At this point current HL is PAST BC, so we must link (DE) with BC, and HL in BC->next
__MEM_LINK_PREV:    ; Link (DE) with BC, and BC->next with HL
	    ex de, hl
	    push hl
	    dec hl
	    ld (hl), c
	    inc hl
	    ld (hl), b ; (DE) <- BC
	    ld h, b    ; HL <- BC (Free block ptr)
	    ld l, c
	    inc hl     ; Skip block length (2 bytes)
	    inc hl
	    ld (hl), e ; Block->next = DE
	    inc hl
	    ld (hl), d
	    ; --- LINKED ; HL = &(BC->next) + 2
	    call __MEM_JOIN_TEST
	    pop hl
__MEM_JOIN_TEST:   ; Checks for fragmented contiguous blocks and joins them
	    ; hl = Ptr to current block + 2
	    ld d, (hl)
	    dec hl
	    ld e, (hl)
	    dec hl
	    ld b, (hl) ; Loads block length into BC
	    dec hl
	    ld c, (hl) ;
	    push hl    ; Saves it for later
	    add hl, bc ; Adds its length. If HL == DE now, it must be joined
	    or a
	    sbc hl, de ; If Z, then HL == DE => We must join
	    pop hl
	    ret nz
__MEM_BLOCK_JOIN:  ; Joins current block (pointed by HL) with next one (pointed by DE). HL->length already in BC
	    push hl    ; Saves it for later
	    ex de, hl
	    ld e, (hl) ; DE -> block->next->length
	    inc hl
	    ld d, (hl)
	    inc hl
	    ex de, hl  ; DE = &(block->next)
	    add hl, bc ; HL = Total Length
	    ld b, h
	    ld c, l    ; BC = Total Length
	    ex de, hl
	    ld e, (hl)
	    inc hl
	    ld d, (hl) ; DE = block->next
	    pop hl     ; Recovers Pointer to block
	    ld (hl), c
	    inc hl
	    ld (hl), b ; Length Saved
	    inc hl
	    ld (hl), e
	    inc hl
	    ld (hl), d ; Next saved
	    ret
	    ENDP
	    pop namespace
#line 5 "src/lib/arch/zx48k/runtime/printstr.asm"
	; PRINT command routine
	; Prints string pointed by HL
	    push namespace core
PRINT_STR:
__PRINTSTR:		; __FASTCALL__ Entry to print_string
	    PROC
	    LOCAL __PRINT_STR_LOOP
	    LOCAL __PRINT_STR_END
	    ld d, a ; Saves A reg (Flag) for later
	    ld a, h
	    or l
	    ret z	; Return if the pointer is NULL
	    push hl
	    ld c, (hl)
	    inc hl
	    ld b, (hl)
	    inc hl	; BC = LEN(a$); HL = &a$
__PRINT_STR_LOOP:
	    ld a, b
	    or c
	    jr z, __PRINT_STR_END 	; END if BC (counter = 0)
	    ld a, (hl)
	    call __PRINTCHAR
	    inc hl
	    dec bc
	    jp __PRINT_STR_LOOP
__PRINT_STR_END:
	    pop hl
	    ld a, d ; Recovers A flag
	    or a   ; If not 0 this is a temporary string. Free it
	    ret z
	    jp __MEM_FREE ; Frees str from heap and return from there
__PRINT_STR:
	    ; Fastcall Entry
	    ; It ONLY prints strings
	    ; HL = String start
	    ; BC = String length (Number of chars)
	    push hl ; Push str address for later
	    ld d, a ; Saves a FLAG
	    jp __PRINT_STR_LOOP
	    ENDP
	    pop namespace
#line 27 "tests/functional/arch/cpc/print_hello.bas"
	END
