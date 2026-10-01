# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# Amstrad CPC architecture for Boriel ZX BASIC compiler
# Inherits from zx48k, overriding the backend for CPC hardware/firmware.
# --------------------------------------------------------------------

import src.api.global_
from src.api.constants import TYPE
from src.arch.cpc import backend, beep  # noqa
from src.arch.z80 import (
    FunctionTranslator,
    Translator,
    VarTranslator,
    optimizer,  # noqa
)

__all__ = (
    "GRAPHICS_COORD_TYPE",
    "FunctionTranslator",
    "Translator",
    "VarTranslator",
    "beep",
)

# PLOT/CIRCLE coordinates are mode pixels (up to 640 wide in mode 2), so they
# don't fit the Spectrum's byte (see zxbparser.graphics_coord_type).
GRAPHICS_COORD_TYPE = "integer"

# -----------------------------------------
# Arch initialization setup (same as zx48k)
# -----------------------------------------
src.api.global_.PARAM_ALIGN = 2
src.api.global_.BOUND_TYPE = TYPE.uinteger
src.api.global_.SIZE_TYPE = TYPE.ubyte
src.api.global_.PTR_TYPE = TYPE.uinteger
src.api.global_.STR_INDEX_TYPE = TYPE.uinteger
src.api.global_.MIN_STRSLICE_IDX = 0
src.api.global_.MAX_STRSLICE_IDX = 65534
