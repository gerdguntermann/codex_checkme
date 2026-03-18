import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/firestore_constants.dart';
import '../domain/entities/check_in_record.dart';
import 'models/check_in_record_model.dart';

class CheckInService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  CheckInService(this._firestore, this._uuid);

  CollectionReference<Map<String, dynamic>> _ref(String userId) => _firestore
      .collection(FirestoreConstants.usersCollection)
      .doc(userId)
      .collection(FirestoreConstants.checkInsCollection);

  Future<CheckInRecord> performCheckIn(String userId) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    log('performCheckIn – writing id=$id at $now', name: 'CheckInService');
    await _ref(userId).doc(id).set({
      'id': id,
      'userId': userId,
      'timestamp': Timestamp.fromDate(now),
    });
    log('performCheckIn – success', name: 'CheckInService');
    return CheckInRecord(id: id, userId: userId, timestamp: now);
  }

  Future<CheckInRecord?> getLastCheckIn(String userId) async {
    log('getLastCheckIn – querying', name: 'CheckInService');
    final snapshot = await _ref(userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      log('getLastCheckIn – no records', name: 'CheckInService');
      return null;
    }
    final record = CheckInRecordModel.fromJson(snapshot.docs.first.data()).toDomain();
    log('getLastCheckIn – found: ${record.timestamp}', name: 'CheckInService');
    return record;
  }
}
