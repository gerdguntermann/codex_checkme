class AppConstants {
  static const String appName = 'My Daily OK';
  static const String backgroundTaskName = 'checkme_overdue_check';
  static const String backgroundTaskTag = 'checkme';
  static const String userIdKey = 'user_id';

  // SharedPreferences keys used for notification deduplication.
  // Each stores the ISO-8601 string of the deadline for which the
  // corresponding notification was last shown.
  static const String notifKeyWindowOpen = 'notif_window_open_deadline';
  static const String notifKeyGrace = 'notif_grace_deadline';
  static const String notifKeyOverdue = 'notif_overdue_deadline';

  // Stores the ISO-8601 timestamp up to which notification_logs have been
  // processed, to avoid showing the same email notification twice.
  static const String notifKeyLastEmailCheck = 'notif_last_email_check';
}
