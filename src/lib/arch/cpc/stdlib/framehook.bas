' ----------------------------------------------------------------
' framehook.bas -- a routine that runs every frame, and game mode
' (--arch cpc)
'
'   FrameHook(addr)     the machine-code routine at addr runs once per
'                       frame, at the frame flyback, with interrupts off
'                       and all registers saved (e.g. a music player)
'   FrameHookOff()      stops it
'   Frames()            frames counted since the program started (ULONG)
'   GameMode(on)        1: interrupts outside firmware calls skip the
'                       firmware's handler (saves the 12-23 % of the CPU
'                       it takes); 0: back to normal
'
' The frame routine runs in every mode, also while the program waits
' inside a firmware call (WaitRetrace, PRINT ...), exactly once per
' frame. It must not call the firmware, PRINT, or use floats or strings:
' write it in asm (an ASM block with a label, @label for its address).
'
' In game mode, while the program isn't inside a firmware call, the
' firmware's own interrupt work stops: its key buffer (INPUT; INKEY$
' scans the keyboard itself and keeps working, ScanKeys from cpcbuild
' reads more keys), its 300 Hz clock (use Frames()), its sound
' queue (BEEP, SoundQueue; use the music player) and its ink refresh.
' Firmware calls themselves still work. Switch it off (GameMode(0))
' before relying on those again.
'
' See runtime/framehook.asm. Written for this project (MIT).
' ----------------------------------------------------------------

#ifndef __LIBRARY_FRAMEHOOK__
#define __LIBRARY_FRAMEHOOK__

#ifndef __CPC__
#error "framehook.bas is for --arch cpc only"
#endif

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE

sub fastcall FrameHook(addr as uinteger)
    asm
    ld (.core.FH_ADDR), hl      ; one instruction: no interrupt between bytes
    end asm
end sub

sub fastcall FrameHookOff()
    asm
    ld hl, 0
    ld (.core.FH_ADDR), hl
    end asm
end sub

function fastcall Frames() as ulong
    asm
    di
    ld hl, (.core.FH_FRAMES)
    ld de, (.core.FH_FRAMES + 2)
    ei
    end asm
end function

sub fastcall GameMode(onoff as ubyte)
    asm
    ld hl, 0
    or a
    jr z, $ + 5                 ; skip the 3-byte ld below
    ld hl, .core.__CPC_GM_ISR
    ld (.core.GM_VEC), hl
    end asm
end sub

#pragma pop(case_insensitive)

#require "framehook.asm"

#endif
