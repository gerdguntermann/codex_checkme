import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/check_in_record_model.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/error/exceptions.dart';

abstract class CheckInRemoteDatasource {
  Future<CheckInRecordModel> performCheckIn(String userId);
  Future<CheckInRecordModel?> getLastCheckIn(String userId);
  Future<List<CheckInRecordModel>> getCheckInHistory(String userId, {int limit = 20});
}

class CheckInRemoteDatasourceImpl implements CheckInRemoteDatasource {
  final FirebaseFirestore firestore;
  final Uuid uuid;

  CheckInRemoteDatasourceImpl(this.firestore, this.uuid);

  CollectionReference<Map<String, dynamic>> _checkInsRef(String userId) =>
      firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.checkInsCollection);

  @override
  Future<CheckInRecordModel> performCheckIn(String userId) async {
    try {
      final record = CheckInRecordModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime.now(),
      );
      await _checkInsRef(userId).doc(record.id).set(record.toJson());
      return record;
    } catch (e) {
      throw ServerException('Failed to perform check-in: $e');
    }
  }

  @override
  Future<CheckInRecordModel?> getLastCheckIn(String userId) async {
    try {
      final snapshot = await _checkInsRef(userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return CheckInRecordModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw ServerException('Failed to get last check-in: $e');
    }
  }

  @override
  Future<List<CheckInRecordModel>> getCheckInHistory(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _checkInsRef(userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => CheckInRecordModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get check-in history: $e');
    }
  }
}
