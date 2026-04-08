import 'dart:async';
import 'package:checkme/core/utils/app_logger.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/firestore_constants.dart';
import '../core/utils/time_utils.dart';
import '../data/check_in_service.dart';
import '../data/config_service.dart';
import '../data/notification_service.dart';
import '../domain/entities/check_in_config.dart';
import '../firebase_options.dart';

/// Same flag as [main.dart] – must match so background isolates talk to emulators.
const bool kUseEmulator = bool.fromEnvironment('USE_EMULATOR');

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await AppLogger.initialize();
    await NotificationService.initialize();
    log('task started: $taskName', name: 'BackgroundService');
    try {
      if (Firebase.apps.isEmpty) {
        log('initializing Firebase in background', name: 'BackgroundService');
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
      if (kUseEmulator) {
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        log('background: using Firebase emulators', name: 'BackgroundService');
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('background: waiting for auth session…', name: 'BackgroundService');
        try {
          user = await FirebaseAuth.instance
              .authStateChanges()
              .where((u) => u != null)
              .map((u) => u!)
              .first
              .timeout(const Duration(seconds: 15));
        } on TimeoutException {
          log('background: auth timeout – aborting', name: 'BackgroundService');
          return false;
        }
      }
      if (user == null) {
        log('background: no authenticated user – aborting',
            name: 'BackgroundService');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final firestore = FirebaseFirestore.instance;

      final userId = user.uid;
      final prefsUserId = prefs.getString(AppConstants.userIdKey);
      if (prefsUserId != userId) {
        await prefs.setString(AppConstants.userIdKey, userId);
      }
      log('running for uid=$userId', name: 'BackgroundService');

      final configService = ConfigService(firestore, prefs);
      final config = await configService.getConfig(userId);
      log('config: active=${config.isActive}, windows=${config.windows.length}',
          name: 'BackgroundService');

      final checkInService = CheckInService(firestore, const Uuid());
      final lastCheckIn = await checkInService.getLastCheckIn(userId);
      log('lastCheckIn: ${lastCheckIn?.timestamp ?? 'none'}',
          name: 'BackgroundService');

      final state = TimeUtils.getState(lastCheckIn?.timestamp, config);
      final isOverdue = state == CheckInState.overdue;
      log('state: ${state.name}', name: 'BackgroundService');
      final now = DateTime.now();

      // ── Background log ──────────────────────────────────────────────────────
      final logsRef = firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.backgroundLogsCollection);

      await logsRef.add({
        'ranAt': Timestamp.fromDate(now),
        'isActive': config.isActive,
        'hasLastCheckIn': lastCheckIn != null,
        'lastCheckInAt': lastCheckIn != null
            ? Timestamp.fromDate(lastCheckIn.timestamp)
            : null,
        'isOverdue': isOverdue,
      });

      // Rotate old log entries.
      final cutoff = now.subtract(
          const Duration(days: FirestoreConstants.backgroundLogRetentionDays));
      final oldLogs = await logsRef
          .where('ranAt', isLessThan: Timestamp.fromDate(cutoff))
          .get();
      if (oldLogs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in oldLogs.docs) batch.delete(doc.reference);
        await batch.commit();
        log('deleted ${oldLogs.docs.length} old background_log entries',
            name: 'BackgroundService');
      }

      if (!config.isActive) {
        log('monitoring inactive – done', name: 'BackgroundService');
        return true;
      }

      // ── State-based notifications ────────────────────────────────────────────
      // Each window triggers at most one notification per type.  The window-start
      // ISO string serves as the deduplication key.
      final windowKey = TimeUtils.currentWindowStart(config)?.toIso8601String();
      if (windowKey != null) {
        switch (state) {
          case CheckInState.windowOpen:
            if (prefs.getString(AppConstants.notifKeyWindowOpen) != windowKey) {
              await NotificationService.showWindowOpen();
              await prefs.setString(AppConstants.notifKeyWindowOpen, windowKey);
              log('Notification: windowOpen', name: 'BackgroundService');
            }
          case CheckInState.overdue:
            if (prefs.getString(AppConstants.notifKeyOverdue) != windowKey) {
              await NotificationService.showOverdue();
              await prefs.setString(AppConstants.notifKeyOverdue, windowKey);
              log('Notification: overdue', name: 'BackgroundService');
            }
          case CheckInState.ok:
            break;
        }
      }

      if (lastCheckIn == null) {
        log('no check-in yet – done', name: 'BackgroundService');
        return true;
      }

      // ── Overdue trigger → triggers Cloud Function → sends emails ────────────
      if (isOverdue) {
        log('OVERDUE – writing overdue_trigger', name: 'BackgroundService');
        await firestore.collection('overdue_triggers').add({
          'userId': userId,
          'triggeredAt': Timestamp.fromDate(now),
        });
        log('overdue_trigger written', name: 'BackgroundService');
      }

      // ── Show notification for each newly sent email ──────────────────────────
      await _handleEmailNotifications(firestore, userId, prefs, now);

      return true;
    } catch (e, stack) {
      log('task error: $e',
          name: 'BackgroundService', error: e, stackTrace: stack);
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(AppConstants.userIdKey);
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.usersCollection)
              .doc(userId)
              .collection(FirestoreConstants.backgroundLogsCollection)
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

Future<void> _handleEmailNotifications(
  FirebaseFirestore firestore,
  String userId,
  SharedPreferences prefs,
  DateTime now,
) async {
  final lastCheckIso = prefs.getString(AppConstants.notifKeyLastEmailCheck);
  final lastCheck = lastCheckIso != null
      ? DateTime.parse(lastCheckIso)
      : now.subtract(const Duration(hours: 1));

  final logsSnap = await firestore
      .collection(FirestoreConstants.usersCollection)
      .doc(userId)
      .collection(FirestoreConstants.notificationLogsCollection)
      .where('createdAt', isGreaterThan: Timestamp.fromDate(lastCheck))
      .get();

  final sentLogs =
      logsSnap.docs.where((d) => d.data()['status'] == 'sent').toList();

  log('email notification check: ${sentLogs.length} new sent log(s)',
      name: 'BackgroundService');

  for (final doc in sentLogs) {
    final recipients =
        List<String>.from(doc.data()['recipientEmails'] as List? ?? []);
    await NotificationService.showEmailSent(recipients);
  }

  await prefs.setString(
      AppConstants.notifKeyLastEmailCheck, now.toIso8601String());
}

class BackgroundService {
  static Future<void> initialize() async {
    if (!_isAndroid) return;
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Registers (or re-registers) the periodic monitoring task.
  ///
  /// [config] is used to compute the [initialDelay] so the first run
  /// happens approximately when the next window opens, avoiding unnecessary
  /// wake-ups in the middle of the night.
  static Future<void> registerNextWindow(CheckInConfig config) async {
    if (!_isAndroid) return;
    await Workmanager().cancelAll();
    final delay = TimeUtils.timeUntilNextWindowStart(config);
    log('BackgroundService: registering task, next window in ${delay.inMinutes} min',
        name: 'BackgroundService');
    await Workmanager().registerPeriodicTask(
      AppConstants.backgroundTaskName,
      AppConstants.backgroundTaskName,
      tag: AppConstants.backgroundTaskTag,
      frequency: const Duration(minutes: 15),
      initialDelay: delay,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancelAll() async {
    if (!_isAndroid) return;
    await Workmanager().cancelAll();
  }
}
