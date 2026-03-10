import '../../domain/entities/check_in_config.dart';

class TimeUtils {
  /// Returns true if the current time is within the configured time window.
  static bool isWithinWindow(CheckInConfig config) {
    final now = DateTime.now();
    final startMinutes = config.timeWindowStartHour * 60 + config.timeWindowStartMinute;
    final endMinutes = config.timeWindowEndHour * 60 + config.timeWindowEndMinute;
    final nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  /// Returns true if the last check-in is overdue (past interval + grace period).
  static bool isOverdue(DateTime? lastCheckIn, CheckInConfig config) {
    if (lastCheckIn == null) return false;
    final deadline = lastCheckIn
        .add(Duration(minutes: config.intervalMinutes))
        .add(Duration(minutes: config.gracePeriodMinutes));
    return DateTime.now().isAfter(deadline);
  }

  /// Returns the deadline DateTime for the next check-in.
  static DateTime nextDeadline(DateTime lastCheckIn, CheckInConfig config) {
    return lastCheckIn
        .add(Duration(minutes: config.intervalMinutes))
        .add(Duration(minutes: config.gracePeriodMinutes));
  }

  /// Returns duration remaining until deadline, or Duration.zero if already overdue.
  static Duration timeUntilDeadline(DateTime lastCheckIn, CheckInConfig config) {
    final deadline = nextDeadline(lastCheckIn, config);
    final remaining = deadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
