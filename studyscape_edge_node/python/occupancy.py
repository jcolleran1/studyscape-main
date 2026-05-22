# SPDX-License-Identifier: MPL-2.0
# StudyScape occupancy detector (local ONNX inference).
#
# Loads a YOLO ONNX model (YOLOv8n, YOLOv11n, or YOLO26n; all share the
# (1, 84, N) output tensor shape) and runs inference on USB camera frames.
# A background thread continuously pulls frames, runs inference, and
# updates a time-stamped sample buffer. main.py reads the rolling max
# at report time.
#
# Why local ONNX instead of the Video Object Detection brick:
#   - The brick's bundled YoloX-Nano consistently undercounts on overhead
#     camera angles. YOLOv8n (and newer Nano variants) detect more people.
#   - This module owns the camera and inference loop directly, giving us
#     full control over preprocessing, NMS, and confidence thresholds.
#
# Public API preserved so main.py is unchanged:
#   - OccupancyDetector(model_path, ...)            (model_path is USED here)
#   - OccupancyDetector.count_people(frame_bgr)     (legacy: per-frame inference)
#   - OccupancyDetector.get_rolling_max(window_s)   (preferred: rolling max)
#   - OccupancyDetector.get_callback_stats()
#   - OccupancyDetector.reset_window()
#   - open_camera(index, ...)                       (real cv2.VideoCapture)

from __future__ import annotations

import os
import threading
import time
from collections import deque

import cv2
import numpy as np
import onnxruntime as ort


# --- Tunables ---
PERSON_CLASS_ID = 0          # COCO class 0 = person
DEFAULT_CONF_THRESHOLD = 0.25
DEFAULT_IOU_THRESHOLD = 0.45
DEFAULT_INPUT_SIZE = 640
DEFAULT_ROLLING_WINDOW_S = 60
INFERENCE_INTERVAL_S = 0.5    # run inference twice per second (2 fps)


# --- Module-level state for the rolling sample buffer ---
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


# --- YOLO inference ---
class _YoloRunner:
    """Wraps onnxruntime inference for a YOLOv8/v11/26-style person detector."""

    def __init__(
        self,
        model_path: str,
        input_size: int = DEFAULT_INPUT_SIZE,
        conf_threshold: float = DEFAULT_CONF_THRESHOLD,
        iou_threshold: float = DEFAULT_IOU_THRESHOLD,
    ):
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"YOLO ONNX model not found: {model_path}")

        self.input_size = input_size
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold

        self.session = ort.InferenceSession(
            model_path, providers=["CPUExecutionProvider"]
        )
        self.input_name = self.session.get_inputs()[0].name
        print(f"[occupancy] YOLO ONNX loaded: {model_path}")

    def _letterbox(self, img: np.ndarray) -> np.ndarray:
        h, w = img.shape[:2]
        s = min(self.input_size / h, self.input_size / w)
        nh, nw = int(round(h * s)), int(round(w * s))
        resized = cv2.resize(img, (nw, nh), interpolation=cv2.INTER_LINEAR)
        canvas = np.full((self.input_size, self.input_size, 3), 114, dtype=np.uint8)
        top = (self.input_size - nh) // 2
        left = (self.input_size - nw) // 2
        canvas[top:top + nh, left:left + nw] = resized
        return canvas

    def count_people(self, frame_bgr: np.ndarray) -> int:
        if frame_bgr is None:
            return 0
        img = self._letterbox(frame_bgr)
        blob = cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
        blob = np.transpose(blob, (2, 0, 1))[None, ...]

        try:
            outputs = self.session.run(None, {self.input_name: blob})
        except Exception as e:
            print(f"[occupancy] inference error: {e}")
            return 0

        preds = outputs[0]
        if preds.ndim == 3:
            preds = preds[0]

        # ---- Auto-detect output format ----------------------------------
        # YOLO26 / NMS-free: (N, 6) where each row = [x1, y1, x2, y2, conf, cls]
        # YOLOv8 / YOLOv11:  (84, A) or (A, 84) raw with 4 box + 80 classes
        # YOLO26 with extra class score: (N, 7); same idea, treat last col as class
        last_dim = preds.shape[-1]

        if last_dim == 6:
            return self._count_yolo26(preds)
        if last_dim == 7:
            # Some exports include both score and class id in adjacent cols
            return self._count_yolo26(preds)
        # Otherwise assume YOLOv8/v11 raw output
        return self._count_yolov8(preds)

    def _count_yolo26(self, preds: np.ndarray) -> int:
        """
        YOLO26 NMS-free output: each row is [x1, y1, x2, y2, confidence, class_id].
        Already deduplicated by the model; no NMS needed. Just filter by
        confidence and class.
        """
        # preds is (N, 6) or (N, 7)
        if preds.size == 0:
            return 0

        # Confidence is column 4; class id is column 5
        conf = preds[:, 4].astype(np.float32)
        cls = preds[:, 5].astype(np.int32)

        mask = (cls == PERSON_CLASS_ID) & (conf >= self.conf_threshold)
        return int(np.sum(mask))

    def _count_yolov8(self, preds: np.ndarray) -> int:
        """
        Classic YOLOv8/v11 raw output: (84, A) or (A, 84) where 84 = 4 box +
        80 class scores. Requires argmax across classes + NMS to deduplicate.
        """
        # Normalize to (A, 84)
        if preds.shape[0] == 84 and preds.shape[1] != 84:
            preds = preds.T
        # else assume already (A, 84)

        if preds.shape[1] < 5:
            return 0

        class_scores = preds[:, 4:]
        if class_scores.shape[1] == 0:
            return 0

        class_ids = np.argmax(class_scores, axis=1)
        confidences = class_scores[np.arange(len(preds)), class_ids]

        mask = (class_ids == PERSON_CLASS_ID) & (confidences >= self.conf_threshold)
        if not np.any(mask):
            return 0

        boxes_xywh = preds[mask][:, :4]
        conf = confidences[mask].astype(np.float32)

        boxes = []
        for b in boxes_xywh:
            x, y, w, h = b
            boxes.append([int(x - w / 2), int(y - h / 2), int(w), int(h)])
        if not boxes:
            return 0

        try:
            indices = cv2.dnn.NMSBoxes(
                boxes, conf.tolist(), self.conf_threshold, self.iou_threshold
            )
        except Exception as e:
            print(f"[occupancy] NMS error: {e}")
            return len(boxes)

        if indices is None or len(indices) == 0:
            return 0
        try:
            return len(indices)
        except Exception:
            return 0


# --- Camera + inference background thread ---
_runner: _YoloRunner | None = None
_capture: cv2.VideoCapture | None = None
_worker_thread: threading.Thread | None = None
_worker_stop = threading.Event()


def _worker_loop() -> None:
    global _capture, _runner
    print("[occupancy] inference worker started")
    while not _worker_stop.is_set():
        try:
            if _capture is None or not _capture.isOpened() or _runner is None:
                time.sleep(0.5)
                continue
            ok, frame = _capture.read()
            if not ok or frame is None:
                _record_sample(0)
                time.sleep(INFERENCE_INTERVAL_S)
                continue

            count = _runner.count_people(frame)
            _record_sample(count)
        except Exception as e:
            print(f"[occupancy] worker error: {e}")
            _record_sample(0)
        time.sleep(INFERENCE_INTERVAL_S)
    print("[occupancy] inference worker stopped")


# --- Public API ---
class OccupancyDetector:
    """
    Loads a YOLO ONNX model and starts a background inference thread that
    samples the USB camera at ~2fps. Counts are recorded into a rolling
    buffer; main.py reads get_rolling_max() at report time.
    """

    def __init__(
        self,
        model_path: str = "",
        input_size: int = DEFAULT_INPUT_SIZE,
        conf_threshold: float = DEFAULT_CONF_THRESHOLD,
        iou_threshold: float = DEFAULT_IOU_THRESHOLD,
    ):
        global _runner
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold

        if _runner is None:
            _runner = _YoloRunner(
                model_path=model_path,
                input_size=input_size,
                conf_threshold=conf_threshold,
                iou_threshold=iou_threshold,
            )

    def count_people(self, frame_bgr=None) -> int:
        """Most recent person count from the inference worker."""
        with _state_lock:
            return _latest_count

    def get_rolling_max(self, window_s: float = DEFAULT_ROLLING_WINDOW_S) -> int:
        """Peak person count in the last `window_s` seconds."""
        cutoff = time.time() - window_s
        with _state_lock:
            return max(
                (count for ts, count in _samples if ts >= cutoff),
                default=0,
            )

    def get_rolling_percentile(
        self,
        window_s: float = 30,
        percentile: float = 75,
    ) -> int:
        """Count at the given percentile across samples in the last window_s seconds.

        Mirrors the same method on the brick-backed OccupancyDetector so
        main.py works regardless of which backend is active.
        """
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
        window_s: float = 30,
        percentiles: tuple = (40, 55, 70, 80),
    ) -> int:
        """Median of multiple percentiles. Recommended for reporting.

        Mirrors the same method on the brick-backed OccupancyDetector.
        Reports the count where the most percentile cuts agree, which is
        far more stable across reports than any single percentile.
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
        """(total_inferences, inferences_with_person) since last reset."""
        with _state_lock:
            return _callback_count, _person_callback_count

    def reset_window(self) -> None:
        """Reset per-report counters. Does NOT clear the rolling sample buffer."""
        global _callback_count, _person_callback_count
        with _state_lock:
            _callback_count = 0
            _person_callback_count = 0


# --- Camera + worker startup ---
def open_camera(device_index: int = 0, width: int = 1280, height: int = 720):
    """
    Open the USB camera and start the background inference worker.
    Returns the cv2.VideoCapture instance for compatibility with main.py.
    """
    global _capture, _worker_thread

    cap = cv2.VideoCapture(device_index, cv2.CAP_V4L2)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
    cap.set(cv2.CAP_PROP_FPS, 15)

    _capture = cap

    # Start the worker thread once
    if _worker_thread is None or not _worker_thread.is_alive():
        _worker_stop.clear()
        _worker_thread = threading.Thread(
            target=_worker_loop, name="occupancy-worker", daemon=True
        )
        _worker_thread.start()

    return cap
