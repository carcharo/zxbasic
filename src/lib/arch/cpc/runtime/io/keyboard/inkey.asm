; INKEY$ Function -- Phase-1 stub for zx48k/runtime/io/keyboard/inkey.asm
; (was: Spectrum ROM KEY_SCAN/KEY_TEST/KEY_CODE, &028E/&031E/&0333, ROM
; code that doesn't exist at those addresses on the CPC).
;
; Rather than a hard trap, this returns the same result the real zx48k
; routine gives when no key is pressed (an allocated, empty ZX BASIC
; string) -- always. That still needs dynamic memory (mem/alloc.asm,
; inherited unchanged), but no ROM, sysvar or hardware access at all, so
; it is a legitimate, if limited, real implementation: INKEY$ always
; reports "no key pressed".
; TODO(cpc): Phase 4a -> wire up to the firmware's KM_TEST_KEY (&BB1E).

#include once <mem/alloc.asm>

    push namespace core

INKEY:
    PROC

    ld bc, 3	; 1 char length string
    call __MEM_ALLOC

    ld a, h
    or l
    ret z	; Return if NULL (No memory)

    xor a
    ld (hl), a
    inc hl
    ld (hl), a
    dec hl
    ret

    ENDP

    pop namespace
