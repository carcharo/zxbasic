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
