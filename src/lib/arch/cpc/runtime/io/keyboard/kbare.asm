; -----------------------------------------------------------------------
; Amstrad CPC -- bare-metal key translation, held-key scan and INPUT's key
; reader (-D CPC_BAREMETAL only; Phase 6 B3)
;
; The bare-mode counterpart of the firmware-mode __CPC_KEYCHAR /
; __CPC_KEYHELD in kscan.asm: the same entry points and the same results,
; with no firmware. The key translation is the three tables below
; (normal, SHIFT, CONTROL; one byte per firmware key number 0-79), and the
; caps lock and shift lock are kept here.
;
; The tables are the CPC's default (English/UK) layout exactly as the
; firmware's own KM_GET_TRANSLATE / KM_GET_SHIFT / KM_GET_CONTROL give it
; (dumped on a 464 and a 6128: identical; the dump program is cpcbuild
; tools/keytables_dump.bas and the conformance test keytables.bas checks
; every entry against its output). The firmware's expansion tokens are
; already resolved to the first character of their default strings: the
; keypad gives "0".."9" and ".", keypad ENTER gives RETURN (13), and
; CONTROL+keypad ENTER gives "R" (the start of the default RUN" string).
; Entries: $FF no character (SHIFT, CONTROL, unused keys, and keys that
; give nothing under CONTROL); $FD and $FE the CAPS LOCK key (under CONTROL
; the shift lock): no character, but a lock toggles.
;
; Locks: the firmware's interrupt-time scan toggles them when the key goes
; down. Here every scan made by __CPC_KBSCAN (so INKEY$, INPUT and
; anything calling __CPC_KEYHELD) toggles one when it sees the CAPS LOCK
; key down after a scan that saw it up: the caps lock normally, the shift
; lock with CONTROL held. A press falling between two scans is missed;
; keys.bas's own scans do not look at the locks. Both start off.
;
; Hardware: the PPI and the AY's port A through __CPC_KSCAN_ROWS
; (kscan.asm): interrupts off for the scan, on again after it.

#include once <sysvars.asm>
#include once <io/keyboard/kscan.asm>

    push namespace core

; __CPC_KB_LOCKS -- bit 0: shift lock on, bit 1: caps lock on.
__CPC_KB_LOCKS:
    defb 0

; __CPC_KEYCHAR -- the character a key gives.
; In: B = firmware key number (0-79), E = modifiers (bit 0: SHIFT held,
; bit 1: CONTROL held).
; Out: Carry set and A = character if the key gives one; Carry clear if
; not. CONTROL is looked at before SHIFT. The shift lock counts as SHIFT
; held; the caps lock turns a-z into A-Z whatever SHIFT says. Characters
; are the CPC's own: ESC 252, COPY 224, cursor keys 240-243, DEL 127...
; Firmware entries called: none. Hardware: none.
; Registers clobbered: AF, D, E, HL (B is kept).
__CPC_KEYCHAR:
    PROC
    LOCAL __KC_NOSL, __KC_CTRL, __KC_SEL, __KC_NOCARRY, __KC_NONE, __KC_OK

    ld   a, (__CPC_KB_LOCKS)
    ld   d, a
    rra
    jr   nc, __KC_NOSL
    set  0, e               ; shift lock acts as SHIFT
__KC_NOSL:
    ld   hl, __CPC_KBT_NORMAL
    bit  1, e
    jr   nz, __KC_CTRL
    bit  0, e
    jr   z, __KC_SEL
    ld   hl, __CPC_KBT_SHIFT
    jr   __KC_SEL
__KC_CTRL:
    ld   hl, __CPC_KBT_CTRL
__KC_SEL:
    ld   a, b
    cp   80
    ret  nc                 ; not a key: Carry clear
    add  a, l
    ld   l, a
    jr   nc, __KC_NOCARRY
    inc  h
__KC_NOCARRY:
    ld   a, (hl)
    cp   $FD
    jr   nc, __KC_NONE      ; $FD-$FF: no character
    bit  1, d
    jr   z, __KC_OK         ; caps lock off
    cp   'a'
    jr   c, __KC_OK
    cp   'z' + 1
    jr   nc, __KC_OK
    sub  $20                ; caps lock: a-z -> A-Z
__KC_OK:
    scf
    ret
__KC_NONE:
    or   a                  ; Carry clear
    ret
    ENDP

; __CPC_KBSCAN -- scans the whole matrix into __CPC_KEYS (kscan.asm), then
; toggles a lock if the CAPS LOCK key (row 8 bit 6) has just gone down.
; Registers clobbered: AF, BC, DE, HL. Returns with interrupts on.
__CPC_KBSCAN:
    PROC
    LOCAL __KB_TOGGLE

    ld   a, (__CPC_KEYS + 8)
    and  $40
    push af                 ; the key's state in the previous scan
    ld   de, 10             ; D = first row 0, E = 10 rows
    call __CPC_KSCAN_ROWS
    ld   a, (__CPC_KEYS + 8)
    and  $40
    ld   c, a
    pop  af
    cpl
    and  c                  ; non-zero: down now, up before
    ret  z
    ld   a, (__CPC_KEYS + 2)
    rla                     ; CONTROL (bit 7) into Carry
    ld   a, 2               ; caps lock
    jr   nc, __KB_TOGGLE
    dec  a                  ; 1: shift lock under CONTROL
__KB_TOGGLE:
    ld   hl, __CPC_KB_LOCKS
    xor  (hl)
    ld   (hl), a
    ret
    ENDP

; __CPC_KEYHELD -- the character of a key held down now (INKEY$'s
; default). Scans the whole matrix and returns the first held key, in
; matrix order (row 0 first, within a row bit 0 first), that gives a
; character. SHIFT and CONTROL are modifiers, not keys; joystick 0 (row 9
; bits 0-6) is not looked at, DEL (row 9 bit 7) is. A held key without a
; character is skipped for the next one.
; Out: Carry set, A = character and B = the key's number, or Carry clear
; (no key).
; Registers clobbered: AF, BC, DE, HL. Returns with interrupts on.
__CPC_KEYHELD:
    PROC
    LOCAL __KH_NOSHIFT, __KH_NOCTRL, __KH_ROW, __KH_BITS
    LOCAL __KH_TRY, __KH_NEXTROW

    call __CPC_KBSCAN
    ld   hl, __CPC_KEYS + 2
    ld   a, (hl)
    and  $5F                ; ignore SHIFT (bit 5) and CONTROL (bit 7)
    ld   c, a
    ld   a, (hl)
    ld   e, 0               ; E = modifiers for __CPC_KEYCHAR
    bit  5, a
    jr   z, __KH_NOSHIFT
    set  0, e
__KH_NOSHIFT:
    bit  7, a
    jr   z, __KH_NOCTRL
    set  1, e
__KH_NOCTRL:
    ld   (hl), c
    ld   hl, __CPC_KEYS + 9
    ld   a, (hl)
    and  $80                ; only DEL, not the joystick
    ld   (hl), a

    ld   hl, __CPC_KEYS
    ld   d, 0               ; D = key number of bit 0 of the row
__KH_ROW:
    ld   a, (hl)
    ld   c, a               ; C = the row's pressed bits still to look at
    ld   b, d               ; B = key number of the bit being looked at
__KH_BITS:
    ld   a, c
    or   a
    jr   z, __KH_NEXTROW
    srl  c
    jr   c, __KH_TRY
    inc  b
    jr   __KH_BITS
__KH_TRY:
    push bc
    push de
    push hl
    call __CPC_KEYCHAR      ; B = key, E = modifiers
    pop  hl
    pop  de
    pop  bc
    ret  c                  ; a character: Carry set, A = it, B = key
    inc  b
    jr   __KH_BITS
__KH_NEXTROW:
    ld   a, d
    add  a, 8
    ld   d, a
    inc  hl
    cp   80
    jr   c, __KH_ROW
    ret                     ; no key: Carry clear (cp 80 with A >= 80)
    ENDP

; INPUT's key reader. State (the runtime's own storage): the key last
; returned and the frame (low 16 bits of FH_FRAMES, which the bare
; interrupt handler counts at 50 Hz) at which it repeats.
__CPC_KR_LAST:
    defb $FF
__CPC_KR_DUE:
    defw 0

; __CPC_KEY_NEXT -- waits for the next typed character and returns it
; in A: a key going down returns its character at once; a key kept down
; returns it again after 30 frames (0.6 s), then every 4 frames (0.08 s),
; like the firmware's defaults. When several keys are down the first in
; matrix order counts. Waits with HALT between scans (interrupts are on).
; Registers clobbered: AF, BC, DE, HL.
__CPC_KEY_NEXT:
    PROC
    LOCAL __KN_LOOP, __KN_WAIT, __KN_GOT, __KN_SAME, __KN_ARM

__KN_LOOP:
    call __CPC_KEYHELD
    jr   c, __KN_GOT
    ld   a, $FF
    ld   (__CPC_KR_LAST), a ; released: the next press is new
__KN_WAIT:
    halt
    jr   __KN_LOOP
__KN_GOT:
    ld   c, a               ; C = the character
    ld   a, (__CPC_KR_LAST)
    cp   b
    jr   z, __KN_SAME
    ld   a, b
    ld   (__CPC_KR_LAST), a
    ld   de, 30             ; first repeat after 0.6 s
    jr   __KN_ARM
__KN_SAME:
    ld   hl, (FH_FRAMES)
    ld   de, (__CPC_KR_DUE)
    or   a
    sbc  hl, de             ; frames - due
    bit  7, h
    jr   nz, __KN_WAIT      ; negative: not due yet
    ld   de, 4              ; then every 0.08 s
__KN_ARM:
    ld   hl, (FH_FRAMES)
    add  hl, de
    ld   (__CPC_KR_DUE), hl
    ld   a, c
    ret
    ENDP

; __CPC_KEY_FLUSH -- INPUT's start: a key already down is taken as used
; (it returns nothing until released), so keys typed before INPUT do not
; leak into the line; a key pressed later is read as usual. Bare mode has
; no key buffer to empty.
; Registers clobbered: AF, BC, DE, HL.
__CPC_KEY_FLUSH:
    PROC
    LOCAL __KF_NONE
    call __CPC_KEYHELD
    jr   nc, __KF_NONE
    ld   a, b
    ld   (__CPC_KR_LAST), a
    ld   hl, (FH_FRAMES)
    ld   de, $4000          ; no repeat for a long time (until released)
    add  hl, de
    ld   (__CPC_KR_DUE), hl
    ret
__KF_NONE:
    ld   a, $FF
    ld   (__CPC_KR_LAST), a
    ret
    ENDP

; The key tables: [normal], [SHIFT], [CONTROL], keys 0-79 each.
__CPC_KBT_NORMAL:
    defb $F0, $F3, $F1, $39, $36, $33, $0D, $2E      ; keys 0-7
    defb $F2, $E0, $37, $38, $35, $31, $32, $30      ; keys 8-15
    defb $10, $5B, $0D, $5D, $34, $FF, $5C, $FF      ; keys 16-23
    defb $5E, $2D, $40, $70, $3B, $3A, $2F, $2E      ; keys 24-31
    defb $30, $39, $6F, $69, $6C, $6B, $6D, $2C      ; keys 32-39
    defb $38, $37, $75, $79, $68, $6A, $6E, $20      ; keys 40-47
    defb $36, $35, $72, $74, $67, $66, $62, $76      ; keys 48-55
    defb $34, $33, $65, $77, $73, $64, $63, $78      ; keys 56-63
    defb $31, $32, $FC, $71, $09, $61, $FD, $7A      ; keys 64-71
    defb $0B, $0A, $08, $09, $58, $5A, $FF, $7F      ; keys 72-79
__CPC_KBT_SHIFT:
    defb $F4, $F7, $F5, $39, $36, $33, $0D, $2E      ; keys 0-7
    defb $F6, $E0, $37, $38, $35, $31, $32, $30      ; keys 8-15
    defb $10, $7B, $0D, $7D, $34, $FF, $60, $FF      ; keys 16-23
    defb $A3, $3D, $7C, $50, $2B, $2A, $3F, $3E      ; keys 24-31
    defb $5F, $29, $4F, $49, $4C, $4B, $4D, $3C      ; keys 32-39
    defb $28, $27, $55, $59, $48, $4A, $4E, $20      ; keys 40-47
    defb $26, $25, $52, $54, $47, $46, $42, $56      ; keys 48-55
    defb $24, $23, $45, $57, $53, $44, $43, $58      ; keys 56-63
    defb $21, $22, $FC, $51, $09, $41, $FD, $5A      ; keys 64-71
    defb $0B, $0A, $08, $09, $58, $5A, $FF, $7F      ; keys 72-79
__CPC_KBT_CTRL:
    defb $F8, $FB, $F9, $39, $36, $33, $52, $2E      ; keys 0-7
    defb $FA, $E0, $37, $38, $35, $31, $32, $30      ; keys 8-15
    defb $10, $1B, $0D, $1D, $34, $FF, $1C, $FF      ; keys 16-23
    defb $1E, $FF, $00, $10, $FF, $FF, $FF, $FF      ; keys 24-31
    defb $1F, $FF, $0F, $09, $0C, $0B, $0D, $FF      ; keys 32-39
    defb $FF, $FF, $15, $19, $08, $0A, $0E, $FF      ; keys 40-47
    defb $FF, $FF, $12, $14, $07, $06, $02, $16      ; keys 48-55
    defb $FF, $FF, $05, $17, $13, $04, $03, $18      ; keys 56-63
    defb $FF, $7E, $FC, $11, $E1, $01, $FE, $1A      ; keys 64-71
    defb $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F      ; keys 72-79

    pop namespace
