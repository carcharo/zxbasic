; Phase-1 stub for zx48k/runtime/attr.asm (was: computing a Spectrum
; attribute cell address from screen coordinates and mixing a byte into
; it). The CPC has no per-cell attribute byte in memory (mode 1 colour
; comes from the palette + pixel bits), so this needs a real design, not
; just a relocated address -- SCREEN_ATTR_ADDR in sysvars.asm is only a
; placeholder until then. Reached from the ATTR()/SETATTR()/ATTRADDR()
; stdlib functions, and internally by sposn.asm, set_pixel_addr_attr.asm
; and print.asm.
; TODO(cpc): Phase 4a -> a CPC-native colour-cell design.

#include once <stub.asm>
#include once <sysvars.asm>

    push namespace core

__ATTR_ADDR:
    jp __CPC_NOT_IMPLEMENTED

SET_ATTR:
    jp __CPC_NOT_IMPLEMENTED

__SET_ATTR:
    jp __CPC_NOT_IMPLEMENTED

__SET_ATTR2:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
