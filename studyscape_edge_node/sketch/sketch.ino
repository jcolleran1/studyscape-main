// SPDX-License-Identifier: MPL-2.0
// StudyScape edge sensor node (MCU side)
// Board: Arduino UNO Q, MCU: STM32U585 (Zephyr + Arduino Core)
//
// Reads MAX4466 pin mic on A0 and exposes classified noise via Bridge RPC.
// This is only compiled/flashed if the Linux side is configured for
// NOISE_MODE="pin". In USB-mic mode the sketch still boots but sits idle.
//
// Wiring (MAX4466 -> UNO Q JANALOG):
//   VCC -> 3V3 OUT    (NOT 5V. A0/PA4 is not 5V-tolerant.)
//   GND -> GND
//   OUT -> A0 (PA4)
//
// IMPORTANT SETUP STEP:
//   In App Lab, click "Add Library" and add Arduino_RouterBridge
//   (version 0.4.1 from Arduino, not the BCMI-labs fork) before Running.
//   App Lab does NOT auto-resolve this library from the #include alone.

#include <Arduino_RouterBridge.h>

const int MIC_PIN = A0;                      // PA4 on JANALOG
const unsigned long SAMPLE_WINDOW_MS = 50;   // one peak-to-peak window
const int  SAMPLES_PER_REPORT = 20;          // ~1 s averaged per reading

// Thresholds in 12-bit ADC counts (0..4095). CALIBRATE for your room.
// Updated from the user's actual readings:
//   quiet      ~ 68–120
//   talking    ~ 200–450
//   loud/claps ~ 1000+
const unsigned int LOW_MAX    = 150;
const unsigned int MEDIUM_MAX = 900;

static unsigned int readPeakToPeak() {
  unsigned long start = millis();
  unsigned int sigMax = 0;
  unsigned int sigMin = 4095;
  while (millis() - start < SAMPLE_WINDOW_MS) {
    unsigned int s = analogRead(MIC_PIN);
    if (s > sigMax) sigMax = s;
    if (s < sigMin) sigMin = s;
  }
  return sigMax - sigMin;
}

static unsigned int averagedP2P() {
  unsigned long sum = 0;
  for (int i = 0; i < SAMPLES_PER_REPORT; i++) {
    sum += readPeakToPeak();
  }
  return (unsigned int)(sum / SAMPLES_PER_REPORT);
}

// Returns "low" | "medium" | "loud"
String get_noise_level() {
  unsigned int avg = averagedP2P();
  Monitor.print("avgP2P=");
  Monitor.println(avg);

  if (avg < LOW_MAX)    return String("low");
  if (avg < MEDIUM_MAX) return String("medium");
  return String("loud");
}

// Raw averaged peak-to-peak ADC count (0-4095). Useful for tuning/graphing.
int get_noise_raw() {
  return (int)averagedP2P();
}

// Health check. Python calls this to verify the MCU is alive.
String ping() {
  return String("pong");
}

void setup() {
  Bridge.begin();
  Monitor.begin();

  analogReadResolution(12);
  pinMode(MIC_PIN, INPUT);

  if (!Bridge.provide("get_noise_level", get_noise_level)) {
    Monitor.println("ERROR registering get_noise_level");
  } else {
    Monitor.println("Registered: get_noise_level");
  }

  if (!Bridge.provide("get_noise_raw", get_noise_raw)) {
    Monitor.println("ERROR registering get_noise_raw");
  } else {
    Monitor.println("Registered: get_noise_raw");
  }

  Bridge.provide("ping", ping);

  Monitor.println("StudyScape MCU ready.");
}

void loop() {
  // RouterBridge services incoming RPCs internally.
  delay(10);
}
