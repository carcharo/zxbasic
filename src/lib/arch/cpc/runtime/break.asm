; Amstrad CPC CHECK_BREAK: polls ESC via the firmware KM_TEST_KEY (&BB1E,
; key number 66) instead of the Spectrum ROM's TS_BRK (&1F54). Raises
; ERROR_BreakIntoProgram (via error.asm's __ERROR) if ESC is down.
; Emitted per source line only with --enable-break (zxbparser.py's
; visit_CHKBREAK); most programs never pull this file in.
;
; Calling convention -- preserved exactly from zx48k's break.asm, because
; the compiler (visit_CHKBREAK, src/arch/z80/visitor/translator.py) emits
; the call site itself and knows nothing about which arch it targets:
;
;     push hl             ; caller's live HL, to be restored on return
;     ld   hl, <line#>    ; line number, for the error message
;     call CHECK_BREAK
;
; No-break path: returns with HL restored to the value it had before
; "push hl" above (i.e. the caller's own HL, not the line number), AF
; also restored to what it was on entry, and the stack back to where it
; was before "push hl". Break path: never returns -- stores the line
; number and jumps into __ERROR.
;
; Firmware Guide (&BB1E): entry A = key number; exit NZ = key pressed,
; Z = not pressed; A and HL corrupt; C = shift/ctrl state; other
; registers preserved. Unlike the Spectrum's TS_BRK, HL does NOT survive
; the call, so the line number (loaded into HL by the caller, see above)
; is saved across the gate call explicitly and only relied on again
; after it returns.
;
; Reliability: the firmware updates its debounced key-state table from
; its own 300 Hz interrupt handler, which runs all the time (isr.asm,
; Phase 4d), so a held ESC is seen at the first CHECK_BREAK after the
; firmware's next keyboard scan (every 20 ms).

#include once <error.asm>
#include once <fwcall.asm>
#include once <sysvars.asm>

    push namespace core

CHECK_BREAK:
    PROC
    LOCAL NO_BREAK, BREAK_HIT

    push af             ; preserve caller's AF across this transparent check
    push hl             ; KM_TEST_KEY corrupts HL; save the line number

    ld   a, 66          ; ESC key number (Firmware Guide, KM_TEST_KEY &BB1E)
    call .core.__FW_CALL
    defw $BB1E          ; NZ = pressed; A/HL corrupt; flags come back as
                         ; the firmware left them (fwcall.asm's contract)

    pop  hl             ; recover the line number (POP does not affect flags)
    jr   nz, BREAK_HIT

NO_BREAK:
    pop  af             ; restore caller's AF
    pop  hl             ; caller's original HL (pushed before this call)
    ex   (sp), hl       ; HL = original HL; stack top = return address
    ret

BREAK_HIT:
    ld   (PPC), hl      ; line number, kept for parity with zx48k (see
                         ; sysvars.asm -- our error.asm doesn't print it)
    ld   a, ERROR_BreakIntoProgram
    jp   __ERROR        ; never returns

    ENDP

    pop namespace
