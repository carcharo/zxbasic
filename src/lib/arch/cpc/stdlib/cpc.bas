' ----------------------------------------------------------------
' cpc.bas -- Amstrad CPC screen basics (--arch cpc only)
'
'   Mode n            screen mode 0 (160x200, 16 pens, 20 columns),
'                     1 (320x200, 4 pens, 40 columns) or 2 (640x200,
'                     2 pens, 80 columns); clears the screen
'   GetMode()         the current screen mode
'   SetInk pen, c     sets a pen to firmware colour c (0-26), at once
'   SetBorder c       sets the border to firmware colour c (0-26), at once
'   WaitVsync         waits for the start of the next frame flyback
'   AyWrite reg, v    writes sound chip (AY-3-8912) register reg (0-15)
'   AyRead(reg)       reads sound chip register reg (0-15)
'
' INK/PAPER/BORDER keep taking Spectrum colours 0-7, mapped to pens of
' the current mode (runtime/colour.asm). SetInk changes what colour a
' pen shows, so it recolours everything drawn with that pen at once.
'
' Hardware colours: 0 black, 1 blue, 2 bright blue, 3 red, 4 magenta,
' 5 mauve, 6 bright red, 7 purple, 8 bright magenta, 9 green, 10 cyan,
' 11 sky blue, 12 yellow, 13 white, 14 pastel blue, 15 orange, 16 pink,
' 17 pastel magenta, 18 bright green, 19 sea green, 20 bright cyan,
' 21 lime, 22 pastel green, 23 pastel cyan, 24 bright yellow,
' 25 pastel yellow, 26 bright white.
'
' Sound chip ownership: the firmware's sound manager (SOUND, BEEP) runs
' from the interrupt handler and writes the AY by itself whenever a note
' is queued. A program that drives the AY directly (AyWrite, or the Play
' library, which does) must not also queue firmware sounds: call the
' firmware's SOUND_RESET (&BCA7) once first to make the manager idle (Play
' does), and don't use BEEP/SOUND afterwards without expecting the chip
' to be reprogrammed. AyWrite/AyRead switch interrupts off for the
' access (the firmware's keyboard scan shares the PPI) and return with
' them on. Register 7 (mixer): keep bits 6-7 clear, bit 6 makes the
' keyboard port an output and the keyboard stops reading.
' ----------------------------------------------------------------

#ifndef __LIBRARY_CPC__
#define __LIBRARY_CPC__

#ifndef __CPC__
#error "cpc.bas is for --arch cpc only"
#endif

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE

' Firmware: SCR_SET_MODE (&BC0E), then the runtime's per-mode variables
' (pen map, widths) and CLS, so the screen clears to the current PAPER.
sub fastcall Mode(n as ubyte)
    asm
    push namespace core
    and 3
    push af
    call .core.__FW_CALL
    defw $BC0E
    pop af
    call __CPC_SET_MODE_VARS
    call CLS
    pop namespace
    end asm
end sub

' Firmware: SCR_GET_MODE (&BC11).
function fastcall GetMode as ubyte
    asm
    call .core.__FW_CALL
    defw $BC11
    end asm
end function

' Firmware: SCR_SET_INK (&BC32, A = pen, B and C = the colour twice,
' i.e. not flashing); then the same colour straight to the Gate Array,
' so it shows at once (runtime/cpcbuild/palette.asm). Pens 0-15 (use
' SetBorder for the border); pens above 15 and colours above 26 are ignored.
sub SetInk(pen as ubyte, colour as ubyte)
    asm
    ld a, (ix+5)
    ld c, (ix+7)
    call .core.__CB_SET_INK
    end asm
end sub

' Firmware: SCR_SET_BORDER (&BC38, B and C = the colour); then the same
' colour straight to the Gate Array. Colours above 26 are ignored.
sub fastcall SetBorder(colour as ubyte)
    asm
    call .core.__CB_SET_BORDER
    end asm
end sub

' Firmware: MC_WAIT_FLYBACK (&BD19). Returns at once if the flyback has
' already started, so call it once per frame.
sub fastcall WaitVsync
    asm
    call .core.__FW_CALL
    defw $BD19
    end asm
end sub

' Writes AY register reg (0-15) with value; direct PPI access with
' interrupts off for the write, back on afterwards (runtime/ay.asm).
' Firmware: none. See the header about sound ownership.
sub AyWrite(reg as ubyte, value as ubyte)
    asm
    ld a, (ix+5)
    ld c, (ix+7)
    call .core.__CPC_AY_WRITE_DI
    end asm
end sub

' Reads AY register reg (0-15); bits a register doesn't implement read as
' 0. Direct PPI access with interrupts off for the read, back on after.
' Firmware: none.
function fastcall AyRead(reg as ubyte) as ubyte
    asm
    call .core.__CPC_AY_READ_DI
    end asm
end function

#pragma pop(case_insensitive)

#require "fwcall.asm"
#require "colour.asm"
#require "cls.asm"
#require "cpcbuild/palette.asm"
#require "ay.asm"

#endif
