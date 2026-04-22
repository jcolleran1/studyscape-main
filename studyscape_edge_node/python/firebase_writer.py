# SPDX-License-Identifier: MPL-2.0
# StudyScape — Firestore writer.
#
# Schema written to Firestore (what the Flutter app streams from):
#
#   spaces/<space_id>
#     space_id: string
#     space_name: string
#     building: string
#     building_index: int
#     floor: int
#     location_line: string
#     capacity: int
#     occupancy: int                        # averaged person count
#     occupancy_percent: int                # 0..100
#     occupancy_level: "low"|"medium"|"high"
#     noise: "low"|"medium"|"loud"
#     noise_label: "Quiet Zone"|"Low Hum"|"Moderate Buzz"|"Loud"
#     noise_hint: string                    # e.g. "Headphones Rec."
#     noise_raw: float                      # raw ADC p2p OR dB
#     noise_source: "pin"|"usb"
#     status: "online"|"offline"
#     updated_at: timestamp
#     history/<auto-id>                     # time-series
#       occupancy, occupancy_percent, noise, noise_raw, timestamp
#
#   devices/<device_id>
#     status, location, updated_at

from __future__ import annotations

import os
import traceback
from typing import Optional


DEFAULT_CRED_PATH = "/home/arduino/serviceAccount.json"
_NOISE_LABELS = {
    "low":    ("Quiet Zone",   ""),
    "medium": ("Moderate Buzz", "Headphones Rec."),
    "loud":   ("Loud",         "Find a quieter spot"),
}
# Map "high" -> "loud" so Flutter-side labels stay consistent.
_NOISE_ALIASES = {"high": "loud"}

_db = None
_initialised = False
_warned_no_creds = False


def _noise_label(level: str) -> tuple[str, str]:
    level = _NOISE_ALIASES.get(level, level)
    return _NOISE_LABELS.get(level, ("Low Hum", ""))


def classify_occupancy_level(percent: int) -> str:
    if percent < 34:
        return "low"
    if percent < 67:
        return "medium"
    return "high"


def init_firebase(cred_path: Optional[str] = None) -> bool:
    """Lazy init. Returns True when Firestore is available."""
    global _db, _initialised, _warned_no_creds
    if _db is not None:
        return True
    path = cred_path or os.environ.get("FIREBASE_SERVICE_ACCOUNT", DEFAULT_CRED_PATH)
    if not os.path.exists(path):
        if not _warned_no_creds:
            print(f"[firebase] no credentials at {path}; running in "
                  f"calibration-only mode (readings printed locally)")
            _warned_no_creds = True
        return False
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
        if not firebase_admin._apps:
            cred = credentials.Certificate(path)
            firebase_admin.initialize_app(cred)
        _db = firestore.client()
        _initialised = True
        print(f"[firebase] initialised with {path}")
        return True
    except Exception as e:
        print(f"[firebase] init failed: {e}")
        traceback.print_exc()
        return False


def write_reading(
    *,
    room_meta: dict,
    device_id: str,
    occupancy: int,
    occupancy_percent: int,
    noise_level: str,
    noise_raw: float,
    noise_source: str,
) -> bool:
    if _db is None:
        return False
    try:
        from firebase_admin import firestore

        space_id = room_meta["space_id"]
        label, hint = _noise_label(noise_level)

        payload = {
            "space_id":           space_id,
            "space_name":         room_meta.get("space_name", space_id),
            "building":           room_meta.get("building", ""),
            "building_index":     room_meta.get("building_index", 0),
            "floor":              room_meta.get("floor", 0),
            "location_line":      room_meta.get("location_line", ""),
            "capacity":           room_meta.get("capacity", 0),

            "occupancy":          int(occupancy),
            "occupancy_percent":  int(occupancy_percent),
            "occupancy_level":    classify_occupancy_level(occupancy_percent),

            "noise":              _NOISE_ALIASES.get(noise_level, noise_level),
            "noise_label":        label,
            "noise_hint":         hint,
            "noise_raw":          float(round(noise_raw, 2)),
            "noise_source":       noise_source,

            "status":             "online",
            "device_id":          device_id,
            "updated_at":         firestore.SERVER_TIMESTAMP,
        }

        space_ref = _db.collection("spaces").document(space_id)
        space_ref.set(payload, merge=True)
        space_ref.collection("history").add({
            "occupancy":          int(occupancy),
            "occupancy_percent":  int(occupancy_percent),
            "noise":              _NOISE_ALIASES.get(noise_level, noise_level),
            "noise_raw":          float(round(noise_raw, 2)),
            "timestamp":          firestore.SERVER_TIMESTAMP,
        })

        _db.collection("devices").document(device_id).set({
            "status":     "online",
            "location":   space_id,
            "updated_at": firestore.SERVER_TIMESTAMP,
        }, merge=True)
        return True
    except Exception as e:
        print(f"[firebase] write failed: {e}")
        return False


def mark_device_offline(device_id: str) -> None:
    if _db is None:
        return
    try:
        from firebase_admin import firestore
        _db.collection("devices").document(device_id).set({
            "status":     "offline",
            "updated_at": firestore.SERVER_TIMESTAMP,
        }, merge=True)
    except Exception:
        pass
