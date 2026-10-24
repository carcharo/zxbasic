# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec: one onedir folder "zxbasic/" with four executables
# (zxbc, zxbasm, zxbpp, mkdsk) sharing one Python runtime.
#
#   pip install pyinstaller==6.22.3
#   pyinstaller --noconfirm --distpath dist --workpath build/pyi packaging/zxbasic.spec
#
# Run from the repository root. Output: dist/zxbasic/
#
# Notes:
# * The parsers are Lark standalone modules (src/*/..._standalone.py) with the
#   LALR tables baked into the source, so nothing is generated or cached at
#   run time and the bundle can be read-only.
# * The compiler locates its libraries relative to src/ (__file__), and the
#   target arch is imported with importlib.import_module(f".{arch}", ...),
#   hence collect_submodules("src") and the data files below, which keep the
#   same relative layout (<bundle>/_internal/src/...).
import os

from PyInstaller.utils.hooks import collect_submodules

ROOT = os.path.abspath(os.path.join(SPECPATH, os.pardir))  # noqa: F821 (SPECPATH is injected)

hiddenimports = collect_submodules("src")

# Run-time data, read through __file__-relative paths:
#   src/lib/**                 arch runtimes + stdlib (.asm/.bas/.bin/.fzx/...), src/zxbpp/zxbpp.py
#   src/arch/*/peephole/opts   optimizer pattern files (*.opt), peephole engines
datas = []
for dirpath, _dirs, files in os.walk(os.path.join(ROOT, "src", "lib")):
    if "__pycache__" in dirpath:
        continue
    for f in files:
        datas.append((os.path.join(dirpath, f), os.path.relpath(dirpath, ROOT)))
for dirpath, _dirs, files in os.walk(os.path.join(ROOT, "src", "arch")):
    if os.path.basename(dirpath) == "opts":
        for f in files:
            if f.endswith(".opt"):
                datas.append((os.path.join(dirpath, f), os.path.relpath(dirpath, ROOT)))
datas.append((os.path.join(ROOT, "LICENSE.txt"), "."))

excludes = ["tkinter", "unittest", "pydoc", "test", "pytest", "_pytest"]

PROGRAMS = [
    # (executable name, entry script)
    ("zxbc", os.path.join(ROOT, "zxbc.py")),
    ("zxbasm", os.path.join(ROOT, "zxbasm.py")),
    ("zxbpp", os.path.join(ROOT, "zxbpp.py")),
    ("mkdsk", os.path.join(ROOT, "tools", "cpc", "mkdsk.py")),
]

exes = []
collect_args = []
for name, script in PROGRAMS:
    a = Analysis(  # noqa: F821
        [script],
        pathex=[ROOT],
        binaries=[],
        datas=datas if name != "mkdsk" else [],  # mkdsk is stdlib-only
        hiddenimports=hiddenimports if name != "mkdsk" else [],
        hookspath=[],
        runtime_hooks=[],
        excludes=excludes,
        noarchive=False,
    )
    pyz = PYZ(a.pure)  # noqa: F821
    exe = EXE(  # noqa: F821
        pyz,
        a.scripts,
        [],
        exclude_binaries=True,
        name=name,
        debug=False,
        strip=False,
        upx=False,
        console=True,
    )
    exes.append(exe)
    collect_args += [exe, a.binaries, a.datas]

coll = COLLECT(  # noqa: F821
    *collect_args,
    strip=False,
    upx=False,
    name="zxbasic",
)
