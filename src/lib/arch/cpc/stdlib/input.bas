' ----------------------------------------------------------------
' input.bas -- Amstrad CPC version
'
' A$ = INPUT(MaxChars): reads a line from the keyboard at the current
' print position, like zx48k's input.bas (not Sinclair BASIC's INPUT
' statement). Keys are read with the firmware (KM_WAIT_CHAR) and the
' firmware's own text cursor shows where typing goes. DEL deletes the
' last character, RETURN ends the input. As in zx48k's version, the
' typed text is erased from the screen when RETURN is pressed.
'
' The firmware's key buffer fills in the background, also while the
' program polls INKEY$ (which scans the keyboard itself). input()
' therefore empties the buffer when it starts, so keys typed earlier
' don't leak into the line.
' ----------------------------------------------------------------

#ifndef __LIBRARY_INPUT__
#define __LIBRARY_INPUT__

#pragma push(case_insensitive)
#pragma case_insensitive = True

' Bare-metal mode (-D CPC_BAREMETAL): there is no firmware, so no key
' buffer and no text cursor. The keys are read from the keyboard matrix
' (runtime io/keyboard/kbare.asm: __CPC_KEY_NEXT): a key going down gives
' its character at once, a key kept down repeats after 0.6 s and then
' every 0.08 s, and the cursor is an underscore drawn at the print
' position. A key already down when input() starts is ignored until it
' is released. Everything else (DEL, RETURN, the limit, the erasing at the
' end) is as below; ESC and the other non-text keys are ignored.
' ------------------------------------------------------------------

' ------------------------------------------------------------------
' Function 'PRIVATE' to this module.
' Waits for a key with the text cursor shown. Firmware: TXT_CUR_ON
' (&BB81), KM_WAIT_CHAR (&BB06, -> A), TXT_CUR_OFF (&BB84).
' ------------------------------------------------------------------
#ifdef CPC_BAREMETAL
FUNCTION FASTCALL PRIVATEInputRead AS UBYTE
    ASM
    call .core.__CPC_KEY_NEXT
    END ASM
END FUNCTION

FUNCTION PRIVATEInputKey AS UBYTE
    DIM c AS UBYTE
    PRINT "_"; CHR$(8);
    c = PRIVATEInputRead()
    PRINT " "; CHR$(8);
    RETURN c
END FUNCTION
#else
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
#endif

' ------------------------------------------------------------------
' Function 'PRIVATE' to this module.
' Discards every character waiting in the firmware's key buffer
' (runtime bootstrap.asm: KM_READ_CHAR, &BB09, until none).
' ------------------------------------------------------------------
SUB FASTCALL PRIVATEInputFlush()
    ASM
#ifdef CPC_BAREMETAL
    call .core.__CPC_KEY_FLUSH
#else
    call .core.__CPC_FLUSH_KEYS
#endif
    END ASM
END SUB

FUNCTION input(MaxLen AS UINTEGER) AS STRING
    DIM result$ AS STRING
    DIM i AS UINTEGER
    DIM k AS UBYTE

    result$ = ""
    PRIVATEInputFlush()

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
#ifdef CPC_BAREMETAL
#require "io/keyboard/kbare.asm"
#endif

#endif
