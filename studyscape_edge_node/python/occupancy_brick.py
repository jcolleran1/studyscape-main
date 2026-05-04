# SPDX-License-Identifier: MPL-2.0
# StudyScape — occupancy detector backed by the Video Object Detection brick.
#
# This is a drop-in replacement for occupancy.py. It exposes the same public
# API (OccupancyDetector + open_camera) so main.py can switch between the two
# backends with a single env var.
#
# Why the brick:
#   - Native to App Lab; deployment, model management, and camera ownership
#     are all handled by the runtime.
#   - The brick's default model on the Uno Q is yolox-object-detection, which
#     already includes the COCO "person" class. No custom training required
#     to get a working person counter.
#   - We can swap in a custom Edge Impulse model later without touching code.
#
# Why YOLO ONNX is kept as a fallback (in occupancy.py):
#   - YoloX-Nano can undercount people on overhead camera angles compared to
#     YOLOv8n / YOLO26n. The fallback exists so the system stays functional
#     if the brick model proves insufficient in SCDI deployment.
#
# Public API (matches occupancy.py exactly, plus get_rolling_percentile):
#   - OccupancyDetector(model_path, ...)                  (model_path ignored here)
#   - OccupancyDetector.count_people(frame_bgr)           (returns latest sample)
#   - OccupancyDetector.get_rolling_max(window_s)         (peak in last N seconds)
#   - OccupancyDetector.get_rolling_percentile(...)       (percentile — preferred)
#   - OccupancyDetector.get_callback_stats()
#   - OccupancyDetector.reset_window()
#   - open_camera(index, ...)                             (no-op shim — brick owns
#                                                          the camera; returns a
#                                                          fake VideoCapture)
#
# v1.4 — adds get_rolling_percentile() to fix the "spurious high frames latch
# the rolling max" problem observed in SCDI testing on 2026-05-01: with 4 real
# people in the room, occasional frames double-counted jackets/reflections as
# people, so get_rolling_max() reported 5 or 6 consistently. The 75th
# percentile across the same samples reports 4 reliably.

from __future__ import annotations

import os
import threading
import time
from collections import deque
from typing import Optional


# ---------------------------------------------------------------------------
# Tunables
# ---------------------------------------------------------------------------
PERSON_LABEL = "person"          # Default COCO label for yolox-object-detection
# Confidence threshold env-tunable so it can be raised in deployment without
# editing source. Higher rejects spurious boxes (chairs, jackets, monitors)
# but may also drop real distant or partially-occluded people.
DEFAULT_CONF_THRESHOLD = float(os.environ.get("BRICK_CONF_THRESHOLD", "0.40"))
DEFAULT_DEBOUNCE_SEC = 0.0       # 0 = invoke callback every frame; aggregation
                                 # happens in our rolling buffer instead.
DEFAULT_ROLLING_WINDOW_S = 30    # Matches REPORT_INTERVAL_S so reports reflect
                                 # the most recent window.
DEFAULT_PERCENTILE = 75          # 75th percentile: forgives frames that miss
                                 # a person, discards spurious high frames.


# ---------------------------------------------------------------------------
# Module-level state for the rolling sample buffer
# ---------------------------------------------------------------------------
_state_lock = threading.Lock()
_latest_count = 0
_callback_count = 0
_person_callback_count = 0
_samples: deque = deque(maxlen=2000)


def _record_sample(count: int) -> None:
    global _latest_count, _callback_count, _person_callback_count
    now = time.time()
    with _state_lock:
        _callback_count += 1
        if count > 0:
            _person_callback_count += 1
        _latest_count = count
        _samples.append((now, count))


# ---------------------------------------------------------------------------
# Brick wiring
# ---------------------------------------------------------------------------
_brick = None
_brick_started = False


def _make_on_all_detections():
    """Build the on_detect_all callback for the brick.

    The brick fires on_detect_all once per frame that produces ANY detections.
    Frames with zero detections do not fire the callback at all, so we rely
    on the per-frame callback frequency rather than absence-as-signal.
    """
    def on_all_detections(detections: dict) -> None:
        # detections is {label: [ {confidence, bounding_box_xyxy}, ... ]}
        boxes = detections.get(PERSON_LABEL, [])
        count = len(boxes)
        _record_sample(count)
    return on_all_detections


def _start_brick(confidence: float, debounce_sec: float):
    """Initialize and start the VideoObjectDetection brick.

    Returns the brick instance, or None if initialization failed (e.g. the
    brick is not available in the current runtime — useful for local dev).
    """
    global _brick, _brick_started

    if _brick is not None:
        return _brick

    try:
        from arduino.app_bricks.video_objectdetection import VideoObjectDetection
    except Exception as e:
        print(f"[occupancy/brick] VideoObjectDetection import failed: {e}")
        print("[occupancy/brick] Is the 'arduino:video_object_detection' brick "
              "declared in app.yaml? Falling back to no-op.")
        return None

    try:
        _brick = VideoObjectDetection(
            confidence=confidence,
            debounce_sec=debounce_sec,
            camera_preview=False,  # No need for raw frames on this code path
        )
        _brick.on_detect_all(_make_on_all_detections())
        _brick.start()
        _brick_started = True
        print(f"[occupancy/brick] VideoObjectDetection started "
              f"(confidence={confidence}, debounce_sec={debounce_sec})")
        return _brick
    except Exception as e:
        print(f"[occupancy/brick] failed to start brick: {e}")
        _brick = None
        return None


# ---------------------------------------------------------------------------
# Heartbeat thread — record a zero sample at idle so absent detections
# decay the rolling buffer correctly.
# ---------------------------------------------------------------------------
_heartbeat_stop = threading.Event()
_heartbeat_thread: Optional[threading.Thread] = None
_HEARTBEAT_INTERVAL_S = 1.0
_HEARTBEAT_QUIET_GRACE_S = 2.0  # If no callback within this window, log a 0.


def _heartbeat_loop() -> None:
    """Records a zero-count sample whenever the brick has gone quiet.

    Without this, an empty room never appends new samples, and the rolling
    aggregates stay elevated until the rolling window expires. With it,
    the rolling max / percentile decay correctly to zero.
    """
    print("[occupancy/brick] heartbeat started")
    while not _heartbeat_stop.is_set():
        time.sleep(_HEARTBEAT_INTERVAL_S)
        with _state_lock:
            if _samples:
                last_ts, _ = _samples[-1]
                quiet_for = time.time() - last_ts
            else:
                quiet_for = float("inf")
        if quiet_for >= _HEARTBEAT_QUIET_GRACE_S:
            _record_sample(0)
    print("[occupancy/brick] heartbeat stopped")


def _start_heartbeat() -> None:
    global _heartbeat_thread
    if _heartbeat_thread is not None and _heartbeat_thread.is_alive():
        return
    _heartbeat_stop.clear()
    _heartbeat_thread = threading.Thread(
        target=_heartbeat_loop, name="occupancy-brick-heartbeat", daemon=True
    )
    _heartbeat_thread.start()


# ---------------------------------------------------------------------------
# Public API — mirrors occupancy.py
# ---------------------------------------------------------------------------
class OccupancyDetector:
    """
    Brick-backed person counter.

    The constructor accepts the same arguments as the YOLO-backed version
    so main.py is interchangeable. ``model_path`` is ignored here — the brick
    manages model selection via app.yaml / Brick Configuration in App Lab.
    """

    def __init__(
        self,
        model_path: str = "",                 # ignored, present for API parity
        input_size: int = 640,                # ignored
        conf_threshold: float = DEFAULT_CONF_THRESHOLD,
        iou_threshold: float = 0.45,          # ignored — handled by the model
        debounce_sec: float = DEFAULT_DEBOUNCE_SEC,
    ):
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold
        self.debounce_sec = debounce_sec

        _start_brick(confidence=conf_threshold, debounce_sec=debounce_sec)
        _start_heartbeat()

    def count_people(self, frame_bgr=None) -> int:
        """Most recent person count from the brick callback."""
        with _state_lock:
            return _latest_count

    def get_rolling_max(self, window_s: float = DEFAULT_ROLLING_WINDOW_S) -> int:
        """Peak person count in the last `window_s` seconds.

        WARNING: get_rolling_max latches onto spurious high frames (e.g.
        a jacket on a chair briefly boxed as a person). Prefer
        get_rolling_percentile() unless you specifically want the peak.
        """
        cutoff = time.time() - window_s
        with _state_lock:
            return max(
                (count for ts, count in _samples if ts >= cutoff),
                default=0,
            )

    def get_rolling_percentile(
        self,
        window_s: float = DEFAULT_ROLLING_WINDOW_S,
        percentile: float = DEFAULT_PERCENTILE,
    ) -> int:
        """Count at the given percentile across samples in the last window_s seconds.

        More robust than max — discards spurious high frames where the model
        momentarily double-counts (e.g. a jacket on a chair gets boxed
        alongside the person sitting on it). The 75th percentile is forgiving
        of frames that miss a person but rejects the top quartile of frames
        as outliers.

        Tuning guide:
          - percentile=50 (median): under-counts if the model regularly
            misses a person.
          - percentile=75 (default): balanced — recovers from misses,
            rejects spurious high frames.
          - percentile=85: trust higher-count frames more. Use if the model
            consistently misses people.
          - percentile=100: equivalent to get_rolling_max — not recommended.
        """
        cutoff = time.time() - window_s
        with _state_lock:
            counts = [count for ts, count in _samples if ts >= cutoff]
        if not counts:
            return 0
        counts.sort()
        # Percentile index — clamp to valid range
        idx = min(len(counts) - 1, int(len(counts) * percentile / 100))
        return counts[idx]

    def get_robust_count(
        self,
        window_s: float = DEFAULT_ROLLING_WINDOW_S,
        percentiles: tuple = (40, 55, 70, 80),
    ) -> int:
        """Median of multiple percentiles — most stable single-number estimate.

        A single percentile (e.g. 75th) can still flicker between consecutive
        report windows when the underlying frame distribution is bimodal —
        for example with 4 real people, half the frames detect 4 and half
        detect 5 (with a misidentified jacket). The 75th percentile then
        bounces between 4 and 5 across reports.

        This method takes 4 different percentile cuts (40, 55, 70, 80) and
        returns the median of those. The reported number is the count where
        the most percentile cuts agree, which is far more stable across
        reports than any single percentile.

        This is the recommended method for production reporting.
        """
        cutoff = time.time() - window_s
        with _state_lock:
            counts = [count for ts, count in _samples if ts >= cutoff]
        if not counts:
            return 0
        counts.sort()
        n = len(counts)
        picks = []
        for p in percentiles:
            idx = min(n - 1, int(n * p / 100))
            picks.append(counts[idx])
        picks.sort()
        mid = len(picks) // 2
        if len(picks) % 2:
            return int(picks[mid])
        return int(round((picks[mid - 1] + picks[mid]) / 2))

    def get_window_max(self) -> int:
        """Peak count across the entire rolling buffer."""
        with _state_lock:
            return max((count for _, count in _samples), default=0)

    def get_callback_stats(self) -> tuple[int, int]:
        """(total_callbacks, callbacks_with_person) since last reset."""
        with _state_lock:
            return _callback_count, _person_callback_count

    def reset_window(self) -> None:
        """Reset per-report counters. Does NOT clear the rolling sample buffer."""
        global _callback_count, _person_callback_count
        with _state_lock:
            _callback_count = 0
            _person_callback_count = 0


# ---------------------------------------------------------------------------
# Camera shim
# ---------------------------------------------------------------------------
# The brick OWNS the camera. main.py's _read_occupancy() expects a cv2-style
# capture object with isOpened() / read() / release(). We return a fake one
# that always returns "no frame" so main.py's per-tick poll is a harmless
# no-op; the actual person count comes via the brick callback.

class _FakeCapture:
    """Minimal cv2.VideoCapture stand-in for compatibility with main.py."""

    def __init__(self):
        self._open = True

    def isOpened(self) -> bool:
        return self._open

    def read(self):
        # (ok, frame) — we never produce a frame on this path.
        return False, None

    def release(self) -> None:
        self._open = False


def open_camera(device_index: int = 0, width: int = 1280, height: int = 720):
    """No-op camera opener — the brick owns /dev/video1 on the Uno Q.

    Returns a fake VideoCapture so main.py's existing logic doesn't break.
    """
    print(f"[occupancy/brick] open_camera(index={device_index}) — brick owns "
          f"the camera; returning fake capture for API compatibility")
    return _FakeCapture()