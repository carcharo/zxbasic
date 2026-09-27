; CHR$(x, y, x) returns the string CHR$(x) + CHR$(y) + CHR$(z)
;
; Amstrad CPC override: only change from zx48k's version is TMP's storage
; address. zx48k stashes the return address in the Spectrum ROM's DEST
; sysvar (23629) while it calls __MEM_ALLOC; on the CPC that address
; falls inside ordinary program RAM instead of a real sysvar, so
; CHR_SCRATCH (sysvars.asm) is used instead (same fix zx81sd's own
; chr.asm applies).

#include once <mem/alloc.asm>
#include once <sysvars.asm>

    push namespace core

CHR:	; Returns HL = Pointer to STRING (NULL if no memory)
    ; Requires alloc.asm for dynamic memory heap.
    ; Parameters: HL = Number of bytes to insert (already push onto the stack)
    ; STACK => parameters (16 bit, only the High byte is considered)
    ; Used registers A, A', BC, DE, HL, H'L'

    PROC

    LOCAL __POPOUT
    LOCAL TMP

TMP		EQU CHR_SCRATCH   ; cpc: dedicated scratch, not DEST

    ld a, h
    or l
    ret z	; If Number of parameters is ZERO, return NULL STRING

    ld b, h
    ld c, l

    pop hl	; Return address
    ld (TMP), hl

    push bc
    inc bc
    inc bc	; BC = BC + 2 => (2 bytes for the length number)
    call __MEM_ALLOC
    pop bc

    ld d, h
    ld e, l			; Saves HL in DE

    ld a, h
    or l
    jr z, __POPOUT	; No Memory, return

    ld (hl), c
    inc hl
    ld (hl), b
    inc hl

__POPOUT:	; Removes out of the stack every byte and return
    ; If Zero Flag is set, don't store bytes in memory
    ex af, af' ; Save Zero Flag

    ld a, b
    or c
    jr z, __CHR_END

    dec bc
    pop af 	   ; Next byte

    ex af, af' ; Recovers Zero flag
    jr z, __POPOUT

    ex af, af' ; Saves Zero flag
    ld (hl), a
    inc hl
    ex af, af' ; Recovers Zero Flag

    jp __POPOUT

__CHR_END:
    ld hl, (TMP)
    push hl		; Restores return addr
    ex de, hl	; Recovers original HL ptr
    ret

    ENDP

    pop namespace
