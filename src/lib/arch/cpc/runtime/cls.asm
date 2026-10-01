;; Clears the text screen and homes the cursor, via the firmware.
;;
;; zx48k's CLS clears the Spectrum bitmap and attribute areas directly
;; and resets its own cursor/VRAM-pointer sysvars; there is no VRAM to
;; touch here, and no local cursor cache to reset (see sposn.asm). The
;; one thing that needs doing by hand is the *colour* to clear to:
;; TXT_CLEAR_WINDOW clears using the firmware's *current* PAPER, and
;; Sinclair BASIC's CLS always clears to the permanent attribute's
;; paper (not any temporary one left over from the last PRINT), so the
;; permanent paper is pushed to the firmware first.

#include once <colour.asm>
#include once <fwcall.asm>
#include once <sysvars.asm>

    push namespace core

CLS:
    ; Firmware entries called (via the gate): TXT_SET_PAPER (&BB96, A =
    ; paper pen) then TXT_CLEAR_WINDOW (&BB6C), which clears the
    ; current window with that paper and homes the cursor to its
    ; top-left corner (0,0 for the default full-screen window).
    ; Registers clobbered: AF, HL (main); BC', DE', HL', AF' (the gate).
    PROC

    ld a, (ATTR_P)
    rrca
    rrca
    rrca                   ; paper: bits 3-5 of ATTR_P -> bits 0-2
    call __INK_TO_PEN      ; -> pen of the current mode (colour.asm)
    call .core.__FW_CALL
    defw $BB96              ; TXT_SET_PAPER

    call .core.__FW_CALL
    defw $BB6C               ; TXT_CLEAR_WINDOW

    ret

    ENDP

    pop namespace
