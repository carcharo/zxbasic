; -----------------------------------------------------------------------
; Amstrad CPC frame hook and game mode (stdlib/framehook.bas)
;
; One routine (FH_ADDR, e.g. a music player) runs once per frame, at the
; frame flyback, in every mode; FH_FRAMES counts the frames.
;
; Normal mode: the routine runs from a firmware frame-flyback event
; (KL_NEW_FRAME_FLY &BCD7) registered at start-up: class &80
; (asynchronous, FAR address) with ROM select &FF, so both ROMs are off
; while it runs and it can live anywhere, program code at &0040+
; included. The event block (FH_BLOCK) is in the private block, in the
; central 32K as the firmware requires. Measured (Caprice32 and chips,
; 464 and 6128): it runs exactly once per frame, also while the program
; waits inside a firmware call, entered with interrupts ON; the firmware
; does not preserve IX around it.
;
; Game mode (GameMode(1)): GM_VEC points isr.asm at __CPC_GM_ISR, so
; interrupts outside firmware calls no longer run the firmware's handler
; (its key buffer, 300 Hz clock, sound queue and ink refresh stop until
; game mode is switched off; they still run during firmware calls).
; __CPC_GM_ISR runs the frame routine itself: on the interrupt that sees
; VSYNC (PPI port B bit 0), or on the 6th interrupt since the last frame
; when a DI section delayed the interrupt past the VSYNC pulse
; (interrupts are never lost: exactly 6 per frame). Frames that arrive
; during a firmware call still reach the firmware, which runs the event;
; either way GM_COUNT restarts, so each frame runs the routine once.
;
; The frame routine (FH_ADDR) runs with interrupts off and every register
; saved; it must not call the firmware (the gate turns interrupts on),
; PRINT, or use floats or strings.

#include once <sysvars.asm>
#include once <fwcall.asm>

#init .core.CPC_INIT_FRAMEHOOK

    push namespace core

; CPC_INIT_FRAMEHOOK -- registers the frame-flyback event.
; Firmware entry called: KL_NEW_FRAME_FLY (&BCD7: HL = event block,
; B = event class, C = ROM select, DE = routine), via the gate.
; Registers clobbered: AF, BC, DE, HL (and the gate's).
CPC_INIT_FRAMEHOOK:
    ld   hl, FH_BLOCK
    ld   de, __CPC_FH_EVENT
    ld   bc, $80FF          ; async, far address; ROM select &FF: both off
    call __FW_CALL
    defw $BCD7
    ret

; __CPC_FH_EVENT -- the firmware event routine (entered with interrupts
; on, both ROMs off).
; Registers clobbered: none (see __CPC_FH_RUN).
__CPC_FH_EVENT:
    di
    call __CPC_FH_RUN
    ei
    ret

; __CPC_FH_RUN -- one frame: restarts GM_COUNT, counts the frame (32-bit
; FH_FRAMES) and calls the routine at FH_ADDR if it isn't 0. Call with
; interrupts off.
; Registers clobbered: none (all of AF..HL, IX, IY and the alternate bank
; are saved around the routine).
__CPC_FH_RUN:
    PROC
    LOCAL __FH_NOCARRY, __FH_CALL

    push af
    push bc
    push de
    push hl
    push ix
    push iy
    exx
    push bc
    push de
    push hl
    exx
    ex   af, af'
    push af
    ex   af, af'

    xor  a
    ld   (GM_COUNT), a
    ld   hl, (FH_FRAMES)
    inc  hl
    ld   (FH_FRAMES), hl
    ld   a, h
    or   l
    jr   nz, __FH_NOCARRY
    ld   hl, (FH_FRAMES + 2)
    inc  hl
    ld   (FH_FRAMES + 2), hl
__FH_NOCARRY:
    ld   hl, (FH_ADDR)
    ld   a, h
    or   l
    call nz, __FH_CALL

    ex   af, af'
    pop  af
    ex   af, af'
    exx
    pop  hl
    pop  de
    pop  bc
    exx
    pop  iy
    pop  ix
    pop  hl
    pop  de
    pop  bc
    pop  af
    ret

__FH_CALL:
    jp   (hl)
    ENDP

; __CPC_GM_ISR -- the game-mode interrupt handler. isr.asm jumps here
; for interrupts outside firmware calls while GM_VEC is set, with
; interrupts off and the program's AF on the stack.
; Registers clobbered: none.
__CPC_GM_ISR:
    PROC
    LOCAL __GM_FRAME, __GM_DONE

    push bc
    ld   a, (GM_COUNT)
    inc  a
    ld   (GM_COUNT), a
    ld   b, $F5             ; PPI port B: bit 0 = VSYNC
    in   a, (c)
    rra
    jr   c, __GM_FRAME
    ld   a, (GM_COUNT)
    cp   6
    jr   c, __GM_DONE       ; not a frame interrupt
__GM_FRAME:
    call __CPC_FH_RUN
__GM_DONE:
    pop  bc
    pop  af
    ei
    ret
    ENDP

    pop namespace
