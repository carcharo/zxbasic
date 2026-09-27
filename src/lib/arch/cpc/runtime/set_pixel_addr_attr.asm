; Phase-1 stub for zx48k/runtime/set_pixel_addr_attr.asm (was: converting
; a Spectrum VRAM pixel address into its attribute-cell address via the
; ROM's interleaved-bitmap formula). Meaningless on the CPC (see
; attr.asm). Used internally by plot.asm and draw.asm.
; TODO(cpc): Phase 4a -> together with attr.asm.

#include once <stub.asm>

    push namespace core

SET_PIXEL_ADDR_ATTR:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
