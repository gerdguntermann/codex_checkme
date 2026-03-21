import '../../domain/entities/check_in_config.dart';

enum CheckInState { ok, windowOpen, grace, overdue }

class TimeUtils {
  static DateTime previousFixedDeadline(CheckInConfig config) {
    final now = DateTime.now();
    final todayDeadline = DateTime(
        now.year, now.month, now.day, config.checkInHour, config.checkInMinute);
    return now.isAfter(todayDeadline)
        ? todayDeadline
        : todayDeadline.subtract(const Duration(days: 1));
  }

  /// The next deadline: for fixedTime mode the next daily occurrence,
  /// for interval mode lastCheckIn + intervalMinutes.
  static DateTime nextDeadline(DateTime lastCheckIn, CheckInConfig config) {
    if (config.timingMode == TimingMode.interval) {
      return lastCheckIn.add(Duration(minutes: config.intervalMinutes));
    }
    final now = DateTime.now();
    final todayDeadline = DateTime(
        now.year, now.month, now.day, config.checkInHour, config.checkInMinute);
    return now.isBefore(todayDeadline)
        ? todayDeadline
        : todayDeadline.add(const Duration(days: 1));
  }

  /// Start of the pre-deadline check-in window.
  static DateTime checkInWindowStart(DateTime lastCheckIn, CheckInConfig config) {
    final deadline = nextDeadline(lastCheckIn, config);
    return deadline.subtract(Duration(minutes: config.preDeadlineMinutes));
  }

  /// Returns the current check-in state based on deadline and grace period.
  static CheckInState getState(DateTime? lastCheckIn, CheckInConfig config) {
    if (lastCheckIn == null) return CheckInState.ok;
    final now = DateTime.now();

    if (config.timingMode == TimingMode.interval) {
      final deadline =
          lastCheckIn.add(Duration(minutes: config.intervalMinutes));
      if (now.isAfter(
          deadline.add(Duration(minutes: config.gracePeriodMinutes)))) {
        return CheckInState.overdue;
      }
      if (now.isAfter(deadline)) return CheckInState.grace;
      final windowStart =
          deadline.subtract(Duration(minutes: config.preDeadlineMinutes));
      if (now.isAfter(windowStart)) return CheckInState.windowOpen;
      return CheckInState.ok;
    }

    // fixedTime
    final prev = previousFixedDeadline(config);
    if (lastCheckIn.isAfter(prev)) {
      // checked in after last deadline → check window for next deadline
      final next = nextDeadline(lastCheckIn, config);
      final windowStart =
          next.subtract(Duration(minutes: config.preDeadlineMinutes));
      if (now.isAfter(windowStart)) return CheckInState.windowOpen;
      return CheckInState.ok;
    }
    // missed last deadline
    if (now.isAfter(prev.add(Duration(minutes: config.gracePeriodMinutes)))) {
      return CheckInState.overdue;
    }
    if (now.isAfter(prev)) return CheckInState.grace;
    return CheckInState.ok;
  }

  /// Returns true when the user is allowed to perform a check-in.
  /// Allowed in windowOpen, grace, overdue states, and on first use (null).
  static bool isCheckInAllowed(DateTime? lastCheckIn, CheckInConfig config) {
    if (lastCheckIn == null) return true;
    return getState(lastCheckIn, config) != CheckInState.ok;
  }

  static bool isOverdue(DateTime? lastCheckIn, CheckInConfig config) =>
      getState(lastCheckIn, config) == CheckInState.overdue;

  /// Returns duration remaining until the next deadline, or Duration.zero if past.
  static Duration timeUntilDeadline(DateTime lastCheckIn, CheckInConfig config) {
    final deadline = nextDeadline(lastCheckIn, config);
    final remaining = deadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
