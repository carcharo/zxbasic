; -----------------------------------------------------------------------
; Amstrad CPC interrupt front-end
;
; Compiled code runs with interrupts on. The firmware's 300 Hz handler
; needs BC' = its own value (B' = &7F, the Gate Array port; C' = the
; ROM/mode configuration) and AF' carry clear (carry set means "interrupt
; inside an interrupt"), but compiled code uses the alternate registers
; freely (SUB epilogues, 32-bit/float pushes, the FP calculator). So the
; RAM vector at &0038 is pointed here: this handler saves both register
; banks, hands the firmware its BC' (the FW_BC shadow, fwcall.asm) and a
; clear AF' carry, runs the original handler, keeps any change it made
; to BC', and restores everything.
;
; The RAM vector is only seen while the lower ROM is off, i.e. while our
; code (or firmware code running from RAM) executes. With the lower ROM
; on, the ROM's own &0038 goes straight to the firmware.
;
; Inside a firmware call (IN_FW = 1, set by the gate) the alternate
; registers already hold the firmware's values, so the handler jumps
; straight to the original. IN_FW also stays 1 while the original runs
; from here: it ends with "ei; ret", so an interrupt can arrive before
; our "di", and the firmware's registers are still loaded then.
;
; The original handler (RAM &B941 on the 6128, &B939 on the 464; the
; same code in both ROMs) is read from the vector at boot.
;
; Cost: about 250 T-states on top of the firmware's handler, 300 times
; a second. See cpcbuild docs/phase4d-design.md.

#include once <sysvars.asm>

    push namespace core

; __CPC_ISR_INSTALL -- points the RAM vector at &0038 to __CPC_ISR,
; keeping the original jump target. Call with interrupts off (the
; bootstrap does, before its first firmware call).
; Firmware entries called: none. Registers clobbered: AF, HL.
__CPC_ISR_INSTALL:
    ld   hl, ($0039)
    ld   (__CPC_ISR_ORIG + 1), hl
    ld   a, $C3             ; JP nn
    ld   ($0038), a
    ld   hl, __CPC_ISR
    ld   ($0039), hl
    ret

; __CPC_ISR -- the IM 1 handler (entered with interrupts off).
; Registers clobbered: none.
__CPC_ISR:
    push af
    ld   a, (IN_FW)
    or   a
    jr   nz, __CPC_ISR_DIRECT
    inc  a
    ld   (IN_FW), a         ; an interrupt during the chain goes direct
    push bc
    push de
    push hl
    push ix                 ; event routines may use IX/IY
    push iy
    ex   af, af'
    push af                 ; the program's AF'
    exx
    push bc                 ; the program's BC', DE', HL'
    push de
    push hl
    ld   bc, (FW_BC)        ; the firmware's BC'
    exx
    or   a                  ; AF' (active now) carry clear
    ex   af, af'
    call __CPC_ISR_ORIG     ; returns with interrupts on
    di
    exx
    ld   (FW_BC), bc        ; keep a ROM/mode change
    pop  hl
    pop  de
    pop  bc
    exx
    pop  af
    ex   af, af'            ; the program's AF' back
    pop  iy
    pop  ix
    pop  hl
    pop  de
    pop  bc
    xor  a
    ld   (IN_FW), a
    pop  af
    ei
    ret

__CPC_ISR_DIRECT:
    pop  af
__CPC_ISR_ORIG:
    jp   $FFFF              ; patched by __CPC_ISR_INSTALL

    pop namespace
