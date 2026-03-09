import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/check_in_config_model.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/error/exceptions.dart';

abstract class ConfigRemoteDatasource {
  Future<CheckInConfigModel> getConfig(String userId);
  Future<void> saveConfig(String userId, CheckInConfigModel config);
}

class ConfigRemoteDatasourceImpl implements ConfigRemoteDatasource {
  final FirebaseFirestore firestore;

  ConfigRemoteDatasourceImpl(this.firestore);

  DocumentReference<Map<String, dynamic>> _configRef(String userId) =>
      firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.configCollection)
          .doc(FirestoreConstants.configDocId);

  @override
  Future<CheckInConfigModel> getConfig(String userId) async {
    try {
      final doc = await _configRef(userId).get();
      if (!doc.exists || doc.data() == null) {
        throw const ServerException('Config not found');
      }
      return CheckInConfigModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get config: $e');
    }
  }

  @override
  Future<void> saveConfig(String userId, CheckInConfigModel config) async {
    try {
      await _configRef(userId).set(config.toJson());
    } catch (e) {
      throw ServerException('Failed to save config: $e');
    }
  }
}
