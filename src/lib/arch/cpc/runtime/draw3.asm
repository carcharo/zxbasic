; -----------------------------------------------------------------------
; Amstrad CPC -- DRAW dx, dy, a (an arc)
;
; As on the Spectrum: from the last point to the last point + (dx, dy),
; turning through a radians on the way (anticlockwise when a > 0, so
; DRAW 100, 0, PI is a bowl below the chord). zx48k's draw3.asm is the
; Spectrum ROM's arc code, calling ROM helpers with byte coordinates;
; this is a fresh version for 16-bit mode pixels (gfx.asm).
;
; The arc is n straight segments of equal length, drawn with draw.asm's
; __DRAW (so colour and OVER/INVERSE work the same as straight lines).
; Each segment vector is the previous one rotated by a/n; the first is
; the chord scaled by k = sin(a/2n) / sin(a/2) and rotated by
; (a/n - a) / 2. Positions are accumulated in floats and rounded, and
; the last segment ends exactly on (dx, dy).
;
;   n = INT(|a| * (|dx| + |dy|) / 8) + 1, at most 255 -- segments of
;       about 4-8 pixels. n = 1 is a straight line.
;
; The float work runs on the calculator (RST 6, fp_calc.asm). Its SIN
; and COS use memory cells 0-2 for their series, so the setup keeps its
; values on the calculator stack or in cells 3-5 until the trig is done.
; In the drawing loop the cells hold: 0 px, 1 py (float position from
; the start), 2 vx, 3 vy (segment vector), 4 cos(a/n), 5 sin(a/n).
;
; Calling convention (unchanged from zx48k): dx pushed, then dy (16-bit
; signed); a in A, E, D, C, B.
; Firmware entries called: draw.asm's (__DRAW, once per segment).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate and the calculator).

#include once <draw.asm>
#include once <fp_calc.asm>
#include once <stackf.asm>
#include once <ftou32reg.asm>
#include once <u32tofreg.asm>

    push namespace core

ARC_DX      EQU CIRC_VARS + 0       ; target, relative to the start
ARC_DY      EQU CIRC_VARS + 2
ARC_X       EQU CIRC_VARS + 4       ; drawn so far, relative to the start
ARC_Y       EQU CIRC_VARS + 6
ARC_N       EQU CIRC_VARS + 8       ; segments left

DRAW3:
    PROC
    LOCAL __A_ABS, __A_BIG, __A_SUM_OK, __A_N_MAX, __A_N_OK, __A_LOOP
    LOCAL __A_LAST, __A_SEG, __A_PUSH_HL, __A_POP_HL, __A_PUSH_K, __A_POP_ROUND

    call __FPSTACK_PUSH         ; [a]
    pop  hl                     ; return address
    pop  de                     ; dy
    pop  bc                     ; dx
    push hl
    ld   (ARC_DY), de
    ld   (ARC_DX), bc
    ld   hl, 0
    ld   (ARC_X), hl
    ld   (ARC_Y), hl

    ; m = |dx| + |dy|, at most 32767
    ld   h, b
    ld   l, c
    call __A_ABS
    push hl
    ex   de, hl
    call __A_ABS
    pop  de
    add  hl, de
    jr   c, __A_BIG
    bit  7, h
    jr   z, __A_SUM_OK
__A_BIG:
    ld   hl, 32767
__A_SUM_OK:
    call __A_PUSH_HL            ; [a, m]
    ld   a, 07Eh
    ld   de, 00000h
    ld   bc, 00000h             ; 0.125
    call __FPSTACK_PUSH
    rst  30h
    defb $04                    ; multiply      a, m/8
    defb $01                    ; exchange      m/8, a
    defb $C4                    ; st-mem-4      (a, kept for the setup)
    defb $2A                    ; abs           m/8, |a|
    defb $04                    ; multiply      |a| m / 8
    defb $38                    ; end-calc
    call __A_POP_HL             ; DEHL = INT(|a| m / 8)
    ld   a, d
    or   e
    or   h
    jr   nz, __A_N_MAX
    ld   a, l
    inc  a                      ; n = INT(...) + 1
    jr   nz, __A_N_OK
__A_N_MAX:
    ld   a, 255
__A_N_OK:
    ld   (ARC_N), a
    dec  a
    jp   z, __A_LAST            ; n = 1: a straight line

    ; --- setup: cells 4 = cos(a/n), 5 = sin(a/n), 2/3 = first segment,
    ; 0/1 = position 0 ---
    inc  a
    ld   l, a
    ld   h, 0
    call __A_PUSH_HL            ; [n]
    rst  30h
    defb $E4                    ; get-mem-4     n, a
    defb $01                    ; exchange      a, n
    defb $05                    ; division      t = a/n
    defb $C3                    ; st-mem-3      (t)
    defb $A2, $04, $1F          ; half, mult, sin       sin(t/2)
    defb $E4, $A2, $04, $1F     ; a, half, mult, sin    sin(t/2), sin(a/2)
    defb $05                    ; division      k
    defb $C5, $02               ; st-mem-5 (k), delete
    defb $E3, $E4, $03          ; t, a, subtract        t - a
    defb $A2, $04               ; half, mult            f = (t - a)/2
    defb $31, $20               ; duplicate, cos        f, cos f
    defb $01, $1F               ; exchange, sin         cos f, sin f
    defb $E5, $04               ; k, mult               cos f, k sin f
    defb $01, $E5, $04, $01     ; ... k cos f, k sin f = C, S
    defb $C4, $02               ; st-mem-4 (S), delete
    defb $C5, $02               ; st-mem-5 (C), delete
    defb $E3, $31, $20          ; t, duplicate, cos     t, cos t
    defb $01, $1F               ; exchange, sin         cos t, sin t
    defb $38                    ; end-calc
    ld   hl, (ARC_DX)
    call __A_PUSH_HL
    ld   hl, (ARC_DY)
    call __A_PUSH_HL            ; [cos t, sin t, dx, dy]
    rst  30h
    defb $C1, $02               ; st-mem-1 (dy), delete
    defb $C0, $02               ; st-mem-0 (dx), delete
    defb $E5, $E0, $04          ; C dx
    defb $E4, $E1, $04          ; C dx, S dy
    defb $03                    ; vx = C dx - S dy
    defb $E4, $E0, $04          ; vx, S dx
    defb $E5, $E1, $04          ; vx, S dx, C dy
    defb $0F                    ; cos t, sin t, vx, vy = S dx + C dy
    defb $C3, $02               ; st-mem-3 (vy), delete
    defb $C2, $02               ; st-mem-2 (vx), delete
    defb $C5, $02               ; st-mem-5 (sin t), delete
    defb $C4, $02               ; st-mem-4 (cos t), delete
    defb $A0, $C0, $C1, $02     ; zero -> mem-0, mem-1 (position)
    defb $38                    ; end-calc

__A_LOOP:
    ld   hl, ARC_N
    dec  (hl)
    jr   z, __A_LAST            ; the last segment ends exactly on (dx, dy)
    call __A_PUSH_K
    call __A_PUSH_K             ; [K, K]
    rst  30h
    defb $E0, $E2, $0F, $C0     ; px += vx              K, K, px
    defb $0F, $01               ; K, px + K
    defb $E1, $E3, $0F, $C1     ; py += vy              px + K, K, py
    defb $0F                    ; px + K, py + K
    defb $E4, $E2, $04          ; c vx
    defb $E5, $E3, $04, $03     ; vx' = c vx - s vy
    defb $E5, $E2, $04          ; s vx
    defb $E4, $E3, $04, $0F     ; vy' = s vx + c vy
    defb $C3, $02, $C2, $02     ; store vy', vx'
    defb $38                    ; end-calc      px + K, py + K
    call __A_POP_ROUND
    push hl                     ; ry
    call __A_POP_ROUND          ; HL = rx
    pop  de                     ; DE = ry
    call __A_SEG
    jr   __A_LOOP

__A_LAST:
    ld   hl, (ARC_DX)
    ld   de, (ARC_DY)

; __A_SEG -- draws from the drawn-so-far point to (HL, DE), relative to
; the start, and makes that the drawn-so-far point.
__A_SEG:
    push de
    ld   de, (ARC_X)
    ld   (ARC_X), hl
    or   a
    sbc  hl, de
    ex   de, hl                 ; DE = segment dx
    pop  hl
    push de
    ld   de, (ARC_Y)
    ld   (ARC_Y), hl
    or   a
    sbc  hl, de                 ; HL = segment dy
    pop  de
    ld   a, d
    or   e
    or   h
    or   l
    ret  z                      ; rounds to no movement: nothing to draw
    jp   __DRAW

; __A_ABS -- HL = |HL|.
__A_ABS:
    bit  7, h
    ret  z
    xor  a
    sub  l
    ld   l, a
    sbc  a, a
    sub  h
    ld   h, a
    ret

; __A_PUSH_HL -- pushes the signed integer HL onto the calculator stack.
__A_PUSH_HL:
    ld   a, h
    rla
    sbc  a, a
    ld   d, a
    ld   e, a
    call __I32TOFREG
    jp   __FPSTACK_PUSH

; __A_POP_HL -- pops a non-negative float off the calculator stack into
; DEHL, truncated.
__A_POP_HL:
    call __FPSTACK_POP
    jp   __FTOU32REG

; Rounding a coordinate p to the nearest integer is INT(p + 0.5), but
; the calculator's int ($27) uses memory cell 0 for negative numbers,
; which holds px here. So the loop adds K = 32768.5 instead, which
; makes the value positive (p > -32768), truncates it in Z80 code
; (__FTOU32REG: for a positive value that is the floor) and takes the
; 32768 back off.
__A_PUSH_K:
    ld   a, 090h
    ld   de, 00000h
    ld   bc, 00080h             ; 32768.5
    jp   __FPSTACK_PUSH

; __A_POP_ROUND -- pops p + 32768.5 into HL = round(p).
__A_POP_ROUND:
    call __A_POP_HL
    ld   a, h
    xor  $80                    ; - 32768 (mod 65536)
    ld   h, a
    ret
    ENDP

    pop namespace
