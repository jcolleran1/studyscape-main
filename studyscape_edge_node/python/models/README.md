# models/

This folder must contain a YOLO ONNX file that `python/occupancy.py` loads.

The default expected path is `python/models/yolov8n.onnx`, set via the
`YOLO_MODEL_PATH` env var. You can override it to point at a YOLO26 or
YOLOv11n ONNX file instead.

## Converting YOLO26 (.pt) to ONNX

The `.pt` file from Ultralytics is a PyTorch checkpoint and won't run on
the UNO Q. You need to convert it to ONNX once on a dev machine that has
Python and the `ultralytics` package installed.

```bash
pip install ultralytics
python -c "from ultralytics import YOLO; YOLO('yolo26n.pt').export(format='onnx', opset=12, imgsz=640, simplify=True)"
```

This produces `yolo26n.onnx` in the same folder. Copy it here:

```bash
cp yolo26n.onnx python/models/yolo26n.onnx
```

Then point the app at it via env var in App Lab's run config:

```
YOLO_MODEL_PATH=/app/python/models/yolo26n.onnx
```

## Falling back to YOLOv8n

If the YOLO26 export fails or runs too slowly on the UNO Q, the same
process works for YOLOv8n (which is what was originally bundled):

```bash
python -c "from ultralytics import YOLO; YOLO('yolov8n.pt').export(format='onnx', opset=12, imgsz=640, simplify=True)"
cp yolov8n.onnx python/models/yolov8n.onnx
```

`occupancy.py` works with any YOLOv8/v11/26 nano-class ONNX export — they
all share the `(1, 84, N)` output tensor shape. No code change needed.

## Why the conversion step

The UNO Q runs `onnxruntime` (lightweight, ARM-compatible). It does NOT
have PyTorch or `ultralytics` installed — those are too heavy for an
embedded board. So the model file shipped here must be the ONNX export,
not the original `.pt` checkpoint.
