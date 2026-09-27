# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# © Copyright 2008-2024 José Manuel Rodríguez de la Rosa and contributors.
# See the file CONTRIBUTORS.md for copyright details.
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------

import os

import pytest

from src.api import config
from src.zxbpp import zxbpp

PATH = os.path.realpath(os.path.dirname(os.path.abspath(__file__)))


@pytest.fixture
def file_bas():
    return os.path.join(PATH, "empty.bas")


def test_default_arch_defines_zx48k_macro_only(file_bas, tmp_path):
    """The standalone preprocessor's own --arch parser must define the
    same automatic __<ARCH>__ macro zxbc's set_option_defines() defines."""
    outfile = str(tmp_path / "out1.bi")
    result = zxbpp.entry_point([file_bas, "-o", outfile, "-e", "/dev/null"])
    assert result == 0
    assert "__ZX48K__" in config.OPTIONS["__DEFINES"].value
    assert "__ZXNEXT__" not in config.OPTIONS["__DEFINES"].value


def test_arch_zxnext_defines_zxnext_macro(file_bas, tmp_path):
    outfile = str(tmp_path / "out2.bi")
    result = zxbpp.entry_point([file_bas, "--arch", "zxnext", "-o", outfile, "-e", "/dev/null"])
    assert result == 0
    assert "__ZXNEXT__" in config.OPTIONS["__DEFINES"].value
    assert "__ZX48K__" not in config.OPTIONS["__DEFINES"].value


def test_arch_zx81sd_defines_zx81sd_macro(file_bas, tmp_path):
    outfile = str(tmp_path / "out3.bi")
    result = zxbpp.entry_point([file_bas, "--arch", "zx81sd", "-o", outfile, "-e", "/dev/null"])
    assert result == 0
    assert "__ZX81SD__" in config.OPTIONS["__DEFINES"].value

