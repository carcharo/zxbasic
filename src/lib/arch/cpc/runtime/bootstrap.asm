; -----------------------------------------------------------------------
; Amstrad CPC bootstrap -- captures FW_BC, initialises the private
; runtime block's sysvars, and sets the initial screen mode
;
; Registered with #init, so the compiler inserts
; "call .core.CPC_INIT_00_BOOTSTRAP" in the prologue (src/arch/cpc/
; backend/main.py's emit_prologue()).
;
; Forced into every program via common.REQUIRES (backend/main.py's
; Backend.init()) rather than pulled in transitively: this must run
; even in programs with no PRINT/arrays/etc. that would otherwise never
; #include sysvars.asm.
;
; Naming: #init calls are emitted in sorted label order (sorted() over
; the raw strings passed to every #init directive -- see
; src/arch/z80/backend/main.py's emit_prologue and
; src/zxbc/zxbparser.py's preproc_line_init). FW_BC must be captured from
; the live BC' before anything else can disturb it (see fwcall.asm's
; header), which means this routine must be the first #init call, full
; stop -- not just first among the cpc runtime's own files, but first
; against anything any future #include might add. ".core.CPC_INIT_FP_CALC"
; (fp_calc.asm) would otherwise sort before ".core.CPC_INIT_SYSVARS" (F <
; S), so the routine is named CPC_INIT_00_BOOTSTRAP: the "00_" digit
; prefix sorts before any plausible future "CPC_INIT_<LETTER>..." name
; (digits are below uppercase letters in ASCII), which is a stronger
; guarantee than just renaming past today's one clash. Nothing else
; references the old CPC_INIT_SYSVARS name.

#ifdef CPC_BAREMETAL
; Bare-metal mode: the firmware is never called; see bareboot.asm.
#include once <bareboot.asm>
#else

#include once <sysvars.asm>
#include once <fwcall.asm>
#include once <isr.asm>
#include once <colour.asm>

#init .core.CPC_INIT_00_BOOTSTRAP

    push namespace core

; CPC_INIT_00_BOOTSTRAP -- captures FW_BC, zero-fills the private
; runtime block ($9E00-$A1FF, .core.CPC_PRIV_BASE for
; .core.CPC_PRIV_SIZE bytes), installs the interrupt front-end, sets the
; few sysvars that need a non-zero default, then sets screen MODE 1
; through the firmware gate (which turns interrupts on for good).
;
; FW_BC is captured first, before the zero-fill, but can't be written
; to its sysvar slot yet -- that slot is about to be zeroed along with
; the rest of the block. So it's parked on the stack (already valid:
; the prologue sets SP before calling #init routines) and only written
; out to FW_BC once the zero-fill is done.
;
; Firmware entry called: SCR_SET_MODE (&BC0E, via the gate, once
; FW_BC/IN_FW exist) -- see fwcall.asm for what that call clobbers.
; Registers clobbered: AF, BC, DE, HL (and, transiently, BC'/DE'/HL').
CPC_INIT_00_BOOTSTRAP:
    PROC

    ; Capture the firmware's BC' immediately -- see the header above
    ; and fwcall.asm's contract. Parked on the stack, not yet in FW_BC.
    exx
    push bc
    exx

    ; Zero-fill the whole private block; sysvars set below simply
    ; overwrite their own zeroed slot. This also zeroes FW_BC's and
    ; IN_FW's slots -- the captured value is still safe on the stack.
    ld   hl, .core.CPC_PRIV_BASE
    ld   (hl), 0
    ld   de, .core.CPC_PRIV_BASE + 1
    ld   bc, .core.CPC_PRIV_SIZE - 1
    ldir

    ; Now write the captured FW_BC out to its (freshly-zeroed) slot.
    ; IN_FW stays 0, which the zero-fill already set.
    pop  bc
    ld   (FW_BC), bc

    ; Our interrupt front-end (isr.asm) goes in before anything enables
    ; interrupts: the first firmware call below returns with them on,
    ; and they stay on from then on.
    call __CPC_ISR_INSTALL

    ; ERR_NR: -1 means "no error", not 0 (matches the ZX Spectrum manual's
    ; convention).
    ld   a, $FF
    ld   (ERR_NR), a

    ; Initial permanent attribute: INK 7 / PAPER 0 (white on black), which
    ; colour.asm maps to the firmware's own default pens, pen 1 on pen 0
    ; in mode 1 (yellow on blue). Set here, not by print.asm, because
    ; PLOT/DRAW/CIRCLE use it too in programs that never PRINT; left at 0
    ; it would be black on black, i.e. invisible.
    ld   a, 7
    ld   (ATTR_P), a

    ; SCREEN_ADDR: mode 1 screen base. SCREEN_ATTR_ADDR is left zeroed --
    ; see the placeholder note in sysvars.asm.
    ld   hl, $C000
    ld   (SCREEN_ADDR), hl

    ; Cursor at the top-left of the text window.
    ld   hl, 0
    ld   (S_POSN), hl

    ; Screen mode 1 (40x25, 4 colours). SCR_SET_MODE also resets the
    ; text/graphics windows to full-screen, the graphics origin, and
    ; the current stream -- and, confirmed in the emulator (see
    ; cpc-port-notes.md Phase 2 results), clears the screen and homes
    ; the firmware's own text cursor, even though the Firmware Guide's
    ; own entry for &BC0E doesn't spell that out explicitly.
    ld   a, 1
    call .core.__FW_CALL
    defw $BC0E
    ld   a, 1
    call __CPC_SET_MODE_VARS    ; colour.asm: pen map, widths for mode 1

    ; Empty the key buffer: the RETURN that submitted RUN"<prog> can
    ; still be in it, and the first INKEY$ or PAUSE would see it.
    jp   __CPC_FLUSH_KEYS

    ENDP

; __CPC_FLUSH_KEYS -- discards every character waiting in the firmware's
; key buffer. KM_FLUSH (&BD3D) does this on the 664/6128 only, so this
; reads characters with KM_READ_CHAR (&BB09, every model) until it
; reports none (Carry clear).
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__CPC_FLUSH_KEYS:
    call .core.__FW_CALL
    defw $BB09
    jr   c, __CPC_FLUSH_KEYS
    ret

; __CPC_WAIT_KEY -- flushes stale keys, then waits for a new keypress
; (KM_WAIT_KEY, &BB18). END and runtime errors use it so the program's
; last screen stays visible until a key is pressed (notes.md question 1).
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__CPC_WAIT_KEY:
    call __CPC_FLUSH_KEYS
    call .core.__FW_CALL
    defw $BB18
    ret

; __CPC_END -- the single choke point for a *clean* END (src/arch/cpc/
; backend/generic.py's _end emits "jp .core.__CPC_END" for every END in
; the program, instead of a bare RST 0). Reaching address 0 by itself
; doesn't prove the program reached END: a crash that happens to reset
; the machine, or a runtime error (error.asm's __ERROR, also RST 0 after
; printing "Error n"), lands there too. This is forced into every build
; (bootstrap.asm is in common.REQUIRES unconditionally -- see the file
; header), so it's the one place a distinguishing marker can live for
; every program, not just ones that happen to #include some other file.
;
; Under -D __CPC_PRINTER_ECHO__ (cpcbuild's cpcrun.py test harness),
; sends __CPC_END_MARKER -- a line containing only "\x04END" -- to the
; printer via MC_PRINT_CHAR (&BD2B), through the gate, before the RST 0.
; \x04 (ASCII EOT) as the first byte makes the line unlike anything a
; Boriel program can PRINT (print.asm's control-code table drops or
; diverts every code below 32 except 6/8/13-23) and unlike the
; "NOT IMPLEMENTED" (stub.asm) / "Error n" (error.asm) text the same
; transcript can otherwise contain, so cpcrun.py can grep for it
; unambiguously and strip it from the reported transcript.
;
; Without the flag it waits for a key first (__CPC_WAIT_KEY), so the
; program's output stays on screen (notes.md question 1), then resets.
;
; Firmware entries called: MC_PRINT_CHAR (&BD2B) in printer-echo builds;
; KM_READ_CHAR/KM_WAIT_KEY otherwise. Registers clobbered: none (never
; returns).
#ifdef __CPC_PRINTER_ECHO__
__CPC_END_MARKER: DEFB 4, "END", 10, 0
#endif

__CPC_END:
#ifdef __CPC_PRINTER_ECHO__
    PROC
    LOCAL __CE_LOOP, __CE_DONE, __CE_RETRY, __CE_SENT

    ld   hl, __CPC_END_MARKER
__CE_LOOP:
    ld   a, (hl)
    or   a
    jr   z, __CE_DONE
    inc  hl
    push hl
    ld   b, 3
__CE_RETRY:
    call .core.__FW_CALL
    defw $BD2B
    jr   c, __CE_SENT
    djnz __CE_RETRY
__CE_SENT:
    pop  hl
    jr   __CE_LOOP
__CE_DONE:
    di                  ; the firmware's reset rebuilds the &0038 vector
    rst  0
    ENDP
#else
    call __CPC_WAIT_KEY
    di
    rst  0
#endif

    pop namespace
#endif
