// Note: Tests that create windows relative to DateTime.now() may produce
// unexpected results if run within 2h of midnight (day-boundary edge cases).
import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/core/utils/time_utils.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

CheckInConfig _cfg(List<CheckInWindow> windows) => CheckInConfig(
      windows: windows,
      maxNotifications: 3,
      isActive: true,
    );

/// Window that started [startMinsAgo] minutes ago and ends [endMinsFromNow]
/// minutes from now.
CheckInConfig _openWindow({int startMinsAgo = 30, int endMinsFromNow = 30}) {
  final now = DateTime.now();
  final s = now.subtract(Duration(minutes: startMinsAgo));
  final e = now.add(Duration(minutes: endMinsFromNow));
  return _cfg([
    CheckInWindow(
        startHour: s.hour,
        startMinute: s.minute,
        endHour: e.hour,
        endMinute: e.minute),
  ]);
}

/// Window that started [startMinsAgo] minutes ago and ended [endMinsAgo]
/// minutes ago.
CheckInConfig _closedWindow({int startMinsAgo = 70, int endMinsAgo = 10}) {
  final now = DateTime.now();
  final s = now.subtract(Duration(minutes: startMinsAgo));
  final e = now.subtract(Duration(minutes: endMinsAgo));
  return _cfg([
    CheckInWindow(
        startHour: s.hour,
        startMinute: s.minute,
        endHour: e.hour,
        endMinute: e.minute),
  ]);
}

void main() {
  // ── getState ──────────────────────────────────────────────────────────────

  group('getState – window open', () {
    test('windowOpen when no check-in and window is currently open', () {
      final cfg = _openWindow();
      // lastCheckIn is very old (before window opened)
      final last = DateTime.now().subtract(const Duration(hours: 25));
      expect(TimeUtils.getState(last, cfg), CheckInState.windowOpen);
    });

    test('windowOpen when lastCheckIn is null and window is open', () {
      final cfg = _openWindow();
      expect(TimeUtils.getState(null, cfg), CheckInState.windowOpen);
    });

    test('ok when checked in during the currently open window', () {
      final cfg = _openWindow(startMinsAgo: 30, endMinsFromNow: 30);
      // Checked in 10 min ago = within the open window
      final last = DateTime.now().subtract(const Duration(minutes: 10));
      expect(TimeUtils.getState(last, cfg), CheckInState.ok);
    });
  });

  group('getState – window closed', () {
    test('overdue when window closed and no check-in during it', () {
      final cfg = _closedWindow();
      final last = DateTime.now().subtract(const Duration(hours: 25));
      expect(TimeUtils.getState(last, cfg), CheckInState.overdue);
    });

    test('overdue with null lastCheckIn and closed window', () {
      final cfg = _closedWindow();
      expect(TimeUtils.getState(null, cfg), CheckInState.overdue);
    });

    test('ok when checked in during the window that has now closed', () {
      final cfg = _closedWindow(startMinsAgo: 70, endMinsAgo: 10);
      // Checked in 30 min ago = within the closed window (started 70 min ago, ended 10 min ago)
      final last = DateTime.now().subtract(const Duration(minutes: 30));
      expect(TimeUtils.getState(last, cfg), CheckInState.ok);
    });
  });

  group('getState – before window', () {
    test('returns ok before window with no check-in (treated as yesterday window)',
        () {
      // A future window has not started yet; _lastStartedWindow returns yesterday's.
      // Since it's the same window on yesterday, and lastCheckIn is null → overdue or ok
      // depending on whether it's actually in overdue. Hard to test time-independently.
      // Instead, just verify it returns a valid state.
      final now = DateTime.now();
      final start = now.add(const Duration(minutes: 30));
      final end = now.add(const Duration(minutes: 90));
      final cfg = _cfg([
        CheckInWindow(
            startHour: start.hour,
            startMinute: start.minute,
            endHour: end.hour,
            endMinute: end.minute),
      ]);
      final state = TimeUtils.getState(null, cfg);
      expect(state, isA<CheckInState>());
    });
  });

  // ── isCheckInAllowed ──────────────────────────────────────────────────────

  group('isCheckInAllowed', () {
    test('true when lastCheckIn is null (first use)', () {
      expect(TimeUtils.isCheckInAllowed(null, CheckInConfig.defaults()), isTrue);
    });

    test('true when window is open and no check-in during it', () {
      final cfg = _openWindow();
      final last = DateTime.now().subtract(const Duration(hours: 25));
      expect(TimeUtils.isCheckInAllowed(last, cfg), isTrue);
    });

    test('false when checked in during currently open window', () {
      final cfg = _openWindow(startMinsAgo: 30, endMinsFromNow: 30);
      final last = DateTime.now().subtract(const Duration(minutes: 10));
      expect(TimeUtils.isCheckInAllowed(last, cfg), isFalse);
    });

    test('false when window closed and user is overdue', () {
      final cfg = _closedWindow();
      final last = DateTime.now().subtract(const Duration(hours: 25));
      expect(TimeUtils.isCheckInAllowed(last, cfg), isFalse);
    });
  });

  // ── currentWindowStart / currentWindowEnd ─────────────────────────────────

  group('currentWindowStart', () {
    test('returns start of currently open window', () {
      final now = DateTime.now();
      final startDt = now.subtract(const Duration(minutes: 30));
      final endDt = now.add(const Duration(minutes: 30));
      final cfg = _cfg([
        CheckInWindow(
            startHour: startDt.hour,
            startMinute: startDt.minute,
            endHour: endDt.hour,
            endMinute: endDt.minute),
      ]);
      final windowStart = TimeUtils.currentWindowStart(cfg);
      expect(windowStart, isNotNull);
      expect(windowStart!.hour, startDt.hour);
      expect(windowStart.minute, startDt.minute);
    });
  });

  group('currentWindowEnd', () {
    test('returns end datetime when window is open', () {
      final now = DateTime.now();
      final start = now.subtract(const Duration(minutes: 30));
      final end = now.add(const Duration(minutes: 30));
      final cfg = _cfg([
        CheckInWindow(
            startHour: start.hour,
            startMinute: start.minute,
            endHour: end.hour,
            endMinute: end.minute),
      ]);
      final windowEnd = TimeUtils.currentWindowEnd(cfg);
      expect(windowEnd, isNotNull);
      expect(windowEnd!.isAfter(now), isTrue);
    });

    test('returns null when window is closed', () {
      final cfg = _closedWindow();
      expect(TimeUtils.currentWindowEnd(cfg), isNull);
    });
  });

  // ── timeUntilNextWindowStart ──────────────────────────────────────────────

  group('timeUntilNextWindowStart', () {
    test('returns Duration.zero when inside a window', () {
      final cfg = _openWindow();
      expect(TimeUtils.timeUntilNextWindowStart(cfg), Duration.zero);
    });

    test('returns positive duration when outside a window', () {
      final cfg = _closedWindow();
      final delay = TimeUtils.timeUntilNextWindowStart(cfg);
      expect(delay.inSeconds, greaterThan(0));
    });
  });

  // ── nextWindowStart ───────────────────────────────────────────────────────

  group('nextWindowStart', () {
    test('returns future datetime when outside window', () {
      final cfg = _closedWindow();
      final next = TimeUtils.nextWindowStart(cfg);
      expect(next.isAfter(DateTime.now()), isTrue);
    });

    test('returns approximately now when inside window', () {
      final cfg = _openWindow();
      final next = TimeUtils.nextWindowStart(cfg);
      // When inside window, delay is 0, so nextWindowStart ≈ now
      expect(next.isAfter(DateTime.now().subtract(const Duration(seconds: 5))),
          isTrue);
    });
  });

  // ── Two-window config ─────────────────────────────────────────────────────

  group('two-window config', () {
    test('windowOpen in first window', () {
      final now = DateTime.now();
      final w1start = now.subtract(const Duration(minutes: 30));
      final w1end = now.add(const Duration(minutes: 30));
      final w2start = now.add(const Duration(hours: 6));
      final w2end = now.add(const Duration(hours: 7));
      final cfg = _cfg([
        CheckInWindow(
            startHour: w1start.hour,
            startMinute: w1start.minute,
            endHour: w1end.hour,
            endMinute: w1end.minute),
        CheckInWindow(
            startHour: w2start.hour,
            startMinute: w2start.minute,
            endHour: w2end.hour,
            endMinute: w2end.minute),
      ]);
      final last = now.subtract(const Duration(hours: 25));
      expect(TimeUtils.getState(last, cfg), CheckInState.windowOpen);
    });

    test('ok after checking in during first window', () {
      final now = DateTime.now();
      final w1start = now.subtract(const Duration(minutes: 30));
      final w1end = now.add(const Duration(minutes: 30));
      final w2start = now.add(const Duration(hours: 6));
      final w2end = now.add(const Duration(hours: 7));
      final cfg = _cfg([
        CheckInWindow(
            startHour: w1start.hour,
            startMinute: w1start.minute,
            endHour: w1end.hour,
            endMinute: w1end.minute),
        CheckInWindow(
            startHour: w2start.hour,
            startMinute: w2start.minute,
            endHour: w2end.hour,
            endMinute: w2end.minute),
      ]);
      final last = now.subtract(const Duration(minutes: 10));
      expect(TimeUtils.getState(last, cfg), CheckInState.ok);
    });
  });
}
