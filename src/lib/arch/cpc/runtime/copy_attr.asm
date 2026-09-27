; Phase-1 stub for zx48k/runtime/copy_attr.asm (was: copying ATTR_P into
; ATTR_T and, via __SET_ATTR_MODE, self-modifying a PRINT_MODE/
; INVERSE_MODE opcode pair inside print.asm's __PRINTCHAR). Whenever a
; program uses PRINT, the compiler defines ___PRINT_IS_USED___, which
; turns on the branch of __SET_ATTR_MODE that pokes those opcodes, so
; this can't be reduced to a plain ATTR_P->ATTR_T copy: its real
; behaviour is inseparable from print.asm's internals. Reached from
; inverse.asm's INVERSE_TMP, over.asm's OVER_TMP and print_eol_attr.asm.
; TODO(cpc): Phase 2/4a -> together with print.asm.

#include once <stub.asm>

    push namespace core

COPY_ATTR:
    jp __CPC_NOT_IMPLEMENTED

__SET_ATTR_MODE:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
