# StudyScape

Senior design capstone, Santa Clara University. Real-time study space
monitoring for SCDI: occupancy and noise data from sensor nodes deployed
in study rooms, streamed live to a Flutter mobile app.

## Repository layout

```
studyscape/
├── studyscape_edge_node/   Runs on Arduino UNO Q in SCDI rooms
│   ├── python/             App Lab Python: occupancy + noise + Firestore
│   ├── sketch/             STM32 sketch: MAX4466 sampling via Bridge RPC
│   ├── app.yaml            App Lab manifest
│   └── README.md           Deploy + tuning notes
│
└── studyscape_app/         Runs on student phones
    ├── lib/                Flutter / Dart UI + Firestore services
    │   ├── firebase_options.dart
    │   ├── services/
    │   │   ├── auth_service.dart        Firebase Auth
    │   │   └── firestore_service.dart   Live spaces/<id> streams
    │   └── models/space_reading.dart    Data model
    ├── pubspec.yaml        firebase_core, cloud_firestore, firebase_auth
    └── README.md
```

The edge node and the app are independent codebases. They talk to each
other through Firestore: edge node writes, app reads.

## Data flow

```
[USB camera] ──┐
               ├──► [Uno Q] ──► [Firestore: spaces/<id>] ──► [Flutter app]
[MAX4466 mic] ─┘    Python +
                    sketch
```

1. Edge node samples noise (MAX4466 on A0) and counts people from a USB
   webcam, using either YOLO ONNX or the Video Object Detection brick.
2. Every 30 seconds it writes the aggregated values to `spaces/<space_id>`
   in Firebase project `studyscapescu`. See
   `studyscape_edge_node/python/firebase_writer.py` for the document shape.
3. The Flutter app reads the same documents through
   `FirestoreService.watchSpace()` (in `lib/services/firestore_service.dart`)
   and renders live markers on the floor plan.

## Setup

### Edge node

See `studyscape_edge_node/README.md`. Imports as an Arduino App Lab project.
Defaults to local YOLO inference and the pin-mic noise path. Both can be
swapped via env vars (`OCCUPANCY_BACKEND`, `NOISE_MODE`) or by editing the
defaults near the top of `python/main.py`.

### Mobile app

Standard Flutter project. From `studyscape_app/`:

```bash
flutter pub get
flutter run
```

For iOS, open `ios/Runner.xcworkspace` once in Xcode to set the signing
team and a unique bundle identifier.

## Firebase

Both pieces use the same Firebase project: `studyscapescu`.

- Edge node auth: service account JSON. Default location on the Uno Q is
  `/home/arduino/serviceAccount.json`. The bundled
  `studyscape_edge_node/python/serviceAccountKey.json` is a blank
  placeholder; paste your real credentials in or set the
  `FIREBASE_SERVICE_ACCOUNT` env var to point somewhere else.
- App auth: `firebase_options.dart` (already generated via
  `flutterfire configure`). End users sign in through Firebase Auth.

## Quick debugging guide

| Symptom                                | Look here                                                 |
|----------------------------------------|-----------------------------------------------------------|
| App shows hardcoded fallback values    | `[firebase] no credentials...` line in the Uno Q console  |
| Markers stay grey or stuck on "loading"| Check that `spaces/<id>` actually has docs in Firestore   |
| App crashes on launch                  | iOS signing: reopen `ios/Runner.xcworkspace`              |
| Edge node always reports `occ=0`       | Camera not connected, or YOLO ONNX failed to load         |
| Counts oscillate by ±1 between reports | Working as designed. See the hysteresis section in the    |
|                                        | edge node README.                                         |

## AI assistance disclosure

Parts of this project (notably the occupancy aggregation logic in
`studyscape_edge_node/python/occupancy_brick.py` and the v1.4 hysteresis
in `main.py`) were developed with help from Anthropic's Claude. The
algorithm design, testing in SCDI, hardware integration, and all
architectural decisions are ours.

## Authors

- Sanaa Ahmed (WDE)
- Zach Anderson (ECEN)
- Joshua Colleran (CSEN)
- Tiffany Doan (GENG)
- Andrew Pritchard (CSEN)
