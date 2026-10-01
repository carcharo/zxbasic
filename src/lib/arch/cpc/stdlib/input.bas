' ----------------------------------------------------------------
' input.bas -- Amstrad CPC version
'
' A$ = INPUT(MaxChars): reads a line from the keyboard at the current
' print position, like zx48k's input.bas (not Sinclair BASIC's INPUT
' statement). Keys are read with the firmware (KM_WAIT_CHAR) and the
' firmware's own text cursor shows where typing goes. DEL deletes the
' last character, RETURN ends the input. As in zx48k's version, the
' typed text is erased from the screen when RETURN is pressed.
' ----------------------------------------------------------------

#ifndef __LIBRARY_INPUT__
#define __LIBRARY_INPUT__

#pragma push(case_insensitive)
#pragma case_insensitive = True

' ------------------------------------------------------------------
' Function 'PRIVATE' to this module.
' Waits for a key with the text cursor shown. Firmware: TXT_CUR_ON
' (&BB81), KM_WAIT_CHAR (&BB06, -> A), TXT_CUR_OFF (&BB84).
' ------------------------------------------------------------------
FUNCTION FASTCALL PRIVATEInputKey AS UBYTE
    ASM
    call .core.__FW_CALL
    defw $BB81
    call .core.__FW_CALL
    defw $BB06
    push af
    call .core.__FW_CALL
    defw $BB84
    pop af
    END ASM
END FUNCTION

FUNCTION input(MaxLen AS UINTEGER) AS STRING
    DIM result$ AS STRING
    DIM i AS UINTEGER
    DIM k AS UBYTE

    result$ = ""

    DO
        k = PRIVATEInputKey()

        REM DEL is 127 on the CPC (12 on the Spectrum)
        IF k = 127 THEN
            IF LEN(result$) THEN
                IF LEN(result$) = 1 THEN
                    LET result$ = ""
                ELSE
                    LET result$ = result$( TO LEN(result$) - 2)
                END IF
                PRINT CHR$(8); " "; CHR$(8);
            END IF
        ELSEIF k >= 32 AND k < 127 AND LEN(result$) < MaxLen THEN
            LET result$ = result$ + CHR$(k)
            PRINT CHR$(k);
        END IF

    LOOP UNTIL k = 13 : REM RETURN

    FOR i = 1 TO LEN(result$)
        PRINT OVER 0; CHR$(8) + " " + CHR$(8);
    NEXT

    RETURN result$

END FUNCTION

#pragma pop(case_insensitive)

#require "fwcall.asm"

#endif
