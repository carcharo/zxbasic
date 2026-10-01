#!/usr/bin/env python3

# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# © Copyright 2008-2024 José Manuel Rodríguez de la Rosa and contributors.
# See the file CONTRIBUTORS.md for copyright details.
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------

import re
import sys
from argparse import Namespace
from collections.abc import Collection
from io import StringIO

import src.api.optimize
from src import arch
from src.api import config, debug, errmsg
from src.api import global_ as gl
from src.api.config import OPTIONS
from src.api.utils import open_file
from src.zxbasm import asmparse
from src.zxbc import zxblex, zxbparser
from src.zxbc.args_config import parse_options, set_option_defines
from src.zxbc.args_parser import FileType
from src.zxbpp import zxbpp
from src.zxbpp.zxbpp import PreprocMode

RE_INIT = re.compile(
    r'^#[ \t]*init[ \t]+((?:[._a-zA-Z][._a-zA-Z0-9]*)|(?:"[._a-zA-Z][._a-zA-Z0-9]*"))[ \t]*$', re.IGNORECASE
)


def get_inits(memory):
    arch.target.backend.INITS.union(zxbparser.INITS)

    i = 0
    for m in memory:
        init = RE_INIT.match(m)
        if init is not None:
            arch.target.backend.INITS.add(init.groups()[0].strip('"'))
            memory[i] = ""
        i += 1


def output(memory, ofile=None):
    """Filters the output removing useless preprocessor #directives
    and writes it to the given file or to the screen if no file is passed
    """
    for m in memory:
        m = m.rstrip("\r\n\t ")  # Ensures no trailing newlines (might with upon includes)
        if m and m[0] == "#":  # Preprocessor directive?
            if ofile is None:
                print(m)
            else:
                ofile.write("%s\n" % m)
            continue

        # Prints a 4 spaces "tab" for non labels
        if m and ":" not in m:
            if ofile is None:
                (print("    "),)
            else:
                ofile.write("\t")

        if ofile is None:
            print(m)
        else:
            ofile.write("%s\n" % m)


def save_config(options: Namespace) -> None:
    if not gl.has_errors and options.save_config:
        src.api.config.save_config_into_file(options.save_config, src.api.config.ConfigSections.ZXBC)


def check_memory_layout(backend, heap_in_use: bool, org: int, length: int, labels: Collection[str] = ()) -> None:
    """Post-assembly sanity check for the compiled binary's memory layout.

    zxbasm's assembler only ever sees a stream of instructions -- it has
    no notion of what else lives in memory, so it can't catch code+data
    running into a heap placed at a fixed address, nor an architecture's
    own absolute ceiling for code+data. Both become checkable only now,
    once assembly is done and the binary's real origin and length are
    known.

    :param backend: the target architecture's Backend instance. Its
        MAX_CODE_ADDRESS (None by default) lets an arch declare an
        absolute upper bound for code+data, e.g. the cpc's private
        runtime block.
    :param heap_in_use: whether the heap start EQU was actually emitted
        (i.e. the program uses something that requires a heap). A heap
        placed at a fixed address that the program never uses can't be
        run into.
    :param org: the assembled binary's origin address.
    :param length: the assembled binary's length in bytes.
    :param labels: the global labels defined in the assembled program.
        A backend's RESERVED_RANGE_LABELS ({label: (start, end, reason)},
        empty by default) reserves [start, end) whenever that label is
        defined -- i.e. only in programs that link the runtime code
        defining it -- and neither code+data nor the heap may overlap it.
    """
    end = org + length  # first address past the compiled binary
    heap_address = OPTIONS.heap_address if heap_in_use else None
    heap_used = heap_address is not None

    for label, (start, stop, reason) in getattr(backend, "RESERVED_RANGE_LABELS", {}).items():
        if label not in labels:
            continue
        if org < stop and start < end:
            errmsg.error(
                0,
                "compiled code+data (0x%04X-0x%04X) overlaps 0x%04X-0x%04X, reserved because %s"
                % (org, end - 1, start, stop - 1, reason),
            )
        if heap_used and heap_address < stop and start < heap_address + OPTIONS.heap_size:
            errmsg.error(
                0,
                "the heap (0x%04X-0x%04X) overlaps 0x%04X-0x%04X, reserved because %s"
                % (heap_address, heap_address + OPTIONS.heap_size - 1, start, stop - 1, reason),
            )

    max_code_address = backend.MAX_CODE_ADDRESS
    if max_code_address is not None and end > max_code_address:
        errmsg.error(
            0,
            "compiled code+data ends at 0x%04X, past this architecture's "
            "memory limit of 0x%04X" % (end, max_code_address),
        )

    if not heap_used:
        return

    heap_end = heap_address + OPTIONS.heap_size
    if org < heap_end and heap_address < end:  # [org, end) and [heap, heap_end) intersect
        errmsg.error(
            0,
            "compiled code+data (0x%04X-0x%04X) overlaps the heap "
            "(0x%04X-0x%04X)" % (org, end - 1, heap_address, heap_end - 1),
        )


def main(args=None, emitter=None) -> int:
    """Entry point when executed from command line.
    zxbc can be used as python module. If so, bear in mind this function
    won't be executed unless explicitly called.
    """
    # region [Initialization]
    config.init()
    zxbparser.init()
    arch.target.backend.Backend().init()
    arch.target.Translator.reset()
    asmparse.init()

    options = parse_options(args)
    zxbpp.init()
    arch.set_target_arch(OPTIONS.architecture)
    arch.target.Translator.reset()
    backend = arch.target.backend.Backend()
    backend.init()  # Must reinitialize it again
    # endregion

    args = [options.PROGRAM]  # Strip out other options, because they're already set in the OPTIONS container
    input_filename = options.PROGRAM

    zxbpp.setMode(PreprocMode.BASIC)
    zxbpp.main(args)

    if gl.has_errors:
        debug.__DEBUG__("exiting due to errors.")
        return 1  # Exit with errors

    input_ = zxbpp.OUTPUT
    zxbparser.parser.parse(input_, lexer=zxblex.lexer, tracking=True, debug=(OPTIONS.debug_level > 1))
    if gl.has_errors:
        debug.__DEBUG__("exiting due to errors.")
        return 1  # Exit with errors

    # Unreachable code removal
    unreachable_code_visitor = src.api.optimize.UnreachableCodeVisitor()
    unreachable_code_visitor.visit(zxbparser.ast)

    # Function calls graph
    func_call_visitor = src.api.optimize.FunctionGraphVisitor()
    func_call_visitor.visit(zxbparser.ast)

    # Optimizations
    optimizer = src.api.optimize.OptimizerVisitor()
    optimizer.visit(zxbparser.ast)

    # Emits intermediate code
    translator = arch.target.Translator(backend)
    translator.visit(zxbparser.ast)

    if gl.DATA_IS_USED:
        gl.FUNCTIONS.extend(gl.DATA_FUNCTIONS)

    # This will fill MEMORY with pending functions
    func_visitor = arch.target.FunctionTranslator(backend=backend, function_list=gl.FUNCTIONS)
    func_visitor.start()

    if gl.has_errors:
        debug.__DEBUG__("exiting due to errors.")
        return 1  # Exit with errors

    if options.parse_only:
        save_config(options)
        return gl.has_errors

    # Emits data lines
    translator.emit_data_blocks()
    # Emits default constant strings
    translator.emit_strings()
    # Emits jump tables
    translator.emit_jump_tables()
    # Signals end of user code
    translator.ic_inline(";; --- end of user code ---")

    if gl.has_errors:
        debug.__DEBUG__("exiting due to errors.")
        return 1  # Exit with errors

    if OPTIONS.emit_backend:
        with open_file(OPTIONS.output_filename, "wt", "utf-8") as output_file:
            for quad in translator.dumpMemory(backend.MEMORY):
                output_file.write(str(quad) + "\n")

            backend.MEMORY[:] = []  # Empties memory
            # This will fill MEMORY with global declared variables
            translator = arch.target.VarTranslator(backend=backend)
            translator.visit(zxbparser.data_ast)

            for quad in translator.dumpMemory(backend.MEMORY):
                output_file.write(str(quad) + "\n")
        return 0  # Exit success

    # Join all lines into a single string and ensures an INTRO at end of file
    asm_output = backend.emit(optimize=OPTIONS.optimization_level > 0)
    asm_output = arch.target.optimizer.Optimizer().optimize(asm_output) + "\n"  # invoke the peephole optimizer

    asm_output = asm_output.split("\n")
    for i in range(len(asm_output)):
        tmp = src.arch.z80.backend.common.ASMS.get(asm_output[i], None)
        if tmp is not None:
            asm_output[i] = "\n".join(tmp)

    asm_output = "\n".join(asm_output)

    # Now filter them against the preprocessor again
    set_option_defines()  # Needed for zxbpp.init()
    zxbpp.reset_id_table()
    zxbpp.setMode(zxbpp.PreprocMode.ASM)
    zxbpp.OUTPUT = ""
    zxbpp.filter_(asm_output, filename=input_filename)

    # Now output the result
    asm_output = zxbpp.OUTPUT.split("\n")
    get_inits(asm_output)  # Find out remaining inits
    backend.MEMORY[:] = []

    # This will fill MEMORY with global declared variables
    var_checker = src.api.optimize.VariableVisitor()
    var_checker.visit(zxbparser.data_ast)
    translator = arch.target.VarTranslator(backend=backend)
    translator.visit(zxbparser.data_ast)
    if gl.has_errors:
        debug.__DEBUG__("exiting due to errors.")
        return 1  # Exit with errors

    tmp = [x for x in backend.emit(optimize=False) if x.strip()[0] != "#"]
    asm_output = (
        backend.emit_prologue()
        + tmp
        + ["%s:" % src.arch.z80.backend.common.DATA_END_LABEL, "%s:" % src.arch.z80.backend.common.MAIN_LABEL]
        + asm_output
        + backend.emit_epilogue()
    )

    # The heap start EQU (OPTIONS.heap_size_label) is only emitted by
    # emit_prologue() when the program actually requires a heap (see
    # e.g. src/arch/cpc/backend/main.py:emit_prologue). Recording that
    # here -- rather than duplicating the REQUIRES/INITS test that
    # decides it -- lets check_memory_layout() below stay architecture-
    # agnostic.
    heap_in_use = any(OPTIONS.heap_size_label in line for line in asm_output)

    if OPTIONS.output_file_type == FileType.ASM:  # Only output assembler file
        with open_file(OPTIONS.output_filename, "wt", "utf-8") as output_file:
            output(asm_output, output_file)
    elif not options.parse_only:
        fout = StringIO()
        output(asm_output, fout)
        asmparse.assemble(fout.getvalue())
        fout.close()
        if gl.has_errors:
            return 5  # Error in assembly

        # Check the memory layout before writing any output: org and
        # length are only known now that assembly is done, and it's
        # cheap to ask (MEMORY.dump() below is exactly what
        # generate_binary() does internally to get them; asking again
        # here is a no-op the second time, since dump() only resolves
        # each pending value once).
        memory = asmparse.MEMORY
        if memory is not None and memory.memory_bytes:
            org, binary = memory.dump()
            if gl.has_errors:
                return 5  # Error in assembly
            check_memory_layout(backend, heap_in_use, org, len(binary), memory.global_labels.keys())
            if gl.has_errors:
                return 5  # Memory layout error (heap overlap or past arch limit)

        asmparse.generate_binary(
            OPTIONS.output_filename,
            OPTIONS.output_file_type,
            binary_files=options.append_binary,
            headless_binary_files=options.append_headless_binary,
            emitter=emitter,
        )
        if gl.has_errors:
            return 5  # Error in assembly

    if OPTIONS.memory_map:
        if asmparse.MEMORY is not None:
            with open_file(OPTIONS.memory_map, "wt", "utf-8") as f:
                f.write(asmparse.MEMORY.memory_map)

    save_config(options)

    return gl.has_errors  # Exit success


if __name__ == "__main__":
    sys.exit(main())  # Exit
