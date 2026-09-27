; Phase-1 stub for zx48k/runtime/break.asm (was: Spectrum ROM TS_BRK
; &1F54, storing the current line number in PPC and raising
; ERROR_BreakIntoProgram). Only emitted with --enable-break, so most
; programs never pull this file in.
;
; CHECK_BREAK uses an unusual CALLEE-ish stack convention (the caller's
; HL/line number sits on the stack above the return address; the "no
; break" path pops and restores it with an `ex (sp), hl` dance) -- easy
; to get subtly wrong with no real keyboard scan to test against yet, so
; this traps instead of guessing.
; TODO(cpc): Phase 2/3 -> real keyboard-scan BREAK check via KM_TEST_KEY
; &BB1E (ESC key, key number 66).

#include once <stub.asm>

    push namespace core

CHECK_BREAK:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
