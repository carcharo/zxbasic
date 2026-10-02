; -----------------------------------------------------------------------
; Amstrad CPC firmware call gate
;
; Every firmware jumpblock entry goes through RST 1 LOW JUMP, which uses
; B' = &7F (gate array port) and C' = current ROM/mode config, and the
; 300 Hz interrupt handler also uses BC' and branches on AF' carry
; ("already inside an interrupt"). Compiled code clobbers both freely
; (SUB epilogues pop into BC'; div8/div16/float pushes use AF'). So every
; firmware call goes through this gate: with interrupts off it sets IN_FW,
; restores BC' from the FW_BC shadow and clears AF' carry, makes the call
; with interrupts on, then (off again) captures BC' back (mode/ROM
; changes) and clears IN_FW. Outside the gate interrupts go through
; isr.asm, which does the same register hand-over for the firmware's
; interrupt handler; IN_FW tells it the firmware's registers are already
; loaded. The gate always returns with interrupts on.
;
; Usage (A, F, BC, DE, HL go in as set and come back as the firmware left
; them, flags included):
;
;     call .core.__FW_CALL        ; or .core.__FW_CALL_IX for CAS_* entries,
;     defw $BB5A                  ; which corrupt IX (Boriel's frame pointer)
;
; Clobbers BC', DE', HL', AF' (never meaningful to compiled code across a
; call). Not re-entrant (the interrupt handler never calls it).
; Cost: about 220 T-states plus the firmware routine.

#include once <sysvars.asm>

    push namespace core

__FW_CALL:
    PROC
    di                  ; IN_FW and BC' must change together (isr.asm)
    exx                 ; alternate bank is scratch; caller's regs stay put
    pop  hl             ; HL -> defw after the call
    ld   e, (hl)
    inc  hl
    ld   d, (hl)        ; DE = firmware entry
    inc  hl
    push hl             ; return past the defw
    ld   (__FW_CALL_TARGET + 1), de
    ld   hl, IN_FW
    ld   (hl), 1
    ld   bc, (FW_BC)    ; becomes BC' after the exx below
    ex   af, af'
    or   a              ; AF' carry clear, or the ISR takes its nested path
    ex   af, af'
    exx
    ei
__FW_CALL_TARGET:
    call $FFFF          ; operand patched above
    di
    exx
    ld   (FW_BC), bc    ; keep mode/ROM changes for the next call
    ld   hl, IN_FW
    ld   (hl), 0
    exx
    ei
    ret
    ENDP

__FW_CALL_IX:
    PROC
    di
    exx
    pop  hl
    ld   e, (hl)
    inc  hl
    ld   d, (hl)
    inc  hl
    push hl
    ld   (__FW_CALL_IX_TARGET + 1), de
    ld   hl, IN_FW
    ld   (hl), 1
    ld   bc, (FW_BC)
    ex   af, af'
    or   a
    ex   af, af'
    exx
    ei
    push ix
__FW_CALL_IX_TARGET:
    call $FFFF
    pop  ix
    di
    exx
    ld   (FW_BC), bc
    ld   hl, IN_FW
    ld   (hl), 0
    exx
    ei
    ret
    ENDP

    pop namespace
