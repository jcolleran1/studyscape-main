// SPDX-License-Identifier: MPL-2.0
// Firestore streams for StudyScape spaces.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/space_reading.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Live updates for a single space.
  Stream<SpaceReading> watchSpace(String spaceId) {
    return _db
        .collection('spaces')
        .doc(spaceId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) {
        return SpaceReading.placeholder(spaceId: spaceId);
      }
      return SpaceReading.fromSnapshot(
        snap as DocumentSnapshot<Map<String, dynamic>>,
      );
    });
  }

  /// Live updates for several spaces (e.g. all markers on one floor).
  /// Returns a map keyed by space_id so UI lookups are O(1).
  Stream<Map<String, SpaceReading>> watchSpaces(List<String> spaceIds) {
    if (spaceIds.isEmpty) {
      return Stream.value(const <String, SpaceReading>{});
    }
    return _db
        .collection('spaces')
        .where(FieldPath.documentId, whereIn: spaceIds)
        .snapshots()
        .map((qs) {
      final Map<String, SpaceReading> out = {};
      for (final doc in qs.docs) {
        out[doc.id] = SpaceReading.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      // Fill in any missing docs with placeholders so the UI can still render.
      for (final id in spaceIds) {
        out.putIfAbsent(id, () => SpaceReading.placeholder(spaceId: id));
      }
      return out;
    });
  }

  /// One-shot read of all spaces for a specific building+floor.
  Future<List<SpaceReading>> fetchSpacesForFloor({
    required int buildingIndex,
    required int floor,
  }) async {
    final qs = await _db
        .collection('spaces')
        .where('building_index', isEqualTo: buildingIndex)
        .where('floor', isEqualTo: floor)
        .get();
    return qs.docs
        .map((d) => SpaceReading.fromSnapshot(
              d as DocumentSnapshot<Map<String, dynamic>>,
            ))
        .toList();
  }
}
