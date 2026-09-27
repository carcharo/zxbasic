; Phase-1 stub for zx48k/runtime/save.asm (was: Spectrum ROM tape saver,
; CHAN_OPEN &1601 / SA_BYTES &04C6 / ROM_SAVE &0970, plus direct ULA port
; I/O). None of that exists on the CPC: saving here means AMSDOS disc
; access via CAS_OUT_OPEN/CAS_OUT_DIRECT (&BC8C/&BC98) instead, needing
; AMSDOS initialised first (see load.asm).
; TODO(cpc): replace once disc I/O is implemented.

#include once <stub.asm>

    push namespace core

SAVE_CODE:
    jp __CPC_NOT_IMPLEMENTED

    pop namespace
