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
    final prevWindowStart =
        prev.subtract(Duration(minutes: config.preDeadlineMinutes));

    // A check-in is valid for the most recent deadline cycle if it occurred
    // at or after the window opening of that cycle (not just after the deadline).
    if (!lastCheckIn.isBefore(prevWindowStart)) {
      // Valid check-in – check if the next cycle's window is open.
      final nextWindowStart = prev
          .add(const Duration(days: 1))
          .subtract(Duration(minutes: config.preDeadlineMinutes));
      if (now.isAfter(nextWindowStart)) return CheckInState.windowOpen;
      return CheckInState.ok;
    }

    // No valid check-in for the most recent cycle.
    // Check if the upcoming deadline's window is currently open (user can still fix it).
    final upcoming = nextDeadline(lastCheckIn, config);
    final upcomingWindowStart =
        upcoming.subtract(Duration(minutes: config.preDeadlineMinutes));
    if (now.isAfter(upcomingWindowStart)) return CheckInState.windowOpen;

    // Not in any window – determine overdue or grace from the most recent deadline.
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
