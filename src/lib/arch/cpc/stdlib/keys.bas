' ----------------------------------------------------------------
' keys.bas -- Amstrad CPC version
'
' The same API as zx48k's keys.bas, so a program written for the
' Spectrum library compiles and runs unchanged on the CPC (including the
' KEY constants' names). The scan codes differ: they encode the CPC
' keyboard matrix. High byte = matrix row (0-9), low byte = bit mask of
' the key in that row, so MultiKeys(KEYH bOR KEYL) works for keys in
' the same row. Never use the numeric values, only the names.
'
' Direct matrix scan (runtime io/keyboard/kscan.asm): no firmware call
' and no cpcbuild dependency. Interrupts are off for a few hundred
' T-states per scan (the firmware's interrupt handler uses the same
' ports), and are on again afterwards. Two keys can "ghost" a third on
' the matrix, as on any CPC.
'
'   GetKey()          waits for a key and returns its character code,
'                     like zx48k (CODE INKEY$). On the CPC INKEY$ returns
'                     the CPC's codes (RETURN 13, DEL 127, cursor keys
'                     240-243) and respects SHIFT/CONTROL and the caps
'                     lock; with -D CPC_INKEY_BUFFERED it reads the
'                     firmware's key buffer instead.
'   MultiKeys(code)   non-zero if that key (or any of the OR-ed keys of
'                     one row) is held; the bits returned tell which.
'                     A value that is not a CPC scan code (row above 9,
'                     e.g. a Spectrum number) gives 0.
'   GetKeyScanCode()  the scan code of the first row (in matrix order,
'                     row 0 first) that has a key held, with the bits of
'                     all held keys of that row; 0 if none. Includes
'                     SHIFT, CONTROL, and the joystick lines of row 9.
'
' Spectrum keys mapped to the CPC:
'   KEYCAPS (Caps Shift)     -> SHIFT
'   KEYSYMBOL (Symbol Shift) -> CONTROL, the CPC's other modifier key
'   KEYENTER                 -> RETURN (the keypad's ENTER is KEYPADENTER)
'   KEYSPACE, letters, digits -> the same keys
' KEYSHIFT and KEYCONTROL are aliases of KEYCAPS and KEYSYMBOL for code
' written for the CPC only.
'
' CPC-only constants: KEYCURUP/DOWN/LEFT/RIGHT (cursor keys), KEYCOPY,
' KEYCLR, KEYDEL, KEYTAB, KEYESC, KEYCAPSLOCK, KEYF0-KEYF9, KEYFDOT,
' KEYPADENTER (the keypad), KEYMINUS, KEYCARET, KEYAT, KEYSEMICOLON,
' KEYCOLON, KEYSLASH, KEYDOT, KEYCOMMA, KEYLBRACKET, KEYRBRACKET,
' KEYBACKSLASH, and KEYJOYUP/DOWN/LEFT/RIGHT/FIRE1/FIRE2 (joystick 0).
' ----------------------------------------------------------------

#ifndef __LIBRARY_IO_KEYS__

REM Avoid recursive / multiple inclusion

#define __LIBRARY_IO_KEYS__
#pragma push(case_insensitive)
#pragma case_insensitive = TRUE

function GetKey AS UByte
    Dim k AS UByte
    do
        k = CODE INKEY$
    loop UNTIL k

    return k
end function

' MultiKeys: H = row, L = mask. Firmware entries called: none.
' Clobbers AF, BC, DE, HL; interrupts off during the scan.
function FASTCALL MultiKeys(scancode as UInteger) AS UByte
    asm
        PROC
        LOCAL __MK_NO, __MK_END

        ld   a, h
        cp   10
        jr   nc, __MK_NO        ; not a CPC row
        push hl
        ld   d, a
        ld   e, 1
        call .core.__CPC_KSCAN_ROWS
        pop  bc                 ; B = row, C = mask
        ld   hl, .core.__CPC_KEYS
        ld   e, b
        ld   d, 0
        add  hl, de
        ld   a, (hl)
        and  c
        jr   __MK_END
__MK_NO:
        xor  a
__MK_END:
        ENDP
    end asm
end function

' GetKeyScanCode: HL = row << 8 | bits of the held keys of the first row
' with any, else 0. Firmware entries called: none.
function FASTCALL GetKeyScanCode AS UInteger
    asm
        PROC
        LOCAL __GK_LOOP, __GK_NONE, __GK_END

        ld   de, 10             ; D = 0 (first row), E = 10 rows
        call .core.__CPC_KSCAN_ROWS
        ld   hl, .core.__CPC_KEYS
        ld   b, 0
__GK_LOOP:
        ld   a, (hl)
        or   a
        jr   nz, __GK_END
        inc  hl
        inc  b
        ld   a, b
        cp   10
        jr   c, __GK_LOOP
        ld   hl, 0
        jr   __GK_NONE
__GK_END:
        ld   l, a
        ld   h, b
__GK_NONE:
        ENDP
    end asm
end function

#pragma pop(case_insensitive)

#require "io/keyboard/kscan.asm"

REM Scan codes: high byte = matrix row, low byte = bit mask

REM Spectrum keys, same names as zx48k's keys.bas, mapped onto the CPC matrix
const KEYB         AS UInteger = 0640h
const KEYN         AS UInteger = 0540h
const KEYM         AS UInteger = 0440h
const KEYSYMBOL    AS UInteger = 0280h
const KEYSPACE     AS UInteger = 0580h
const KEYH         AS UInteger = 0510h
const KEYJ         AS UInteger = 0520h
const KEYK         AS UInteger = 0420h
const KEYL         AS UInteger = 0410h
const KEYENTER     AS UInteger = 0204h
const KEYY         AS UInteger = 0508h
const KEYU         AS UInteger = 0504h
const KEYI         AS UInteger = 0408h
const KEYO         AS UInteger = 0404h
const KEYP         AS UInteger = 0308h
const KEY6         AS UInteger = 0601h
const KEY7         AS UInteger = 0502h
const KEY8         AS UInteger = 0501h
const KEY9         AS UInteger = 0402h
const KEY0         AS UInteger = 0401h
const KEY5         AS UInteger = 0602h
const KEY4         AS UInteger = 0701h
const KEY3         AS UInteger = 0702h
const KEY2         AS UInteger = 0802h
const KEY1         AS UInteger = 0801h
const KEYT         AS UInteger = 0608h
const KEYR         AS UInteger = 0604h
const KEYE         AS UInteger = 0704h
const KEYW         AS UInteger = 0708h
const KEYQ         AS UInteger = 0808h
const KEYG         AS UInteger = 0610h
const KEYF         AS UInteger = 0620h
const KEYD         AS UInteger = 0720h
const KEYS         AS UInteger = 0710h
const KEYA         AS UInteger = 0820h
const KEYV         AS UInteger = 0680h
const KEYC         AS UInteger = 0740h
const KEYX         AS UInteger = 0780h
const KEYZ         AS UInteger = 0880h
const KEYCAPS      AS UInteger = 0220h

REM CPC cursor, editing and special keys
const KEYCURUP     AS UInteger = 0001h
const KEYCURRIGHT  AS UInteger = 0002h
const KEYCURDOWN   AS UInteger = 0004h
const KEYCURLEFT   AS UInteger = 0101h
const KEYCOPY      AS UInteger = 0102h
const KEYCLR       AS UInteger = 0201h
const KEYDEL       AS UInteger = 0980h
const KEYTAB       AS UInteger = 0810h
const KEYESC       AS UInteger = 0804h
const KEYCAPSLOCK  AS UInteger = 0840h

REM CPC keypad (the function keys; PADENTER is the keypad's ENTER, FDOT its dot)
const KEYF0        AS UInteger = 0180h
const KEYF1        AS UInteger = 0120h
const KEYF2        AS UInteger = 0140h
const KEYF3        AS UInteger = 0020h
const KEYF4        AS UInteger = 0210h
const KEYF5        AS UInteger = 0110h
const KEYF6        AS UInteger = 0010h
const KEYF7        AS UInteger = 0104h
const KEYF8        AS UInteger = 0108h
const KEYF9        AS UInteger = 0008h
const KEYFDOT      AS UInteger = 0080h
const KEYPADENTER  AS UInteger = 0040h

REM CPC punctuation keys
const KEYMINUS     AS UInteger = 0302h
const KEYCARET     AS UInteger = 0301h
const KEYAT        AS UInteger = 0304h
const KEYSEMICOLON AS UInteger = 0310h
const KEYCOLON     AS UInteger = 0320h
const KEYSLASH     AS UInteger = 0340h
const KEYDOT       AS UInteger = 0380h
const KEYCOMMA     AS UInteger = 0480h
const KEYLBRACKET  AS UInteger = 0202h
const KEYRBRACKET  AS UInteger = 0208h
const KEYBACKSLASH AS UInteger = 0240h

REM CPC joystick 0 (its lines are keys of row 9 of the matrix)
const KEYJOYUP     AS UInteger = 0901h
const KEYJOYDOWN   AS UInteger = 0902h
const KEYJOYLEFT   AS UInteger = 0904h
const KEYJOYRIGHT  AS UInteger = 0908h
const KEYJOYFIRE1  AS UInteger = 0910h
const KEYJOYFIRE2  AS UInteger = 0920h

REM Aliases for CPC-only code
const KEYSHIFT    AS UInteger = KEYCAPS
const KEYCONTROL  AS UInteger = KEYSYMBOL

#endif
