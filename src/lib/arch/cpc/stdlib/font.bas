' ----------------------------------------------------------------
' font.bas -- Amstrad CPC custom font (--arch cpc only)
'
'   SetFont addr      replaces the glyphs of characters 32-127 with the
'                     768 bytes at addr: 96 characters x 8 bytes, top
'                     row first, bit 7 the leftmost pixel (the Spectrum's
'                     font format, which is also the CPC's matrix format)
'
' The CPC firmware draws characters from a "user matrix table" set with
' TXT_SET_M_TABLE; the table always runs from its first character up to
' 255, so a table starting at character 32 is 1792 bytes. It has to lie
' in the central 32K (&4000-&BFFF). The first SetFont call takes those
' 1792 bytes from the heap and installs the table; the firmware fills it
' with the glyphs in use, so characters 128-255 keep their CPC shapes.
' CHARS then holds the table address - 256 (the Spectrum's convention:
' the address of the glyph for character 32, minus 256), and 0 means no
' table yet. Every call copies the 768 bytes from addr into the table, so
' SetFont can be called again to switch fonts; addr may be anywhere.
'
' UDGs: a program that uses USR "a" already has a 896-byte table for
' characters 144-255 (runtime/udg.asm, set up at start-up, address in
' UDG). The first SetFont frees it and points UDG into the new table
' (at character 144), so UDGs defined before the call survive and USR "a"
' keeps working after it.
'
' Memory: 1792 bytes of heap, out of the default 4768 (a program that
' also uses USR "a" gets 896 of them back). If the heap is too small,
' the first call stops with error 3 (out of memory); raise it with
' "#pragma heap_size = 8192" or so. A program that doesn't include this
' file pays nothing.
' ----------------------------------------------------------------

#ifndef __LIBRARY_FONT__
#define __LIBRARY_FONT__

#ifndef __CPC__
#error "font.bas is for --arch cpc only"
#endif

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE

' Firmware: TXT_SET_M_TABLE (&BBAB, DE = first character, HL = table),
' first call only. Also uses __MEM_ALLOC / __MEM_FREE.
' Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF'.
#ifdef CPC_BAREMETAL
' Bare-metal mode: no firmware, no allocation. The glyph table is part of
' the program (runtime/txtbare.asm) and already holds characters 32-255, so
' SetFont just copies the 768 bytes over characters 32-127. UDGs (the
' table from character 144) are not moved.
sub SetFont(addr as uinteger)
    asm
    push namespace core
    ld l, (ix+4)
    ld h, (ix+5)
    ld de, __CPC_FONT
    ld bc, 768
    ldir
    pop namespace
    end asm
end sub
#else
sub SetFont(addr as uinteger)
    asm
    push namespace core
    PROC
    LOCAL __SF_NOMEM, __SF_COPY, __SF_NOOLD

    ld hl, (CHARS)
    ld a, h
    or l
    jr nz, __SF_COPY        ; table already installed

    ld bc, 1792
    call __MEM_ALLOC
    ld a, h
    cp $40
    jr c, __SF_NOMEM        ; NULL, or not in the central 32K
    push hl                 ; the new table
    ld de, 32
    call .core.__FW_CALL
    defw $BBAB              ; TXT_SET_M_TABLE
    ld hl, (UDG)
    ld a, h
    or l
    jr z, __SF_NOOLD
    call __MEM_FREE         ; the 144-255 table from udg.asm
__SF_NOOLD:
    pop hl                  ; the table again
    ld de, 896              ; (144 - 32) * 8
    push hl
    add hl, de
    ld (UDG), hl
    pop hl
    dec h                   ; table - 256
    ld (CHARS), hl

__SF_COPY:
    ld hl, (CHARS)
    inc h                   ; back to the table
    ex de, hl
    ld l, (ix+4)
    ld h, (ix+5)
    ld bc, 768
    ldir
    jr __SF_END

__SF_NOMEM:
    ld a, ERROR_OutOfMemory
    jp __ERROR
__SF_END:
    ENDP
    pop namespace
    end asm
end sub
#endif

#pragma pop(case_insensitive)

#ifdef CPC_BAREMETAL
#require "txtbare.asm"
#else
#require "fwcall.asm"
#require "error.asm"
#require "sysvars.asm"
#require "mem/alloc.asm"
#require "mem/free.asm"
#endif

#endif
