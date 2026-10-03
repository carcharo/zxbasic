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

#include once <fwcall.asm>
#include once <sysvars.asm>
#include once <bootstrap.asm>
#ifdef CPC_BAREMETAL
#include once <txtbare.asm>
#endif

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

#ifndef CPC_BAREMETAL
#ifdef __CPC_PRINTER_ECHO__
; __ERR_PRN_ECHO -- sends A to the printer (MC_PRINT_CHAR &BD2B), through
; the gate. Retried a few times: the Firmware Guide says a busy printer
; makes MC_PRINT_CHAR give up after 0.4s (Carry clear), and caprice32's
; virtual printer (this file's only tested target so far) never reports
; busy, so the retry is defensive rather than load-bearing.
; Registers preserved.
__ERR_PRN_ECHO:
    PROC
    push af
    push bc
    ld   b, 3
__EPE_TRY:
    call .core.__FW_CALL
    defw $BD2B
    jr   c, __EPE_DONE
    djnz __EPE_TRY
__EPE_DONE:
    pop  bc
    pop  af
    ret
    ENDP
#endif
#endif

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
#ifdef CPC_BAREMETAL
; Bare-metal mode: no firmware. The screen part is txtbare.asm's glyph
; renderer (13 = CR, 10 = LF, 32-255 drawn); the echo goes straight to the
; printer port. Both preserve AF, BC, DE, HL.
__ERR_SCR:
    push af
    push bc
    push de
    push hl
    call __BT_PUTC
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret
__ERR_OUT:
    call __ERR_SCR
#ifdef __CPC_PRINTER_ECHO__
    push af
    push bc
    push de
    push hl
    call __CPC_PRN_CHAR
    pop  hl
    pop  de
    pop  bc
    pop  af
#endif
    ret
__ERR_RESET:
    jp   __CPC_RESET    ; bareboot.asm: lower ROM in, jump to 0
#else
; Firmware: TXT_OUTPUT (&BB5A, preserves every register) through the gate.
__ERR_SCR:
    call .core.__FW_CALL
    defw $BB5A
    ret
__ERR_OUT:
    call .core.__FW_CALL
    defw $BB5A
#ifdef __CPC_PRINTER_ECHO__
    call __ERR_PRN_ECHO
#endif
    ret
__ERR_RESET:
    di
    rst  0
#endif

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

#ifdef __CPC_PRINTER_ECHO__
    ; Echo mode: a failing test still has to reach END, so don't block
    ; on a keypress here (see the file header) -- straight to reset.
    jp   __ERR_RESET
#else
    ; Flush stale keys, then wait for a real one (bootstrap.asm).
    call __CPC_WAIT_KEY
    jp   __ERR_RESET    ; reset to BASIC's Ready prompt
#endif

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
