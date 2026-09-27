#!/usr/bin/env bash

# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# © Copyright 2008-2024 José Manuel Rodríguez de la Rosa and contributors.
# See the file CONTRIBUTORS.md for copyright details.
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------
#
# run.sh -- compile a Boriel BASIC program (or take an existing raw
# binary), package it into an AMSDOS .dsk with mkdsk.py, and launch it
# in Caprice32.
#
# Usage:
#   tools/cpc/run.sh prog.bas [extra zxbc args...]
#   tools/cpc/run.sh prog.bin
#   tools/cpc/run.sh --shot prog.bas|prog.bin   # headless, one screenshot
#
# --shot runs cap32 with SDL_VIDEODRIVER=dummy and a small autocmd script
# (load, delay, screenshot, exit) instead of opening an interactive
# window; the screenshot lands in build/shots/. Useful for CI or an
# unattended sanity check before the Phase 5a test harness exists.
#
# Caprice32 is found at $CAP32, or, by default, as a sibling checkout:
# ../caprice32/cap32 relative to this repo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MKDSK="$SCRIPT_DIR/mkdsk.py"

SHOT=0
if [[ "${1:-}" == "--shot" ]]; then
    SHOT=1
    shift
fi

if [[ $# -lt 1 ]]; then
    echo "usage: $0 [--shot] prog.bas|prog.bin [extra zxbc args...]" >&2
    exit 1
fi

SRC="$1"
shift
EXTRA_ARGS=("$@")

if [[ ! -f "$SRC" ]]; then
    echo "run.sh: error: $SRC not found" >&2
    exit 1
fi

SRC_DIR="$(cd "$(dirname "$SRC")" && pwd)"
SRC_ABS="$SRC_DIR/$(basename "$SRC")"
BASENAME="$(basename "$SRC")"
STEM="${BASENAME%.*}"
EXT="${BASENAME##*.}"

# AMSDOS names are 8.3: truncate so the on-disk name and the "run" command
# sent to BASIC below refer to the same file.
AMSDOS_STEM="${STEM:0:8}"

BUILD_DIR="$(pwd)/build"
mkdir -p "$BUILD_DIR"
BIN_ABS="$BUILD_DIR/$STEM.bin"
DSK_ABS="$BUILD_DIR/$STEM.dsk"

if command -v poetry >/dev/null 2>&1; then
    ZXBC=(poetry run zxbc)
else
    ZXBC=(python3 "$REPO_ROOT/zxbc.py")
fi

case "$EXT" in
    bas | BAS)
        echo "run.sh: compiling $SRC_ABS -> $BIN_ABS"
        (cd "$REPO_ROOT" && "${ZXBC[@]}" --arch cpc --org 0x1000 -o "$BIN_ABS" "$SRC_ABS" "${EXTRA_ARGS[@]}")
        ;;
    bin | BIN)
        cp "$SRC_ABS" "$BIN_ABS"
        ;;
    *)
        echo "run.sh: error: expected a .bas or .bin file, got $SRC" >&2
        exit 1
        ;;
esac

echo "run.sh: packaging $BIN_ABS -> $DSK_ABS"
python3 "$MKDSK" -o "$DSK_ABS" --load 0x1000 --exec 0x1000 --name "$AMSDOS_STEM.BIN" "$BIN_ABS"

CAP32="${CAP32:-$REPO_ROOT/../caprice32/cap32}"
if [[ ! -x "$CAP32" ]]; then
    echo "run.sh: error: Caprice32 not found/executable at $CAP32 (set CAP32=/path/to/cap32)" >&2
    exit 1
fi

if [[ "$SHOT" -eq 1 ]]; then
    SHOT_DIR="$BUILD_DIR/shots"
    mkdir -p "$SHOT_DIR"

    TIMEOUT_BIN="timeout"
    if ! command -v timeout >/dev/null 2>&1 && command -v gtimeout >/dev/null 2>&1; then
        TIMEOUT_BIN="gtimeout"
    fi

    echo "run.sh: running headlessly (run\"$AMSDOS_STEM), screenshot -> $SHOT_DIR"
    SDL_VIDEODRIVER=dummy "$TIMEOUT_BIN" 30 "$CAP32" \
        -O "file.sdump_dir=$SHOT_DIR" \
        -a "run\"$AMSDOS_STEM" \
        -a 'CAP32_DELAY' \
        -a 'CAP32_DELAY' \
        -a 'CAP32_SCRNSHOT' \
        -a 'CAP32_EXIT' \
        "$DSK_ABS"
else
    echo "run.sh: launching Caprice32 (a window should open)"
    "$CAP32" "$DSK_ABS" -a "run\"$AMSDOS_STEM"
fi
