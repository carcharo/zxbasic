# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# Amstrad CPC backend — program prologue / epilogue
# --------------------------------------------------------------------

from src.api.config import OPTIONS
from src.arch.z80.backend import Backend as Z80Backend
from src.arch.z80.backend import ICInfo, common
from src.arch.z80.backend.icinstruction import ICInstruction
from src.arch.z80.backend.runtime import NAMESPACE
from src.arch.z80.peephole import engine

from .generic import _end

# ---------------------------------------------------------------------------
# Amstrad CPC architecture constants
# ---------------------------------------------------------------------------
#
# Memory map (flat binary, loaded at ORG by AMSDOS after RUN"<file>"):
#
#   $0000-$003F   firmware RST vectors (ROM/firmware; not part of our binary.
#                 TODO(cpc): wire RST 6 ($0030) to FP_CALC_ENTRY once the FP
#                 calculator is hooked up)
#   $0040-$0FFF   unused (4 KB); usable for code (--org 0x40 works: proven on
#                 Caprice32 464/664/6128 and chips 464/6128). The default ORG
#                 stays at $1000
#   $1000 -> up   code + constant data (the compiled .bin); may run past $4000
#   ...  -$9DFF   heap, top-aligned just below the private block (never
#                 emitted as DEFS -- see emit_prologue)
#   $9E00-$A1FF   private runtime block (1 KB): relocated sysvars, future
#                 firmware-gate state and FP calculator workspace
#   $A200-$A5FF   stack (1 KB)
#   $A600-$A67B   slack, below boot HIMEM with AMSDOS ($A67B, measured)
#   $A67C-$B0FF   AMSDOS workspace once initialised; not ours
#   $B100-$BFFF   firmware variables, jumpblocks, firmware stack
#   $C000-$FFFF   screen
#
# These are the single source of truth for the memory map: nothing else in
# the backend or runtime hard-codes these numbers. The prologue also emits
# them as asm EQUs (.core.CPC_PRIV_BASE etc.) so runtime .asm files never
# need to duplicate them either.

_ORG = 0x1000  # default code origin

_PRIV_BASE = 0x9E00  # private runtime block: relocated sysvars, Phase 2 state
_PRIV_SIZE = 0x400  # 1 KB ($9E00-$A1FF)

_STACK_TOP = 0xA600  # SP set here by the prologue; stack occupies $A200-$A5FF
_MEM_TOP = 0xA67B  # boot HIMEM with AMSDOS (measured); code+data must end at
# or below this


class Backend(Z80Backend):
    # Code+data must stay below the private runtime block, whether or not
    # a heap is in use (see the memory map above). Checked by zxbc's
    # generic post-assembly memory-layout check.
    MAX_CODE_ADDRESS = _PRIV_BASE

    # Code must start at or above $0040: $0000-$003F are the restarts (the
    # firmware's, plus our RST 6 FP-calculator jump at $0030 and IM 1
    # vector at $0038; the firmware's ISR calls the external-interrupt
    # vector at $003B).
    MIN_CODE_ADDRESS = 0x0040
    MIN_CODE_REASON = "$0000-$003F hold the restarts and interrupt vectors"

    # Address ranges reserved only in programs that define the label
    # (checked by zxbc's memory-layout check). A library that wants the
    # second 16 KB screen area (a double-buffered back screen, say) defines
    # `.core.__CPC_RESERVE_4000` in an asm block, in code that is only
    # compiled in when the program uses it.
    RESERVED_RANGE_LABELS = {
        ".core.__CPC_RESERVE_4000": (
            0x4000,
            0x8000,
            "the program uses a library that reserves it (such as a double-buffered back screen)",
        ),
    }

    # Options that must not be enabled on this arch -> why (reported as a
    # compile error by zxbc for -N and by the parser for #pragma).
    UNSUPPORTED_OPTIONS = {
        "zxnext": "zxnext (Z80N opcodes) is not available on --arch cpc: the CPC's Z80 can't run them",
    }

    def init(self):
        super().init()

        # ZXNext asm is a zx48k/zxnext concept; the CPC never enables it.
        # Reset here so a value left by a previous in-process compile (e.g.
        # --arch zxnext) can't leak in; asking for it on cpc (-N or the
        # pragma) is reported as an error via UNSUPPORTED_OPTIONS.
        OPTIONS.zxnext = False

        # bootstrap.asm (and, transitively, sysvars.asm) must run
        # unconditionally -- CPC_INIT_SYSVARS zero-fills the private
        # runtime block -- so force it in rather than relying on
        # incidental inclusion via common.REQUIRES.
        common.REQUIRES.add("bootstrap.asm")

        # zxbc.main() runs a first Backend().init() for whatever arch the
        # previous compile in this process left as target, before options
        # are parsed. Only apply CPC memory defaults when cpc really is the
        # target, or they leak into the next compile (e.g. org 4096 for zxnext).
        if OPTIONS.architecture == "cpc":
            # super().init() left OPTIONS.org at the generic z80 default
            # (32768); only override it when the user did not pass --org.
            if "org" not in OPTIONS.cli_overrides:
                OPTIONS.org = _ORG

            # heap_size keeps the generic default or the user's -H value.
            # Unless --heap-address was given, top-align the heap just below
            # the private runtime block (a None heap_address would make the
            # prologue emit the heap inline as DEFS in the binary).
            if "heap_address" not in OPTIONS.cli_overrides:
                OPTIONS.heap_address = _PRIV_BASE - OPTIONS.heap_size

        self._QUAD_TABLE.update(
            {
                ICInstruction.END: ICInfo(1, _end),
            }
        )

        engine.main()

    @staticmethod
    def emit_prologue() -> list[str]:
        """Program prologue for the Amstrad CPC.

        Structure of the generated binary:
          org {OPTIONS.org}          (default $1000)
          .core.CPC_* EQUs           (memory-map constants for runtime asm)
          {START_LABEL}:
            di                      ; off until the bootstrap has put in
                                     ; the interrupt front-end (isr.asm);
                                     ; its first firmware call turns them on
            ld sp, .core.CPC_STACK_TOP
            call <#init routines>   ; e.g. .core.CPC_INIT_SYSVARS
            jp   {MAIN_LABEL}
          heap / user data definitions (as the generic z80 backend)

        Unlike the generic zx48k prologue, this does not save any state to
        return to a BASIC caller: RUN"<file>" goes through CPC firmware
        that never returns to BASIC (see END, in generic.py), so no
        CALL_BACK is used or emitted.
        """
        heap_init = [f"{common.DATA_LABEL}:"]
        output = [f"org {OPTIONS.org}"]

        # Memory-map constants for runtime .asm files (sysvars.asm,
        # bootstrap.asm, ...) instead of hard-coding these numbers.
        output.append(f"{NAMESPACE}.CPC_PRIV_BASE EQU {_PRIV_BASE}")
        output.append(f"{NAMESPACE}.CPC_PRIV_SIZE EQU {_PRIV_SIZE}")
        output.append(f"{NAMESPACE}.CPC_STACK_TOP EQU {_STACK_TOP}")
        output.append(f"{NAMESPACE}.CPC_MEM_TOP EQU {_MEM_TOP}")

        if common.REQUIRES.intersection(common.MEMINITS) or f"{NAMESPACE}.__MEM_INIT" in common.INITS:
            heap_init.append("; Defines HEAP SIZE\n" + OPTIONS.heap_size_label + " EQU " + str(OPTIONS.heap_size))
            if OPTIONS.heap_address is None:
                # Not expected on the CPC (init() always computes a
                # top-aligned default), kept only for parity with the
                # generic backend in case Backend.init() is ever bypassed.
                heap_init.append(OPTIONS.heap_start_label + ":")
                heap_init.append(f"DEFS {OPTIONS.heap_size}")
            else:
                heap_init.append("; Defines HEAP ADDRESS\n" + OPTIONS.heap_start_label + f" EQU {OPTIONS.heap_address}")

        heap_init.append(
            "; Defines USER DATA Length in bytes\n"
            + f"{NAMESPACE}.ZXBASIC_USER_DATA_LEN EQU {common.DATA_END_LABEL} - {common.DATA_LABEL}"
        )
        heap_init.append(f"{NAMESPACE}.__LABEL__.ZXBASIC_USER_DATA_LEN EQU {NAMESPACE}.ZXBASIC_USER_DATA_LEN")
        heap_init.append(f"{NAMESPACE}.__LABEL__.ZXBASIC_USER_DATA EQU {common.DATA_LABEL}")

        output.append(f"{common.START_LABEL}:")
        if OPTIONS.headerless:
            output.extend(heap_init)
            return output

        output.append("di")
        output.append(f"ld sp, {NAMESPACE}.CPC_STACK_TOP")

        output.extend(f"call {x}" for x in sorted(common.INITS))

        output.append(f"jp {common.MAIN_LABEL}")
        output.extend(heap_init)

        return output

    @staticmethod
    def emit_epilogue() -> list[str]:
        output = list(common.AT_END)
        if OPTIONS.autorun:
            output.append(f"END {common.START_LABEL}")
        else:
            output.append("END")
        return output
