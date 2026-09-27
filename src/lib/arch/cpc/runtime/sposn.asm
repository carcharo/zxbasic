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

#include once <fwcall.asm>
#include once <sysvars.asm>

; Printing positioning library.
    push namespace core

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

    ld a, h           ; H = logical column, 1-based (up to 41)
    cp SCR_COLS_VISIBLE + 1
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

    pop namespace
