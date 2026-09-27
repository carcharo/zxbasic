; Phase-1 stub for zx48k/runtime/print.asm (was: the PRINT character
; writer, writing directly into Spectrum VRAM using the ROM's
; interleaved-row bitmap layout, self-modifying a PRINT_MODE/INVERSE_MODE
; opcode pair per call, reading CHARS/UDG as the font source, testing
; `bit n,(iy+$47)` against a fixed Spectrum sysvar IY convention the CPC
; doesn't have, and calling the ROM's PO_GR_1 &0B38 / SCROLL &0DFE). None
; of that has a CPC equivalent yet. __PRINTCHAR is exported because
; printnum.asm/printstr.asm (both inherited unchanged) call it directly
; per character; PRINT_EOL is exported because print_eol_attr.asm
; (inherited unchanged) calls it before COPY_ATTR.
; TODO(cpc): Phase 2/4a -> a CPC-native character writer, either
; bitmap-blit into the linear mode 1 screen directly, or through the
; firmware's TXT_OUTPUT (&BB5A) / TXT_WR_CHAR (&BB5D).

#include once <stub.asm>

    push namespace core

PRINT_AT:
    jp __CPC_NOT_IMPLEMENTED

PRINT_COMMA:
    jp __CPC_NOT_IMPLEMENTED

PRINT_EOL:
    jp __CPC_NOT_IMPLEMENTED

PRINT_TAB:
    jp __CPC_NOT_IMPLEMENTED

__PRINTCHAR:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
