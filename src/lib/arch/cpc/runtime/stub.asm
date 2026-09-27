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
;
; Phase-3 printer echo (-D __CPC_PRINTER_ECHO__): a hang looks the same
; from outside as a real timeout, so cpcbuild's cpcrun.py can only tell
; the two apart (both time out) unless the stub leaves a clue. Cheap to
; do: print "NOT IMPLEMENTED" to the printer (MC_PRINT_CHAR &BD2B,
; direct gate calls -- print.asm isn't necessarily linked in) before the
; di/halt. Interrupts are still enabled at this point (the prologue's
; own `di` is long past, and nothing here disables them), so the gate's
; own `ei`/`di` bracket around each character is safe.

#ifdef __CPC_PRINTER_ECHO__
#include once <fwcall.asm>
#endif

    push namespace core

; __CPC_NOT_IMPLEMENTED -- hangs the CPU. Nothing calls or returns from
; this; it is a dead end reached only by a `jp` from an unfinished stub.
; Firmware entry called: none. Registers clobbered: none (never returns).
__CPC_NOT_IMPLEMENTED:
#ifdef __CPC_PRINTER_ECHO__
    PROC
    LOCAL __CNI_STR, __CNI_LOOP, __CNI_DONE, __CNI_RETRY, __CNI_SENT

    ld   hl, __CNI_STR
__CNI_LOOP:
    ld   a, (hl)
    or   a
    jr   z, __CNI_DONE
    inc  hl
    push hl
    ld   b, 3
__CNI_RETRY:
    call .core.__FW_CALL
    defw $BD2B
    jr   c, __CNI_SENT
    djnz __CNI_RETRY
__CNI_SENT:
    pop  hl
    jr   __CNI_LOOP
__CNI_DONE:
    di
    halt

__CNI_STR: DEFB "NOT IMPLEMENTED", 10, 0
    ENDP
#else
    di
    halt
#endif

    pop namespace
