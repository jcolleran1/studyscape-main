# SPDX-License-Identifier: MPL-2.0
# StudyScape — noise acquisition.
#
# Two backends, selected by NOISE_MODE env var:
#   "pin" (default) — MAX4466 on MCU A0, read via Bridge RPC
#   "usb"           — USB microphone via sounddevice (44.1kHz RMS -> dB)

from __future__ import annotations

import os
import time
from typing import Optional, Tuple


class NoiseSource:
    """Abstract: returns (level_str, numeric) per call."""

    def read(self) -> Tuple[str, float]:
        raise NotImplementedError

    def close(self):
        pass


# ---------------------------------------------------------------------------
# Pin-mic backend (MAX4466 on A0 -> MCU sketch -> Bridge RPC)
# ---------------------------------------------------------------------------
class PinMicNoiseSource(NoiseSource):
    def __init__(self, bridge):
        self._bridge = bridge

    def read(self) -> Tuple[str, float]:
        try:
            level = str(self._bridge.call("get_noise_level"))
            raw = float(self._bridge.call("get_noise_raw"))
            return level, raw
        except Exception as e:
            print(f"[noise/pin] RPC failed: {e}")
            return "low", 0.0


# ---------------------------------------------------------------------------
# USB-mic backend (sounddevice)
# ---------------------------------------------------------------------------
class UsbMicNoiseSource(NoiseSource):
    """Records 0.5 s chunks via sounddevice and returns RMS in approximate dB.

    Classification thresholds in dB (after the +90 offset used in the
    arduino_node legacy code):
        low    < 50 dB
        medium 50..65 dB
        loud   >= 65 dB
    Tune for your environment with the NOISE_LOW_DB and NOISE_MED_DB env vars.
    """

    def __init__(
        self,
        sample_rate: int = 44100,
        duration_s: float = 0.5,
        low_db: float = 50.0,
        med_db: float = 65.0,
    ):
        import numpy as np
        import sounddevice as sd  # type: ignore
        self._np = np
        self._sd = sd
        self.sample_rate = sample_rate
        self.duration_s = duration_s
        self.low_db = low_db
        self.med_db = med_db

    def read(self) -> Tuple[str, float]:
        try:
            n = int(self.duration_s * self.sample_rate)
            rec = self._sd.rec(n, samplerate=self.sample_rate, channels=1)
            self._sd.wait()
            rms = float(self._np.sqrt(self._np.mean(rec ** 2)))
            db = 20.0 * self._np.log10(rms + 1e-9) + 90.0
        except Exception as e:
            print(f"[noise/usb] capture failed: {e}")
            return "low", 0.0

        if db < self.low_db:
            return "low", db
        if db < self.med_db:
            return "medium", db
        return "loud", db


# ---------------------------------------------------------------------------
# Factory
# ---------------------------------------------------------------------------
def make_noise_source(mode: str, bridge=None) -> NoiseSource:
    mode = (mode or "pin").lower().strip()
    if mode == "pin":
        if bridge is None:
            raise ValueError("Pin-mic mode requires a Bridge reference")
        return PinMicNoiseSource(bridge)
    if mode == "usb":
        low = float(os.environ.get("NOISE_LOW_DB", "50"))
        med = float(os.environ.get("NOISE_MED_DB", "65"))
        return UsbMicNoiseSource(low_db=low, med_db=med)
    raise ValueError(f"Unknown NOISE_MODE: {mode!r}. Use 'pin' or 'usb'.")
