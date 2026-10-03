; -----------------------------------------------------------------------
; Amstrad CPC bare-metal bootstrap (-D CPC_BAREMETAL, Phase 6)
;
; Replaces bootstrap.asm's firmware start-up when the program is built
; for bare-metal mode: no firmware is called, before or after. It works
; whether the firmware ran first (RUN" from disc) or not (a cold start,
; e.g. a cartridge): every piece of hardware the runtime relies on is set
; up here from scratch.
;
; Same entry points as bootstrap.asm: CPC_INIT_00_BOOTSTRAP (first #init),
; __CPC_FLUSH_KEYS, __CPC_WAIT_KEY, __CPC_END; plus __CPC_PRN_CHAR (the
; printer port, used for the test harness's echo).
;
; Hardware touched (no firmware entries): Gate Array (&7Fxx: ROM/mode
; register, RAM configuration, palette), CRTC (&BCxx/&BDxx), PPI
; (&F4xx-&F7xx), the AY through the PPI (ay.asm), the printer port
; (&EFxx).

#include once <sysvars.asm>
#include once <isr.asm>
#include once <colour.asm>
#include once <gacolour.asm>
#include once <ay.asm>
#include once <io/keyboard/kscan.asm>

#init .core.CPC_INIT_00_BOOTSTRAP

    push namespace core

; CPC_INIT_00_BOOTSTRAP -- takes the machine over: interrupts off, both
; ROMs paged out, normal RAM configuration, PPI, CRTC (standard 50 Hz
; screen at &C000, no hardware-scroll offset), AY silent, default inks,
; screen cleared, private block zeroed with the sysvar defaults, mode 1,
; our &0038 handler in IM 1, interrupts on.
; Registers clobbered: AF, BC, DE, HL (and AF', BC', DE', HL' via ay.asm
; callers' conventions: none here).
CPC_INIT_00_BOOTSTRAP:
    PROC
    LOCAL __BB_CRTC, __BB_INKS, __BB_AY

    di
    im   1
    ld   bc, $7F8D          ; Gate Array: mode 1, lower and upper ROM off
    out  (c), c
    ; Private block zeroed and our &0038 handler installed FIRST: helpers
    ; used below (the palette writes) end with EI, and an interrupt must
    ; then find our handler (with a zero FH_ADDR), not whatever the
    ; firmware -- or nothing, on a cold start -- left at &0038.
    ld   hl, .core.CPC_PRIV_BASE
    ld   (hl), 0
    ld   de, .core.CPC_PRIV_BASE + 1
    ld   bc, .core.CPC_PRIV_SIZE - 1
    ldir
    call __CPC_ISR_INSTALL  ; jp __CPC_ISR at &0038
    ld   bc, $7F8D          ; (B for the RAM configuration write below)
    ld   c, $C0             ; RAM configuration: normal (no-op on a 464)
    out  (c), c
    ld   bc, $F782          ; PPI control: port A out, B in, C out
    out  (c), c
    ld   bc, $F600          ; PPI port C: AY inactive, cassette off, row 0
    out  (c), c

    ; CRTC registers 0-13 (a cold start leaves them undefined)
    ld   hl, __BB_CRTC
    ld   d, 0
__BB_CRTC_LOOP:
    ld   b, $BC
    out  (c), d             ; register select
    ld   b, $BD
    ld   a, (hl)
    out  (c), a             ; value
    inc  hl
    inc  d
    ld   a, d
    cp   14
    jr   nz, __BB_CRTC_LOOP

    ; AY: every register 0 (tones, noise, volumes), mixer &3F (all off)
    ld   d, 0
__BB_AY_LOOP:
    ld   a, d
    ld   c, 0
    cp   7
    jr   nz, __BB_AY
    ld   c, $3F
__BB_AY:
    push de
    call __CPC_AY_WRITE     ; A = register, C = value (interrupts are off;
    pop  de                 ; it uses D and E)
    inc  d
    ld   a, d
    cp   14
    jr   nz, __BB_AY_LOOP

    ; private block: the sysvar defaults (zeroed at the start)
    ld   a, $FF
    ld   (ERR_NR), a        ; no error
    ld   a, 7
    ld   (ATTR_P), a        ; INK 7 / PAPER 0 (pen 1 on pen 0 in mode 1)
    ld   hl, $C000
    ld   (SCREEN_ADDR), hl
    ld   hl, 0
    ld   (S_POSN), hl
    ld   a, 1
    call __CPC_SET_MODE_VARS ; pen map and widths for mode 1

    ; inks: the firmware's power-on defaults (flashing pens 14/15 steady)
    ld   hl, __BB_INKS
    xor  a
__BB_INK_LOOP:
    ld   c, (hl)
    push af
    push hl
    call __CPC_GA_SET       ; A = pen (16 = border), C = firmware colour
    pop  hl
    pop  af
    inc  hl
    inc  a
    cp   17
    jr   nz, __BB_INK_LOOP

    ; screen: &C000-&FFFF cleared to pen 0
    ld   hl, $C000
    ld   (hl), 0
    ld   de, $C001
    ld   bc, $3FFF
    ldir

    ei
    ret

__BB_CRTC:                  ; standard CPC 50 Hz values, screen &C000
    defb 63, 40, 46, $8E, 38, 0, 25, 30, 0, 7, 0, 0, $30, 0
__BB_INKS:                  ; pens 0-15, then the border (firmware numbers)
    defb 1, 24, 20, 6, 26, 0, 2, 8, 10, 12, 14, 16, 18, 22, 1, 16, 1
    ENDP

; __CPC_FLUSH_KEYS -- nothing to flush: bare mode has no key buffer.
; Registers clobbered: none.
__CPC_FLUSH_KEYS:
    ret

; __CPC_WAIT_KEY -- waits until no key is held, then for a key press
; (direct matrix scan; SHIFT and CONTROL count as keys here).
; Registers clobbered: AF, BC, DE, HL.
__CPC_WAIT_KEY:
    PROC
    LOCAL __BW_UP, __BW_DOWN, __BW_ANY
__BW_UP:
    call __BW_ANY
    jr   nz, __BW_UP
__BW_DOWN:
    call __BW_ANY
    jr   z, __BW_DOWN
    ret
__BW_ANY:                   ; NZ if any key in rows 0-9 is held
    ld   de, $000A          ; D = first row, E = count
    call __CPC_KSCAN_ROWS
    ld   hl, __CPC_KEYS
    ld   b, 10
    xor  a
__BW_OR:
    or   (hl)
    inc  hl
    djnz __BW_OR
    or   a
    ret
    ENDP

; __CPC_PRN_CHAR -- A = character -> the printer port (Centronics,
; &EFxx: bits 0-6 data, bit 7 the inverted strobe). Waits while the
; printer reports busy (PPI port B bit 6), giving up after a while so a
; machine with no printer doesn't hang.
; Registers clobbered: AF, BC, DE.
__CPC_PRN_CHAR:
    PROC
    LOCAL __BP_WAIT, __BP_READY
    and  $7F
    ld   e, a
    ld   d, 0               ; ~256 polls
__BP_WAIT:
    ld   b, $F5
    in   a, (c)
    bit  6, a
    jr   z, __BP_READY
    dec  d
    jr   nz, __BP_WAIT
__BP_READY:
    ld   b, $EF
    out  (c), e             ; data, strobe inactive
    ld   a, e
    or   $80
    out  (c), a             ; strobe
    out  (c), e             ; strobe released
    ret
    ENDP

; __CPC_END -- the single clean END (generic.py's _end jumps here).
; Under -D __CPC_PRINTER_ECHO__ (the test harness) sends the END marker
; line ("\x04END") to the printer; otherwise waits for a key so the last
; screen stays visible. Then resets: lower ROM paged in, jump to 0 (the
; firmware's cold start, or a cartridge's).
; Registers clobbered: none (never returns).
#ifdef __CPC_PRINTER_ECHO__
__CPC_END_MARKER: DEFB 4, "END", 10, 0
#endif

__CPC_END:
    PROC
#ifdef __CPC_PRINTER_ECHO__
    LOCAL __BE_LOOP, __BE_RESET
    ld   hl, __CPC_END_MARKER
__BE_LOOP:
    ld   a, (hl)
    or   a
    jr   z, __BE_RESET
    inc  hl
    push hl
    call __CPC_PRN_CHAR
    pop  hl
    jr   __BE_LOOP
__BE_RESET:
    jp   __CPC_RESET
#else
    call __CPC_WAIT_KEY
    jp   __CPC_RESET
#endif
    ENDP

; __CPC_RESET -- resets the machine: lower ROM paged in, jump to 0 (the
; firmware's cold start on a 464/664/6128, or a cartridge's start).
; The paging must run from RAM above &4000: this code may sit below
; &4000, where the instruction after the Gate Array write would already
; be fetched from the ROM. So the last three instructions are copied to
; the start of the private block (&BC00; nothing needs it any more) and
; run there.
; Registers clobbered: n/a (never returns).
__CPC_RESET:
    PROC
    LOCAL __BR_STUB, __BR_END
    di
    ld   hl, __BR_STUB
    ld   de, .core.CPC_PRIV_BASE
    ld   bc, __BR_END - __BR_STUB
    ldir
    jp   .core.CPC_PRIV_BASE
__BR_STUB:
    ld   bc, $7F89          ; lower ROM on, upper off, mode 1
    out  (c), c
    rst  0
__BR_END:
    ENDP

    pop namespace
