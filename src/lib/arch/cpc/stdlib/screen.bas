' ----------------------------------------------------------------
' screen.bas -- Amstrad CPC version
'
' SCREEN$(row, col): the character at text row/col (0-based, row 0-24,
' col 0 to the current mode's width - 1), as a 1-character string; ""
' if the cell holds no recognisable character or row/col is off the
' screen. Like the Spectrum's SCREEN$, pixels drawn with PLOT/DRAW make
' a cell unrecognisable.
'
' The character is matched by the firmware (TXT_RD_CHAR), which compares
' the cell's pixels with the character set, UDGs included, so a UDG
' comes back as its code (144-164). Colours: cells printed in the
' current colours, or with only INK or only PAPER changed, read back
' correctly (tested); with both changed (e.g. PAPER 2; INK 4) the firmware
' misreads the cell, as a space on the 6128 and a solid block on the 464
' -- unlike the Spectrum, whose SCREEN$ ignores colours.
' Block graphics: PRINT turns the Spectrum's CHR$ 128-143 into the CPC's
' quadrant characters (bits 0<->1 and 2<->3 swapped); SCREEN$ swaps
' them back, so CHR$ 129 prints and reads back as CHR$ 129.
' The text cursor is left where it was.
' ----------------------------------------------------------------

#ifndef __LIBRARY_SCREEN__

#define __LIBRARY_SCREEN__

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE

' ----------------------------------------------------------------
' function SCREEN
'
' Parameters:
'     row: screen row
'     col: screen column
'
' Returns:
'     a string containing the screen char value
'
' Firmware entries called (via the gate): TXT_GET_CURSOR (&BB78,
' -> H = column, L = row, 1-based), TXT_SET_CURSOR (&BB75), TXT_RD_CHAR
' (&BB60, -> A = character, Carry set if recognised).
' Registers clobbered: AF, BC, DE, HL (main); BC', DE', HL', AF' (gate).
' ----------------------------------------------------------------
function screen(byval row as ubyte, byval col as ubyte) as string
	Dim result as String

	asm
    push namespace core

    PROC
    LOCAL __SCREEN_END, __SCREEN_NOSWAP

    ld bc, 3                ; 2-byte length + 1 character
    call __MEM_ALLOC
    push hl                 ; the new string

    ld a, h
    or l
    jr z, __SCREEN_END      ; no memory: return NULL

    xor a
    ld (hl), a              ; length 0 (= "") until a char is found
    inc hl
    ld (hl), a

    ld a, (ix+5)            ; row
    cp 25
    jr nc, __SCREEN_END
    ld a, (ix+7)            ; col
    ld hl, TXT_COLS
    cp (hl)
    jr nc, __SCREEN_END

    call .core.__FW_CALL
    defw $BB78              ; TXT_GET_CURSOR
    push hl                 ; the caller's cursor

    ld h, (ix+7)
    ld l, (ix+5)
    inc h                   ; firmware coordinates are 1-based
    inc l
    call .core.__FW_CALL
    defw $BB75              ; TXT_SET_CURSOR
    call .core.__FW_CALL
    defw $BB60              ; TXT_RD_CHAR
    push af                 ; A = char, Carry = recognised

    pop bc                  ; BC = AF
    pop hl                  ; the caller's cursor
    push bc
    call .core.__FW_CALL
    defw $BB75              ; TXT_SET_CURSOR (restore)
    pop af
    jr nc, __SCREEN_END     ; not recognised: ""

    cp 128                  ; CPC quadrant blocks 128-143 -> Spectrum's
    jr c, __SCREEN_NOSWAP
    cp 144
    jr nc, __SCREEN_NOSWAP
    ld c, a
    and $0A
    rrca                    ; bits 1, 3 -> 0, 2
    ld b, a
    ld a, c
    and $05
    rlca                    ; bits 0, 2 -> 1, 3
    or b
    or $80
__SCREEN_NOSWAP:
    pop hl
    push hl
    ld (hl), 1              ; length 1
    inc hl
    inc hl
    ld (hl), a

__SCREEN_END:
    pop hl
    ld (ix-2), l
    ld (ix-1), h

    ENDP

    pop namespace
	end asm

	return result

end function

#pragma pop(case_insensitive)

#require "fwcall.asm"
#require "mem/alloc.asm"

#endif
