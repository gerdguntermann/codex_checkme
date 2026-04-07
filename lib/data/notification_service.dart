import 'dart:io';

import 'package:checkme/core/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles all local notifications for CheckMe.
///
/// Call [initialize] once per process context (main isolate and Workmanager
/// background isolate) before using any other method.
///
/// Notifications are shown immediately via [show] – exact-alarm scheduling
/// is not used.  Timing is provided by the Workmanager periodic task.
class NotificationService {
  static const String _channelId = 'checkme_status';
  static const String _channelName = 'Status Benachrichtigungen';
  static const String _channelDesc =
      'Informiert über den aktuellen CheckMe-Status';

  static const int idWindowOpen = 1;
  static const int idOverdue = 3;
  static const int idEmailSent = 4;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Initialisation ─────────────────────────────────────────────────────────

  /// Initialises the plugin.  Safe to call multiple times.
  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings);
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );
    }
    log('NotificationService initialised', name: 'NotificationService');
  }

  /// Requests POST_NOTIFICATIONS on Android 13+ and alert/sound on iOS.
  static Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
          alert: true, badge: false, sound: true);
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      log('POST_NOTIFICATIONS granted: $granted', name: 'NotificationService');
    }
  }

  // ─── Immediate notifications ─────────────────────────────────────────────────

  /// Test notification – verifies channel and permission are working.
  static Future<void> showTest() => _show(
        id: 99,
        title: 'Test-Benachrichtigung',
        body: 'Benachrichtigungen funktionieren. ✓',
      );

  /// Shown when the check-in window opens.
  static Future<void> showWindowOpen() => _show(
        id: idWindowOpen,
        title: 'Jetzt einchecken',
        body: 'Das Check-in Fenster ist geöffnet.',
      );

  /// Shown when a window closes without a check-in.
  static Future<void> showOverdue() => _show(
        id: idOverdue,
        title: 'Überfällig',
        body: 'Check-in Fenster verpasst. Ihre Notfallkontakte werden '
            'per E-Mail benachrichtigt.',
        importance: Importance.max,
      );

  /// Shown when the Cloud Function confirms an email was sent.
  static Future<void> showEmailSent(List<String> recipients) => _show(
        id: idEmailSent,
        title: 'E-Mail gesendet',
        body: 'Benachrichtigung an ${recipients.length} '
            'Kontakt${recipients.length == 1 ? '' : 'e'} versendet.',
      );

  // ─── Internal helpers ────────────────────────────────────────────────────────

  static NotificationDetails _details({
    required String body,
    Importance importance = Importance.high,
  }) {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: importance,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    Importance importance = Importance.high,
  }) async {
    await _plugin.show(
        id, title, body, _details(body: body, importance: importance));
    log('Notification shown: id=$id title=$title', name: 'NotificationService');
  }
}
