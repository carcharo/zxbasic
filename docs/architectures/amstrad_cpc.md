# Amstrad CPC

`--arch cpc` compiles a Boriel BASIC program (the ZX dialect, not Locomotive
BASIC) into a Z80 binary for the Amstrad CPC 464, 664 and 6128. The compiled
program runs on top of the CPC firmware: text, graphics, keyboard and sound
go through the firmware jumpblock (&BB00-&BDxx), and the runtime only touches
the hardware directly where the firmware has no equivalent (the keyboard
matrix scan and the sound chip in the optional libraries, the palette for
instant colour changes).

The architecture is tested in emulators (Caprice32 and floooh/chips) on the
464 (with a disc drive), 664 and 6128. It uses only firmware entries that all
three models have. The CPC Plus machines are not a target yet.

This page describes the target. The platform library built on top of it
(sprites, tiles, double buffering, keyboard matrix, palette) is called
cpcbuild and is documented in its own repository, `cpcbuild/docs/library.md`.

## Building and running

```sh
zxbc --arch cpc -o prog.bin prog.bas
python3 tools/cpc/mkdsk.py -o prog.dsk --load 0x1000 --exec 0x1000 --name PROG.BIN prog.bin
```

The output is a flat binary that expects to be loaded and started at &1000
(`--org`, default 4096). `-f bin` is the format to use; the `.tap`, `.tzx`,
`.sna` and `.z80` outputs are Spectrum formats and mean nothing here.
`tools/cpc/mkdsk.py` (pure Python, standard library only) prepends the 128-byte
AMSDOS header and writes a standard CPCEMU `.dsk` in AMSDOS data format. On the
CPC, or in an emulator with the disc inserted:

```
RUN"PROG
```

AMSDOS names are 8.3, upper case. Starting a binary with `RUN"` never returns
to BASIC (see "END" below).

`tools/cpc/run.sh` does all of this and starts Caprice32:

```sh
tools/cpc/run.sh prog.bas [extra zxbc arguments]
tools/cpc/run.sh prog.bin                 # an existing binary
CPC_MODEL=464 tools/cpc/run.sh prog.bas   # 464 (with DDI-1 disc ROM), 664 or 6128 (default)
tools/cpc/run.sh --shot prog.bas          # headless; one screenshot in build/shots/
```

Output goes to `build/` in the current directory. The emulator is taken from
`$CAP32`, by default `../caprice32/cap32` next to the repository. With `--shot`
the emulator runs with `SDL_VIDEODRIVER=dummy`; `SHOT_DELAYS=n` sets how many
short waits come before the screenshot (default 6). The run name is
truncated to eight characters.

### Compiler options

| Option | Effect on cpc |
|---|---|
| `-S`, `--org` | Start address. Default &1000. Must match `--load`/`--exec` given to `mkdsk.py`. |
| `-H`, `--heap-size` | Heap size in bytes (default 4768). |
| `--heap-address` | Heap address. Default: just below the private block, `&9E00 - heap size`. |
| `--enable-break` | Check for ESC (key 66) at every line. See "Input". Not supported together with the Play library. |
| `-D name[=value]` | Preprocessor define. |
| `-N`, `--zxnext`, `#pragma zxnext` | Compile error: the CPC's Z80 cannot run Z80N opcodes. |

The compiler always defines `__CPC__` (every architecture defines
`__<ARCH>__`), so a source can test `#ifdef __CPC__`. The cpc standard library
files fail with `#error` unless it is defined.

`-D __CPC_PRINTER_ECHO__` is a test option: it copies everything PRINT sends to
the screen to the printer port, makes runtime errors skip their key wait and
makes END print a marker line. It is used by the test runner to capture output
in an emulator.

## Memory map

| Range | Use |
|---|---|
| &0000-&003F | Firmware restart vectors. The runtime writes only &0030 (RST 6, the floating-point calculator entry) and &0038 (the interrupt front-end). |
| &0040-&0FFF | Unused. |
| &1000 up | Code and constant data (the `.bin`). May run past &4000. |
| up to &9DFF | Heap, top-aligned below the private block (default start &8B60). Not part of the binary. |
| &9E00-&A1FF | Private runtime block (1 KB): relocated system variables, firmware gate state, floating-point workspace, library state, sound block. |
| &A200-&A5FF | Stack (1 KB). SP starts at &A600. Below it is the private block, and there is no overflow check. |
| &A600-&A67B | Slack, below the boot HIMEM with AMSDOS (&A67B). |
| &A67C-&B0FF | AMSDOS workspace. Not ours. |
| &B100-&BFFF | Firmware variables, jumpblocks and firmware stack. |
| &C000-&FFFF | Screen. |

The compiled code and data must end below &9E00, and below the heap if the
program uses one; `zxbc` stops with an error when they do not
(`compiled code+data ends at 0x....`, `past this architecture's memory limit of
0x9E00`, or a heap overlap error). With the default heap that leaves about
30.8 KB (&1000-&8B5F) for code and data.

The constants are in one place, `src/arch/cpc/backend/main.py`, and the
prologue emits them as `.core.CPC_PRIV_BASE`, `CPC_PRIV_SIZE`, `CPC_STACK_TOP`
and `CPC_MEM_TOP`.

**Reserved &4000-&7FFF.** A program that calls the cpcbuild library's
`EnableDoubleBuffer` gets the label `.core.__CB_DBUF_RESERVED`, which makes
the compiler reserve &4000-&7FFF for the second screen. Code and data must
then fit in &1000-&3FFF (12 KB) and the heap must lie above &7FFF, or the
build fails with `compiled code+data ... overlaps 0x4000-0x7FFF, reserved
because the program uses double buffering`. Other programs are unaffected.
Backends declare such ranges with `RESERVED_RANGE_LABELS`, checked in
`check_memory_layout` in `zxbc.py`.

**Central 32K.** While the firmware runs, the lower ROM (&0000-&3FFF) and, for
some calls, the upper ROM (&C000-&FFFF) are paged in for reading. Anything the
firmware reads through a pointer, and the stack, must therefore be in
&4000-&BFFF. The heap, the private block and the stack are. Code and
constants below &4000 are fine to execute, but the runtime copies pointer
arguments that may live there before handing them to the firmware.

## Runtime model

**Firmware first.** The runtime calls the firmware for everything it can, so
the firmware's own state (cursor, pens, palette, windows) stays consistent
with what the program sees.

**The firmware gate.** The firmware needs BC' (the Gate Array port and the
ROM/mode configuration) and AF' carry (clear, or the interrupt handler thinks
it is nested) to hold its own values on every call and every interrupt.
Compiled code uses the alternate registers freely (every SUB epilogue, 32-bit
and floating-point code, the calculator). So every firmware call goes through
`.core.__FW_CALL`:

```
    call .core.__FW_CALL
    defw $BB5A              ; TXT_OUTPUT
```

Registers A, F, BC, DE and HL go in as set and come back as the firmware left
them. The gate restores the firmware's BC', clears AF' carry, enables
interrupts for the call, then captures BC' again (mode and ROM changes) and
returns with interrupts on. It clobbers BC', DE', HL' and AF' and costs about
220 T-states plus the routine. `.core.__FW_CALL_IX` also saves IX: use it for
CAS_* and AMSDOS entries, which corrupt IX (Boriel's frame pointer).

**Interrupts are always on.** The runtime points the RAM vector at &0038 to
its own front-end (`isr.asm`) before the first firmware call. The front-end
saves both register banks, loads the firmware's BC' and a clear AF' carry,
runs the firmware's 300 Hz handler (found from the original vector, so it
works on every model), keeps any change it made to BC' and restores
everything. Inside a gate call it jumps straight to the firmware's handler.
The RAM vector is only seen while the lower ROM is off, which is whenever
program code runs. The firmware's clock, key buffer, sound queue and events
therefore keep running during compiled code. Cost: about 12 % of the CPU in
all (about 2 % is the front-end, the rest the firmware's own work), more with
sound envelopes playing (up to about 23 % measured with three channels).

**Frame hook and game mode (optional, `#include <framehook.bas>`).**

| Call | What it does |
|---|---|
| `FrameHook(addr)` | the machine-code routine at `addr` runs once per frame, at the frame flyback |
| `FrameHookOff()` | stops it |
| `Frames()` | frames since the program started (`ULONG`) |
| `GameMode(1)` / `GameMode(0)` | game mode on / off |

The hook runs in every mode, also while the program waits inside a firmware
call (WaitRetrace, PRINT), exactly once per frame. It runs with interrupts off
and all registers (including IX, IY and the alternate bank) saved, so it may
use any of them; it must not call the firmware (the gate turns interrupts on),
PRINT, or use floats or strings. Write it in asm and pass its address, e.g. a
BASIC label in front of an `ASM` block (`FrameHook(@myhook)`). It is a
firmware frame-flyback event with a far address and ROM select &FF, so it can
live anywhere in the program.

Game mode makes interrupts outside firmware calls skip the firmware's handler:
the interrupt load drops from about 14.5 % to about 3.3 % of the CPU (busy-loop
measurement). While in game mode and not inside a firmware call, the
firmware's key buffer (INKEY$), its 300 Hz clock, its sound queue (BEEP,
`SoundQueue`) and its ink refresh stop; firmware calls themselves still work.
Use a direct keyboard scan, `Frames()` and the hook instead. The cpcbuild
library's music player runs on this hook
([library reference](https://github.com/carcharo/cpcbuild/blob/main/docs/library.md),
section 7.8).

**Rules for inline `asm`:**

1. Call the firmware only through `.core.__FW_CALL` (or `__FW_CALL_IX`). Never
   `call` a jumpblock address directly, never use `rst` to reach the firmware.
2. Nothing live below SP. An interrupt can push onto the stack at any point,
   so code that uses `inc sp`/`dec sp` pairs, `ld sp` tricks or data below SP
   is wrong (the inherited zx48k `swap32.asm` was, and is overridden). Pushing
   and popping is fine.
3. Keep IX. It is the frame pointer of the enclosing SUB or FUNCTION. IY is
   not used by compiled code.
4. Do not rely on the alternate registers surviving a gate call. They survive
   interrupts.
5. Direct access to the PPI (keyboard, sound chip), Gate Array or CRTC must run
   inside `di` ... `ei`, because the firmware's interrupt handler uses them
   too. Use plain `di`/`ei` and return with interrupts on; do not save and
   restore the interrupt state with `ld a,i` (it misreports on NMOS Z80s).
   Do not call such routines from code that already has interrupts off.
   Leave the PPI as the firmware expects (control word &82).
6. Firmware event routines (KL_NEW_FRAME_FLY and the like), and any block or
   table the firmware reads through a pointer, must be in &4000-&BFFF. Event
   routines are called with the lower ROM on, so they cannot live in
   program code at &1000-&3FFF.
7. Do not write to &0030 or &0038.

**END.** `RUN"` never returns to BASIC, so there is nothing to return to. END
waits for a key (so the last screen stays visible) and then resets the machine
(`rst 0`), which gives the BASIC Ready prompt. A runtime error prints
`Error n` on a fresh line (n is the same code as on the Spectrum), waits for a
key and resets the same way. Division by zero is error 5.

**Load and save.** LOAD, SAVE and VERIFY are not implemented: the runtime
entry points are stubs that stop the machine (`di`, `halt`).

## Screen and text

The program starts in MODE 1 with INK 7, PAPER 0, which is the CPC's own pen 1
on pen 0 (yellow on blue with the default palette). The text screen is the
CPC's own size, not the Spectrum's:

| Mode | Pixels | Pens | Text columns |
|---|---|---|---|
| 0 | 160 x 200 | 16 | 20 |
| 1 | 320 x 200 | 4 | 40 |
| 2 | 640 x 200 | 2 | 80 |

All modes have 25 text rows. `PRINT AT row, col` takes row 0-24 and column 0 to
the mode's width minus 1; the runtime converts to the firmware's 1-based
coordinates. The comma moves to the next half-screen zone and TAB works modulo
the screen width. Text that reaches the bottom scrolls (the firmware scrolls
with the CRTC start address, not by copying).

`Mode n` (in `cpc.bas`, `#include <cpc.bas>`) switches mode and clears the
screen to the current PAPER. `SetInk pen, colour` and `SetBorder colour` take
the firmware's colour numbers 0-26 and change the palette at once.

**INK, PAPER, BORDER** take the Spectrum colours 0-7. They are mapped to the
pen of the current mode whose firmware default colour is nearest:

| Spectrum colour | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| Mode 0 pen | 5 | 6 | 3 | 7 | 12 | 2 | 1 | 4 |
| Mode 1 pen | 0 | 0 | 3 | 3 | 2 | 2 | 1 | 1 |
| Mode 2 pen | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 |

`BORDER c` shows the current colour of the pen that `PAPER c` would use. The
mapping changes what is drawn, not the palette; for other colours change the
palette with `SetInk`. INVERSE swaps pen and paper. BRIGHT, FLASH, BOLD and
ITALIC are accepted and have no effect.

**Characters.** Text uses the CPC's character set, so some glyphs (pound,
copyright) differ from the Spectrum's. Codes 128-143 (the Spectrum's block
graphics) print as the CPC's quadrant characters; the runtime swaps the bit
pairs so `CHR$ 129` shows the same picture as on the Spectrum. Codes below 32
are Boriel's embedded control codes (AT, INK, PAPER, ...) and are translated;
they never reach the firmware raw.

**UDGs.** `USR "a"` returns the address of a table for characters 144-255
(896 bytes), taken from the heap at start-up, only in programs that use
`USR "a"`; `POKE USR "a" + n, ...` and `PRINT CHR$ 144` work as on the
Spectrum. The UDGs start as the CPC's own glyphs 144-164 and not as copies of
A-U. If the heap cannot supply the table the program stops with error 3. The
firmware requires its character table to lie in &4000-&BFFF and to run from its
first character to 255, which is why the table is that large.

**Font.** `#include <font.bas>` and `SetFont @font` replace the glyphs of
characters 32-127 with 768 bytes in the Spectrum's font format (the first call
takes 1792 bytes of heap). `CHARS` holds the table address minus 256 as on the
Spectrum, but programs that `POKE CHARS` at 23606 do not work: that address is
program memory here. Use `SetFont`.

**SCREEN$** (`screen.bas`) reads a character cell with the firmware
(TXT_RD_CHAR). It returns `""` for an unrecognisable cell or an off-screen
position. UDGs are recognised and return their code. Colours matter, unlike on
the Spectrum: cells printed in the current colours, or with only INK or only
PAPER changed, read correctly; with both changed the firmware misreads the cell
(a space on the 6128, a solid block on the 464).

**Graphics.** PLOT, DRAW, CIRCLE and POINT use the current mode's pixels with
the origin at the bottom-left, y up: 320 x 200 in mode 1 (so Spectrum code
drawing in 256 x 176 works unchanged), 160 x 200 in mode 0, 640 x 200 in mode 2.
Coordinates are 16-bit signed on this architecture (the Spectrum architectures
cast them to a byte). The runtime scales them to the firmware's 640 x 400
virtual units. Points outside the screen are clipped silently; the Spectrum
stops with an error. The graphics pen is the temporary INK (the PAPER under
INVERSE 1). `OVER 1` makes PLOT, DRAW and CIRCLE XOR with the screen (the
firmware's XOR write mode); it has no effect on text. Pixels are not square
in modes 0 and 2, so circles are stretched (mode 0) or squashed (mode 2).
CIRCLE plots every pixel once, so a circle drawn twice with OVER 1 erases
itself. `DRAW dx, dy, angle` draws an arc as straight segments of 4-8 pixels,
and a radius-50 semicircle takes about 0.25 s. `POINT(x, y)` returns the pen of
the pixel (0 off the screen), not 0 or 1; with the default colours the paper is
pen 0, so `IF POINT(x, y) THEN` still works. POINT leaves the graphics cursor
where it was.

Not supported: ATTR and attribute access (the CPC has no attribute memory),
BRIGHT and FLASH (ignored), `print42.bas` and `print64.bas` (they write
Spectrum screen memory; use mode 2 for 80 columns), and POKE/PEEK of Spectrum
screen or system variable addresses.

## Input

`INKEY$` reads the firmware's key buffer (`KM_READ_CHAR`): the CPC's own
buffered model, like Locomotive BASIC. A key pressed once is returned once, and
a held key repeats at the firmware's repeat rate. This differs from the
Spectrum, where INKEY$ returns the key held now. The codes are the CPC's:
RETURN 13, DEL 127, cursor keys 240-243 (up, down, left, right). The key buffer
is emptied at start-up so the RETURN that started the program is not seen.
Because interrupts are always on, the buffer fills during compiled code.

`INPUT(maxchars)` from `input.bas` is a function, as in zx48k:
`a$ = INPUT(20)`. It reads with the firmware, shows the firmware's cursor,
handles DEL and RETURN, and erases the typed text when RETURN is pressed.

`PAUSE n` waits n frames (1/50 s) or until a key is pressed; `PAUSE 0` waits for
a key. The key that ends a pause is put back in the buffer for INKEY$.

With `--enable-break`, ESC (key 66) raises the break error. It is seen within a
few loop iterations.

Games that need several keys at once, or the joystick, should use the cpcbuild
library's `ScanKeys` and `KeyDown`, which read the keyboard matrix directly.

## Sound

**BEEP** has the Spectrum's arguments (duration in seconds, pitch in semitones
from middle C). The compiler converts constant arguments to the firmware's
units (`src/arch/cpc/beep.py`), the runtime converts others on the calculator.
The note is queued on channel A at full volume, and BEEP waits until it ends,
as on the Spectrum. The tone period is `62500 / frequency` (the AY runs at
1 MHz), so middle C is 239. A duration of 0 plays nothing.

**Firmware sound calls** (`cpc.bas`) queue notes without waiting, so the
program carries on while they play: `SoundQueue`, `SoundFree`, `SoundBusy`,
`SoundEnvelope` and `SoundStop`. The sound manager plays from the interrupt
handler, which is always running. Each channel holds one playing note and four
queued. On the 464 (firmware 1.0) a note without a volume envelope takes
volumes 0-7 only, doubled; `SoundQueue` converts the requested 0-15 volume so
that every model sounds the same, to the nearest even volume the 464 can play
(15 plays as 14).

**Direct AY access.** `AyWrite reg, value` and `AyRead(reg)` use the PPI
directly, with interrupts off for the access (about 58 us per write). Keep
bits 6-7 of register 7 clear: bit 6 makes the keyboard port an output and the
keyboard stops reading.

**Play** (`play.bas`) is Boriel's Play library for the AY with the changes for
the CPC listed in its header: AY writes through the PPI, dividers for the 1 MHz
AY clock, timing for the CPC (tempo within 0.6 % in tests), and a mixer value
that keeps register 7 bit 6 clear. Play runs its whole tune with interrupts
off, so the keyboard and the firmware clock stop until it returns.

**Music and sound effects (Arkos Tracker).** The cpcbuild library includes an
interrupt-driven music player (Arkos Tracker 3.7, MIT licensed) that plays songs
and sound effects from the frame hook. The player is built into `<music/music.bas>`
in the cpcbuild repository; it is not part of the compiler fork. See
[cpcbuild's library reference](https://github.com/carcharo/cpcbuild/blob/main/docs/library.md) section 7.9.

**One owner of the sound chip.** Either the firmware sound manager (BEEP,
`SoundQueue`), the music player, or direct access (`AyWrite`, Play) owns the AY
at any one time, never more than one. The music player calls `SoundStop` so the
manager is idle. After using Play or AyWrite, call `SoundStop` before going
back to BEEP or `SoundQueue`, and never queue firmware sounds while another owner
is in use. After Play returns, BEEP works again.

## Floating point

FLOAT is the Spectrum's five-byte format. The arithmetic runs on a software
reimplementation of the Spectrum ROM calculator (`fp_calc.asm`, taken over
from the zx81sd port) entered through RST 6 (&0030), because the firmware's own
floating-point routines use a different format and the CPC's RST 5 (&0028)
belongs to the firmware.

* **Speed.** Floating point is the slow part of the target. Measured against
  Locomotive BASIC 1.1 on a 6128, a loop of `SQR(i) * SIN(i) + i / 3` takes
  about three times as long compiled as interpreted; `+ - * /` cost about the
  same as Locomotive's, SIN, COS, EXP and ATN about three times as much, SQR
  four times and LN five. SQR alone is about 112 ms and SIN about 43 ms.
  (Measured before interrupts were always on; add about 12 %.) Integer and
  fixed-point code is 12 to 52 times faster than Locomotive, so use those
  for anything that must be quick.
* **Text format.** PRINT and STR$ of a FLOAT print the sign, the integer part and
  up to five decimals, rounded half away from zero, with trailing zeros removed.
  There is no exponent notation: very large numbers print as long digit
  strings, and very small ones print as 0 once they round below five decimals.
  A constant expression folded by the compiler (`STR$(SIN(PI/6))`) keeps full
  precision and can differ from the same expression evaluated at run time.
* **VAL** accepts one numeric literal (sign, digits, optional decimal point and
  digits) and stops at the first other character. It does not evaluate
  expressions: `VAL("2+2")` does not work.

## Differences from zx48k

| Area | zx48k | cpc |
|---|---|---|
| Default ORG | 32768 | 4096 (&1000) |
| Heap | 4768 bytes after the code, in the binary | 4768 bytes just below &9E00, not in the binary |
| Output | `.bin`, `.tap`, `.tzx`, `.sna`, `.z80` | `.bin`; package with `tools/cpc/mkdsk.py` |
| Program exit | Returns to BASIC | Waits for a key, then resets |
| Text screen | 32 x 24, attributes | 20/40/80 x 25 by mode, per-pixel pens |
| Pixel screen | 256 x 176 for PLOT | 160/320/640 x 200, origin bottom-left |
| PLOT/CIRCLE coordinates | byte | 16-bit signed |
| Off-screen PLOT/DRAW | Error | Clipped silently |
| INK/PAPER | Attributes 0-7 | Mapped to pens of the mode |
| BRIGHT, FLASH | Attribute bits | Ignored |
| OVER 1 | XOR for text and graphics | XOR for graphics only |
| ATTR, `attr.bas` | Works | Compile error |
| `print42.bas`, `print64.bas`, `sinclair.bas` | Work | Compile error |
| POINT | 0 or 1 | The pixel's pen |
| SCREEN$ | Ignores colours | Colour-sensitive (see above) |
| INKEY$ | Key held now | Buffered key codes |
| BEEP | ULA, blocks, interrupts off | AY through the firmware, blocks, interrupts on |
| Interrupts | Spectrum's IM 1 | Firmware's 300 Hz handler, always on |
| Float text | PRINT-FP, with exponent | Fixed, 5 decimals, no exponent |
| VAL | Evaluates expressions | One numeric literal |
| LOAD, SAVE | Tape | Not implemented |
| UDG table | Always present, copies of A-U | Only with `USR "a"`, CPC glyphs |
| System variables | At 23552 (&5C00) | Private block at &9E00; &5C00 is program memory |
| Error report | Report code at the bottom | `Error n`, then key, then reset |

## Unsupported features and compile errors

| Feature | Result |
|---|---|
| `-N`, `--zxnext`, `#pragma zxnext = true` | `error: zxnext (Z80N opcodes) is not available on --arch cpc: the CPC's Z80 can't run them` |
| `#include <attr.bas>` (ATTR, SETATTR, ATTRADDR) | `#error`: the CPC has no colour attributes; use INK/PAPER, and POINT from `point.bas` |
| `#include <print42.bas>`, `<print64.bas>` | `#error`: they write Spectrum screen memory; use mode 2 for 80 columns |
| `#include <sinclair.bas>` | `#error`: it bundles Spectrum-only libraries; include `point.bas`, `input.bas` or `alloc.bas` directly |
| `#include <cpc.bas>`, `<cpcbuild.bas>` on another architecture | `#error` |
| Code and data past &9E00, or into a reserved range | Build error (exit code 5) |
| LOAD, SAVE, VERIFY | Compiles; the program stops at run time |
| USR with a Spectrum ROM address, POKE of Spectrum system variables | Compile fine; meaningless on the CPC |

Other zx48k standard library files are found through the inheritance fallback
(`ARCH_PARENTS`: cpc falls back to zx48k) and are not specifically tested on
the CPC. Those that write Spectrum screen memory or attributes, read Spectrum
ports or system variables, or use the Spectrum ROM (for example `putchars.bas`,
`puttile.bas`, `scroll.bas`, `keys.bas`, the `SP/` routines) do not work.

## Standard library files for cpc

Files in `src/lib/arch/cpc/stdlib/`:

| File | Purpose |
|---|---|
| `cpc.bas` | `Mode`, `GetMode`, `SetInk`, `SetBorder`, `WaitVsync`, `AyWrite`, `AyRead`, and the firmware sound calls `SoundQueue`, `SoundFree`, `SoundBusy`, `SoundEnvelope`, `SoundStop`. |
| `framehook.bas` | `FrameHook(addr)`, `FrameHookOff()`, `Frames()`, `GameMode(on)`: an interrupt-driven frame hook (machine code that runs once per frame with interrupts off and registers saved) and opt-in game mode (firmware interrupt work off outside firmware calls). |
| `cpcbuild.bas` | The cpcbuild library: includes the six files below. |
| `cpcbuild/display.bas` | Frame sync, double buffering, `PokeScreen`, `PeekScreen`. |
| `cpcbuild/sprites.bas` | `PutSprite`, `PutSpriteMasked`, `GetBlock`, clipped. |
| `cpcbuild/fill.bas` | `PenByte`, `FillRect`, `ClearScreen`. |
| `cpcbuild/tiles.bas` | 8x8 tiles and tile maps: `SetTileSet`, `DoTile8`, `DoTile16`, `TileMap`, `TileMapPart`, `TileRestore`. |
| `cpcbuild/keyboard.bas` | Direct keyboard matrix scan: `ScanKeys`, `KeyDown`, `AnyKeyDown`, `KEY_*` and `JOY_*` constants. |
| `cpcbuild/palette.bas` | `SetPalette`, `PalUpload`. |
| `font.bas` | `SetFont`: replaces the glyphs of characters 32-127. |
| `input.bas` | `INPUT(maxchars)` on the firmware keyboard. |
| `play.bas` | MML Play for the AY, adapted to the CPC. |
| `point.bas` | `POINT(x, y)` returning the pixel's pen. |
| `screen.bas` | `SCREEN$(row, col)` on TXT_RD_CHAR. |
| `attr.bas`, `print42.bas`, `print64.bas`, `sinclair.bas` | Only an `#error` explaining why they are not available. |

The runtime is in `src/lib/arch/cpc/runtime/` (`bootstrap.asm`, `fwcall.asm`,
`isr.asm`, `sysvars.asm`, `ay.asm`, `fwsound.asm`, `print.asm`, `fp_calc.asm`,
`cpcbuild/*.asm` and the rest). Its header comments name the firmware entries
each routine calls and the registers it clobbers.

## Further reading

### documentation
* http://cpcwiki.eu/index.php/Technical_documentation
* www.cpcmania.com/Docs/Programming/Programming.htm

### games with sources
* http://www.mojontwins.com/juegos_mojonos/uwol-2-cpc/
* http://www.mojontwins.com/juegos_mojonos/lala-prologue-cpc/

### Locomotive Basic
* http://www.qsl.net/hb9xch/computer/amstrad/locomotivebasic.html
* http://www.grimware.org/doku.php/documentations/software/locomotive.basic/start
* http://www.cpcwiki.eu/index.php/Locomotive_BASIC
* http://rosettacode.org/wiki/Category:Locomotive_Basic
