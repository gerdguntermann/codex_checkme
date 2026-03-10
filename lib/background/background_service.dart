import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../data/datasources/local/config_local_datasource.dart';
import '../data/datasources/remote/check_in_remote_datasource.dart';
import '../data/datasources/remote/config_remote_datasource.dart';
import '../core/utils/time_utils.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await Firebase.initializeApp();
      final prefs = await SharedPreferences.getInstance();
      final firestore = FirebaseFirestore.instance;

      final localDs = ConfigLocalDatasourceImpl(prefs);
      final remoteConfigDs = ConfigRemoteDatasourceImpl(firestore);

      final userId = prefs.getString(AppConstants.userIdKey);
      if (userId == null) return true;

      final configModel = await () async {
        try {
          return await remoteConfigDs.getConfig(userId);
        } catch (_) {
          return await localDs.getConfig();
        }
      }();

      final config = configModel.toDomain();
      if (!config.isActive) return true;
      if (!TimeUtils.isWithinWindow(config)) return true;

      final checkInDs = CheckInRemoteDatasourceImpl(firestore, const Uuid());
      final lastCheckIn = await checkInDs.getLastCheckIn(userId);
      if (lastCheckIn == null) return true;

      final isOverdue = TimeUtils.isOverdue(lastCheckIn.timestamp, config);
      if (!isOverdue) return true;

      await firestore
          .collection('overdue_triggers')
          .add({'userId': userId, 'triggeredAt': DateTime.now().millisecondsSinceEpoch});

      return true;
    } catch (e) {
      debugPrint('Background task error: $e');
      return false;
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> registerPeriodicTask() async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      AppConstants.backgroundTaskName,
      AppConstants.backgroundTaskName,
      tag: AppConstants.backgroundTaskTag,
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();
  }
}
