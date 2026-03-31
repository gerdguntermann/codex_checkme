import 'dart:async';
import 'package:checkme/core/utils/app_logger.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/firestore_constants.dart';
import '../core/utils/time_utils.dart';
import '../data/check_in_service.dart';
import '../data/config_service.dart';
import '../data/notification_service.dart';
import '../domain/entities/check_in_config.dart';
import '../firebase_options.dart';

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
      log(
          'config: active=${config.isActive}, '
          'checkIn=${config.checkInHour}:${config.checkInMinute.toString().padLeft(2, '0')}, '
          'grace=${config.gracePeriodMinutes}min',
          name: 'BackgroundService');

      final checkInService = CheckInService(firestore, const Uuid());
      final lastCheckIn = await checkInService.getLastCheckIn(userId);
      log('lastCheckIn: ${lastCheckIn?.timestamp ?? 'none'}',
          name: 'BackgroundService');

      final state = TimeUtils.getState(lastCheckIn?.timestamp, config);
      final isOverdue = state == CheckInState.overdue;
      log('state: $state', name: 'BackgroundService');

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

      // Rotate: delete all log entries older than the retention threshold.
      final cutoff = now.subtract(
          const Duration(days: FirestoreConstants.backgroundLogRetentionDays));
      final oldLogs = await logsRef
          .where('ranAt', isLessThan: Timestamp.fromDate(cutoff))
          .get();
      if (oldLogs.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in oldLogs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        log('deleted ${oldLogs.docs.length} old background_log entries',
            name: 'BackgroundService');
      }

      if (!config.isActive) {
        log('monitoring inactive – done', name: 'BackgroundService');
        return true;
      }
      if (lastCheckIn == null) {
        log('no check-in yet – done', name: 'BackgroundService');
        return true;
      }

      // ── State-based notifications ───────────────────────────────────────────
      await _handleStateNotifications(state, lastCheckIn.timestamp, config, prefs);

      // ── Overdue trigger ─────────────────────────────────────────────────────
      if (isOverdue) {
        log('OVERDUE – writing overdue_trigger', name: 'BackgroundService');
        await firestore.collection('overdue_triggers').add({
          'userId': userId,
          'triggeredAt': Timestamp.fromDate(now),
        });
        log('overdue_trigger written', name: 'BackgroundService');
      }

      // ── Email-sent notifications ────────────────────────────────────────────
      await _handleEmailNotifications(firestore, userId, prefs, now);

      return true;
    } catch (e, stack) {
      log('task error: $e', name: 'BackgroundService', error: e, stackTrace: stack);
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

/// Shows the appropriate local notification when the state has changed since
/// the last run.  Uses the cycle-deadline as a deduplication key so that each
/// transition fires at most one notification.
Future<void> _handleStateNotifications(
  CheckInState state,
  DateTime lastCheckInTimestamp,
  CheckInConfig config,
  SharedPreferences prefs,
) async {
  final deadlineKey = _cycleDeadlineKey(state, lastCheckInTimestamp, config);
  log('state=$state, deadlineKey=$deadlineKey', name: 'BackgroundService');

  switch (state) {
    case CheckInState.windowOpen:
      if (prefs.getString(AppConstants.notifKeyWindowOpen) != deadlineKey) {
        await NotificationService.showWindowOpen();
        await prefs.setString(AppConstants.notifKeyWindowOpen, deadlineKey);
      }
    case CheckInState.grace:
      if (prefs.getString(AppConstants.notifKeyGrace) != deadlineKey) {
        await NotificationService.showGrace();
        await prefs.setString(AppConstants.notifKeyGrace, deadlineKey);
      }
    case CheckInState.overdue:
      if (prefs.getString(AppConstants.notifKeyOverdue) != deadlineKey) {
        await NotificationService.showOverdue();
        await prefs.setString(AppConstants.notifKeyOverdue, deadlineKey);
      }
    case CheckInState.ok:
      break; // no notification needed
  }
}

/// Returns an ISO-8601 string that uniquely identifies the current check-in
/// cycle for the given state, used as a notification deduplication key.
String _cycleDeadlineKey(
  CheckInState state,
  DateTime lastCheckIn,
  CheckInConfig config,
) {
  final DateTime deadline;
  if (state == CheckInState.windowOpen) {
    // Approaching deadline.
    deadline = TimeUtils.nextDeadline(lastCheckIn, config);
  } else if (config.timingMode == TimingMode.interval) {
    // Missed deadline in interval mode.
    deadline = lastCheckIn.add(Duration(minutes: config.intervalMinutes));
  } else {
    // Missed deadline in fixedTime mode.
    deadline = TimeUtils.previousFixedDeadline(config);
  }
  return deadline.toIso8601String();
}

/// Queries [notification_logs] for newly confirmed email sends and shows a
/// local notification for each one, preventing duplicates via SharedPreferences.
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

  final sentLogs = logsSnap.docs
      .where((d) => d.data()['status'] == 'sent')
      .toList();

  log('email notification check: ${sentLogs.length} new sent log(s)',
      name: 'BackgroundService');

  for (final doc in sentLogs) {
    final recipients =
        List<String>.from(doc.data()['recipientEmails'] as List? ?? []);
    await NotificationService.showEmailSent(recipients);
  }

  // Advance the watermark so we don't re-process these logs.
  await prefs.setString(AppConstants.notifKeyLastEmailCheck, now.toIso8601String());
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
