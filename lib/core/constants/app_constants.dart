class AppConstants {
  static const String appName = 'My Daily OK';
  static const String backgroundTaskName = 'checkme_overdue_check';
  static const String backgroundTaskTag = 'checkme';
  static const String userIdKey = 'user_id';

  // SharedPreferences keys for notification deduplication.
  // Each stores the ISO-8601 window-start timestamp for which the notification
  // was last shown, so each window triggers at most one notification per type.
  static const String notifKeyWindowOpen = 'notif_window_open_key';
  static const String notifKeyOverdue = 'notif_overdue_key';

  // Stores the ISO-8601 timestamp up to which notification_logs have been
  // processed, to avoid showing the same email notification twice.
  static const String notifKeyLastEmailCheck = 'notif_last_email_check';
}
