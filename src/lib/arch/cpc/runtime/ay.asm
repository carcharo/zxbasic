; -----------------------------------------------------------------------
; Amstrad CPC AY-3-8912 register access
;
; Written from scratch for this project (MIT); see core.asm. From the
; public documentation of the 8255 PPI and the AY-3-8912 as wired in the
; CPC (cpcwiki.eu, CPC Firmware Guide); no library code.
;
; The AY sits behind the PPI: port A (&F4xx) is the AY's data bus, and
; port C (&F6xx) bits 7-6 are the AY's BDIR and BC1 lines (11 = latch a
; register number, 10 = write data, 01 = read data, 00 = inactive). Port C
; bits 5-4 are the cassette write data and motor (kept as they are) and
; bits 3-0 select the keyboard row, which the firmware's own scan (inside
; its 300 Hz interrupt handler) changes. So every access here has to run
; with interrupts off, or the handler could slip a keyboard scan between
; two of the OUTs. The raw routines do not touch the interrupt flag (a
; caller that already has interrupts off, like the Play library, pays for
; neither DI nor EI); the _DI variants wrap them and return with
; interrupts on, as every compiled-code routine does.
;
; The PPI must be as the firmware leaves it, control word &82 (port A
; output, B input, C output).
;
; Who owns the sound chip: the firmware's sound manager (SOUND/BEEP) runs
; from the interrupt handler and writes the AY by itself whenever a note
; is queued, so a program that uses these routines directly must not
; also queue firmware sounds. Call SOUND_RESET (&BCA7) once first to make
; the manager idle (Play does).
;
; Cost (CPC "NOP" units of 1 us, every instruction rounded up to a whole
; number of them; IN/OUT are 4): __CPC_AY_WRITE 53 us plus 5 for the CALL,
; 58 us measured (tests/stress/play_tempo.bas). The DI variants add the
; DI, EI, CALL and RET: 12 us.

    push namespace core

; __CPC_AY_WRITE -- writes AY register A with the value in C. Interrupts
; must be off on entry; they are left as they were. Port C is left as it
; was (cassette bits kept, AY inactive, keyboard row 0). The AY's
; register select is left on A.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE (HL is not touched).
__CPC_AY_WRITE:
    ld   e, c               ; E = value
    ld   d, a               ; D = register
    ld   b, $F6
    in   a, (c)             ; port C (the low byte of the port is not decoded)
    and  $30                ; cassette bits
    ld   c, a               ; C = port C "inactive" value
    ld   a, d
    ld   b, $F4
    out  (c), a             ; port A = register number
    ld   b, $F6
    ld   a, c
    or   $C0
    out  (c), a             ; AY: latch register
    out  (c), c             ; AY: inactive
    ld   b, $F4
    out  (c), e             ; port A = value
    ld   b, $F6
    ld   a, c
    or   $80
    out  (c), a             ; AY: write
    out  (c), c             ; AY: inactive
    ret

; __CPC_AY_WRITE_DI -- as __CPC_AY_WRITE, for code that has interrupts on:
; di, write, ei. Returns with interrupts on, whatever they were on entry.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_WRITE_DI:
    di
    call __CPC_AY_WRITE
    ei
    ret

; __CPC_AY_READ -- A = AY register -> A = its value (bits the register
; doesn't implement read as 0). Interrupts must be off on entry; they are
; left as they were. Port A is switched to input for the read and back
; to output, which clears the PPI's output latches, so the cassette bits
; are written back at once (the motor is off for a few microseconds only,
; and only if it was on). Port C is left as in __CPC_AY_WRITE. Reading
; register 14 (the keyboard port) gives the keyboard row selected by port
; C bits 3-0, which is row 0 here.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_READ:
    ld   d, a               ; D = register
    ld   b, $F6
    in   a, (c)
    and  $30
    ld   e, a               ; E = port C "inactive" value
    ld   b, $F4
    out  (c), d             ; port A = register number
    ld   b, $F6
    ld   a, e
    or   $C0
    out  (c), a             ; AY: latch register
    out  (c), e             ; AY: inactive
    ld   bc, $F792
    out  (c), c             ; port A becomes an input
    ld   a, e
    or   $40
    ld   b, $F6
    out  (c), a             ; AY: read
    ld   b, $F4
    in   a, (c)             ; the value
    ld   d, a
    ld   b, $F6
    out  (c), e             ; AY: inactive (before port A drives the bus again)
    ld   bc, $F782
    out  (c), c             ; port A back to output (clears the latches)
    ld   b, $F6
    out  (c), e             ; cassette bits back
    ld   a, d
    ret

; __CPC_AY_READ_DI -- as __CPC_AY_READ, for code that has interrupts on:
; di, read, ei. Returns with interrupts on.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_READ_DI:
    di
    call __CPC_AY_READ
    ei
    ret

    pop namespace
