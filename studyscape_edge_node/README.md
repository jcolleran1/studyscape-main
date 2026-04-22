# StudyScape — Edge Sensor Node

Arduino UNO Q app that runs on the StudyScape sensor node. Averages noise
and occupancy over 30 s and writes to Firestore. Flutter app streams from
the same Firestore documents.

- **Noise** via MAX4466 pin mic on A0 (default) *or* USB microphone
- **Occupancy** via USB webcam + YOLOv8n (local inference, frames never leave the device)
- **Firestore writes** every 30 s to `spaces/<space_id>`
- **Privacy-by-design**: only integers + classifications uploaded

## Directory layout

```
studyscape_edge_node/
├── app.yaml                    # App Lab manifest
├── room_config.json (see below)
├── sketch/
│   ├── sketch.ino              # MCU: MAX4466 + Bridge RPCs
│   └── sketch.yaml
└── python/
    ├── main.py                 # Orchestrator
    ├── noise.py                # Pin-mic + USB-mic backends
    ├── occupancy.py            # YOLOv8n inference
    ├── firebase_writer.py      # Firestore schema + writes
    ├── requirements.txt
    ├── room_config.json        # Per-device settings
    └── models/
        ├── README.md
        └── yolov8n.onnx        # bundled (~13 MB)
```

## Hardware wiring

### MAX4466 pin mic → UNO Q JANALOG

| MAX4466 | UNO Q            | Important                                     |
|---------|------------------|-----------------------------------------------|
| VCC     | `3V3 OUT`        | **Must be 3.3 V.** A0/PA4 is NOT 5V-tolerant. |
| GND     | `GND`            |                                               |
| OUT     | `A0` (PA4)       |                                               |

### USB webcam

Plug into the UNO Q's USB-C (via a USB-C hub if you also need it for power).
V4L2 exposes it as `/dev/video0`.

### USB microphone (only if NOISE_MODE=usb)

Any class-compliant USB mic. `sounddevice` finds it automatically.

## First-time setup in App Lab

1. **Import the zip** in Arduino App Lab.
2. **Open the sketch** and click **Add Library** → search
   `Arduino_RouterBridge` → install the **Arduino 0.4.1** version (not the
   BCMI-labs fork). This step is required; App Lab does not auto-resolve
   this library from the `#include` alone.
3. **Put `serviceAccount.json` on the board** (see Firebase setup below).
4. **Edit `python/room_config.json`** for the room this device covers.
5. Press **Run**.

## Firebase setup

1. Firebase Console → Project settings → Service accounts → Generate new
   private key. Rename the download to `serviceAccount.json`.
2. Copy it to the UNO Q:
   ```bash
   scp serviceAccount.json arduino@<uno-q-ip>:/home/arduino/serviceAccount.json
   ```
3. The app boots even without credentials — it just prints readings to
   the console (calibration mode).

## `room_config.json`

```json
{
  "space_id": "scdi_f2_a",
  "space_name": "Study room A",
  "building": "SCDI",
  "building_index": 3,
  "floor": 2,
  "location_line": "Level 2, East Wing",
  "capacity": 24,
  "device_id": "device_001"
}
```

`space_id` is the Firestore document id. Keep it stable per physical room —
the Flutter app's markers reference these ids.

## Switching noise source

Default is the **pin mic**. To use the **USB mic** instead, set an env var
in the App Lab run configuration:

```
NOISE_MODE=usb
```

Both modes write the same `spaces/<id>` schema so the Flutter app is agnostic.

## Firestore schema

```
spaces/<space_id>
  space_id, space_name, building, building_index, floor, location_line,
  capacity,
  occupancy, occupancy_percent, occupancy_level,  # low|medium|high
  noise,                                          # low|medium|loud
  noise_label,                                    # "Quiet Zone"|"Moderate Buzz"|"Loud"
  noise_hint,                                     # e.g. "Headphones Rec."
  noise_raw, noise_source,
  status, device_id, updated_at
  └─ history/<auto_id>
       occupancy, occupancy_percent, noise, noise_raw, timestamp

devices/<device_id>
  status, location, updated_at
```

## Calibration

Noise thresholds live in `sketch/sketch.ino`:

```cpp
const unsigned int LOW_MAX    = 150;   // below → low
const unsigned int MEDIUM_MAX = 900;   // below → medium, above → loud
```

Watch the Sketch console in App Lab to see `avgP2P=<n>` each report, tune
for your space. These defaults match the user's working calibration:
quiet ≈ 70–120, talking ≈ 200–450, loud ≈ 1000+.

USB-mode thresholds are dB numbers, tunable via env vars
`NOISE_LOW_DB` (default 50) and `NOISE_MED_DB` (default 65).

## Troubleshooting

| Symptom                                    | Fix                                                            |
|--------------------------------------------|----------------------------------------------------------------|
| `Arduino_RouterBridge.h: No such file`     | Click **Add Library** in App Lab; install 0.4.1 from Arduino.  |
| `avgP2P` pinned at 0                       | Gain pot too low, or mic unpowered (check 3V3).                |
| `avgP2P` pinned at 4095                    | Gain clipping — turn the pot counter-clockwise.                |
| `level=` always `low`                      | Thresholds too high; check `avgP2P` range then lower `LOW_MAX`.|
| `[camera] /dev/video0 did not open`        | USB hub without power delivery; plug cam into powered hub.     |
| `[yolo] model not found`                   | Put `yolov8n.onnx` in `python/models/`.                        |
| Firestore stays empty                      | `serviceAccount.json` missing or Firestore rules block writes. |

## Environment variables (full list)

| Var                        | Default                                   |
|----------------------------|-------------------------------------------|
| `NOISE_MODE`               | `pin`  (other: `usb`)                     |
| `ENABLE_CAMERA`            | `1`                                       |
| `CAMERA_INDEX`             | `0`                                       |
| `REPORT_INTERVAL_S`        | `30`                                      |
| `LOOP_INTERVAL_S`          | `1.0`                                     |
| `YOLO_MODEL_PATH`          | `python/models/yolov8n.onnx`              |
| `ROOM_CONFIG_PATH`         | `python/room_config.json`                 |
| `FIREBASE_SERVICE_ACCOUNT` | `/home/arduino/serviceAccount.json`       |
| `NOISE_LOW_DB`             | `50` (USB mode only)                      |
| `NOISE_MED_DB`             | `65` (USB mode only)                      |
