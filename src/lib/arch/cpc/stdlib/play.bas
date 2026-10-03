' ----------------------------------------------------------------------
' play.bas (cpc) -- COPY of zx48k/stdlib/play.bas adapted to the Amstrad
' CPC (AY-3-8912 behind the 8255 PPI, 1 MHz AY clock, 4 MHz Z80 with
' every instruction stretched to whole 1 us units). Keep in sync with the
' zx48k original; the ONLY changes from it are:
'
'   1. _PLAY_WRITE_TO_REGISTER: the Spectrum 128's `out $fffd / $bffd`
'      becomes a call to _Play_AyWrite, a FASTCALL helper around
'      runtime/ay.asm's __CPC_AY_WRITE (PPI port A = register, port C
'      latch / inactive, port A = value, port C write / inactive; port C's
'      cassette bits kept). It's the raw routine: Play runs with
'      interrupts off (the firmware's keyboard scan in the interrupt
'      handler shares the PPI), and every AY write in Play is inside
'      that DI ... EI section (the registers are only written after the
'      `di`, none before it). Cost: 58 us per write measured (the CALL,
'      the 53 us body and the RET), plus about 16 us for the helper's
'      own CALL and argument passing. In _PLAY_BENCHMARK_MODE
'      (interrupts on) the helper calls the DI variant instead.
'   2. _Play_NoteDividers: regenerated for the CPC's 1 MHz AY clock:
'      divider = round(1000000 / 16 / f), f = 440 * 2^((n - 57) / 12)
'      for note index n = octave * 12 + semitone (A of octave 4 is 440 Hz,
'      C0 is 16.35 Hz). That is exactly how the zx48k table is built: it
'      matches round(1773447.5 / 16 / f) for all 108 entries (1773447.5 Hz
'      being the Spectrum 128's AY clock; 1773400 gives 5 off by one).
'      The lowest notes fit in 12 bits (3822) so octave 0 plays
'      correctly here; the highest divider is 8.
'   3. CpuCyclesPerSecond = 4000000 and CpuCyclesPerMicrotick = 28. The
'      Wait loop is SBC HL,BC (4 us) + JR NZ taken (3 us) = 7 us per
'      microtick on the CPC, i.e. 28 T-states of the 4 MHz clock.
'      TickGeneralOverheadInMicroticks (90 -> 113) and
'      TickChannelCommandsOverheadInMicroticks (140 -> 185) were
'      re-measured: the same code costs more on the CPC. Method and
'      results are at the constants; the calibration program is
'      tests/stress/play_tempo.bas in the cpcbuild repository.
'   4. SetChipMixer masks the value with $3F. Bits 6-7 of AY register 7
'      are the I/O port directions; on the CPC port A is the keyboard
'      input, and setting bit 6 (as the Spectrum 128 default %11111000
'      does) would turn it into an output and stop the keyboard working.
'      DefaultMixer is therefore %00111000.
'   5. SOUND_RESET (firmware &BCA7, through the firmware gate) is called
'      once at the start, before the `di`, so the firmware's sound
'      manager (which writes the AY from the interrupt handler when a
'      note is queued) is idle and doesn't fight over the chip.
'   6. _PLAY_BENCHMARK_MODE times with the firmware's 300 Hz clock
'      (KL_TIME_PLEASE, &BD0D) instead of the Spectrum's FRAMES sysvar,
'      and leaves the result in _Play_BenchTicks.
'   7. The final `ei` is kept: compiled cpc code runs with interrupts on.
'   8. Documentation comments about the CPU speed and sound ownership.
'   9. Bare-metal mode (-D CPC_BAREMETAL, Phase 6): there is no firmware
'      sound manager, so the SOUND_RESET call of change 5 is replaced by
'      silencing the AY directly (runtime/ay.asm's __CPC_AY_SILENCE);
'      everything else is the same, Play only ever wrote the AY itself.
'      _PLAY_BENCHMARK_MODE needs the firmware's clock: a compile error
'      in bare mode.
'
' Not changed: the MML parser, the note length table, the noise-period
' formula (taken from the Spectrum ROM; it only maps a note to a noise
' pitch, whatever the clock).
' ----------------------------------------------------------------------

' ----------------------------------------------------------------------
' This file is released under the MIT License
'
' Copyright (C) 2026
' by Oleg S. Kostenko (a.k.a. Ollibony) <https://github.com/oskostenko>
' ----------------------------------------------------------------------

#pragma once

#pragma push(explicit)
#pragma push(strict)

#pragma explicit = true
#pragma strict = true

' ---------------------------------------------------------------------------------------------------------------------
' Plays the given MML strings on the AY music chip.
' The syntax is compatible with the Sinclair Basic Play routine.
'
' The documentation can be found here: https://fizyka.umk.pl/~jacek/zx/doc/man128/sp128p09.html
'
' More accurate (although not as well structured) documentation can be found in ZX Spectrum +3 manual here:
' https://zxspectrumvault.github.io/Manuals/Hardware/SpectrumPlus3Manual.html (see Chapter 8 Part 19)
'
' This is work in progress.

' The following commands are already implemented:
' - cdefgab, CDEFGAB - gives pitch of note within current octave range
' - $ - flattens note following it
' - # - sharpens note following it
' - & - denotes a rest
' - 1-12 - sets length of notes
' - _ - creates tied notes (sums multiple durations)
' - O - followed by a number 0 to 8 sets current octave range
' - V - followed by a number 0 to 15 sets volume of notes
' - T - followed by a number 60 to 240 sets tempo of music
' - N - separates two numbers (actually, any unexpected character does this, including space)
' - () - specifies that the enclosed phrase must be repeated
' - H - specifies that the Play command must stop
' - W - followed by a number 0 to 7 sets volume effect
' - X - followed by a number 0 to 65535 sets duration of volume effect
' - U - turns on volume effect in the channel
' - M - followed by a number from 0 to 63 specifies the channels mixer mode
'
' The following commands are not implemented yet:
' - !! - comments
' - Y, Z - MIDI control (also you can't now pass more than 3 parameters to Play).
'
' Notes:
'
' - Unlike Sinclair Basic Play routine, this one doesn't insert tiny pauses between adjacent notes.
'   I consider this to be a feature, rather than a bug.
'
' - There is no proper error handling implemented. In particular:
'   - Unknown commands are silently ignored.
'   - Out-of-range numbers cause undefined behavior.
'   - An opening bracket is silently ignored if nesting level limit was reached (brackets can be maximum 4 levels deep).
'
' - This routine is more flexible in the way it parses commands than Sinclair Basic Play routine.
'   Some combinations that give errors in Sinclair Basic, will play fine in this implementation.
'
' - This sub tends to provide more accurate timings than the original Sinclair Basic Play routine.
'   However, perfect timing is not guaranteed, it may fluctuate depending on the complexity of the melody.
'
' - There can be subtle difference in behaviour between this sub and Sinclair Play,
'   especially in undocumented edge cases (such as using ties together with triplets).
'
' - This sub disables interrupts at the start, and enables them in the end,
'   regardless of whether they were enabled or not before.
'
' - (cpc) The tempo assumes the CPC's 4 MHz Z80 (1 us per NOP-unit); see the port notes at the top of this file.
'
' - (cpc) The sound chip belongs to Play while it runs: SOUND_RESET is called first so firmware sounds (BEEP, SOUND)
'   already queued are cancelled, and Play runs with interrupts off, so the keyboard and firmware clock don't run
'   during the music. Don't use BEEP/SOUND at the same time as AyWrite or Play; after Play returns, BEEP works again.
'   The `--enable-break` option is not supported with Play on the CPC: its per-line check goes through the firmware
'   gate, which enables interrupts, and the firmware's keyboard scan would collide with the AY writes.
'
' - The strings are passed by value and thus are copied on the routine invocation.
'   The memory-effective version of this routine is yet to be implemented.
'
' - The compiler gives warning `[W150] Parameter 'microticks' is never used`.
'   This is false positive and, unfortunately, cannot be suppressed on library level.
'
' - For some obscure reason, this sub doesn't work if compiler optimization level is set to 1 or lower.
'   The default optimization level (2) is fine.
'
' - The `--enable-break` compiler option causes play slowdown. The sound chip is not silenced when Break is pressed,
'   so it may feel as if the music 'freezed'.
' ---------------------------------------------------------------------------------------------------------------------
declare sub Play(channel0 as string, channel1 as string = "", channel2 as string = "")


' Implementation ------------------------------------------------------------------------------------------------------

' How many ticks there are in a bar (a whole note).
' A tick is a single iteration of the main processing loop.
const _Play_TicksPerBar as ubyte = 96

const _Play_NotesPerOctave as ubyte = 12
const _Play_TotalOctaves as ubyte = 9

' Maps note length to the corresponding number of ticks.
dim _Play_NoteLengthsInTicks(1 to 12) as ubyte => { _
    _Play_TicksPerBar / 16,       _ '1 - semi-quaver
    _Play_TicksPerBar / 16 * 1.5, _ '2 - dotted semi-quaver
    _Play_TicksPerBar / 8,        _ '3 - quaver
    _Play_TicksPerBar / 8 * 1.5,  _ '4 - dotted quaver
    _Play_TicksPerBar / 4,        _ '5 - crotchet
    _Play_TicksPerBar / 4 * 1.5,  _ '6 - dotted crotchet
    _Play_TicksPerBar / 2,        _ '7 - minim
    _Play_TicksPerBar / 2 * 1.5,  _ '8 - dotted minim
    _Play_TicksPerBar,            _ '9 - semi-breve
    _Play_TicksPerBar / 24,       _ '10 - triplet semi-quaver
    _Play_TicksPerBar / 12,       _ '11 - triplet quaver
    _Play_TicksPerBar / 6         _ '12 - triplet crotchet
}

' Divider values that need to be sent to the audio chip registers to play the notes.
' On the CPC (1 MHz AY clock), the lowest notes in octave 0 fit in 12 bits (3822 for C0),
' so they play correctly here.
' TODO: in Sinclair Play it is possible to play notes in higher octaves (using several sharps in a row).
'       Need to add more values to the table.
dim _Play_NoteDividers(0 to _Play_NotesPerOctave * _Play_TotalOctaves - 1) as uinteger = { _
_ ' C     C#    D     D#    E     F     F#    G     G#    A     A#    B
    3822, 3608, 3405, 3214, 3034, 2863, 2703, 2551, 2408, 2273, 2145, 2025, _ 'octave 0
    1911, 1804, 1703, 1607, 1517, 1432, 1351, 1276, 1204, 1136, 1073, 1012, _ 'octave 1
     956,  902,  851,  804,  758,  716,  676,  638,  602,  568,  536,  506, _ 'octave 2
     478,  451,  426,  402,  379,  358,  338,  319,  301,  284,  268,  253, _ 'octave 3
     239,  225,  213,  201,  190,  179,  169,  159,  150,  142,  134,  127, _ 'octave 4
     119,  113,  106,  100,   95,   89,   84,   80,   75,   71,   67,   63, _ 'octave 5
      60,   56,   53,   50,   47,   45,   42,   40,   38,   36,   34,   32, _ 'octave 6
      30,   28,   27,   25,   24,   22,   21,   20,   19,   18,   17,   16, _ 'octave 7
      15,   14,   13,   13,   12,   11,   11,   10,    9,    9,    8,    8  _ 'octave 8
}

' Maps ascii code of a letter to the corresponding index of `_Play_NoteDividers` (octave 0).
dim _Play_NoteIndexes(code("A") to code("G")) as ubyte = { _
    /'A'/ 9,  _
    /'B'/ 11, _
    /'C'/ 0,  _
    /'D'/ 2,  _
    /'E'/ 4,  _
    /'F'/ 5,  _
    /'G'/ 7   _
}

' Maps envelope shape number to its hardware equivalent.
dim _Play_EnvelopeShapes(0 to 7) as ubyte = { _
    /'0'/ %0000, _
    /'1'/ %0100, _
    /'2'/ %1011, _
    /'3'/ %1101, _
    /'4'/ %1000, _
    /'5'/ %1100, _
    /'6'/ %1110, _
    /'7'/ %1010  _
}

' Pointer to the current channel context.
' Made global for better performance, and also because it would be problematic to access it from nested subs if it were
' local (see 'Implementation note' on `Play`).
dim _Play_ContextPtr as uinteger

' Switches to the first channel context.
#define _PLAY_CTX_FIRST_CHANNEL() let _Play_ContextPtr = ChannelContextBufferPtr

' Swithes to the next channel context.
#define _PLAY_CTX_NEXT_CHANNEL() let _Play_ContextPtr = _Play_ContextPtr + ChannelContextSize

' Gets the value of the given `type` at the given `offset` of the current channel context.
#define _PLAY_CTX_GET(type, offset) (peek(type, _Play_ContextPtr + (offset)))

' Sets the given `value` of the given `type` to the given `offset` of the current channel context.
#define _PLAY_CTX_SET(type, offset, value) poke type _Play_ContextPtr + (offset), (value)

' Arithmetically adds the given `value` to the value of the given `type` stored at the given `offset`
' of the current channel context.
#define _PLAY_CTX_ADD(type, offset, value) _PLAY_CTX_SET(type, offset, _PLAY_CTX_GET(type, offset) + (value))

' Write the value to the given register of the sound chip.
' AY register A = reg, value on the stack (FASTCALL with two parameters: the first in A, the second pushed as the
' high byte of AF, which the helper pops). The helper must run with interrupts off (see the header); in benchmark mode
' (interrupts on) it uses the DI variant. Firmware entries called: none. Clobbers AF, BC, DE.
' (The compiler warns that FASTCALL with 2 parameters and unused parameters: false positives, like for `Wait`.)
#ifdef CPC_BAREMETAL
#ifdef _PLAY_BENCHMARK_MODE
#error "Play: _PLAY_BENCHMARK_MODE needs the firmware's 300 Hz clock; not available with -D CPC_BAREMETAL"
#endif
#endif
#ifndef _PLAY_BENCHMARK_MODE
    sub fastcall _Play_AyWrite(reg as ubyte, value as ubyte)
        asm
            pop hl              ; return address
            pop bc              ; B = value
            ld c, b
            call .core.__CPC_AY_WRITE    ; (does not touch HL)
            jp (hl)
        end asm
    end sub
#else
    sub fastcall _Play_AyWrite(reg as ubyte, value as ubyte)
        asm
            pop hl
            pop bc
            ld c, b
            call .core.__CPC_AY_WRITE_DI
            jp (hl)
        end asm
    end sub
    dim _Play_BenchTicks as ulong

    ' The firmware's 300 Hz clock, KL_TIME_PLEASE (&BD0D): DEHL.
    function fastcall _Play_Ticks() as ulong
        asm
            call .core.__FW_CALL
            defw $BD0D
        end asm
    end function
#endif

#define _PLAY_WRITE_TO_REGISTER(register, value) _Play_AyWrite((register), (value))


' Main sub.
'
' Implementation notes:
'
' If you want to extend the inner subs or functions, or add new ones,
' please beware that the current compiler version (v1.19.0-beta7 at the time of writing)
' doesn't support accessing outer local vars from the inner sub/function,
' if the inner sub/function has its own vars or params.
'
' The readability of the code was in many ways sacrificed in favor of performance,
' which is necessary to achieve accurate timings.
'
' TODO: add sub variants that accept strings byref, and that accept an array.
' TODO: check valid ranges of command parameters, handle integer overflow/underflow
'
sub Play(channel0 as string, channel1 as string = "", channel2 as string = "")

    const CpuCyclesPerSecond as ulong = 4000000
    const CpuCyclesPerMicrotick as ubyte = 28  ' see the `Wait` sub
    const BeatsPerBar as ubyte = 4
    const SecondsPerMinute as ubyte = 60
    const ChannelCount as ubyte = 3

    const DefaultTempo as ubyte = 120
    const DefaultOctave as ubyte = 5
    const DefaultNoteLength as ubyte = 5
    const DefaultVolume as ubyte = 15
    const DefaultMixer as ubyte = %00111000  ' bits 6-7 must stay 0 on the CPC (see the header, change 4)
    const DefaultEnvelopeShape as ubyte = 0

    ' Special volume value that enables hardware envelope.
    const VolumeEnvelopeOn as ubyte = 16

    ' General processing overhead compensation. Applied to every `Wait` invocation.
    ' Determined experimentally (cpc: 1 microtick = 7 us). Play runs with interrupts off, so it can't be timed with
    ' the firmware clock; tests/stress/play_tempo.bas (cpcbuild repo) builds this file with _PLAY_BENCHMARK_MODE
    ' (interrupts on, same code), times 16 s tunes with KL_TIME_PLEASE and corrects for the interrupt handler's share
    ' of the time (about 12 %) with a reference loop of known cost. With 113 and 185 below, 3-channel crotchet,
    ' semiquaver and semibreve tunes at T60-T240 are within 0.2 % of the metronome (plus the one extra tick the
    ' loop runs at the end), one channel 0.4 % short (the empty channels' rest events cost less), and a tune full of
    ' V/O/&/_ commands 0.4 % long. Per tick the code takes about 790 us plus about 1300 us for every channel that
    ' processes a note.
    const TickGeneralOverheadInMicroticks as uinteger = 113

    ' Overhead compensation for commands processing of a single channel.
    ' Applied only on those ticks when there are commands processed for the channel.
    ' Determined experimentally (see above).
    const TickChannelCommandsOverheadInMicroticks as uinteger = 185

    ' Channel numbers are zero-based, because it's better in terms of performance (less arithmetics in runtime needed).
    const MaxChannel as ubyte = ChannelCount - 1

    ' Maximum nesting level for brackets.
    ' Initial level is 0. An opening bracket increases the level, a closing bracket decreases the level.
    const MaxNestingLevel as ubyte = 4

    ' Size of a single channel context in bytes. Don't forget to increase this if you add more context fields.
    ' Note: this is used in macro `_PLAY_CTX_NEXT_CHANNEL`.
    const ChannelContextSize as ubyte = 26

    ' Channel context data is stored here.
    dim ChannelContextBuffer(0 to ChannelContextSize * ChannelCount - 1) as ubyte

    ' Pointer to context data.
    ' Note: this is used in macro `_PLAY_CTX_FIRST_CHANNEL`.
    dim ChannelContextBufferPtr as uinteger
    ChannelContextBufferPtr = @ChannelContextBuffer(0)

    ' Offsets of fields in a channel context.
    ' If you add more fields, don't forget to increase `ChannelContextSize`.
    const _CharPtr         as ubyte = 0 ' (uinteger) Pointer to the current character in the channel string.
    const _StringEndPtr    as ubyte = 2 ' (uinteger) Pointer to the first byte after the last char of the channel
                                        '            string.
    const _TickBackCounter as ubyte = 4 ' (uinteger) How many ticks to wait before proceeding to the next command
                                        '            in the channel string. Zero means we need to proceed now.
    const _PrimaryNoteLengthInTicks as ubyte = 6 ' (uinteger) Current note length in ticks.
    const _ActualNoteLengthInTicks  as ubyte = 8 ' (uinteger) Actual note length in ticks.
                                                 '            Mostly the same as `_PrimaryNoteLengthInTicks`,
                                                 '            but may differ for triplets and ties.
    const _ResetNoteLengthBackCount as ubyte = 10 ' (ubyte) How many notes left to play before actual note length must
                                                  '         be reset to primary note length.
    const _BaseDividerIndex   as ubyte = 11 ' (ubyte) Divider index (see `_Play_NoteDividers`) that corresponds to
                                            '         note C of the current octave.
    const _SemitoneAdjustment as ubyte = 12 ' (byte)  How many semitones to add or subtract from the next note.
    const _FinishedFlag       as ubyte = 13 ' (ubyte) If nonzero, then the channel has finished playing.
    const _Volume             as ubyte = 14 ' (ubyte) Current volume.
                                            '         If equals to `VolumeEnvelopeOn`, the envelope generator is used.
    const _NestingLevel       as ubyte = 15 ' (ubyte) Current brackets nesting level.
    const _ReturnPtrs         as ubyte = 16 ' (uinteger * (MaxNestingLevel+1))
                                            '           Stack of pointers to return to on closing brackets.
                                            '           The zeroth element always points to the string start,
                                            '           for infinite repeat when there is an unpaired closing bracket.

    ' Current tempo as beats per minute. A 'beat' is a 1/4-length note.
    dim Tempo as ubyte

    ' Current tempo as microticks per tick.
    ' For 'microtick' definition, see the `CpuCyclesPerMicrotick` const.
    ' For 'tick' definition, see the `_Play_TicksPerBar` const.
    dim MicroticksPerTick as uinteger

    ' Current hardware envelope shape.
    ' See `_Play_EnvelopeShapes` for possible values.
    dim EnvelopeShape as ubyte

    dim LastChar as ubyte      ' Last char read by `ReadChar` sub.
    dim LastNumber as uinteger ' Last number read by `ReadNumber` sub.

    ' Reads a char from the current channel string and puts it to `LastChar` variable.
    ' Puts 0 if there's nothing left to read.
    ' This is a sub, not a function, for performance reasons.
    sub ReadChar
        if _PLAY_CTX_GET(uinteger, _CharPtr) = _PLAY_CTX_GET(uinteger, _StringEndPtr) then
            LastChar = 0
            return
        end if

        LastChar = peek(_PLAY_CTX_GET(uinteger, _CharPtr))
        _PLAY_CTX_ADD(uinteger, _CharPtr, 1)
    end sub

    ' Reads the number from the current channel string and puts it in `LastNumber` variable.
    ' Puts 0 if the number is unreadable.
    sub ReadNumber
        LastNumber = 0

        do
            ReadChar

            if LastChar >= code("0") and LastChar <= code("9") then
                LastNumber = LastNumber * 10 + LastChar - code("0")
            else
                ' The number has ended.
                if LastChar <> 0 then
                    ' Step back if the string has not ended.
                    _PLAY_CTX_ADD(uinteger, _CharPtr, -1)
                end if
                exit do
            end if
        loop
    end sub

    ' Sets octave for the current channel.
    sub SetOctave(octave as ubyte)
        _PLAY_CTX_SET(ubyte, _BaseDividerIndex, octave * _Play_NotesPerOctave)
    end sub

    ' Sets `MicroticksPerTick` according to the current `Tempo` value.
    sub UpdateMicroticksPerTick
        MicroticksPerTick = _
            CpuCyclesPerSecond * SecondsPerMinute * BeatsPerBar _
            / CpuCyclesPerMicrotick / _Play_TicksPerBar / Tempo
    end sub

    ' Waits for the given amount of microticks.
    ' One microtick is 28 CPU cycles of the 4 MHz clock, i.e. 7 us on the CPC: SBC HL,BC is 4 us and JR NZ (taken)
    ' 3 us, every instruction taking a whole number of 1 us units (if you change it, also change `CpuCyclesPerMicrotick`).
    ' TODO: is it possible to suppress the 'unused parameter' warning?
    sub fastcall Wait(microticks as uinteger)
        asm
            proc
            local loop

            ld bc, 1        ; bc = 1
            or a            ; reset carry flag
        loop:
            sbc hl, bc      ; microticks = microticks - bc       ; 15 cycles = 4 us on the CPC
            jr nz, loop     ; if microticks <> 0 then goto loop  ; 12 cycles = 3 us on the CPC

            endp
        end asm
    end sub

    ' Set tone pitch on the sound chip for a channel.
    sub SetChipTonePitchDivider(channel as ubyte, divider as uinteger)
        _PLAY_WRITE_TO_REGISTER(channel * 2, divider band $ff)
        _PLAY_WRITE_TO_REGISTER(channel * 2 + 1, divider >> 8)
    end sub

    ' Set pitch for noise generator of the sound chip.
    sub SetChipNoisePitchDivider(divider as ubyte)
        _PLAY_WRITE_TO_REGISTER(6, divider)
    end sub

    ' Set volume on the sound chip for a channel. A special value `VolumeEnvelopeOn` means use envelope generator.
    sub SetChipVolume(channel as ubyte, volume as ubyte)
        _PLAY_WRITE_TO_REGISTER(channel + 8, volume)
    end sub

    ' Sets envelope shape on the sound chip.
    ' See `_Play_EnvelopeShapes` for possible values.
    sub SetChipEnvelopeShape(shape as ubyte)
        _PLAY_WRITE_TO_REGISTER(13, shape)
    end sub

    ' Sets envelope period on the sound chip.
    sub SetChipEnvelopePeriod(period as uinteger)
        _PLAY_WRITE_TO_REGISTER(11, period band $ff)
        _PLAY_WRITE_TO_REGISTER(12, period >> 8)
    end sub

    ' Set mixer mode on the sound chip.
    ' Bits 0, 1, 2 - if zero, enable tone on channels A, B, C correspondingly
    ' Bits 3, 4, 5 - if zero, enable noise on channels A, B, C correspondingly
    ' Bits 6, 7 - i/o ports (forced to 0 here, see below).
    ' (cpc) Bits 6, 7 are always written as 0: on the CPC they are the I/O port directions and port A is the keyboard.
    sub SetChipMixer(value as ubyte)
        _PLAY_WRITE_TO_REGISTER(7, value band $3f)
    end sub

    ' If macro `_PLAY_BENCHMARK_MODE` is defined, then interrupts are not disabled, and the system timer is used to
    ' measure the duration of play. The duration in ticks (1/300 s) is printed on the screen after playing and left
    ' in `_Play_BenchTicks`.
    ' Note that interrupts add overhead and inaccuracies to timings, so this mode is not intended for fine-tuning
    ' timings. This should only be used for differential analysis of code optimization efficiency.
    ' (cpc) SOUND_RESET (firmware &BCA7) first, so the firmware sound manager is idle and stops writing the AY from the
    ' interrupt handler; then, unless benchmarking, interrupts off for the whole piece (every AY write is below).
    ' The firmware gate returns with interrupts on, so the `di` has to come after it.
    #ifdef CPC_BAREMETAL
    ' Bare-metal mode: no firmware sound manager; just silence the chip (volumes 0, mixer all off).
    asm
        call .core.__CPC_AY_SILENCE
    end asm
    #else
    asm
        call .core.__FW_CALL
        defw $BCA7
    end asm
    #endif

    #ifndef _PLAY_BENCHMARK_MODE
        asm
            di
        end asm
    #endif

    _PLAY_CTX_FIRST_CHANNEL()
    _PLAY_CTX_SET(uinteger, _CharPtr, @channel0)

    _PLAY_CTX_NEXT_CHANNEL()
    _PLAY_CTX_SET(uinteger, _CharPtr, @channel1)

    _PLAY_CTX_NEXT_CHANNEL()
    _PLAY_CTX_SET(uinteger, _CharPtr, @channel2)

    dim channel as ubyte
    dim strLen as uinteger
    dim ptr as uinteger

    _PLAY_CTX_FIRST_CHANNEL()

    for channel = 0 to MaxChannel
        ' We need low-level access to the strings to achieve good performance.

        ' dereference the pointer to the heap
        ptr = peek(uinteger, _PLAY_CTX_GET(uinteger, _CharPtr))

        ' read the string length
        strLen = peek(uinteger, ptr)

        ' adjust the pointer so it points to the first char
        ptr = ptr + 2

        ' store pointers to the string start and end
        _PLAY_CTX_SET(uinteger, _CharPtr, ptr)
        _PLAY_CTX_SET(uinteger, _ReturnPtrs + 0, ptr)
        _PLAY_CTX_SET(uinteger, _StringEndPtr, ptr + strLen)

        SetOctave DefaultOctave
        _PLAY_CTX_SET(ubyte, _Volume, DefaultVolume)
        _PLAY_CTX_SET(uinteger, _PrimaryNoteLengthInTicks, _Play_NoteLengthsInTicks(DefaultNoteLength))
        _PLAY_CTX_SET(uinteger, _ActualNoteLengthInTicks, _Play_NoteLengthsInTicks(DefaultNoteLength))
        _PLAY_CTX_SET(uinteger, _TickBackCounter, 0)
        _PLAY_CTX_SET(byte, _SemitoneAdjustment, 0)
        _PLAY_CTX_SET(ubyte, _ResetNoteLengthBackCount, 0)
        _PLAY_CTX_SET(ubyte, _FinishedFlag, 0)
        _PLAY_CTX_SET(ubyte, _NestingLevel, 0)

        _PLAY_CTX_NEXT_CHANNEL()
    next channel

    EnvelopeShape = DefaultEnvelopeShape
    Tempo = DefaultTempo
    UpdateMicroticksPerTick
    SetChipMixer DefaultMixer

    dim processedChannels as ubyte
    dim finishedChannels as ubyte
    dim lengthInTicks as uinteger
    dim dividerIndex as ubyte
    dim nestingLevel as ubyte
    dim returnPtr as uinteger
    dim returnPtrOffset as uinteger
    dim halt as ubyte = 0
    dim volume as ubyte
    dim mustInitEnvelope as ubyte

    #ifdef _PLAY_BENCHMARK_MODE
        dim startTime as ulong = _Play_Ticks()
    #endif

    do
        finishedChannels = 0
        processedChannels = 0
        mustInitEnvelope = 0

        _PLAY_CTX_FIRST_CHANNEL()

        for channel = 0 to MaxChannel
            if _PLAY_CTX_GET(uinteger, _TickBackCounter) = 0 then
                do
                    ReadChar

                    if LastChar = 0 then
                        ' This channel has finished playing.
                        _PLAY_CTX_SET(ubyte, _FinishedFlag, 1)
                        ' While other channels are still playing, this one will do rests.
                        SetChipVolume channel, 0
                        exit do

                    else if LastChar = code("&") then
                        SetChipVolume channel, 0
                        exit do

                    else if (LastChar >= code("a") and LastChar <= code("g")) _
                        or (LastChar >= code("A") and LastChar <= code("G")) then

                        dividerIndex = _PLAY_CTX_GET(ubyte, _BaseDividerIndex)

                        if LastChar >= code("a") then
                            ' if lowercase, then transpose down 1 octave and make uppercase
                            dividerIndex = dividerIndex - _Play_NotesPerOctave
                            LastChar = LastChar - 32
                        end if

                        dividerIndex = dividerIndex + _
                            _Play_NoteIndexes(LastChar) + _PLAY_CTX_GET(byte, _SemitoneAdjustment)

                        _PLAY_CTX_SET(byte, _SemitoneAdjustment, 0)

                        SetChipTonePitchDivider channel, _Play_NoteDividers(dividerIndex)

                        if channel = 0 then
                            ' Channel A pitch also defines noise generator pitch.
                            ' The formula taken from ROM disassembly.
                            ' Note: this affects all channels which have noise enabled.
                            SetChipNoisePitchDivider ((bnot dividerIndex) band $7f) >> 2
                        end if

                        volume = _PLAY_CTX_GET(ubyte, _Volume)
                        SetChipVolume channel, volume

                        if volume = VolumeEnvelopeOn then
                            ' If volume envelope is enabled on any channel, we need to re-initialize volume shape
                            ' on sound chip on every note start, for the envelope to start when the note starts.
                            ' Note that this affects all channels at once, but this is the limitation of hardware.
                            mustInitEnvelope = 1
                        end if

                        exit do

                    else if LastChar = code("$") then
                        _PLAY_CTX_ADD(byte, _SemitoneAdjustment, -1)

                    else if LastChar = code("#") then
                        _PLAY_CTX_ADD(byte, _SemitoneAdjustment, 1)

                    else if LastChar >= code("0") and LastChar <= code("9")
                        _PLAY_CTX_ADD(uinteger, _CharPtr, -1)  ' step back
                        ReadNumber
                        lengthInTicks = _Play_NoteLengthsInTicks(LastNumber)

                        _PLAY_CTX_SET(uinteger, _ActualNoteLengthInTicks, lengthInTicks)

                        if LastNumber >= 10 then
                            ' triplet mode (temporary length)
                            _PLAY_CTX_SET(ubyte, _ResetNoteLengthBackCount, 3)
                        else
                            _PLAY_CTX_SET(uinteger, _PrimaryNoteLengthInTicks, lengthInTicks)
                        end if

                    else if LastChar = code("_") then
                        ' TODO: ties with triplets work differently in Sinclair ROM.
                        ReadNumber
                        lengthInTicks = _Play_NoteLengthsInTicks(LastNumber)

                        _PLAY_CTX_SET(ubyte, _ResetNoteLengthBackCount, 1)
                        _PLAY_CTX_ADD(uinteger, _ActualNoteLengthInTicks, lengthInTicks)
                        _PLAY_CTX_SET(uinteger, _PrimaryNoteLengthInTicks, lengthInTicks)

                    else if LastChar = code("(") then
                        nestingLevel = _PLAY_CTX_GET(ubyte, _NestingLevel)

                        if nestingLevel < MaxNestingLevel then
                            nestingLevel = nestingLevel + 1
                            returnPtrOffset = _ReturnPtrs + nestingLevel * 2
                            _PLAY_CTX_SET(ubyte, _NestingLevel, nestingLevel)
                            _PLAY_CTX_SET(uinteger, returnPtrOffset, _PLAY_CTX_GET(uinteger, _CharPtr))
                        end if

                    else if LastChar = code(")") then
                        nestingLevel = _PLAY_CTX_GET(ubyte, _NestingLevel)
                        returnPtrOffset = _ReturnPtrs + nestingLevel * 2
                        returnPtr = _PLAY_CTX_GET(uinteger, returnPtrOffset)

                        if returnPtr = 0 then
                            ' already repeated - decrease nesting level
                            nestingLevel = nestingLevel - 1
                            _PLAY_CTX_SET(ubyte, _NestingLevel, nestingLevel)
                        else
                            ' return to the repeat point
                            _PLAY_CTX_SET(uinteger, _CharPtr, returnPtr)

                            ' clear return pointer unless it is zero level (in which case we loop infinitely)
                            if nestingLevel > 0 then
                                _PLAY_CTX_SET(uinteger, returnPtrOffset, 0)
                            end if
                        end if

                    else if LastChar = code("O") then
                        ReadNumber
                        SetOctave LastNumber

                    else if LastChar = code("V") then
                        ReadNumber
                        _PLAY_CTX_SET(ubyte, _Volume, LastNumber)

                    else if LastChar = code("U") then
                        _PLAY_CTX_SET(ubyte, _Volume, VolumeEnvelopeOn)

                    else if LastChar = code("X") then
                        ReadNumber
                        SetChipEnvelopePeriod LastNumber

                    else if LastChar = code("W") then
                        ReadNumber
                        EnvelopeShape = _Play_EnvelopeShapes(LastNumber)

                    else if LastChar = code("M") then
                        ReadNumber
                        ' invert the bits and push directly to the chip
                        SetChipMixer bnot LastNumber

                    else if LastChar = code("T") then
                        ReadNumber

                        if channel = 0 then
                            Tempo = LastNumber
                            UpdateMicroticksPerTick
                        end if

                    else if LastChar = code("H") then
                        halt = 1
                        exit for

                    ' TODO: process other commands here
                    end if
                loop

                if _PLAY_CTX_GET(ubyte, _ResetNoteLengthBackCount) > 0 then
                    _PLAY_CTX_ADD(ubyte, _ResetNoteLengthBackCount, -1)
                else
                    _PLAY_CTX_SET(uinteger, _ActualNoteLengthInTicks, _PLAY_CTX_GET(uinteger, _PrimaryNoteLengthInTicks))
                end if

                _PLAY_CTX_SET(uinteger, _TickBackCounter, _PLAY_CTX_GET(uinteger, _ActualNoteLengthInTicks))

                processedChannels = processedChannels + 1
            end if

            _PLAY_CTX_ADD(uinteger, _TickBackCounter, -1)

            finishedChannels = finishedChannels + _PLAY_CTX_GET(ubyte, _FinishedFlag)

            _PLAY_CTX_NEXT_CHANNEL()
        next channel

        if mustInitEnvelope then
            SetChipEnvelopeShape EnvelopeShape
        end if

        if halt then
            for channel = 0 to MaxChannel
                SetChipVolume channel, 0
            next channel
            exit do
        end if

        Wait MicroticksPerTick _
            - TickGeneralOverheadInMicroticks _
            - TickChannelCommandsOverheadInMicroticks * processedChannels
    loop until finishedChannels = ChannelCount

    #ifdef _PLAY_BENCHMARK_MODE
        _Play_BenchTicks = _Play_Ticks() - startTime
        print "Play duration: "; _Play_BenchTicks; " ticks (1/300 s)."
    #endif

    asm
        ei
    end asm
end sub

#ifndef CPC_BAREMETAL
#require "fwcall.asm"
#endif
#require "ay.asm"

#pragma pop(explicit)
#pragma pop(strict)
