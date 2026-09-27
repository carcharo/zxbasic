#!/usr/bin/env python3

# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# © Copyright 2008-2024 José Manuel Rodríguez de la Rosa and contributors.
# See the file CONTRIBUTORS.md for copyright details.
# See https://www.gnu.org/licenses/agpl-3.0.html for details.
# --------------------------------------------------------------------

"""mkdsk.py -- pure-Python (stdlib only) Amstrad CPC disk-image writer.

Packages one or more raw binaries into a standard (non-extended) CPCEMU
".dsk" disk image, formatted as an AMSDOS "Data" format disk (the classic
180 KB single-sided CP/M-alike filesystem AMSDOS uses), with each file
preceded by a 128-byte AMSDOS header so it can be LOADed or RUN from
Locomotive BASIC / AMSDOS.

Formats implemented, and where they were verified:

* AMSDOS file header (128 bytes prepended to the raw binary).
  Field offsets and the checksum algorithm verified against:
    - https://www.cpcwiki.eu/index.php/AMSDOS_Header
    - https://cpctech.cpcwiki.de/docs/allhead.html (mirror of the above;
      cpcwiki.eu is behind a bot-blocking challenge that rejects
      unattended fetches, so the cpctech.cpcwiki.de mirror -- and the
      cpcwiki.eu content surfaced through search-result snippets -- were
      used to cross-check the field table below).

  Offset  Size  Field
  0x00    1     User number (0 for a normal visible file)
  0x01    8     Filename, space-padded, upper-case
  0x09    3     Extension, space-padded, upper-case
  0x0C    4     Unused (0)
  0x10    1     Block number (unused for a file header written to disk; 0)
  0x11    1     Last block flag (0)
  0x12    1     File type (0=BASIC, 2=binary; this tool always writes 2)
  0x13    2     Unused (0)
  0x15    2     Load address (little-endian)
  0x17    1     First block flag (0)
  0x18    2     Logical length: real length truncated to 16 bits (LE)
  0x1A    2     Entry/execution address (little-endian)
  0x1C    36    Unused (0)
  0x40    3     Real length, 24-bit little-endian (allows > 64K files)
  0x43    2     Checksum, little-endian
  0x45    59    Unused (0)

  The checksum is the 16-bit (mod-65536) sum of bytes 0..66 inclusive,
  stored at offset 0x43 (67). AMSDOS treats a file as headerless if this
  checksum does not match.

* Standard CPCEMU ".dsk" disk image container plus the AMSDOS "Data"
  format filesystem inside it (a variant of a CP/M 2.2 disk: single
  8-bit-clean directory, 1 KB allocation blocks). Verified against:
    - https://www.cpcwiki.eu/index.php/Format:DSK_disk_image_file_format
      (and its mirror at https://cpctech.cpcwiki.de/docs/dsk.html)
    - General CP/M 2.2 directory-entry semantics (user/EX/S1/S2/RC/
      allocation-block fields) used by AMSDOS, cross-checked against
      https://www.cpcwiki.eu/index.php/AMSDOS and
      https://www.cpcwiki.eu/index.php/Disc_format via search snippets,
      since cpcwiki.eu itself blocks unattended fetches (see above).

  Standard (non-extended) DSK was chosen over Extended DSK: every
  sector on an AMSDOS Data disk is a uniform 512 bytes, so there is no
  need for Extended DSK's per-track/per-sector size table, and standard
  DSK is the more widely supported, simpler-to-write format for this
  fixed, non-copy-protected layout.

  Disk Information Block (first 256 bytes of the file):
    0x00  34  "MV - CPCEMU Disk-File\r\nDisk-Info\r\n"
    0x22  14  Creator name
    0x30   1  Number of tracks (40)
    0x31   1  Number of sides (1)
    0x32   2  Track size in bytes, little-endian (includes the 256-byte
              Track Information Block header): 256 + 9*512 = 0x1300
    0x34  204 Unused (0)

  Track Information Block (256-byte header immediately followed by the
  track's sector data; one such block per track, laid out back-to-back
  starting at file offset 0x100):
    0x00  12  "Track-Info\r\n"
    0x0C   4  Unused (0)
    0x10   1  Track number
    0x11   1  Side number (0)
    0x12   2  Unused (0)
    0x14   1  Sector size code N; actual size = 128 << N (N=2 -> 512)
    0x15   1  Number of sectors (9)
    0x16   1  GAP#3 length (0x4E, the conventional value for this format)
    0x17   1  Filler byte (0xE5)
    0x18  72  Sector Information List: 9 entries * 8 bytes each:
                +0 track, +1 side, +2 sector ID, +3 size code,
                +4 FDC status 1, +5 FDC status 2, +6..7 data length (LE)
    0x100 ... 9 * 512 bytes of sector data, in the same order as the
              Sector Information List above.

  AMSDOS "Data" format parameters: 40 tracks, 1 side, 9 sectors/track of
  512 bytes each, sector IDs 0xC1..0xC9, 1 KB allocation blocks, 64
  directory entries (2 KB = blocks 0-1) with unused entries (and the
  unused tail of the directory) filled with 0xE5. Physical sector order
  on each track follows AMSDOS's own skew of 5 over 9 sectors -- C1, C6,
  C2, C7, C3, C8, C4, C9, C5 -- which is how a real AMSDOS-formatted disk
  lays sectors out; the *logical* sector number used for CP/M block
  addressing is always (sector ID - 0xC1), independent of this physical
  ordering.

  Directory entry (32 bytes), standard CP/M 2.2 layout as used by AMSDOS:
    0x00  1   User number (0xE5 = unused/deleted entry)
    0x01  8   Filename
    0x09  3   Extension
    0x0C  1   EX (low byte of the extent number)
    0x0D  1   S1 (reserved, 0)
    0x0E  1   S2 (high byte of the extent number, 0 on this small disk)
    0x0F  1   RC (128-byte records used in this extent, 0-128)
    0x10  16  Allocation: 16 block numbers, 1 byte each (block <= 179
              fits in a byte, so AMSDOS uses 8-bit block numbers here)

  One directory entry (one "extent") covers at most 16 blocks = 16 KB.
  A file bigger than 16 KB needs multiple directory entries with
  increasing EX (0, 1, 2, ...); only the last one has a partial RC.

Usage:
    python tools/cpc/mkdsk.py -o out.dsk [--load 0x1000] [--exec 0x1000] \\
        [--name PROG.BIN] input.bin [more.bin ...]

Addresses accept 0x1000, &1000 or $1000 notation (or plain decimal).
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# --------------------------------------------------------------------
# AMSDOS header
# --------------------------------------------------------------------

AMSDOS_HEADER_SIZE = 128
AMSDOS_CHECKSUM_RANGE = 67  # bytes 0..66 inclusive are checksummed

FILETYPE_BASIC = 0
FILETYPE_PROTECTED_BASIC = 1
FILETYPE_BINARY = 2

FIRMWARE_START = 0xA000  # approximate start of firmware variables; see PLAN


def parse_int(text: str) -> int:
    """Parses a CLI integer that may be plain decimal, 0x.., &.. or $.. hex."""
    text = text.strip()
    if text[:2].lower() == "0x":
        return int(text, 16)
    if text[:1] in ("&", "$"):
        return int(text[1:], 16)
    return int(text, 0)


def amsdos_name_parts(name: str) -> tuple[bytes, bytes]:
    """Splits a filename into (8-byte, 3-byte) upper-case, space-padded
    AMSDOS name/extension fields, per the AMSDOS_Header field layout."""
    name = name.strip().upper()
    if "." in name:
        base, ext = name.rsplit(".", 1)
    else:
        base, ext = name, ""

    base = base[:8]
    ext = ext[:3]
    if not base:
        raise ValueError(f"empty AMSDOS filename in {name!r}")

    return base.ljust(8).encode("ascii"), ext.ljust(3).encode("ascii")


def build_amsdos_header(
    name: str,
    data: bytes,
    *,
    load_addr: int,
    exec_addr: int,
    user: int = 0,
    filetype: int = FILETYPE_BINARY,
) -> bytes:
    """Builds the 128-byte AMSDOS header for `data` (the file's raw content,
    not including this header). Offsets per the module docstring / cpcwiki
    AMSDOS_Header."""
    base, ext = amsdos_name_parts(name)
    real_length = len(data)

    header = bytearray(AMSDOS_HEADER_SIZE)
    header[0x00] = user
    header[0x01:0x09] = base
    header[0x09:0x0C] = ext
    # 0x0C..0x0F: unused, block number / last-block flag: left at 0
    header[0x12] = filetype
    header[0x15:0x17] = struct.pack("<H", load_addr & 0xFFFF)
    # 0x17: "first block" flag, always 0 for a disk file
    header[0x18:0x1A] = struct.pack("<H", real_length & 0xFFFF)
    header[0x1A:0x1C] = struct.pack("<H", exec_addr & 0xFFFF)
    header[0x40:0x43] = struct.pack("<I", real_length & 0xFFFFFF)[:3]

    checksum = sum(header[0:AMSDOS_CHECKSUM_RANGE]) & 0xFFFF
    header[0x43:0x45] = struct.pack("<H", checksum)

    return bytes(header)


# --------------------------------------------------------------------
# AMSDOS "Data" format disk geometry
# --------------------------------------------------------------------

TRACKS = 40
SIDES = 1
SECTORS_PER_TRACK = 9
SECTOR_SIZE = 512
SECTOR_SIZE_CODE = 2  # 128 << 2 == 512
FIRST_SECTOR_ID = 0xC1
GAP3_LENGTH = 0x4E
FILLER_BYTE = 0xE5

# Physical order sectors are laid out in on each track (AMSDOS's skew of 5
# over 9 sectors): physical slot -> logical sector index (0..8). Logical
# sector index N always has ID FIRST_SECTOR_ID + N, regardless of where it
# physically sits on the track.
SECTOR_SKEW = [0, 5, 1, 6, 2, 7, 3, 8, 4]

BLOCK_SIZE = 1024  # 1 KB allocation blocks
DIR_ENTRY_SIZE = 32
DIR_ENTRIES = 64
DIR_BLOCKS = 2  # 64 * 32 = 2048 bytes = 2 blocks
EXTENT_BLOCKS = 16  # 16 blocks * 1KB = 16KB per directory entry/extent
EXTENT_SIZE = EXTENT_BLOCKS * BLOCK_SIZE
RECORD_SIZE = 128  # CP/M "record"; RC counts these
RECORDS_PER_EXTENT = EXTENT_SIZE // RECORD_SIZE  # 128

TOTAL_SECTORS = TRACKS * SIDES * SECTORS_PER_TRACK
TOTAL_BYTES = TOTAL_SECTORS * SECTOR_SIZE
TOTAL_BLOCKS = TOTAL_BYTES // BLOCK_SIZE  # 180
DATA_BLOCKS = TOTAL_BLOCKS - DIR_BLOCKS  # 178
MAX_DATA_BYTES = DATA_BLOCKS * BLOCK_SIZE  # 178 KB, matches PLAN's spec

DISK_INFO_IDENT = b"MV - CPCEMU Disk-File\r\nDisk-Info\r\n"
TRACK_INFO_IDENT = b"Track-Info\r\n"
TRACK_INFO_HEADER_SIZE = 0x100
TRACK_SIZE = TRACK_INFO_HEADER_SIZE + SECTORS_PER_TRACK * SECTOR_SIZE


class DiskFullError(Exception):
    pass


class DiskImage:
    """An in-memory AMSDOS "Data" format disk, ready to be serialised as a
    standard CPCEMU .dsk file. Sectors are addressed by their *logical*
    index (track * SECTORS_PER_TRACK + (sector_id - FIRST_SECTOR_ID)); the
    on-disk physical order is only applied when writing the .dsk file
    (see SECTOR_SKEW)."""

    def __init__(self) -> None:
        self._sectors = [bytearray([FILLER_BYTE] * SECTOR_SIZE) for _ in range(TOTAL_SECTORS)]
        self._directory = bytearray([FILLER_BYTE] * (DIR_ENTRIES * DIR_ENTRY_SIZE))
        self._next_block = DIR_BLOCKS
        self._next_dir_entry = 0

    def _set_block(self, block: int, block_data: bytes) -> None:
        assert len(block_data) == BLOCK_SIZE
        base = block * (BLOCK_SIZE // SECTOR_SIZE)
        for i in range(BLOCK_SIZE // SECTOR_SIZE):
            self._sectors[base + i][:] = block_data[i * SECTOR_SIZE : (i + 1) * SECTOR_SIZE]

    def add_file(
        self,
        name: str,
        raw_data: bytes,
        *,
        load_addr: int,
        exec_addr: int,
        user: int = 0,
        filetype: int = FILETYPE_BINARY,
    ) -> None:
        """Adds a file (its raw content, before the AMSDOS header) to the
        disk: builds and prepends the AMSDOS header, allocates blocks and
        directory entries (one entry per 16KB extent for files > 16KB),
        and writes the data into the image."""
        header = build_amsdos_header(
            name, raw_data, load_addr=load_addr, exec_addr=exec_addr, user=user, filetype=filetype
        )
        content = header + raw_data

        blocks_needed = -(-len(content) // BLOCK_SIZE)  # ceil div
        blocks_needed = max(blocks_needed, 1)
        extents_needed = -(-blocks_needed // EXTENT_BLOCKS)
        extents_needed = max(extents_needed, 1)

        if self._next_block + blocks_needed > TOTAL_BLOCKS:
            free_bytes = (TOTAL_BLOCKS - self._next_block) * BLOCK_SIZE
            raise DiskFullError(
                f"{name}: disk full: needs {blocks_needed} blocks "
                f"({len(content)} bytes with header) but only {free_bytes} "
                f"bytes ({TOTAL_BLOCKS - self._next_block} blocks) remain "
                f"of {MAX_DATA_BYTES} bytes total data capacity"
            )
        if self._next_dir_entry + extents_needed > DIR_ENTRIES:
            raise DiskFullError(
                f"{name}: disk full: needs {extents_needed} directory "
                f"entries but only {DIR_ENTRIES - self._next_dir_entry} "
                f"remain of {DIR_ENTRIES} total"
            )

        base, ext = amsdos_name_parts(name)
        blocks = list(range(self._next_block, self._next_block + blocks_needed))

        padded = content + bytes(blocks_needed * BLOCK_SIZE - len(content))
        for i, block in enumerate(blocks):
            self._set_block(block, padded[i * BLOCK_SIZE : (i + 1) * BLOCK_SIZE])

        remaining_records = -(-len(content) // RECORD_SIZE)  # ceil div, records used in total
        for ex in range(extents_needed):
            entry_blocks = blocks[ex * EXTENT_BLOCKS : (ex + 1) * EXTENT_BLOCKS]
            rc = min(remaining_records, RECORDS_PER_EXTENT)
            remaining_records -= rc

            entry = bytearray(DIR_ENTRY_SIZE)
            entry[0x00] = user
            entry[0x01:0x09] = base
            entry[0x09:0x0C] = ext
            entry[0x0C] = ex & 0xFF  # EX low byte
            entry[0x0D] = 0  # S1 (reserved)
            entry[0x0E] = (ex >> 5) & 0xFF  # S2: extent number high bits
            entry[0x0F] = rc
            alloc = bytes(entry_blocks) + bytes(EXTENT_BLOCKS - len(entry_blocks))
            entry[0x10:0x20] = alloc

            slot = self._next_dir_entry + ex
            self._directory[slot * DIR_ENTRY_SIZE : (slot + 1) * DIR_ENTRY_SIZE] = entry

        self._next_block += blocks_needed
        self._next_dir_entry += extents_needed

    def to_dsk_bytes(self) -> bytes:
        # Commit the directory into logical sectors 0..3 (blocks 0-1).
        for i in range(DIR_BLOCKS * (BLOCK_SIZE // SECTOR_SIZE)):
            self._sectors[i][:] = self._directory[i * SECTOR_SIZE : (i + 1) * SECTOR_SIZE]

        out = bytearray()

        disk_info = bytearray(TRACK_INFO_HEADER_SIZE)
        disk_info[0 : len(DISK_INFO_IDENT)] = DISK_INFO_IDENT
        disk_info[0x22:0x30] = b"mkdsk.py".ljust(14, b"\x00")
        disk_info[0x30] = TRACKS
        disk_info[0x31] = SIDES
        disk_info[0x32:0x34] = struct.pack("<H", TRACK_SIZE)
        out += disk_info

        for track in range(TRACKS):
            track_info = bytearray(TRACK_INFO_HEADER_SIZE)
            track_info[0 : len(TRACK_INFO_IDENT)] = TRACK_INFO_IDENT
            track_info[0x10] = track
            track_info[0x11] = 0  # side
            track_info[0x14] = SECTOR_SIZE_CODE
            track_info[0x15] = SECTORS_PER_TRACK
            track_info[0x16] = GAP3_LENGTH
            track_info[0x17] = FILLER_BYTE

            track_data = bytearray()
            for slot, logical in enumerate(SECTOR_SKEW):
                sector_id = FIRST_SECTOR_ID + logical
                entry_off = 0x18 + slot * 8
                track_info[entry_off + 0] = track
                track_info[entry_off + 1] = 0
                track_info[entry_off + 2] = sector_id
                track_info[entry_off + 3] = SECTOR_SIZE_CODE
                track_info[entry_off + 4] = 0  # FDC status 1
                track_info[entry_off + 5] = 0  # FDC status 2
                track_info[entry_off + 6 : entry_off + 8] = struct.pack("<H", SECTOR_SIZE)

                track_data += self._sectors[track * SECTORS_PER_TRACK + logical]

            out += track_info
            out += track_data

        return bytes(out)


# --------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Pack raw binaries into an AMSDOS-formatted CPCEMU .dsk disk image.",
    )
    parser.add_argument("inputs", metavar="input.bin", nargs="+", help="Raw binary file(s) to add to the disk")
    parser.add_argument("-o", "--output", required=True, help="Output .dsk file")
    parser.add_argument(
        "--load", type=parse_int, default=0x1000, help="Load address (default 0x1000). Accepts 0x, & or $ hex"
    )
    parser.add_argument(
        "--exec", dest="exec_addr", type=parse_int, default=None, help="Exec/entry address (default: same as --load)"
    )
    parser.add_argument(
        "--name",
        help="AMSDOS filename (8.3) for a single input file (default: the input file's own basename)",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.name and len(args.inputs) > 1:
        parser.error("--name can only be used with a single input file")

    load_addr = args.load
    exec_addr = args.exec_addr if args.exec_addr is not None else load_addr

    disk = DiskImage()

    for input_path_str in args.inputs:
        input_path = Path(input_path_str)
        try:
            raw_data = input_path.read_bytes()
        except OSError as exc:
            print(f"mkdsk.py: error: cannot read {input_path}: {exc}", file=sys.stderr)
            return 1

        name = args.name if args.name else input_path.name

        if load_addr + len(raw_data) > FIRMWARE_START:
            print(
                f"mkdsk.py: warning: {name}: load address 0x{load_addr:04X} + length "
                f"{len(raw_data)} bytes = 0x{load_addr + len(raw_data):04X}, which overlaps "
                f"the firmware area starting at 0x{FIRMWARE_START:04X}",
                file=sys.stderr,
            )

        try:
            disk.add_file(name, raw_data, load_addr=load_addr, exec_addr=exec_addr)
        except (DiskFullError, ValueError) as exc:
            print(f"mkdsk.py: error: {exc}", file=sys.stderr)
            return 1

    output_path = Path(args.output)
    output_path.write_bytes(disk.to_dsk_bytes())
    print(f"mkdsk.py: wrote {output_path} ({output_path.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
