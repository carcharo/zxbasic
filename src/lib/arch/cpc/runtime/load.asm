; Phase-1 stub for zx48k/runtime/load.asm (was: Spectrum ROM tape loader,
; LD_BYTES &0556/&0562, a hand-built ROM header block, and the
; HIDE_LOAD_MSG tape-message table). None of that exists on the CPC:
; loading here means AMSDOS disc access via CAS_IN_OPEN/CAS_IN_DIRECT
; (&BC77/&BC83) instead, needing AMSDOS initialised first (KL_ROM_WALK) --
; a bigger piece of work than a stub.
; TODO(cpc): replace once disc I/O is implemented.

#include once <stub.asm>

    push namespace core

LOAD_CODE:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
