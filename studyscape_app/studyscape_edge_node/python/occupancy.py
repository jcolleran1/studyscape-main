# SPDX-License-Identifier: MPL-2.0
# StudyScape — YOLOv8n occupancy detector.
# Runs on the QRB2210 MPU. Input: BGR frame. Output: integer person count.
#
# Privacy: frames never leave this process. Only the count is emitted.

from __future__ import annotations

import os
from typing import Optional

import cv2
import numpy as np
import onnxruntime as ort


PERSON_CLASS_ID = 0  # COCO class 0


class OccupancyDetector:
    def __init__(
        self,
        model_path: str,
        input_size: int = 640,
        conf_threshold: float = 0.30,  # per StudyScape deck slide 7
        iou_threshold: float = 0.45,
    ):
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"YOLOv8n model not found: {model_path}")
        self.input_size = input_size
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold
        self.session = ort.InferenceSession(
            model_path, providers=["CPUExecutionProvider"]
        )
        self.input_name = self.session.get_inputs()[0].name

    def _letterbox(self, img):
        h, w = img.shape[:2]
        s = min(self.input_size / h, self.input_size / w)
        nh, nw = int(round(h * s)), int(round(w * s))
        resized = cv2.resize(img, (nw, nh), interpolation=cv2.INTER_LINEAR)
        canvas = np.full((self.input_size, self.input_size, 3), 114, dtype=np.uint8)
        top = (self.input_size - nh) // 2
        left = (self.input_size - nw) // 2
        canvas[top:top + nh, left:left + nw] = resized
        return canvas

    def count_people(self, frame_bgr) -> int:
        if frame_bgr is None:
            return 0
        img = self._letterbox(frame_bgr)
        blob = cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
        blob = np.transpose(blob, (2, 0, 1))[None, ...]

        outputs = self.session.run(None, {self.input_name: blob})
        # YOLOv8 ONNX: (1, 84, N) -> [x,y,w,h, class0..class79]
        preds = outputs[0][0].T  # (N, 84)

        class_scores = preds[:, 4:]
        class_ids = np.argmax(class_scores, axis=1)
        confidences = class_scores[np.arange(len(preds)), class_ids]

        mask = (class_ids == PERSON_CLASS_ID) & (confidences >= self.conf_threshold)
        if not np.any(mask):
            return 0

        boxes_xywh = preds[mask][:, :4]
        conf = confidences[mask].astype(np.float32)

        # Convert to x,y,w,h ints for cv2.dnn.NMSBoxes
        boxes = []
        for b in boxes_xywh:
            x, y, w, h = b
            boxes.append([int(x - w / 2), int(y - h / 2), int(w), int(h)])
        if not boxes:
            return 0
        indices = cv2.dnn.NMSBoxes(
            boxes, conf.tolist(), self.conf_threshold, self.iou_threshold
        )
        if indices is None:
            return 0
        return len(indices)


def open_camera(device_index: int = 0, width: int = 1280, height: int = 720):
    cap = cv2.VideoCapture(device_index, cv2.CAP_V4L2)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
    cap.set(cv2.CAP_PROP_FPS, 15)
    return cap
