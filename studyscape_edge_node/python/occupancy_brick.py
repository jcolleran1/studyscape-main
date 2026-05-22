# SPDX-License-Identifier: MPL-2.0
# StudyScape occupancy detector using the Video Object Detection brick.
#
# Drop-in replacement for occupancy.py. Same OccupancyDetector + open_camera
# public API so main.py picks the backend via the OCCUPANCY_BACKEND env var.
#
# The brick runs the yolox-object-detection model that ships with the Uno Q.
# It already detects the COCO "person" class, so no training is needed.
# YOLO ONNX (occupancy.py) is still available as a fallback because in our
# SCDI testing the brick model overcounts at overhead angles.
#
# History: in early testing with 4 people in the room, get_rolling_max kept
# reporting 5 or 6 because jackets on chair backs and bag straps were briefly
# boxed as people. get_robust_count (median of multiple percentile cuts) was
# added in v1.4 to reject those spurious frames.

from __future__ import annotations

import os
import threading
import time
from collections import deque
from typing import Optional


PERSON_LABEL = "person"
# Raise BRICK_CONF_THRESHOLD if the room has lots of chairs, jackets, or
# monitors getting boxed as people. Lower it if distant or occluded people
# are getting dropped.
DEFAULT_CONF_THRESHOLD = float(os.environ.get("BRICK_CONF_THRESHOLD", "0.40"))
DEFAULT_DEBOUNCE_SEC = 0.0  # fire callback every frame; we aggregate ourselves
DEFAULT_ROLLING_WINDOW_S = 30
DEFAULT_PERCENTILE = 75


# Rolling sample buffer. The brick fires _record_sample from a worker
# thread, main.py reads from the main thread, so everything goes through
# the lock.
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


_brick = None
_brick_started = False


def _make_on_all_detections():
    """Builds the per-frame callback registered with the brick.

    The brick only fires on_detect_all when a frame produces at least one
    detection. Frames with zero detections produce no callback at all, so
    we need the heartbeat thread below to record idle samples.
    """
    def on_all_detections(detections: dict) -> None:
        # detections looks like {label: [{confidence, bounding_box_xyxy}, ...]}
        boxes = detections.get(PERSON_LABEL, [])
        _record_sample(len(boxes))
    return on_all_detections


def _start_brick(confidence: float, debounce_sec: float):
    """Imports and starts the brick. Returns None if the brick isn't available
    in the current runtime (useful for local dev outside App Lab)."""
    global _brick, _brick_started

    if _brick is not None:
        return _brick

    try:
        from arduino.app_bricks.video_objectdetection import VideoObjectDetection
    except Exception as e:
        print(f"[occupancy/brick] VideoObjectDetection import failed: {e}")
        print("[occupancy/brick] Check that arduino:video_object_detection "
              "is listed in app.yaml.")
        return None

    try:
        _brick = VideoObjectDetection(
            confidence=confidence,
            debounce_sec=debounce_sec,
            camera_preview=False,  # we don't need raw frames here
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


# Heartbeat: if no detection callback fires for HEARTBEAT_QUIET_GRACE_S
# seconds, we write a zero into the buffer. Without this an empty room
# keeps the old samples around until the rolling window expires, and
# get_robust_count stays high for too long.
_heartbeat_stop = threading.Event()
_heartbeat_thread: Optional[threading.Thread] = None
_HEARTBEAT_INTERVAL_S = 1.0
_HEARTBEAT_QUIET_GRACE_S = 2.0


def _heartbeat_loop() -> None:
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


class OccupancyDetector:
    """Brick-backed person counter.

    Constructor takes the same arguments as the YOLO version so main.py
    can swap backends. model_path is accepted for compatibility but ignored;
    the brick picks its model from app.yaml.
    """

    def __init__(
        self,
        model_path: str = "",                 # accepted for API parity; unused
        input_size: int = 640,                # accepted for API parity; unused
        conf_threshold: float = DEFAULT_CONF_THRESHOLD,
        iou_threshold: float = 0.45,          # the model handles NMS
        debounce_sec: float = DEFAULT_DEBOUNCE_SEC,
    ):
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold
        self.debounce_sec = debounce_sec

        _start_brick(confidence=conf_threshold, debounce_sec=debounce_sec)
        _start_heartbeat()

    def count_people(self, frame_bgr=None) -> int:
        """Latest per-frame count from the brick."""
        with _state_lock:
            return _latest_count

    def get_rolling_max(self, window_s: float = DEFAULT_ROLLING_WINDOW_S) -> int:
        """Peak person count seen in the last window_s seconds.

        Use get_robust_count instead unless you specifically need the peak.
        Rolling max latches onto single bad frames (e.g. one frame where a
        jacket got boxed as a person inflates the whole window).
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
        """Count at the given percentile across the recent window."""
        cutoff = time.time() - window_s
        with _state_lock:
            counts = [count for ts, count in _samples if ts >= cutoff]
        if not counts:
            return 0
        counts.sort()
        idx = min(len(counts) - 1, int(len(counts) * percentile / 100))
        return counts[idx]

    def get_robust_count(
        self,
        window_s: float = DEFAULT_ROLLING_WINDOW_S,
        percentiles: tuple = (40, 55, 70, 80),
    ) -> int:
        """Median of multiple percentile cuts. Recommended for reporting.

        A single percentile can flicker when the per-frame distribution is
        bimodal. Example: 4 real people, half the frames detect 4 and half
        detect 5 because of a misidentified jacket. The 75th percentile
        bounces between 4 and 5. Taking the median of cuts at 40, 55, 70,
        and 80 reports whichever count the most cuts agree on, which is
        much more stable.
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
        """Peak count across the entire rolling buffer (any age)."""
        with _state_lock:
            return max((count for _, count in _samples), default=0)

    def get_callback_stats(self) -> tuple[int, int]:
        """(total_callbacks, callbacks_with_person) since last reset_window."""
        with _state_lock:
            return _callback_count, _person_callback_count

    def reset_window(self) -> None:
        """Clears per-report counters. Sample buffer is left alone so the
        next get_robust_count call still has data to work with."""
        global _callback_count, _person_callback_count
        with _state_lock:
            _callback_count = 0
            _person_callback_count = 0


# The brick owns the camera (/dev/video1 on the Uno Q). main.py was written
# against a cv2.VideoCapture interface, so we hand it a fake one. read() never
# returns a frame on this code path; counts come in via the brick callback.

class _FakeCapture:
    """cv2.VideoCapture stand-in. Always reports open, never returns a frame."""

    def __init__(self):
        self._open = True

    def isOpened(self) -> bool:
        return self._open

    def read(self):
        return False, None

    def release(self) -> None:
        self._open = False


def open_camera(device_index: int = 0, width: int = 1280, height: int = 720):
    """Returns a fake VideoCapture. The brick owns the real camera."""
    print(f"[occupancy/brick] open_camera(index={device_index}): brick owns "
          f"the camera, returning fake capture for API compatibility")
    return _FakeCapture()
