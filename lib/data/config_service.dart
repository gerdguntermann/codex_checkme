import 'dart:convert';
import 'package:checkme/core/utils/app_logger.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/firestore_constants.dart';
import '../domain/entities/check_in_config.dart';
import 'models/check_in_config_model.dart';

class ConfigService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  static const _cacheKey = 'check_in_config';

  ConfigService(this._firestore, this._prefs);

  DocumentReference<Map<String, dynamic>> _ref(String userId) => _firestore
      .collection(FirestoreConstants.usersCollection)
      .doc(userId)
      .collection(FirestoreConstants.configCollection)
      .doc(FirestoreConstants.configDocId);

  Future<CheckInConfig> getConfig(String userId) async {
    try {
      log('getConfig – fetching from Firestore', name: 'ConfigService');
      final doc = await _ref(userId).get();
      if (doc.exists && doc.data() != null) {
        final config = CheckInConfigModel.fromJson(doc.data()!).toDomain();
        await _prefs.setString(_cacheKey, jsonEncode(doc.data()!));
        log('getConfig – loaded from remote', name: 'ConfigService');
        return config;
      }
    } catch (e) {
      log('getConfig – remote failed: $e, trying cache', name: 'ConfigService');
    }
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      log('getConfig – loaded from cache', name: 'ConfigService');
      return CheckInConfigModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      ).toDomain();
    }
    log('getConfig – using defaults', name: 'ConfigService');
    return CheckInConfig.defaults();
  }

  Future<void> saveConfig(String userId, CheckInConfig config) async {
    log('saveConfig – writing', name: 'ConfigService');
    final model = CheckInConfigModel.fromDomain(config);
    final json = model.toJson();
    await _ref(userId).set(json);
    await _prefs.setString(_cacheKey, jsonEncode(json));
    log('saveConfig – success', name: 'ConfigService');
  }
}
