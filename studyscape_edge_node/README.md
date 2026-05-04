# StudyScape — Edge Sensor Node

Arduino UNO Q app that runs on the StudyScape sensor node. Averages noise
and occupancy and writes to Firestore. Flutter app streams from the same
Firestore documents.

- **Noise** via MAX4466 pin mic on A0 (default) *or* USB microphone
- **Occupancy** via USB webcam — primary path is the App Lab
  Video Object Detection brick (`yolox-object-detection` on the Uno Q),
  with local YOLO ONNX inference kept as a fallback
- **Firestore writes** every 30 s to `spaces/<space_id>`
- **Privacy-by-design**: only integers + classifications uploaded

## What changed in v1.3

This release switches the **default** occupancy backend from local
ONNX inference back to the **Video Object Detection brick**.

Why:

- The brick is the native App Lab path. Camera ownership, model deployment,
  and runtime supervision are all handled by the platform.
- The default `yolox-object-detection` model already includes a `person`
  class, so no Edge Impulse training is required for a working person
  counter.
- The 4 GB Uno Q has the headroom to run the brick alongside the noise
  sampling, Firestore client, and our app code with comfortable margin.
- Custom Edge Impulse models can be swapped in later from App Lab without
  any code changes.

The local YOLO ONNX path (`occupancy.py`) is **kept intact** as a fallback.
If the bundled YoloX-Nano under-counts in a particular SCDI room — typically
a problem with overhead camera angles — you can flip a single environment
variable and fall back to YOLOv8n / YOLO26n locally.

```
OCCUPANCY_BACKEND=brick   # default — Video Object Detection brick
OCCUPANCY_BACKEND=yolo    # fallback — local ONNX in occupancy.py
```

Both backends expose the same `OccupancyDetector` API, so `main.py` is
unchanged between them.

## Directory layout

```
studyscape_edge_node/
├── app.yaml                       # App Lab manifest (declares the brick)
├── README.md
├── sketch/
│   ├── sketch.ino                 # MCU: MAX4466 + Bridge RPCs
│   └── sketch.yaml
└── python/
    ├── main.py                    # Orchestrator — picks a backend
    ├── noise.py                   # Pin-mic + USB-mic backends
    ├── occupancy_brick.py         # PRIMARY: Video Object Detection brick
    ├── occupancy.py               # FALLBACK: local YOLO ONNX inference
    ├── firebase_writer.py         # Firestore schema + writes
    ├── requirements.txt
    ├── room_config.json           # Per-device settings
    ├── serviceAccountKey.json     # Firebase creds (paste yours in)
    └── models/                    # Used only when backend=yolo
        ├── README.md
        ├── yolo26n.pt
        └── yolo26n.onnx
```

## Hardware wiring

### MAX4466 pin mic → UNO Q JANALOG

| MAX4466 | UNO Q     | Important                                     |
|---------|-----------|-----------------------------------------------|
| VCC     | `3V3 OUT` | **Must be 3.3 V.** A0/PA4 is NOT 5V-tolerant. |
| GND     | `GND`     |                                               |
| OUT     | `A0` (PA4)|                                               |

### USB webcam

Plug into the UNO Q's USB-C (via a USB-C hub if you also need it for power).
The brick auto-discovers the camera at `/dev/video1`. The fallback YOLO
path uses `/dev/video0` via OpenCV V4L2.

### USB microphone (only if NOISE_MODE=usb)

Any class-compliant USB mic. `sounddevice` finds it automatically.

## First-time setup in App Lab

1. **Import the zip** in Arduino App Lab → My Apps → Import.
2. **First run** will pull the `arduino:video_object_detection` brick
   container from the Arduino registry. This requires a working internet
   connection on the Uno Q. Subsequent runs are fast.
3. **Fill in `python/serviceAccountKey.json`** with your Firebase service
   account JSON. (Or copy it to `/home/arduino/serviceAccount.json` on the
   Uno Q and leave the bundled file blank.)
4. **Edit `python/room_config.json`** for the room this device covers.
5. **Open the sketch** and click **Add Library** → search
   `Arduino_RouterBridge` → install the **Arduino 0.4.1** version.
6. Press **Run**.

The Python console should show:

```
[occupancy] backend=brick (Video Object Detection)
[occupancy/brick] VideoObjectDetection started (confidence=0.3, debounce_sec=0.0)
[occupancy/brick] heartbeat started
[noise] mode=pin
[noise] ready (pin backend)
```

When people enter the camera frame you'll start seeing periodic `[report]`
lines with non-zero `occ=` counts.

## Switching to the YOLO fallback

If the brick's bundled model under-counts for your room:

1. Make sure `python/models/yolo26n.onnx` (or `yolov8n.onnx`) exists.
   See `python/models/README.md` and the `.pt` → `.onnx` conversion below.
2. In the App Lab project settings, add an environment variable:
   `OCCUPANCY_BACKEND=yolo`
3. Restart the app.

The Python console should then show:

```
[occupancy] backend=yolo (local ONNX fallback)
[occupancy] YOLO ONNX loaded: .../models/yolo26n.onnx
[occupancy] inference worker started
```

### Converting the YOLO .pt to ONNX (fallback path only)

The board can't run PyTorch / ultralytics. Convert once on a dev machine:

```bash
pip install ultralytics
python -c "from ultralytics import YOLO; YOLO('yolo26n.pt').export(format='onnx', opset=12, imgsz=640, simplify=True)"
```

Drop the `.onnx` into `python/models/`. `occupancy.py` autodetects.

## Tuning occupancy

### Brick path (default)

- **Confidence threshold** — default is `0.30` in `occupancy_brick.py`
  (`DEFAULT_CONF_THRESHOLD`). Raise to suppress false positives (chairs,
  jackets); lower to catch more seated people.
- **Custom model** — to swap in an Edge Impulse model trained on SCDI
  photos: open the brick in App Lab → AI Models → Train new AI model.
  Once deployed, select it under Brick Configuration. No code change.
- **Heartbeat** — `_HEARTBEAT_QUIET_GRACE_S` (default 2 s). After this
  much silence from the brick, we record a 0 sample so the rolling max
  decays correctly when the room empties.

### YOLO fallback path

- Confidence threshold defaults to `0.25` in `occupancy.py`.
- Inference runs at ~2 fps in a background thread.
- Tweak `INFERENCE_INTERVAL_S` in `occupancy.py` for fps vs CPU trade-off.

### Both paths

- Rolling max window is 60 s. Longer is more forgiving of flickery
  detection; shorter responds faster when the room empties.

## Firestore schema

Same as v1.1 / v1.2:

```
spaces/<space_id>
  space_id, space_name, building, building_index, floor, location_line,
  capacity,
  occupancy, occupancy_percent, occupancy_level,  # low|medium|high
  noise,                                          # low|medium|loud
  noise_label,                                    # "Quiet Zone"|"Moderate Buzz"|"Loud"
  noise_hint, noise_raw, noise_source,
  status, device_id, updated_at
  └─ history/<auto_id>
       occupancy, occupancy_percent, noise, noise_raw, timestamp

devices/<device_id>
  status, location, updated_at
```

## Environment variables (full list)

| Var                        | Default                                        |
|----------------------------|------------------------------------------------|
| `OCCUPANCY_BACKEND`        | `brick` (other: `yolo`)                        |
| `NOISE_MODE`               | `pin`  (other: `usb`)                          |
| `ENABLE_CAMERA`            | `1`                                            |
| `CAMERA_INDEX`             | `0` (only used by `yolo` backend)              |
| `REPORT_INTERVAL_S`        | `30`                                           |
| `LOOP_INTERVAL_S`          | `1.0`                                          |
| `HYSTERESIS_DELTA`         | `1` (set `0` to disable smoothing)             |
| `HYSTERESIS_PERSISTENCE`   | `3` (consecutive windows before forced update) |
| `BRICK_CONF_THRESHOLD`     | `0.40` (only used by `brick` backend)          |
| `YOLO_MODEL_PATH`          | auto: `models/yolo26n.onnx` else `yolov8n.onnx`|
| `ROOM_CONFIG_PATH`         | `python/room_config.json`                      |
| `FIREBASE_SERVICE_ACCOUNT` | `/home/arduino/serviceAccount.json`            |
| `NOISE_LOW_DB`             | `50` (USB mode only)                           |
| `NOISE_MED_DB`             | `65` (USB mode only)                           |

## How hysteresis works (v1.4.1+)

Hysteresis stops the reported occupancy from flickering between adjacent
values when the model output is borderline (e.g. 3/4 with 4 real people
and one occasionally missed). It works on three rules:

1. **Within tolerance + matches reported** → no change.
2. **Within tolerance + new value persists for `HYSTERESIS_PERSISTENCE`
   consecutive windows** → accept the change. With the default of 3 and
   a 30-second report interval, this means a steady ±1 disagreement
   catches up after ~90 seconds.
3. **Outside tolerance** (jump > `HYSTERESIS_DELTA`) → accept immediately.

This avoids the v1.4 bug where a steady 1-person disagreement would
permanently mask the truth. Real changes still propagate; transient
flicker is still smoothed.

To see hysteresis in action, watch the `[report]` lines: when `raw`
and `occ` differ, `raw` is the model's current best estimate and `occ`
is what's actually reported / sent to Firestore. They should converge
within 3 reports unless `raw` is genuinely flickering.

## Honest caveats

- **First-run iteration is normal.** I have not been able to test this
  zip end-to-end on actual Uno Q hardware. Expect one or two small fixes
  on first deploy — a missing import, a brick API quirk, a Firestore auth
  detail. Logging is verbose so debugging is straightforward.
- **The brick container downloads on first run.** Plan for ~1–2 minutes of
  setup the first time the app deploys. Subsequent restarts are fast.
- **YoloX-Nano vs YOLOv8n is a real trade-off.** If accuracy in SCDI is
  unacceptable on the brick path, the fallback flag exists for exactly
  this reason. Both backends are fully wired; either can be the production
  one.
- **A custom Edge Impulse model trained on SCDI photos** is the long-term
  best answer for accuracy, but is not required to ship — the bundled
  model is a reasonable starting point. Capture this as v2 work.
