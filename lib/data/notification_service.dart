import 'package:checkme/core/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps [FlutterLocalNotificationsPlugin] and provides named methods for each
/// CheckMe notification event.
///
/// Must be initialised once per process context (main isolate AND Workmanager
/// background isolate) via [initialize] before calling any show* method.
class NotificationService {
  static const String _channelId = 'checkme_status';
  static const String _channelName = 'Status Benachrichtigungen';
  static const String _channelDesc =
      'Informiert über den aktuellen CheckMe-Status';

  /// Stable notification IDs – replacing a previous notification with the same
  /// ID updates it in-place instead of stacking new ones.
  static const int idWindowOpen = 1;
  static const int idGrace = 2;
  static const int idOverdue = 3;
  static const int idEmailSent = 4;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialise the plugin.  Safe to call multiple times.
  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    log('NotificationService initialised', name: 'NotificationService');
  }

  // ─── Internal helper ────────────────────────────────────────────────────────

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    Importance importance = Importance.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: importance,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    await _plugin.show(id, title, body, NotificationDetails(android: androidDetails));
    log('Notification shown: id=$id, title=$title', name: 'NotificationService');
  }

  // ─── Public notification methods ────────────────────────────────────────────

  /// State: windowOpen – the check-in window has opened.
  static Future<void> showWindowOpen() => _show(
        id: idWindowOpen,
        title: 'Jetzt einchecken',
        body: 'Das Zeitfenster für Ihren Check-in ist geöffnet.',
      );

  /// State: grace – deadline passed, grace period running.
  static Future<void> showGrace() => _show(
        id: idGrace,
        title: 'Deadline erreicht – Karenzzeit läuft',
        body:
            'Sie haben die Deadline verpasst. Bitte jetzt einchecken, solange '
            'die Karenzzeit noch läuft.',
        importance: Importance.max,
      );

  /// State: overdue – grace period expired, email notifications will be sent.
  static Future<void> showOverdue() => _show(
        id: idOverdue,
        title: 'Überfällig',
        body:
            'Karenzzeit abgelaufen. Ihre Notfallkontakte werden per E-Mail '
            'benachrichtigt.',
        importance: Importance.max,
      );

  /// An email notification was successfully sent by the Cloud Function.
  static Future<void> showEmailSent(List<String> recipients) => _show(
        id: idEmailSent,
        title: 'E-Mail gesendet',
        body:
            'Benachrichtigung an ${recipients.length} '
            'Kontakt${recipients.length == 1 ? '' : 'e'} versendet.',
      );
}
