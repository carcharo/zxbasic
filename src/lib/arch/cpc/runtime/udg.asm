; -----------------------------------------------------------------------
; Amstrad CPC -- the UDG table (CHR$ 144-164)
;
; The Spectrum keeps its 21 UDGs at the address in the UDG sysvar, and
; POKE USR "a"+n writes straight into them. The CPC firmware draws
; characters from a "user matrix table" set with TXT_SET_M_TABLE, which
; always covers its first character up to 255 (measured: SYMBOL AFTER 144
; takes 896 bytes), and must be in the central 32K (&4000-&BFFF), where
; the firmware reads it with the ROMs paged in.
;
; So the table for 144-255 (896 bytes) is taken from the heap, which is
; always in the central 32K with the default layout, and UDG points at
; its start: PRINT CHR$ 144 then shows whatever POKE USR "a" wrote.
; TXT_SET_M_TABLE fills the new table with the current glyphs, so
; CHR$ 144-255 keep showing the CPC's own characters until redefined
; (on the Spectrum the UDGs start as copies of A-U).
;
; Only programs that use USR "a" pay for it: usr_str.asm includes this
; file, which registers the init (cpcbuild/docs/notes.md, question 20).
; font.bas's full font (chars 32-255) replaces this table; if it has
; already set UDG, this does nothing.
;
; Init order: #init routines run in sorted name order, and this one has
; to come after the heap's .core.__MEM_INIT, so it's named __UDG_INIT
; ("__U" sorts after "__M"; the CPC_INIT_* routines sort first).

#include once <error.asm>
#include once <fwcall.asm>
#include once <mem/alloc.asm>
#include once <sysvars.asm>

#init .core.__UDG_INIT

    push namespace core

UDG_FIRST       EQU 144
UDG_TABLE_SIZE  EQU (256 - UDG_FIRST) * 8

; __UDG_INIT -- allocates and installs the 144-255 matrix table, unless
; UDG is already set. Stops with "Error 3" (out of memory) if the heap
; can't hold it, or holds it below &4000 (a custom heap address).
; Firmware entry called: TXT_SET_M_TABLE (&BBAB, DE = first character,
; HL = table).
; Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (the
; gate).
__UDG_INIT:
    PROC
    LOCAL __UI_NOMEM

    ld   hl, (UDG)
    ld   a, h
    or   l
    ret  nz
    ld   bc, UDG_TABLE_SIZE
    call __MEM_ALLOC
    ld   a, h
    cp   $40
    jr   c, __UI_NOMEM      ; NULL, or not in the central 32K
    ld   (UDG), hl
    ld   de, UDG_FIRST
    call .core.__FW_CALL
    defw $BBAB              ; TXT_SET_M_TABLE
    ret

__UI_NOMEM:
    ld   a, ERROR_OutOfMemory
    jp   __ERROR
    ENDP

    pop namespace
