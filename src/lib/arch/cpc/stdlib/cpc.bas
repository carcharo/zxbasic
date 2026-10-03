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
'   SoundQueue(ch, period, dur, vol, env)
'                     queues a note on the firmware sound manager and
'                     returns at once: 1 queued, 0 queue full
'   SoundFree(ch)     free queue slots (0-4) of channel ch
'   SoundBusy(ch)     1 if channel ch is playing or has notes queued
'   SoundEnvelope n, @data, sections
'                     defines volume envelope n (1-15)
'   SoundStop         empties every queue and silences the chip
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
' Firmware sound (non-blocking; BEEP queues a note and waits, these never
' wait). The firmware's sound manager plays from its 300 Hz interrupt
' handler, which always runs in compiled code, so a note queued here
' sounds while the program carries on. Each of the 3 channels has a queue
' of 4 notes (the one playing is not counted: up to 5 in all).
'
'   SoundQueue(channels, period, duration, volume, envelope) AS UBYTE
'     channels: 1 = A, 2 = B, 4 = C, or OR'd (the same note on several).
'       Add 8/16/32 for a rendezvous with A/B/C (the note waits until the
'       other channel's note is also waiting for it: keeps channels in
'       step), 128 to flush the queues first (the note starts at once).
'     period: the AY's tone period, 0-4095 (above that is clamped):
'       period = 62500 / frequency in Hz (the AY runs at 1 MHz; middle C,
'       262 Hz, is 239; A 440 Hz is 142). Bigger = lower.
'     duration: in 1/100 s, 1-32767. 0 = one run of the volume envelope.
'       Negative: repeats the envelope that many times (65536 - n).
'     volume: starting volume 0-15 (the volume envelope, if any, then
'       changes it). Same loudness on every model: with no envelope
'       the 464's firmware (1.0) only has volumes 0-7 (doubled into the
'       AY's 0-15), so there v plays as the nearest even volume (15 as
'       14, 1 as 2); with an envelope 0-15 everywhere.
'     envelope: volume envelope number 1-15 (SoundEnvelope), 0 = none.
'     Returns 1 if the note was queued, 0 if that channel's queue was
'     full (nothing is queued; try again later). When several channels
'     are given, the result is the last one's.
'   SoundFree(channel)  channel is 1, 2 or 4: how many more notes can be
'     queued on it (0-4).
'   SoundBusy(channel)  1 while that channel is playing a note or has any
'     queued, else 0.
'   SoundEnvelope n, @data, sections
'     Defines volume envelope n (1-15), which SoundQueue then refers to.
'     data: sections * 3 bytes (1-5 sections), played in order; per
'     section: step count (1-127), step size (signed, added to the volume
'     per step, volume 0-15), pause per step in 1/100 s (0-255). Example,
'     a decay from 15 to 0 in 15 steps of 2/100 s (0.3 s):
'        DIM decay(2) AS UBYTE = {15, 255, 2}: SoundEnvelope 1, @decay(0), 1
'     The data is copied; the array can be reused at once. A section
'     whose first byte has bit 7 set is a hardware envelope (the AY's own
'     envelope generator: shape in bits 0-3, then the period, 2 bytes).
'   SoundStop  the firmware's SOUND_RESET: all queues emptied, all
'     channels silenced.
'
' Bare-metal mode (-D CPC_BAREMETAL, no firmware): WaitVsync waits for the
' next frame of the interrupt handler's counter; SoundStop silences the AY;
' SoundQueue, SoundFree, SoundBusy and SoundEnvelope need the firmware's
' sound manager and are a compile error (an "Undefined GLOBAL label ...
' needs_the_firmware__not_available_with_CPC_BAREMETAL"). AyWrite/AyRead
' work as ever.
'
' Sound chip ownership: the firmware's sound manager (SOUND, BEEP) runs
' from the interrupt handler and writes the AY by itself whenever a note
' is queued. A program that drives the AY directly (AyWrite, or the Play
' library, which does) must not also queue firmware sounds: call the
' firmware's SOUND_RESET (&BCA7) once first to make the manager idle (Play
' does), and don't use BEEP/SOUND afterwards without expecting the chip
' to be reprogrammed (so: SoundStop first, and never queue firmware
' sounds while Play or AyWrite are in use). AyWrite/AyRead switch interrupts off for the
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
#ifdef CPC_BAREMETAL
' Bare-metal mode: the Gate Array's mode register directly, the runtime's
' per-mode variables, and the screen cleared to the current PAPER
' (runtime/txtbare.asm).
sub fastcall Mode(n as ubyte)
    asm
    push namespace core
    call __BT_SET_MODE
    pop namespace
    end asm
end sub
#else
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
#endif

' Firmware: SCR_GET_MODE (&BC11).
#ifdef CPC_BAREMETAL
function fastcall GetMode as ubyte
    asm
    ld a, (.core.BT_MODE)
    end asm
end function
#else
function fastcall GetMode as ubyte
    asm
    call .core.__FW_CALL
    defw $BC11
    end asm
end function
#endif

' Firmware: SCR_SET_INK (&BC32, A = pen, B and C = the colour twice,
' i.e. not flashing); then the same colour straight to the Gate Array,
' so it shows at once (runtime/gacolour.asm). Pens 0-15 (use
' SetBorder for the border); pens above 15 and colours above 26 are ignored.
sub SetInk(pen as ubyte, colour as ubyte)
    asm
    ld a, (ix+5)
    ld c, (ix+7)
    call .core.__CPC_SET_INK
    end asm
end sub

' Firmware: SCR_SET_BORDER (&BC38, B and C = the colour); then the same
' colour straight to the Gate Array. Colours above 26 are ignored.
sub fastcall SetBorder(colour as ubyte)
    asm
    call .core.__CPC_SET_BORDER
    end asm
end sub

' Firmware: MC_WAIT_FLYBACK (&BD19). Returns at once if the flyback has
' already started, so call it once per frame.
' Bare-metal mode (-D CPC_BAREMETAL): waits for the next frame count of the
' interrupt handler (FH_FRAMES, which counts at the frame flyback), i.e. it
' always waits for the next frame; interrupts must be on.
#ifdef CPC_BAREMETAL
sub fastcall WaitVsync
    asm
    push namespace core
    ld bc, 1
    call __CPC_WAIT_FRAMES
    pop namespace
    end asm
end sub
#else
sub fastcall WaitVsync
    asm
    call .core.__FW_CALL
    defw $BD19
    end asm
end sub
#endif

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

#ifdef CPC_BAREMETAL
' Bare-metal mode: there is no firmware sound manager. These four are
' refused at compile time: using one fails with an "Undefined GLOBAL label"
' error whose name says why. (Unused ones are ignored as usual.) Use the
' music library, Play or AyWrite instead.
function SoundQueue(channels as ubyte, period as uinteger, duration as uinteger, volume as ubyte, envelope as ubyte) as ubyte
    asm
    call .core.SoundQueue_needs_the_firmware__not_available_with_CPC_BAREMETAL
    end asm
end function

function fastcall SoundFree(channel as ubyte) as ubyte
    asm
    call .core.SoundFree_needs_the_firmware__not_available_with_CPC_BAREMETAL
    end asm
end function

function fastcall SoundBusy(channel as ubyte) as ubyte
    asm
    call .core.SoundBusy_needs_the_firmware__not_available_with_CPC_BAREMETAL
    end asm
end function

sub SoundEnvelope(n as ubyte, addr as uinteger, sections as ubyte)
    asm
    call .core.SoundEnvelope_needs_the_firmware__not_available_with_CPC_BAREMETAL
    end asm
end sub

' Bare-metal mode: silences the chip (volumes 0, mixer all off; the AY
' registers directly, runtime/ay.asm). Firmware: none.
sub SoundStop
    asm
    call .core.__CPC_AY_SILENCE
    end asm
end sub
#else
' Queues a note on the firmware sound manager and returns at once; see the
' header for the arguments. Firmware: SOUND_QUEUE (&BCAA).
function SoundQueue(channels as ubyte, period as uinteger, duration as uinteger, volume as ubyte, envelope as ubyte) as ubyte
    asm
    ld l, (ix+6)
    ld h, (ix+7)
    ld e, (ix+8)
    ld d, (ix+9)
    ld a, (ix+5)
    ld b, (ix+11)
    ld c, (ix+13)
    call .core.__CPC_SND_QUEUE
    end asm
end function

' Free queue slots of one channel (1, 2 or 4), 0-4.
' Firmware: SOUND_CHECK (&BCAD).
function fastcall SoundFree(channel as ubyte) as ubyte
    asm
    call .core.__CPC_SND_CHECK
    and 7
    end asm
end function

' 1 if the channel (1, 2 or 4) is playing a note or has notes queued.
' Firmware: SOUND_CHECK (&BCAD).
function fastcall SoundBusy(channel as ubyte) as ubyte
    asm
    call .core.__CPC_SND_BUSY
    end asm
end function

' Defines volume envelope n (1-15) from sections * 3 bytes at the address.
' Firmware: SOUND_AMPL_ENVELOPE (&BCBC).
sub SoundEnvelope(n as ubyte, addr as uinteger, sections as ubyte)
    asm
    ld a, (ix+5)
    ld l, (ix+6)
    ld h, (ix+7)
    ld b, (ix+9)
    call .core.__CPC_SND_ENV
    end asm
end sub

' Empties all sound queues and silences the chip. Firmware: SOUND_RESET
' (&BCA7).
sub SoundStop
    asm
    call .core.__CPC_SND_RESET
    end asm
end sub

#endif

#pragma pop(case_insensitive)

#ifndef CPC_BAREMETAL
#require "fwcall.asm"
#endif
#require "colour.asm"
#require "cls.asm"
#ifdef CPC_BAREMETAL
#require "txtbare.asm"
#endif
#require "gacolour.asm"
#require "ay.asm"
#ifdef CPC_BAREMETAL
#require "waitframes.asm"
#else
#require "fwsound.asm"
#endif

#endif
