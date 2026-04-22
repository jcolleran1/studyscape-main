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
#   YOLO_MODEL_PATH     path to yolov8n.onnx (default ./models/yolov8n.onnx)
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
YOLO_MODEL_PATH     = os.environ.get(
    "YOLO_MODEL_PATH", os.path.join(HERE, "models", "yolov8n.onnx")
)
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
        from occupancy import OccupancyDetector, open_camera
        detector = OccupancyDetector(YOLO_MODEL_PATH)
        print(f"[yolo] model loaded: {YOLO_MODEL_PATH}")
        cap = open_camera(CAMERA_INDEX)
        if not cap.isOpened():
            print(f"[camera] /dev/video{CAMERA_INDEX} did not open; "
                  f"occupancy will report 0")
            cap = None
        else:
            print(f"[camera] /dev/video{CAMERA_INDEX} ready")
    except FileNotFoundError as e:
        print(f"[yolo] {e}; occupancy will report 0 (drop yolov8n.onnx "
              f"into python/models/ to enable)")
    except Exception as e:
        print(f"[yolo/camera] init failed: {e}; occupancy will report 0")
else:
    print("[camera] disabled via ENABLE_CAMERA=0")


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
        print(f"[yolo] inference error: {e}")
        return 0


def _majority(levels) -> str:
    if not levels:
        return "low"
    counts = {}
    for lvl in levels:
        counts[lvl] = counts.get(lvl, 0) + 1
    return max(counts, key=counts.get)


def loop():
    global last_report_ts

    # --- per-tick sample ---------------------------------------------------
    occ_count = _read_occupancy()
    occupancy_ring.append(occ_count)

    level, raw = noise_source.read()
    noise_raw_ring.append(raw)
    noise_level_ring.append(level)

    now = time.monotonic()
    if now - last_report_ts < REPORT_INTERVAL_S:
        time.sleep(LOOP_INTERVAL_S)
        return
    last_report_ts = now

    # --- aggregate window --------------------------------------------------
    avg_occ = sum(occupancy_ring) / len(occupancy_ring) if occupancy_ring else 0.0
    occ_int = int(round(avg_occ))
    occ_pct = min(100, int(round(100.0 * avg_occ / CAPACITY)))

    avg_noise_raw = (sum(noise_raw_ring) / len(noise_raw_ring)
                     if noise_raw_ring else 0.0)
    noise_level = _majority(list(noise_level_ring))

    print(f"[report] occ={occ_int} ({occ_pct}%)  "
          f"noise={noise_level} raw={avg_noise_raw:.1f}  "
          f"mode={NOISE_MODE}")

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

    occupancy_ring.clear()
    noise_raw_ring.clear()
    noise_level_ring.clear()
    time.sleep(LOOP_INTERVAL_S)


App.run(user_loop=loop)
