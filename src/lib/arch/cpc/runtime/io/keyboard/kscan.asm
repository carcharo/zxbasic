; -----------------------------------------------------------------------
; Amstrad CPC -- keyboard matrix scan and key translation
;
; Shared by INKEY$ (inkey.asm) and the stdlib keys.bas (GetKeyScanCode,
; MultiKeys). From the public documentation of the 8255 PPI, the
; AY-3-8912's I/O port and the keyboard matrix (cpcwiki.eu, CPC Firmware
; Guide).
;
; The keyboard is a matrix of 10 rows x 8 columns, read through the
; AY-3-8912: PPI port C bits 0-3 pick the row, bits 6-7 are the AY's BDIR
; (bit 7) and BC1 (bit 6) lines (&C0 = select register, &40 = read it),
; and the AY's port A (register 14) returns the 8 column bits, 0 =
; pressed. Row 9 is joystick 0 (bits 0-5: up, down, left, right, fire 1,
; fire 2) and DEL (bit 7). The firmware's key number is row * 8 + bit.
;
; __CPC_KEYS holds the last scan, one byte per row, bit = 1: pressed.
; It is the runtime's own storage, in the program image.
;
; Direct PPI access: the firmware's interrupt handler scans the keyboard
; through the same ports, so a scan runs with interrupts off (plain di,
; and ei at the end: never call these from code that already has
; interrupts off). The PPI is left as the firmware expects it.

#include once <fwcall.asm>

    push namespace core

; __CPC_KSCAN_ROWS -- scans E rows starting at row D into __CPC_KEYS (the
; bytes for other rows are left alone). D + E must not exceed 10, E >= 1.
;
; Afterwards the PPI is as the firmware leaves it: control word &82 (port
; A output, B input, C output), port C = the cassette bits it had before
; (bits 4-5: motor and write data) with the AY lines (bits 6-7) and row
; bits (0-3) inactive, AY register 14 selected (the register the
; firmware's own scan selects too). Writing the PPI control word clears
; its output latches, so the cassette bits are put back at once.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE, HL. Returns with interrupts on.
__CPC_KSCAN_ROWS:
    PROC
    LOCAL __KS_PTR, __KS_LOOP

    ld   hl, __CPC_KEYS
    ld   a, d
    add  a, l
    ld   l, a
    jr   nc, __KS_PTR
    inc  h
__KS_PTR:
    push de                 ; D = first row, E = count (BC is the port)
    di
    ld   b, $F6
    in   a, (c)             ; port C: keep the cassette bits (4, 5)
    and  $30
    ld   d, a
    ld   bc, $F40E
    out  (c), c             ; port A = 14 (AY register number)
    ld   b, $F6
    or   $C0
    out  (c), a             ; AY: select register
    out  (c), d             ; AY: inactive
    ld   bc, $F792
    out  (c), c             ; port A becomes an input
    pop  bc                 ; B = first row, C = count (the PPI ignores
                            ; the low byte of its port address)
    ld   a, d
    or   $40                ; BC1 only = read
    add  a, b
    ld   e, a               ; E = port C value selecting the first row
__KS_LOOP:
    ld   b, $F6
    out  (c), e             ; select the row, AY: read
    ld   b, $F4
    in   a, (c)
    cpl                     ; 1 = pressed
    ld   (hl), a
    inc  hl
    inc  e
    dec  c
    jr   nz, __KS_LOOP
    ld   bc, $F782
    out  (c), c             ; port A back to output (clears the latches)
    ld   b, $F6
    out  (c), d             ; cassette bits back, AY inactive, row 0
    ei
    ret
    ENDP

; __CPC_KEYCHAR -- the character the firmware's own key translation
; gives a key. Respects the machine's layout (KEY tables set with
; KM_SET_TRANSLATE and friends), the shift lock and the caps lock.
;
; In: B = firmware key number (0-79), E = modifiers (bit 0: SHIFT held,
; bit 1: CONTROL held).
; Out: Carry set and A = character if the key gives one; Carry clear if
; not. CONTROL is looked at before SHIFT (the CONTROL table is used if
; both are held). The firmware's shift lock counts as SHIFT held (as the
; firmware behaves: shift lock + SHIFT stays shifted); the caps lock turns
; a-z into A-Z whatever SHIFT says (as in the firmware).
; No character: table entry &FF (ignored key, e.g. SHIFT itself), &FD and
; &FE (CAPS LOCK / SHIFT LOCK keys: the firmware's interrupt-time scan
; toggles the locks itself), and an expansion token (&80-&9F: the keypad
; F0-F9, F., ENTER, CTRL+ENTER...) with no string. A token with a string
; gives the string's first character (KM_GET_EXPAND), so the default
; keypad gives "0".."9", "." and RETURN. Every other entry is returned
; as is: ESC is 252, COPY 224, cursor keys 240-243, CTRL+cursor 248-251.
; Firmware entries called (via the gate): KM_GET_STATE (&BB21),
; KM_GET_TRANSLATE (&BB2A), KM_GET_SHIFT (&BB30), KM_GET_CONTROL (&BB36),
; KM_GET_EXPAND (&BB12). The same on the 464, 664 and 6128.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).
__CPC_KEYCHAR:
    PROC
    LOCAL __KC_NOLOCK, __KC_SHIFT, __KC_CTRL, __KC_GOT
    LOCAL __KC_PASS, __KC_PLAIN, __KC_DONE

    push bc
    push de
    call .core.__FW_CALL
    defw $BB21              ; KM_GET_STATE: L = shift lock, H = caps lock
    pop  de
    pop  bc
    ld   a, l
    or   a
    jr   z, __KC_NOLOCK
    set  0, e               ; shift lock acts as SHIFT
__KC_NOLOCK:
    push hl                 ; H = caps lock
    ld   a, b               ; A = key number
    bit  1, e
    jr   nz, __KC_CTRL
    bit  0, e
    jr   nz, __KC_SHIFT
    call .core.__FW_CALL
    defw $BB2A              ; KM_GET_TRANSLATE: A = key -> A = character
    jr   __KC_GOT
__KC_SHIFT:
    call .core.__FW_CALL
    defw $BB30              ; KM_GET_SHIFT
    jr   __KC_GOT
__KC_CTRL:
    call .core.__FW_CALL
    defw $BB36              ; KM_GET_CONTROL
__KC_GOT:
    pop  hl                 ; H = caps lock
    cp   $FD
    jr   nc, __KC_PASS      ; $FD-$FF: no character
    cp   $A0
    jr   nc, __KC_PLAIN     ; $A0-$FC: a character as is
    cp   $80
    jr   c, __KC_PLAIN
    ; expansion token $80-$9F
    sub  $80
    ld   l, 0               ; first character of the string
    call .core.__FW_CALL
    defw $BB12              ; KM_GET_EXPAND: A = token, L = index -> A, Carry
    ret                     ; Carry set = A is a character
__KC_PASS:
    or   a                  ; Carry clear
    ret
__KC_PLAIN:
    ld   l, a
    ld   a, h
    or   a
    ld   a, l
    jr   z, __KC_DONE       ; caps lock off
    cp   'a'
    jr   c, __KC_DONE
    cp   'z' + 1
    jr   nc, __KC_DONE
    sub  $20                ; caps lock: a-z -> A-Z
__KC_DONE:
    scf
    ret
    ENDP

; __CPC_KEYHELD -- the character of a key held down now (INKEY$'s
; default). Scans the whole matrix and returns the first held key, in
; matrix order (row 0 first, within a row bit 0 first), that gives a
; character. SHIFT and CONTROL are modifiers, not keys; joystick 0 (row 9
; bits 0-6) is not looked at, DEL (row 9 bit 7) is. A held key without a
; character (see __CPC_KEYCHAR) is skipped for the next one.
; Out: Carry set and A = character, or Carry clear (no key).
; Firmware entries called: those of __CPC_KEYCHAR, only when a key is
; held.
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate). Returns with interrupts on.
__CPC_KEYHELD:
    PROC
    LOCAL __KH_NOSHIFT, __KH_NOCTRL, __KH_ROW, __KH_BITS
    LOCAL __KH_TRY, __KH_NEXTROW

    ld   de, 10             ; D = 0 (first row), E = 10 rows
    call __CPC_KSCAN_ROWS
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
    ret  c                  ; a character: Carry set, A = it
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

; __CPC_KEYS -- the last scan, rows 0-9, one byte each, bit = 1: pressed.
__CPC_KEYS:
    defs 10

    pop namespace
