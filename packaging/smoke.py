#!/usr/bin/env python3
"""Smoke test for the frozen (PyInstaller) ZX BASIC / CPC tools.

Compiles/assembles/preprocesses a handful of programs with the frozen
binaries AND with the compiler running from source, and requires the
outputs to be byte-identical. Then packs a CPC binary into a .dsk with the
frozen mkdsk and checks the file.

Pure Python, stdlib only.

    python packaging/smoke.py --frozen dist/zxbasic [--source-python PYTHON]

The source compiler is run as `<python> <repo>/zxbc.py ...` (likewise
zxbasm.py, zxbpp.py), so PYTHON must be an interpreter that has the repo's
dependencies installed (default: the interpreter running this script).
Exit status is 0 only if every check passes.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
EXE = ".exe" if sys.platform == "win32" else ""

HELLO_CPC = 'CLS\nPRINT "Hello CPC"\nPRINT AT 5, 3; "Frozen"\n'
HELLO_ZX = 'CLS\nPRINT "Hello ZX"\nPAUSE 0\n'
# Pulls in stdlib files through the include path (checks library lookup).
STDLIB_CPC = '#include <string.bas>\n#include <hex.bas>\nPRINT hex(255)\nPRINT STR$(42); " "; "x"\n'
STDLIB_ZX = "#include <string.bas>\n#include <hex.bas>\nPRINT hex(255)\n"
ASM = """\
    org 0x8000
start:
    ld hl, msg
    ld b, 5
loop:
    ld a, (hl)
    inc hl
    djnz loop
    ret
msg:
    defb "HELLO"
"""
PP = '#define GREETING "hi"\n#ifdef GREETING\nPRINT GREETING\n#endif\n#include <string.bas>\n'

failures: list[str] = []


def fail(msg: str) -> None:
    print(f"FAIL: {msg}", file=sys.stderr)
    failures.append(msg)


def run(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd, cwd=cwd, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=300, check=False
    )


class Tools:
    """Command prefixes for one flavour (frozen or source)."""

    def __init__(self, name: str, prefix: dict[str, list[str]], lib_roots: list[Path]):
        self.name = name
        self.prefix = prefix
        self.lib_roots = lib_roots


TEXT_SUFFIXES = (".asm", ".pp", ".map")


def normalise(name: str, data: bytes, roots: list[Path]) -> bytes:
    """Text outputs embed the absolute path of library files (#line markers);
    that legitimately differs between the bundle and the source tree, so
    replace each library root with a placeholder before comparing."""
    if not name.endswith(TEXT_SUFFIXES):
        return data
    text = data.decode("utf-8", "surrogateescape")
    for root in roots:
        for form in (str(root), str(root).replace("\\", "/"), str(root).replace("\\", "\\\\")):
            text = text.replace(form, "<SRC>")
    return text.encode("utf-8", "surrogateescape")


def case(label: str, tool: str, args_for, outputs: list[str], tools: list[Tools], work: Path, stdout_cmp=False):
    """Run the same command with each flavour (in its own dir) and compare outputs.

    args_for(dir) -> argument list; `outputs` are file names produced in dir.
    """
    results = {}
    for t in tools:
        # Same directory for every flavour: the compiler embeds file paths
        # (#line, include dirs) in its asm output, so paths must not differ.
        d = work / label / "run"
        shutil.rmtree(d, ignore_errors=True)
        d.mkdir(parents=True)
        for f in work.glob("inputs/*"):
            shutil.copy(f, d / f.name)
        proc = run(t.prefix[tool] + args_for(d), d)
        if proc.returncode != 0:
            fail(f"{label}: {t.name} {tool} exited {proc.returncode}\n{proc.stdout}\n{proc.stderr}")
            return None
        data = {}
        for o in outputs:
            p = d / o
            if not p.is_file() or p.stat().st_size == 0:
                fail(f"{label}: {t.name} did not produce {o}")
                return None
            data[o] = normalise(o, p.read_bytes(), t.lib_roots)
        if stdout_cmp:
            data["<stdout>"] = proc.stdout.encode()
        results[t.name] = data
    a, b = (results[t.name] for t in tools[:2])
    for key in a:
        if a[key] != b[key]:
            n0, n1 = tools[0].name, tools[1].name
            fail(f"{label}: {key} differs between {n0} ({len(a[key])} bytes) and {n1} ({len(b[key])} bytes)")
            return None
    print(f"ok   {label}: " + ", ".join(f"{k}={len(v)}B" for k, v in a.items()))
    return a


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument(
        "--frozen", required=True, type=Path, help="the frozen folder (contains zxbc, zxbasm, zxbpp, mkdsk)"
    )
    ap.add_argument("--source-python", default=sys.executable, help="python used to run the compiler from source")
    ap.add_argument("--keep", action="store_true", help="keep the temporary work directory")
    args = ap.parse_args()

    frozen = args.frozen.resolve()
    tools_frozen = {n: [str(frozen / (n + EXE))] for n in ("zxbc", "zxbasm", "zxbpp", "mkdsk")}
    for n, c in tools_frozen.items():
        if not Path(c[0]).is_file():
            print(f"FAIL: missing frozen executable {c[0]}", file=sys.stderr)
            return 1
    py = args.source_python
    tools_source = {n: [py, str(REPO / (n + ".py"))] for n in ("zxbc", "zxbasm", "zxbpp")}
    both = [
        Tools("frozen", tools_frozen, [frozen / "_internal" / "src", frozen / "src"]),
        Tools("source", tools_source, [REPO / "src"]),
    ]

    # --version works and names the same version in both
    vers = [run(t.prefix["zxbc"] + ["--version"], REPO) for t in both]
    if any(v.returncode != 0 for v in vers) or vers[0].stdout.split()[-1] != vers[1].stdout.split()[-1]:
        fail(f"--version mismatch: {[v.stdout + v.stderr for v in vers]}")
    else:
        print(f"ok   zxbc --version: {vers[0].stdout.strip()}")

    work = Path(tempfile.mkdtemp(prefix="zxb-smoke-"))
    try:
        inputs = work / "inputs"
        inputs.mkdir()
        (inputs / "hello_cpc.bas").write_text(HELLO_CPC)
        (inputs / "hello_zx.bas").write_text(HELLO_ZX)
        (inputs / "stdlib_cpc.bas").write_text(STDLIB_CPC)
        (inputs / "stdlib_zx.bas").write_text(STDLIB_ZX)
        (inputs / "prog.asm").write_text(ASM)
        (inputs / "pp.bas").write_text(PP)
        big = REPO / "tests" / "functional" / "arch" / "cpc" / "float_heavy.bas"
        if not big.is_file():
            fail(f"missing test program {big}")
        else:
            shutil.copy(big, inputs / "float_heavy.bas")

        cpc = ["--arch", "cpc"]
        cpc_bin = case(
            "hello-cpc",
            "zxbc",
            lambda d: [*cpc, "-o", "out.bin", "-M", "out.map", "hello_cpc.bas"],
            ["out.bin", "out.map"],
            both,
            work,
        )
        case(
            "hello-cpc-asm",
            "zxbc",
            lambda d: [*cpc, "-f", "asm", "-o", "out.asm", "hello_cpc.bas"],
            ["out.asm"],
            both,
            work,
        )
        case(
            "stdlib-cpc",
            "zxbc",
            lambda d: [*cpc, "-O", "3", "-o", "out.bin", "stdlib_cpc.bas"],
            ["out.bin"],
            both,
            work,
        )
        case(
            "float-heavy-cpc",
            "zxbc",
            lambda d: [*cpc, "-O", "4", "-o", "out.bin", "float_heavy.bas"],
            ["out.bin"],
            both,
            work,
        )
        case("hello-zx48k-bin", "zxbc", lambda d: ["-o", "out.bin", "hello_zx.bas"], ["out.bin"], both, work)
        case(
            "hello-zx48k-tap",
            "zxbc",
            lambda d: ["-t", "-a", "-B", "-o", "out.tap", "hello_zx.bas"],
            ["out.tap"],
            both,
            work,
        )
        case("stdlib-zx48k", "zxbc", lambda d: ["-O", "3", "-o", "out.bin", "stdlib_zx.bas"], ["out.bin"], both, work)
        # the other architectures: only their runtime/library lookup matters
        case(
            "hello-zxnext",
            "zxbc",
            lambda d: ["--arch", "zxnext", "-o", "out.bin", "hello_zx.bas"],
            ["out.bin"],
            both,
            work,
        )
        case(
            "hello-zx81sd",
            "zxbc",
            lambda d: ["--arch", "zx81sd", "-o", "out.bin", "hello_zx.bas"],
            ["out.bin"],
            both,
            work,
        )
        case("zxbasm", "zxbasm", lambda d: ["-o", "out.bin", "prog.asm"], ["out.bin"], both, work)
        case("zxbpp", "zxbpp", lambda d: [*cpc, "-o", "out.pp", "pp.bas"], ["out.pp"], both, work)

        # frozen mkdsk: pack the CPC binary and check the image
        if cpc_bin is not None:
            d = work / "mkdsk"
            d.mkdir()
            binfile = d / "HELLO.BIN"
            binfile.write_bytes(cpc_bin["out.bin"])
            dsk = d / "hello.dsk"
            proc = run(
                tools_frozen["mkdsk"] + ["--load", "0x40", "--name", "HELLO.BIN", "-o", str(dsk), str(binfile)], d
            )
            if proc.returncode != 0:
                fail(f"mkdsk exited {proc.returncode}\n{proc.stdout}\n{proc.stderr}")
            elif not dsk.is_file():
                fail("mkdsk did not produce hello.dsk")
            else:
                # standard CPCEMU image: 256 header + 40 tracks * (256 + 9*512)
                expected = 0x100 + 40 * 0x1300
                size = dsk.stat().st_size
                data = dsk.read_bytes()
                if size != expected:
                    fail(f"mkdsk: hello.dsk is {size} bytes, expected {expected}")
                elif not data.startswith(b"MV - CPCEMU Disk-File"):
                    fail("mkdsk: hello.dsk lacks the CPCEMU signature")
                elif b"HELLO   BIN" not in data:
                    fail("mkdsk: directory entry HELLO.BIN not found in hello.dsk")
                else:
                    # the same image from the source mkdsk must be identical
                    dsk2 = d / "hello_src.dsk"
                    p2 = run(
                        [
                            py,
                            str(REPO / "tools" / "cpc" / "mkdsk.py"),
                            "--load",
                            "0x40",
                            "--name",
                            "HELLO.BIN",
                            "-o",
                            str(dsk2),
                            str(binfile),
                        ],
                        d,
                    )
                    if p2.returncode != 0 or dsk2.read_bytes() != data:
                        fail("mkdsk: frozen and source disk images differ")
                    else:
                        print(f"ok   mkdsk: hello.dsk={size}B (matches source mkdsk)")
    finally:
        if args.keep:
            print(f"work dir kept: {work}")
        else:
            shutil.rmtree(work, ignore_errors=True)

    if failures:
        print(f"\nSMOKE TEST FAILED: {len(failures)} problem(s)", file=sys.stderr)
        return 1
    print("\nSMOKE TEST PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
