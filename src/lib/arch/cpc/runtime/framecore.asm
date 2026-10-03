; -----------------------------------------------------------------------
; Amstrad CPC frame core: counts frames and runs the frame hook
;
; __CPC_FH_RUN is one frame's work (count it, call FH_ADDR); __CPC_GM_ISR
; decides which interrupt is the frame one (VSYNC on PPI port B, or the
; 6th interrupt since the last frame when a DI section hid the pulse).
; Used by framehook.asm (firmware mode: game mode and the frame event) and
; by isr.asm in bare-metal mode (-D CPC_BAREMETAL), where every interrupt
; goes through __CPC_GM_ISR and frames are always counted.

#include once <sysvars.asm>

    push namespace core

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
