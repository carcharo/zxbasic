; -----------------------------------------------------------------------
; Amstrad CPC -- placeholder floating point calculator
;
; The FP runtime files (arith/*.asm, negf.asm, cmp/*.asm, bool/*.asm,
; math/*.asm) all execute `rst 30h` expecting it to behave like the ZX
; Spectrum ROM's `rst 28h` CALCULATE entry. &0030 has no meaning to the
; CPC firmware -- it is the one RST vector (RST 6) the Firmware Guide
; reserves for the user -- so nothing places anything useful there unless
; we do it ourselves.
;
; This file is only a placeholder: .core.FP_CALC_ENTRY traps (hangs the
; machine visibly) instead of running Spectrum calculator bytecode against
; whatever happens to be at &0030. #init installs `jp .core.FP_CALC_ENTRY`
; at &0030 at runtime, so RST 6 always reaches it.
;
; TODO(cpc): replace with a real calculator, porting
; src/lib/arch/zx81sd/runtime/fp_calc.asm (reimplements the ROM CALCULATE
; engine using the same 5-byte float format and Lxxxx labels). Nothing
; outside this file needs to change then: the `rst 30h` call sites and
; every other file that calls .core.FP_CALC_ENTRY will just start working.

#include once <stub.asm>

#init .core.CPC_INIT_FP_CALC

    push namespace core

; CPC_RST6_VECTOR is the fixed address of the RST 6 vector itself, not a
; relocatable name: RST 6 always executes the 3 bytes at &0030, wherever
; this file happens to be assembled into the program.
CPC_RST6_VECTOR EQU $0030

; FP_CALC_ENTRY -- for now, traps. TODO(cpc): the real ROM-CALCULATE-alike
; entry point, reached via `rst 30h` (opcode C7-equivalent at &0030..&0032
; once CPC_INIT_FP_CALC has run).
FP_CALC_ENTRY:
    jp __CPC_NOT_IMPLEMENTED

; CPC_INIT_FP_CALC -- writes `jp FP_CALC_ENTRY` (bytes $C3, lo, hi) at
; &0030-&0032, so every `rst 30h` in the FP runtime files reaches
; FP_CALC_ENTRY above. &0000-&003F is ordinary RAM that user code can
; write while the lower ROM is paged out; this must be done, and RST 6
; must only ever be used, with interrupts disabled (the lower ROM pages
; back in during firmware calls).
; Firmware entry called: none. Registers clobbered: AF, HL.
CPC_INIT_FP_CALC:
    PROC

    ld   hl, FP_CALC_ENTRY
    ld   a, $C3        ; JP opcode
    ld   (CPC_RST6_VECTOR), a
    ld   (CPC_RST6_VECTOR + 1), hl

    ret

    ENDP

    pop namespace
