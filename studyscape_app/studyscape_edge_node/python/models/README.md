# YOLOv8n ONNX model

Place `yolov8n.onnx` in this folder. The app looks for it at:

    python/models/yolov8n.onnx

(Or override with the `YOLO_MODEL_PATH` env var.)

## If you already have it

Your GitHub repo ships `models/yolov8n.onnx` at the root — just copy that file here:

    cp /path/to/studyscape/models/yolov8n.onnx python/models/

## If you need to generate it

On any machine with Python (not required to be the UNO Q):

    pip install ultralytics
    python -c "from ultralytics import YOLO; YOLO('yolov8n.pt').export(format='onnx', opset=12, imgsz=640, simplify=True)"

Then copy `yolov8n.onnx` into this folder.

## Without this file

The app still boots. Camera inference is disabled and `occupancy` reports as 0
until the model is present. The noise pipeline (pin or USB) works regardless.
