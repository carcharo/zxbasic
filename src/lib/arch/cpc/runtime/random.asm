; RANDOM functions -- Amstrad CPC
;
; Copied from zx48k/runtime/random.asm. Changes from the zx48k original:
;   - FRAMES: relocated from the Spectrum ROM sysvar (a 3-byte counter) to
;     sysvars.asm's own FRAMES, a 2-byte software counter in the cpc
;     private block (RAND only ever consumed the low 16 bits anyway).
;     RANDOM_SEED_HIGH is seeded with 0 when a program takes the frame
;     counter as its seed (matches zx81sd's own fix for the same issue).
;   - RANDOM_SEED_LOW: relocated from the Spectrum ROM sysvar to
;     sysvars.asm's own RANDOM_SEED_LOW.
;   - RANDOM_SEED_HIGH is unchanged: it is `RAND + 1`, the inline 16-bit
;     immediate operand of `ld de, 0C0DEh` inside RAND below (self-
;     modifying code used as 2 bytes of storage), a relative offset from
;     a label in this same file, so nothing to relocate.
; No change to the RNG algorithm itself (xorshift).

#include once <sysvars.asm>

    push namespace core

RANDOMIZE:
    ; Randomize with 32 bit seed in DE HL
    ; if SEED = 0, seeds from the software FRAMES counter instead
    PROC

    LOCAL TAKE_FRAMES

    ld a, h
    or l
    or d
    or e
    jr z, TAKE_FRAMES

    ld (RANDOM_SEED_LOW), hl
    ld (RANDOM_SEED_HIGH), de
    ret

TAKE_FRAMES:
    ; Takes the seed from the software frame counter (FRAMES is only 16
    ; bits wide on the cpc, so the high half of the seed is just 0)
    ld hl, (FRAMES)
    ld (RANDOM_SEED_LOW), hl
    ld hl, 0
    ld (RANDOM_SEED_HIGH), hl
    ret

    ENDP

RANDOM_SEED_HIGH EQU RAND + 1 ; RANDOM seed, 16 higher bits (inline operand, see header)

RAND:
    PROC
    ld  de,0C0DEh   ; yw -> zt
    ld  hl,(RANDOM_SEED_LOW)   ; xz -> yw
    ld  (RANDOM_SEED_LOW),de  ; x = y, z = w
    ld  a,e         ; w = w ^ ( w << 3 )
    add a,a
    add a,a
    add a,a
    xor e
    ld  e,a
    ld  a,h         ; t = x ^ (x << 1)
    add a,a
    xor h
    ld  d,a
    rra             ; t = t ^ (t >> 1) ^ w
    xor d
    xor e
    ld  d,l         ; y = z
    ld  e,a         ; w = t
    ld  (RANDOM_SEED_HIGH),de
    ret
    ENDP

RND:
    ; Returns a FLOATING point integer
    ; using RAND as a mantissa
    PROC
    LOCAL RND_LOOP

    call RAND
    ; BC = HL since ZX BASIC uses ED CB A registers for FP
    ld b, h
    ld c, l

    ld a, e
    or d
    or c
    or b
    ret z   ; Returns 0 if BC=DE=0

    ; We already have a random 32 bit mantissa in ED CB
    ; From 0001h to FFFFh

    ld l, 81h    ; Exponent
    ; At this point we have [0 .. 1) FP number;

    ; Now we must shift mantissa left until highest bit goes into carry
    ld a, e ; Use A register for rotating E faster (using RLA instead of RL E)
RND_LOOP:
    dec l
    sla b
    rl c
    rl d
    rla
    jp nc, RND_LOOP

    ; Now undo last mantissa left-shift once
    ccf ; Clears carry to insert a 0 bit back into mantissa -> positive FP number
    rra
    rr d
    rr c
    rr b

    ld e, a     ; E must have the highest byte
    ld a, l     ; exponent in A
    ret

    ENDP

    pop namespace
