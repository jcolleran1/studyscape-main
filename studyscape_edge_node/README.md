# StudyScape edge sensor node

Arduino UNO Q application. Samples occupancy and noise in an SCDI study
room every 30 seconds and writes the result to Firestore. The Flutter app
streams those same documents.

- Noise via MAX4466 pin mic on A0 (default), or USB microphone
- Occupancy via USB webcam. Local YOLO ONNX is the primary path; the
  App Lab Video Object Detection brick is an alternative.
- Firestore writes every 30 s to `spaces/<space_id>`
- Only integers and short classification strings leave the device.
  No frames, no audio, no PII.

## Why two inference backends

YOLO ONNX (`occupancy.py`) and the Video Object Detection brick
(`occupancy_brick.py`) both work. In our SCDI 2201A testing they failed
in opposite directions: the brick (yolox-object-detection) overcounted
because it boxed jackets and bag straps as people, and the local YOLO
backend undercounted at certain camera angles when occupants were
partially occluded. Either backend may be the right choice in a given
room, so both are kept. Switch with:

```
OCCUPANCY_BACKEND=yolo    # default: local ONNX
OCCUPANCY_BACKEND=brick   # use the App Lab brick
```

Both expose the same `OccupancyDetector` API, so `main.py` doesn't change.

## Directory layout

```
studyscape_edge_node/
├── app.yaml                       App Lab manifest
├── README.md
├── sketch/
│   ├── sketch.ino                 MCU: MAX4466 sampling + Bridge RPCs
│   └── sketch.yaml
└── python/
    ├── main.py                    Orchestrator, picks the backend
    ├── noise.py                   Pin-mic and USB-mic backends
    ├── occupancy.py               YOLO ONNX backend (primary)
    ├── occupancy_brick.py         Video Object Detection brick backend
    ├── firebase_writer.py         Firestore schema and writes
    ├── requirements.txt
    ├── room_config.json           Per-device settings
    ├── serviceAccountKey.json     Firebase creds; placeholder
    └── models/
        ├── README.md
        ├── yolo26n.pt             Source weights
        └── yolo26n.onnx           Converted for on-device inference
```

## Hardware wiring

### MAX4466 pin mic to UNO Q JANALOG

| MAX4466 | UNO Q     | Note                                          |
|---------|-----------|-----------------------------------------------|
| VCC     | `3V3 OUT` | Must be 3.3 V. A0/PA4 is not 5V-tolerant.     |
| GND     | `GND`     |                                               |
| OUT     | `A0` (PA4)|                                               |

### USB webcam

Plug into the UNO Q's USB-C through a powered USB-C hub. The brick path
auto-discovers the camera at `/dev/video1`. The local YOLO path opens
`/dev/video0` through OpenCV's V4L2 backend.

### USB microphone

Only used when `NOISE_MODE=usb`. Any class-compliant mic works;
`sounddevice` finds it on its own.

## First-run setup in App Lab

1. Import the project: My Apps → Import zip.
2. The first run pulls any required brick containers. Needs a working
   internet connection on the Uno Q. Subsequent runs are fast.
3. Fill in `python/serviceAccountKey.json` with the real Firebase service
   account JSON. Alternatively, copy it to
   `/home/arduino/serviceAccount.json` on the Uno Q and leave the bundled
   file empty.
4. Edit `python/room_config.json` for the room this device covers.
5. In the App Lab sketch view: Add Library → search `Arduino_RouterBridge`
   → install the 0.4.1 release from Arduino (not the BCMI-labs fork).
6. Press Run.

Console output during a healthy startup looks like:

```
[occupancy] backend=yolo (local ONNX)
[occupancy] YOLO ONNX loaded: .../models/yolo26n.onnx
[occupancy] inference worker started
[noise] mode=pin
[noise] ready (pin backend)
```

Once people are visible to the camera you'll see `[report]` lines with
non-zero `occ=` values.

## Converting YOLO weights to ONNX

The Uno Q doesn't ship with PyTorch or ultralytics, so convert once on
your dev machine and check in the `.onnx`:

```bash
pip install ultralytics
python -c "from ultralytics import YOLO; YOLO('yolo26n.pt').export(format='onnx', opset=12, imgsz=640, simplify=True)"
```

Drop the resulting file in `python/models/`. `occupancy.py` autodetects.

## Tuning

### Brick path

- `BRICK_CONF_THRESHOLD` (default `0.40`): raise it to drop chairs,
  jackets, and monitors that get boxed as people. Lower it if real
  distant people are being filtered out.
- Custom Edge Impulse model: in App Lab, open the brick → AI Models →
  Train new AI model. Once it's deployed, pick it under Brick
  Configuration. No code change needed.
- Heartbeat: `_HEARTBEAT_QUIET_GRACE_S` (default 2 s). After this much
  silence we record a zero so the rolling buffer decays correctly when
  the room empties.

### YOLO path

- Confidence threshold defaults to `0.25` (in `occupancy.py`).
- Inference runs at roughly 2 fps in a background thread.
- Tweak `INFERENCE_INTERVAL_S` for fps vs CPU.

### Both paths

- Rolling window is 30 s, matching the report interval.
- `HYSTERESIS_DELTA` (default 1): the size of change that gets smoothed.
- `HYSTERESIS_PERSISTENCE` (default 3): how many consecutive windows
  the same disagreement must appear in before the smoother accepts it.
  At a 30 s report cadence this means a steady ±1 change catches up
  after about 90 seconds. Set `HYSTERESIS_DELTA=0` to turn smoothing off.

## Firestore schema

```
spaces/<space_id>
  space_id, space_name, building, building_index, floor, location_line,
  capacity,
  occupancy, occupancy_percent, occupancy_level,   # low | medium | high
  noise,                                           # low | medium | loud
  noise_label,                                     # "Quiet Zone" | ...
  noise_hint, noise_raw, noise_source,
  status, device_id, updated_at
  └── history/<auto_id>
        occupancy, occupancy_percent, noise, noise_raw, timestamp

devices/<device_id>
  status, location, updated_at
```

## Environment variables

| Var                        | Default                                        |
|----------------------------|------------------------------------------------|
| `OCCUPANCY_BACKEND`        | `yolo` (alt: `brick`)                          |
| `NOISE_MODE`               | `pin`  (alt: `usb`)                            |
| `ENABLE_CAMERA`            | `1`                                            |
| `CAMERA_INDEX`             | `0` (yolo backend only)                        |
| `REPORT_INTERVAL_S`        | `30`                                           |
| `LOOP_INTERVAL_S`          | `1.0`                                          |
| `HYSTERESIS_DELTA`         | `1` (set `0` to disable smoothing)             |
| `HYSTERESIS_PERSISTENCE`   | `3` consecutive windows before forced update   |
| `BRICK_CONF_THRESHOLD`     | `0.40` (brick backend only)                    |
| `YOLO_MODEL_PATH`          | autodetected: `models/yolo26n.onnx`, etc.      |
| `ROOM_CONFIG_PATH`         | `python/room_config.json`                      |
| `FIREBASE_SERVICE_ACCOUNT` | `/home/arduino/serviceAccount.json`            |
| `NOISE_LOW_DB`             | `50` (USB mode only)                           |
| `NOISE_MED_DB`             | `65` (USB mode only)                           |

## How the occupancy aggregation works

Each 30-second window holds 27 to 47 per-frame counts from the camera.
Individual frames disagree because the model occasionally misses or
double-counts. We need to turn that buffer into one stable number per
report.

### Per-window aggregation: `get_robust_count`

Plain average drifts when spurious detections cluster, and it produces
fractional values. Plain max latches onto single bad frames (one frame
where a jacket got boxed inflates the entire 30 s report). Plain median
flip-flops on boundary cases.

The method we settled on: take four percentile cuts (40th, 55th, 70th,
80th) across the sorted samples, then return the median of those four
numbers. This gives the count where most percentile cuts agree, which
is much more stable than any single statistic.

### Cross-window smoothing: hysteresis with an escape valve

Even after `get_robust_count`, consecutive 30 s reports can still differ
by 1 person when the model output sits on a boundary. Smoothing the
reported value fixes the flicker but introduces a new bug: a persistent
±1 disagreement gets masked forever. So the smoothing has an escape
valve: when the same disagreement persists for `HYSTERESIS_PERSISTENCE`
consecutive windows, the reported value updates. Larger changes (more
than `HYSTERESIS_DELTA`) update immediately.

Each `[report]` log line prints both the raw aggregated count and the
hysteresis-applied reported count, so you can see the smoother working:

```
[report] occ=4 (20%) raw=4 noise=low raw_noise=53.7 mode=pin backend=yolo
```

If `raw` and `occ` disagree for more than three reports in a row,
something is off (or the persistence counter is mid-update; check the
next report).

## Known limitations

- We have not been able to test this on every camera mount angle in
  every SCDI room. Some rooms may need tuning of `BRICK_CONF_THRESHOLD`
  or the percentile cuts in `get_robust_count`.
- The pin-mic path reports peak-to-peak ADC counts (0–4095), not real
  decibels. The thresholds in the sketch (`LOW_MAX`, `MED_MAX`) were
  calibrated for our test room and may need adjustment elsewhere.
- The system has no offline buffering for Firestore writes. If the Uno
  Q's Wi-Fi drops, the readings for that window are lost.
