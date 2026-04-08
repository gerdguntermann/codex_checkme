import '../../domain/entities/check_in_config.dart';

enum CheckInState { ok, windowOpen, overdue }

class TimeUtils {
  static List<CheckInWindow> _sorted(CheckInConfig config) =>
      config.windows.toList()
        ..sort((a, b) => a.startHour != b.startHour
            ? a.startHour.compareTo(b.startHour)
            : a.startMinute.compareTo(b.startMinute));

  static (DateTime, DateTime) _windowOnDay(CheckInWindow w, DateTime day) => (
        DateTime(day.year, day.month, day.day, w.startHour, w.startMinute),
        DateTime(day.year, day.month, day.day, w.endHour, w.endMinute),
      );

  /// The most recently started window (open or just closed).
  /// Checks today first, then yesterday's last window.
  static (DateTime, DateTime)? _lastStartedWindow(
      CheckInConfig config, DateTime now) {
    final sorted = _sorted(config);

    for (final w in sorted.reversed) {
      final (start, end) = _windowOnDay(w, now);
      if (!now.isBefore(start)) return (start, end);
    }

    // No window started today – use yesterday's last window.
    return _windowOnDay(sorted.last, now.subtract(const Duration(days: 1)));
  }

  /// Current check-in state.
  static CheckInState getState(DateTime? lastCheckIn, CheckInConfig config) {
    final now = DateTime.now();
    final window = _lastStartedWindow(config, now);
    if (window == null) return CheckInState.ok;

    final (windowStart, windowEnd) = window;

    if (now.isBefore(windowEnd)) {
      // Currently inside the window.
      if (lastCheckIn != null && !lastCheckIn.isBefore(windowStart)) {
        return CheckInState.ok;
      }
      return CheckInState.windowOpen;
    }

    // Window has closed – check if user checked in during it.
    if (lastCheckIn != null &&
        !lastCheckIn.isBefore(windowStart) &&
        lastCheckIn.isBefore(windowEnd)) {
      return CheckInState.ok;
    }
    return CheckInState.overdue;
  }

  /// True when the user may perform a check-in.
  /// The first ever check-in (null [lastCheckIn]) is always allowed.
  static bool isCheckInAllowed(DateTime? lastCheckIn, CheckInConfig config) {
    if (lastCheckIn == null) return true;
    return getState(lastCheckIn, config) == CheckInState.windowOpen;
  }

  /// The start [DateTime] of the most recently started window.
  /// Used as a deduplication key for notifications.
  static DateTime? currentWindowStart(CheckInConfig config) {
    final w = _lastStartedWindow(config, DateTime.now());
    return w?.$1;
  }

  /// The end [DateTime] of the currently open window, or null if no window
  /// is open right now.
  static DateTime? currentWindowEnd(CheckInConfig config) {
    final now = DateTime.now();
    final w = _lastStartedWindow(config, now);
    if (w == null) return null;
    final (_, end) = w;
    return now.isBefore(end) ? end : null;
  }

  /// Duration until the next window opens.
  /// Returns [Duration.zero] when currently inside a window.
  static Duration timeUntilNextWindowStart(CheckInConfig config) {
    final now = DateTime.now();
    final sorted = _sorted(config);

    for (final w in sorted) {
      final (start, end) = _windowOnDay(w, now);
      if (now.isBefore(end)) {
        return now.isBefore(start) ? start.difference(now) : Duration.zero;
      }
    }

    // All today's windows have passed – time until tomorrow's first window.
    final (firstStart, _) =
        _windowOnDay(sorted.first, now.add(const Duration(days: 1)));
    return firstStart.difference(now);
  }

  /// [DateTime] when the next window opens.
  static DateTime nextWindowStart(CheckInConfig config) =>
      DateTime.now().add(timeUntilNextWindowStart(config));
}
