import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/time_utils.dart';
import '../data/check_in_service.dart';
import '../data/config_service.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    log('task started: $taskName', name: 'BackgroundService');
    try {
      if (Firebase.apps.isEmpty) {
        log('initializing Firebase in background', name: 'BackgroundService');
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      final prefs = await SharedPreferences.getInstance();
      final firestore = FirebaseFirestore.instance;

      final userId = prefs.getString(AppConstants.userIdKey);
      if (userId == null) {
        log('no userId in prefs – aborting', name: 'BackgroundService');
        return true;
      }
      log('running for uid=$userId', name: 'BackgroundService');

      final configService = ConfigService(firestore, prefs);
      final config = await configService.getConfig(userId);
      log('config: active=${config.isActive}, checkIn=${config.checkInHour}:${config.checkInMinute.toString().padLeft(2, '0')}, grace=${config.gracePeriodMinutes}min',
          name: 'BackgroundService');

      final checkInService = CheckInService(firestore, const Uuid());
      final lastCheckIn = await checkInService.getLastCheckIn(userId);
      log('lastCheckIn: ${lastCheckIn?.timestamp ?? 'none'}', name: 'BackgroundService');

      final isOverdue = lastCheckIn != null && TimeUtils.isOverdue(lastCheckIn.timestamp, config);
      log('isOverdue: $isOverdue', name: 'BackgroundService');
      final now = DateTime.now();

      await firestore
          .collection('users')
          .doc(userId)
          .collection('background_logs')
          .add({
            'ranAt': Timestamp.fromDate(now),
            'isActive': config.isActive,
            'hasLastCheckIn': lastCheckIn != null,
            'lastCheckInAt': lastCheckIn != null ? Timestamp.fromDate(lastCheckIn.timestamp) : null,
            'isOverdue': isOverdue,
          });

      if (!config.isActive) {
        log('monitoring inactive – done', name: 'BackgroundService');
        return true;
      }
      if (lastCheckIn == null) {
        log('no check-in yet – done', name: 'BackgroundService');
        return true;
      }
      if (!isOverdue) {
        log('not overdue – done', name: 'BackgroundService');
        return true;
      }

      log('OVERDUE – writing overdue_trigger', name: 'BackgroundService');
      await firestore.collection('overdue_triggers').add({
        'userId': userId,
        'triggeredAt': Timestamp.fromDate(now),
      });
      log('overdue_trigger written', name: 'BackgroundService');

      return true;
    } catch (e, stack) {
      log('task error: $e', name: 'BackgroundService', error: e, stackTrace: stack);
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(AppConstants.userIdKey);
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('background_logs')
              .add({
                'ranAt': Timestamp.fromDate(DateTime.now()),
                'error': e.toString(),
              });
        }
      } catch (_) {}
      return false;
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicTask() async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      AppConstants.backgroundTaskName,
      AppConstants.backgroundTaskName,
      tag: AppConstants.backgroundTaskTag,
      frequency: const Duration(seconds: 900),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();
  }
}
