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

#include once <sposn.asm>
#include once <fwcall.asm>
#include once <error.asm>
#include once <table_jump.asm>
#include once <ink.asm>
#include once <paper.asm>
#include once <flash.asm>
#include once <bright.asm>
#include once <over.asm>
#include once <inverse.asm>
#include once <bold.asm>
#include once <italic.asm>
#include once <sysvars.asm>
#ifdef CPC_BAREMETAL
#include once <txtbare.asm>
#endif

    push namespace core

#ifdef __CPC_PRINTER_ECHO__
#ifdef CPC_BAREMETAL
; __PRN_ECHO -- sends A to the printer port directly (bareboot.asm's
; __CPC_PRN_CHAR). Preserves AF, BC, DE.
__PRN_ECHO:
    push af
    push bc
    push de
    call __CPC_PRN_CHAR
    pop  de
    pop  bc
    pop  af
    ret
#else
; __PRN_ECHO -- sends A to the printer (MC_PRINT_CHAR &BD2B), through
; the gate; preserves A/F. Retried a few times: the Firmware Guide says
; a busy printer makes MC_PRINT_CHAR give up after 0.4s (Carry clear on
; return); caprice32's virtual printer (this file's only tested target
; so far) never reports busy, so the retry is defensive, not load-bearing.
__PRN_ECHO:
    PROC
    push af
    push bc
    ld   b, 3
__PE_TRY:
    call .core.__FW_CALL
    defw $BD2B
    jr   c, __PE_DONE
    djnz __PE_TRY
__PE_DONE:
    pop  bc
    pop  af
    ret
    ENDP
#endif
#endif

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
#ifdef CPC_BAREMETAL
    push de             ; TXT_OUTPUT preserved every register, and callers
                        ; (printnum.asm and friends) rely on DE surviving
#endif

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
#ifdef CPC_BAREMETAL
    ; Bare-metal mode: the glyph table is indexed by the Spectrum code
    ; directly (block graphics 128-143 are generated in its numbering),
    ; so there is no translation.
    push af
    call __BT_PUTC
    pop af              ; the character again, for the echo
#ifdef __CPC_PRINTER_ECHO__
    call __PRN_ECHO
#endif
    jr __PC_DONE
__PC_OUT:               ; (unused in bare mode; the label keeps the LOCAL list valid)
#else
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
#ifdef __CPC_PRINTER_ECHO__
    call __PRN_ECHO     ; A still holds the char -- TXT_OUTPUT preserves it
#endif
    jr __PC_DONE
#endif

__PC_STATE_DISPATCH:    ; C held a pending state -> this byte is its parameter
    ld hl, __PC_STATE_TABLE
    ld a, c
    call JUMP_HL_PLUS_2A

__PC_DONE:
#ifdef CPC_BAREMETAL
    pop de
#endif
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
#ifdef CPC_BAREMETAL
    ; Bare-metal mode: CR then LF (the LF scrolls at the bottom row) by
    ; __BT_PUTC; no firmware entry. Registers clobbered: AF, BC, DE, HL.
    call __BT_CR
    call __BT_LF
    ld a, 10            ; (for the printer echo below)
#else
    ld a, 13
    call .core.__FW_CALL
    defw $BB5A
    ld a, 10
    call .core.__FW_CALL
    defw $BB5A
#endif
#ifdef __CPC_PRINTER_ECHO__
    call __PRN_ECHO     ; printer gets a bare LF, not CR+LF -- see header
#endif
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
#ifdef __CPC_PRINTER_ECHO__
    ld a, 10            ; AT emits no character -- send a bare LF instead
    call __PRN_ECHO
#endif
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
#ifdef __CPC_PRINTER_ECHO__
    ld a, 10            ; AT emits no character -- send a bare LF instead
    call __PRN_ECHO
#endif
    ret

__PA_ERR:
    ld a, ERROR_OutOfScreen
    jp __STOP

    ENDP

    pop namespace
