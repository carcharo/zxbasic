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

#include once <sysvars.asm>

#init .core.CPC_INIT_SYSVARS

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
