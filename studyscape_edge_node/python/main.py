# SPDX-License-Identifier: MPL-2.0
# StudyScape — Linux orchestrator.
#
# Runs on the QRB2210 MPU. Reads noise (via pin mic OR USB mic), optionally
# reads camera frames for occupancy, averages over 30 s, writes to Firestore.
#
# Env var configuration:
#   NOISE_MODE          "pin" (default) | "usb"
#   ENABLE_CAMERA       "1" (default) | "0"
#   CAMERA_INDEX        integer (default 0)
#   REPORT_INTERVAL_S   seconds between Firestore writes (default 30)
#   LOOP_INTERVAL_S     seconds between samples inside the window (default 1.0)
#   OCCUPANCY_BACKEND   "brick" (default) | "yolo"
#                       brick = Video Object Detection brick (yolox-object-detection)
#                       yolo  = local ONNX inference (fallback)
#   YOLO_MODEL_PATH     path to YOLO ONNX (used only when backend=yolo)
#                       default: ./models/yolov8n.onnx (autodetected)
#   FIREBASE_SERVICE_ACCOUNT  path to service account JSON
#                             (default /home/arduino/serviceAccount.json)
#   ROOM_CONFIG_PATH    path to room_config.json (default ./room_config.json)

import json
import os
import signal
import sys
import time
from collections import deque

from arduino.app_utils import App, Bridge

import firebase_writer
from noise import make_noise_source


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
HERE                = os.path.dirname(os.path.abspath(__file__))
NOISE_MODE          = os.environ.get("NOISE_MODE", "pin").lower()
ENABLE_CAMERA       = os.environ.get("ENABLE_CAMERA", "1") == "1"
CAMERA_INDEX        = int(os.environ.get("CAMERA_INDEX", "0"))
REPORT_INTERVAL_S   = int(os.environ.get("REPORT_INTERVAL_S", "30"))
LOOP_INTERVAL_S     = float(os.environ.get("LOOP_INTERVAL_S", "1.0"))
OCCUPANCY_BACKEND   = os.environ.get("OCCUPANCY_BACKEND", "yolo").lower()
def _autodetect_model_path() -> str:
    """Pick the first existing ONNX model in models/, in preference order."""
    candidates = ["yolo26n.onnx", "yolo11n.onnx", "yolov8n.onnx"]
    for name in candidates:
        p = os.path.join(HERE, "models", name)
        if os.path.exists(p):
            return p
    # Fall back to the v8n path even if missing — main.py's error path
    # will print a helpful message.
    return os.path.join(HERE, "models", "yolov8n.onnx")


YOLO_MODEL_PATH     = os.environ.get("YOLO_MODEL_PATH", _autodetect_model_path())
ROOM_CONFIG_PATH    = os.environ.get(
    "ROOM_CONFIG_PATH", os.path.join(HERE, "room_config.json")
)


# ---------------------------------------------------------------------------
# Load room config
# ---------------------------------------------------------------------------
try:
    with open(ROOM_CONFIG_PATH) as f:
        ROOM_META = json.load(f)
    print(f"[config] loaded room: {ROOM_META['space_id']} "
          f"({ROOM_META.get('space_name', '?')})")
except Exception as e:
    print(f"[config] failed to load {ROOM_CONFIG_PATH}: {e}")
    ROOM_META = {
        "space_id": "unknown",
        "space_name": "Unknown space",
        "building": "",
        "building_index": 0,
        "floor": 0,
        "location_line": "",
        "capacity": 10,
        "device_id": "device_000",
    }

DEVICE_ID = ROOM_META.get("device_id", "device_000")
CAPACITY  = max(1, int(ROOM_META.get("capacity", 10)))


# ---------------------------------------------------------------------------
# Init Firebase (non-fatal if creds are missing)
# ---------------------------------------------------------------------------
firebase_writer.init_firebase()


# ---------------------------------------------------------------------------
# Init noise source
# ---------------------------------------------------------------------------
print(f"[noise] mode={NOISE_MODE}")
try:
    noise_source = make_noise_source(NOISE_MODE, bridge=Bridge)
    print(f"[noise] ready ({NOISE_MODE} backend)")
except Exception as e:
    print(f"[noise] init failed ({e}); falling back to pin mode")
    noise_source = make_noise_source("pin", bridge=Bridge)


# ---------------------------------------------------------------------------
# Init camera + YOLO (optional)
# ---------------------------------------------------------------------------
detector = None
cap = None
if ENABLE_CAMERA:
    try:
        if OCCUPANCY_BACKEND == "brick":
            print("[occupancy] backend=brick (Video Object Detection)")
            from occupancy_brick import OccupancyDetector, open_camera
        elif OCCUPANCY_BACKEND == "yolo":
            print("[occupancy] backend=yolo (local ONNX fallback)")
            from occupancy import OccupancyDetector, open_camera
        else:
            print(f"[occupancy] unknown OCCUPANCY_BACKEND={OCCUPANCY_BACKEND!r}; "
                  f"defaulting to brick")
            from occupancy_brick import OccupancyDetector, open_camera

        detector = OccupancyDetector(YOLO_MODEL_PATH)  # arg ignored by brick path
        cap = open_camera(CAMERA_INDEX)                # brick path returns a shim
        if not cap.isOpened():
            print("[occupancy] camera shim not ready; occupancy will report 0")
            cap = None
    except Exception as e:
        print(f"[occupancy] init failed: {e}; occupancy will report 0")
else:
    print("[occupancy] disabled via ENABLE_CAMERA=0")


# ---------------------------------------------------------------------------
# Graceful shutdown
# ---------------------------------------------------------------------------
def _handle_shutdown(*_):
    print("[shutdown] marking device offline…")
    try:
        firebase_writer.mark_device_offline(DEVICE_ID)
    finally:
        if cap is not None:
            cap.release()
        sys.exit(0)

signal.signal(signal.SIGTERM, _handle_shutdown)
signal.signal(signal.SIGINT, _handle_shutdown)


# ---------------------------------------------------------------------------
# Main loop — samples inside a 30 s window, then reports
# ---------------------------------------------------------------------------
# Ring for occupancy samples (1 Hz -> 30 samples over the window)
occupancy_ring: deque = deque(maxlen=max(1, REPORT_INTERVAL_S))
# Ring for noise samples (we take one reading per loop iteration as well)
noise_raw_ring: deque = deque(maxlen=max(1, REPORT_INTERVAL_S))
# Most common classification in window (majority vote)
noise_level_ring: deque = deque(maxlen=max(1, REPORT_INTERVAL_S))

last_report_ts = time.monotonic()


def _read_occupancy() -> int:
    if cap is None or detector is None:
        return 0
    ok, frame = cap.read()
    if not ok or frame is None:
        return 0
    try:
        return detector.count_people(frame)
    except Exception as e:
        print(f"[occupancy] read error: {e}")
        return 0


def _majority(levels) -> str:
    if not levels:
        return "low"
    counts = {}
    for lvl in levels:
        counts[lvl] = counts.get(lvl, 0) + 1
    return max(counts, key=counts.get)


# ---------------------------------------------------------------------------
# Hysteresis with escape-valve — stabilizes reports across windows without
# permanently masking real changes.
#
# Behavior:
#   - If new estimate is within HYSTERESIS_DELTA of the last reported value,
#     normally we keep the last value (suppresses brief flicker).
#   - BUT if the new estimate has *consistently* disagreed with the reported
#     value for HYSTERESIS_PERSISTENCE consecutive windows, we accept the
#     change. This stops the smoother from latching forever onto a stale
#     number when reality has shifted by 1 person.
#   - If the new estimate jumps by MORE than HYSTERESIS_DELTA, accept it
#     immediately (a real change of 2+ people is real).
#
# Set HYSTERESIS_DELTA=0 to disable hysteresis entirely.
HYSTERESIS_DELTA       = int(os.environ.get("HYSTERESIS_DELTA", "1"))
HYSTERESIS_PERSISTENCE = int(os.environ.get("HYSTERESIS_PERSISTENCE", "3"))

_last_reported_occ: int = 0
_pending_value: int = 0          # the value that's been pushing for a change
_pending_count: int = 0          # how many consecutive windows it's pushed


def _apply_hysteresis(new_occ: int) -> int:
    """Smooth the reported value while still allowing real changes through.

    Returns the value to report. Updates the persistence counters as a
    side effect so consecutive disagreements eventually win.
    """
    global _last_reported_occ, _pending_value, _pending_count

    # Hysteresis disabled — pass through.
    if HYSTERESIS_DELTA <= 0:
        _last_reported_occ = new_occ
        _pending_value = new_occ
        _pending_count = 0
        return new_occ

    diff = abs(new_occ - _last_reported_occ)

    # Big jump: accept immediately and reset persistence.
    if diff > HYSTERESIS_DELTA:
        _last_reported_occ = new_occ
        _pending_value = new_occ
        _pending_count = 0
        return new_occ

    # Within tolerance and matches what's already reported — nothing pending.
    if new_occ == _last_reported_occ:
        _pending_value = new_occ
        _pending_count = 0
        return _last_reported_occ

    # Small disagreement. Track persistence: how many windows in a row has
    # this same new value been pushing for a change?
    if new_occ == _pending_value:
        _pending_count += 1
    else:
        _pending_value = new_occ
        _pending_count = 1

    # Escape valve: if it's been pushing for long enough, accept the change.
    if _pending_count >= HYSTERESIS_PERSISTENCE:
        _last_reported_occ = new_occ
        _pending_count = 0
        return new_occ

    # Otherwise hold the previous reported value.
    return _last_reported_occ


def loop():
    global last_report_ts

    # --- per-tick sample ---------------------------------------------------
    # Occupancy is no longer polled here: the brick fires its own callback
    # every frame and we read the rolling max at report time. We still
    # call _read_occupancy() once for backward compatibility with logging
    # but its return value is unused for the report.
    _ = _read_occupancy()

    level, raw = noise_source.read()
    noise_raw_ring.append(raw)
    noise_level_ring.append(level)

    now = time.monotonic()
    if now - last_report_ts < REPORT_INTERVAL_S:
        time.sleep(LOOP_INTERVAL_S)
        return
    last_report_ts = now

    # --- aggregate window --------------------------------------------------
    # Occupancy: most stable count across the recent window.
    #
    # Method preference (works on BOTH brick and YOLO backends — both classes
    # expose the same API in v1.4):
    #   1. get_robust_count: median of multiple percentiles — most stable
    #   2. get_rolling_percentile: single percentile fallback
    #   3. get_rolling_max: legacy peak — last resort, susceptible to spikes
    if detector is not None and hasattr(detector, "get_robust_count"):
        raw_occ = int(detector.get_robust_count(window_s=30))
    elif detector is not None and hasattr(detector, "get_rolling_percentile"):
        raw_occ = int(detector.get_rolling_percentile(window_s=30, percentile=75))
    elif detector is not None and hasattr(detector, "get_rolling_max"):
        raw_occ = int(detector.get_rolling_max(window_s=30))
    else:
        raw_occ = 0

    # Hysteresis: suppress ±1 person bounces between consecutive reports.
    occ_int = _apply_hysteresis(raw_occ)

    if detector is not None:
        try:
            cb_total, cb_person = detector.get_callback_stats()
        except Exception:
            cb_total, cb_person = 0, 0
        try:
            detector.reset_window()
        except Exception:
            pass
    else:
        cb_total, cb_person = 0, 0

    occ_pct = min(100, int(round(100.0 * occ_int / CAPACITY)))

    avg_noise_raw = (sum(noise_raw_ring) / len(noise_raw_ring)
                     if noise_raw_ring else 0.0)
    noise_level = _majority(list(noise_level_ring))

    print(f"[report] occ={occ_int} ({occ_pct}%)  raw={raw_occ}  "
          f"noise={noise_level} raw_noise={avg_noise_raw:.1f}  "
          f"mode={NOISE_MODE}  backend={OCCUPANCY_BACKEND}  "
          f"frames={cb_total} with_person={cb_person}")

    # try Firebase init again in case creds were just dropped in
    firebase_writer.init_firebase()
    firebase_writer.write_reading(
        room_meta=ROOM_META,
        device_id=DEVICE_ID,
        occupancy=occ_int,
        occupancy_percent=occ_pct,
        noise_level=noise_level,
        noise_raw=avg_noise_raw,
        noise_source=NOISE_MODE,
    )

    noise_raw_ring.clear()
    noise_level_ring.clear()
    time.sleep(LOOP_INTERVAL_S)


App.run(user_loop=loop)
