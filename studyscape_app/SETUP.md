# StudyScape — Complete Project

This is the full StudyScape project with everything merged together:

- **Flutter app** (`lib/`, `android/`, `ios/`, etc.) — wired to Firebase
- **`studyscape_edge_node/`** — Arduino UNO Q App Lab app (noise + occupancy)
- **`backend/`** — legacy prototype scripts (kept for reference)

## Quick start

### Part A — Flutter app (your dev machine)

Open PowerShell in this folder:

```powershell
cd <wherever-you-unzipped-this>
```

#### 1. Install dependencies

```powershell
flutter pub get
```

#### 2. Create / connect a Firebase project

If you haven't already:

```powershell
# One-time installs
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login

# Then, from this folder:
flutterfire configure
```

`flutterfire configure` will:
- let you pick or create a Firebase project (pick the StudyScape one)
- ask which platforms (select **android** and **ios** at minimum, spacebar to toggle)
- write `lib/firebase_options.dart`
- drop `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`

#### 3. Enable `firebase_options.dart` in main.dart

Open `lib/main.dart`. There are two commented-out lines marked with
`Uncomment this after flutterfire configure:` — uncomment both, and comment
out the plain `await Firebase.initializeApp();` line. It'll look like:

```dart
import 'firebase_options.dart';    // ← uncomment
// ...
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  // ← uncomment
// await Firebase.initializeApp();  // ← comment out
```

#### 4. Enable Firestore in the Firebase console

Firebase Console → your project → **Build → Firestore Database → Create database**.
Pick a region. Start in **test mode** (open reads/writes for 30 days) so the
Flutter app can read without needing auth during development.

#### 5. Run

```powershell
flutter run
```

Pick a target (Chrome for fastest iteration, or a connected phone).

Open the app → go to the home screen → tap the **SCDI** building → tap the
**Floor 2** button. The three markers will read live values from
Firestore documents `spaces/scdi_f2_a`, `spaces/scdi_f2_b`, `spaces/scdi_f2_c`.

Before the edge node is running, the markers fall back to the same seed
values you saw before (58%, 72%, 41% etc.) so the UI never looks broken.

---

### Part B — Edge node (on the Arduino UNO Q)

See `studyscape_edge_node/README.md` for full details. Quick version:

1. Open Arduino App Lab.
2. Import the `studyscape_edge_node` folder (or zip it first and import).
3. Open the sketch → click **Add Library** → install **Arduino_RouterBridge
   0.4.1 by Arduino** (not the BCMI-labs fork).
4. Edit `studyscape_edge_node/python/room_config.json` to match the room
   the device will monitor. Set `space_id` to one of the ids the app
   expects: `scdi_f2_a`, `scdi_f2_b`, or `scdi_f2_c`.
5. `scp serviceAccount.json arduino@<uno-q-ip>:/home/arduino/serviceAccount.json`
   (download the service-account JSON from Firebase Console → Project
   settings → Service accounts → Generate new private key)
6. Press Run in App Lab.

Within one 30-second cycle, the matching marker in the Flutter app will
show the live values.

---

## What's in this project

```
studyscape-main/
├── SETUP.md                          ← you are here
├── README.md                         ← original project README
├── pubspec.yaml                      ← now includes firebase deps
├── lib/
│   ├── main.dart                     ← Firebase init
│   ├── models/
│   │   └── space_reading.dart        ← NEW: Firestore → model
│   ├── services/
│   │   └── firestore_service.dart    ← NEW: space streams
│   ├── screens/
│   │   ├── building_detail_screen.dart ← streams 3 markers
│   │   ├── space_insights_screen.dart  ← streams single space
│   │   └── (other screens unchanged)
│   └── widgets/                      ← unchanged
├── assets/, images/, android/, ios/, etc.
├── studyscape_edge_node/             ← Arduino UNO Q app
│   ├── README.md
│   ├── app.yaml
│   ├── sketch/                       ← MCU code
│   └── python/                       ← MPU code + bundled yolov8n.onnx
└── backend/                          ← legacy reference scripts
```

## How the Flutter patch wires live data into the existing UI

Markers on SCDI Floor 2 already had hardcoded `capacityPercent`,
`noiseLevel`, `noiseHint` values. Those are now **fallbacks**. The actual
values come from a Firestore stream:

```dart
_firestore.watchSpaces(['scdi_f2_a', 'scdi_f2_b', 'scdi_f2_c'])
  .listen((Map<String, SpaceReading> live) {
    // live['scdi_f2_a'].occupancyPercent — current capacity
    // live['scdi_f2_a'].noiseLabel       — "Quiet Zone" / "Moderate Buzz" / "Loud"
    // live['scdi_f2_a'].status           — "online" / "offline"
  });
```

If Firestore has no document for a space yet, or the device is marked
offline, the UI keeps showing the seed values. No "loading..." or empty
placeholders.

## Firestore schema

Edge node writes, Flutter reads:

```
spaces/<space_id>
  space_id, space_name, building, building_index, floor, location_line, capacity
  occupancy, occupancy_percent, occupancy_level
  noise, noise_label, noise_hint, noise_raw, noise_source
  status, device_id, updated_at
  └─ history/<auto_id>               # time-series

devices/<device_id>
  status, location, updated_at
```

## Troubleshooting

| Symptom                                                  | Fix                                                     |
|----------------------------------------------------------|---------------------------------------------------------|
| `flutter pub get` fails on `firebase_core` / `cloud_firestore` | Upgrade Flutter: `flutter upgrade`. Minimum SDK is 3.10.8. |
| App crashes with `[firebase_core] No Firebase App '[DEFAULT]'` | `flutterfire configure` not run, or you didn't uncomment the lines in `main.dart`. |
| Markers show 58%/72%/41% even with edge node running     | Firestore has no doc yet. Wait one 30 s cycle, then check Firebase Console for a `spaces/scdi_f2_a` doc. |
| `Permission denied` reading Firestore                    | Firestore rules are too strict. In dev, use test mode (open reads). |
| `flutterfire` not found                                  | Run `dart pub global activate flutterfire_cli`, then add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH. |
