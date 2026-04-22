// SPDX-License-Identifier: MPL-2.0
// Data model for a StudyScape space document from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class SpaceReading {
  const SpaceReading({
    required this.spaceId,
    required this.spaceName,
    required this.building,
    required this.buildingIndex,
    required this.floor,
    required this.locationLine,
    required this.capacity,
    required this.occupancy,
    required this.occupancyPercent,
    required this.occupancyLevel,
    required this.noise,
    required this.noiseLabel,
    required this.noiseHint,
    required this.noiseRaw,
    required this.noiseSource,
    required this.status,
    required this.updatedAt,
  });

  final String spaceId;
  final String spaceName;
  final String building;
  final int buildingIndex;
  final int floor;
  final String locationLine;
  final int capacity;

  /// Averaged person count in the last reporting window.
  final int occupancy;

  /// 0–100.
  final int occupancyPercent;

  /// 'low' | 'medium' | 'high'.
  final String occupancyLevel;

  /// 'low' | 'medium' | 'loud'.
  final String noise;

  /// Human-friendly label: 'Quiet Zone' | 'Moderate Buzz' | 'Loud' | 'Low Hum'.
  final String noiseLabel;

  /// Secondary hint: '', 'Headphones Rec.', 'Find a quieter spot'.
  final String noiseHint;

  /// Raw noise number — ADC counts in pin mode, dB in USB mode.
  final double noiseRaw;

  /// 'pin' | 'usb'.
  final String noiseSource;

  /// 'online' | 'offline'.
  final String status;

  final DateTime? updatedAt;

  factory SpaceReading.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? <String, dynamic>{};
    final ts = data['updated_at'];
    return SpaceReading(
      spaceId:          (data['space_id'] ?? snap.id).toString(),
      spaceName:        (data['space_name'] ?? snap.id).toString(),
      building:         (data['building'] ?? '').toString(),
      buildingIndex:    (data['building_index'] ?? 0) as int,
      floor:            (data['floor'] ?? 0) as int,
      locationLine:     (data['location_line'] ?? '').toString(),
      capacity:         (data['capacity'] ?? 0) as int,
      occupancy:        (data['occupancy'] ?? 0) as int,
      occupancyPercent: (data['occupancy_percent'] ?? 0) as int,
      occupancyLevel:   (data['occupancy_level'] ?? 'low').toString(),
      noise:            (data['noise'] ?? 'low').toString(),
      noiseLabel:       (data['noise_label'] ?? 'Low Hum').toString(),
      noiseHint:        (data['noise_hint'] ?? '').toString(),
      noiseRaw:         (data['noise_raw'] is num)
                           ? (data['noise_raw'] as num).toDouble()
                           : 0.0,
      noiseSource:      (data['noise_source'] ?? 'pin').toString(),
      status:           (data['status'] ?? 'offline').toString(),
      updatedAt:        (ts is Timestamp) ? ts.toDate() : null,
    );
  }

  /// Sensible placeholder when no Firestore document exists yet.
  factory SpaceReading.placeholder({
    required String spaceId,
    String? spaceName,
    String? locationLine,
  }) => SpaceReading(
        spaceId:          spaceId,
        spaceName:        spaceName ?? spaceId,
        building:         '',
        buildingIndex:    0,
        floor:            0,
        locationLine:     locationLine ?? '',
        capacity:         0,
        occupancy:        0,
        occupancyPercent: 0,
        occupancyLevel:   'low',
        noise:            'low',
        noiseLabel:       'Low Hum',
        noiseHint:        '',
        noiseRaw:         0.0,
        noiseSource:      'pin',
        status:           'offline',
        updatedAt:        null,
      );
}
