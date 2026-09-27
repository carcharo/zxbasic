# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# © Copyright 2008-2024 José Manuel Rodríguez de la Rosa and contributors.
# See the file CONTRIBUTORS.md for copyright details.
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------

import os

import pytest

from src import arch
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


def test_arch_parents_declares_zx81sd_inherits_zx48k():
    """zx81sd and cpc are the architectures that inherit another one's
    stdlib/runtime include search path."""
    assert arch.ARCH_PARENTS == {"zx81sd": "zx48k", "cpc": "zx48k"}


def test_set_include_path_zx81sd_inherits_zx48k_unchanged():
    """zx81sd's include search path must stay byte-for-byte identical to
    the previous hard-coded special case: its own stdlib/runtime first,
    then zx48k's, in that order."""
    config.OPTIONS.architecture = "zx81sd"
    zxbpp.init()
    zxbpp.set_include_path()

    zx81sd_pwd = zxbpp.get_include_path("zx81sd")
    zx48k_pwd = zxbpp.get_include_path("zx48k")

    assert zxbpp.INCLUDE_MAP["zx81sd"] == [
        os.path.join(zx81sd_pwd, "stdlib"),
        os.path.join(zx81sd_pwd, "runtime"),
        os.path.join(zx48k_pwd, "stdlib"),
        os.path.join(zx48k_pwd, "runtime"),
    ]


def test_set_include_path_zx48k_has_no_parent_fallback():
    """An architecture with no entry in ARCH_PARENTS only searches its own
    stdlib/runtime dirs."""
    config.OPTIONS.architecture = "zx48k"
    zxbpp.init()
    zxbpp.set_include_path()

    zx48k_pwd = zxbpp.get_include_path("zx48k")
    assert zxbpp.INCLUDE_MAP["zx48k"] == [
        os.path.join(zx48k_pwd, "stdlib"),
        os.path.join(zx48k_pwd, "runtime"),
    ]
