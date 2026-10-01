# --------------------------------------------------------------------
# SPDX-License-Identifier: AGPL-3.0-or-later
# Amstrad CPC: converts constant BEEP arguments into the firmware sound
# manager's units (src/lib/arch/cpc/runtime/io/sound/beeper.asm).
# --------------------------------------------------------------------

from src.arch.z80.beep import TABLE, BeepError

__all__ = "BeepError", "getDEHL"

AY_TONE_CLOCK = 62500  # 1 MHz AY clock / 16: frequency = 62500 / period
MAX_PERIOD = 4095  # the AY's 12-bit tone period


def getDEHL(duration: float, pitch: float) -> tuple[int, int]:
    """Converts BEEP duration (seconds), pitch (semitones from middle C)
    into (DE, HL) = (duration in 1/100 s, AY tone period), for __BEEPER.
    Same ranges as the Spectrum: pitch -60..127, duration 0..10.
    """
    if not -60 <= int(pitch) <= 127:
        raise BeepError("Pitch out of range: must be between [-60, 127]")

    if duration < 0 or duration > 10:
        raise BeepError("Invalid duration: must be between [0, 10]")

    frequency = TABLE[0] * 2.0 ** (pitch / 12.0)
    period = min(MAX_PERIOD, max(1, int(0.5 + AY_TONE_CLOCK / frequency)))
    return int(0.5 + duration * 100), period
