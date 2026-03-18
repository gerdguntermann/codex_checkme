import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/core/utils/time_utils.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

void main() {
  CheckInConfig intervalCfg({int intervalMinutes = 60, int gracePeriodMinutes = 10}) =>
      CheckInConfig(
        timingMode: TimingMode.interval,
        checkInHour: 9,
        checkInMinute: 0,
        intervalMinutes: intervalMinutes,
        gracePeriodMinutes: gracePeriodMinutes,
        maxNotifications: 3,
        isActive: true,
      );

  // Fixed-time config with deadline at a given hour (today or yesterday)
  CheckInConfig fixedCfg({required int hour, int minute = 0, int gracePeriodMinutes = 30}) =>
      CheckInConfig(
        timingMode: TimingMode.fixedTime,
        checkInHour: hour,
        checkInMinute: minute,
        intervalMinutes: 240,
        gracePeriodMinutes: gracePeriodMinutes,
        maxNotifications: 3,
        isActive: true,
      );

  // ── Interval mode ────────────────────────────────────────────────────────

  group('interval mode – getState', () {
    test('ok: checked in 30 min ago, interval 60 min', () {
      final last = DateTime.now().subtract(const Duration(minutes: 30));
      expect(TimeUtils.getState(last, intervalCfg()), CheckInState.ok);
    });

    test('grace: 65 min ago, interval 60 + grace 10', () {
      final last = DateTime.now().subtract(const Duration(minutes: 65));
      expect(TimeUtils.getState(last, intervalCfg()), CheckInState.grace);
    });

    test('overdue: 75 min ago, interval 60 + grace 10', () {
      final last = DateTime.now().subtract(const Duration(minutes: 75));
      expect(TimeUtils.getState(last, intervalCfg()), CheckInState.overdue);
    });

    test('null lastCheckIn returns ok', () {
      expect(TimeUtils.getState(null, intervalCfg()), CheckInState.ok);
    });

    test('exactly at deadline edge → still ok (not yet past)', () {
      // 60 min ago – deadline is exactly now, grace not yet elapsed
      final last = DateTime.now().subtract(const Duration(minutes: 60));
      // could be ok or grace depending on sub-second timing; at least not overdue
      final state = TimeUtils.getState(last, intervalCfg());
      expect(state, isNot(CheckInState.overdue));
    });
  });

  group('interval mode – nextDeadline', () {
    test('returns lastCheckIn + intervalMinutes', () {
      final last = DateTime(2025, 3, 15, 10, 0);
      final cfg = intervalCfg(intervalMinutes: 120);
      expect(TimeUtils.nextDeadline(last, cfg), DateTime(2025, 3, 15, 12, 0));
    });

    test('5 min interval: deadline 5 min from last check-in', () {
      final last = DateTime(2025, 1, 1, 8, 0);
      expect(TimeUtils.nextDeadline(last, intervalCfg(intervalMinutes: 5)),
          DateTime(2025, 1, 1, 8, 5));
    });
  });

  group('interval mode – isOverdue', () {
    test('true when state is overdue', () {
      final last = DateTime.now().subtract(const Duration(minutes: 75));
      expect(TimeUtils.isOverdue(last, intervalCfg()), isTrue);
    });

    test('false when in grace period', () {
      final last = DateTime.now().subtract(const Duration(minutes: 65));
      expect(TimeUtils.isOverdue(last, intervalCfg()), isFalse);
    });

    test('false when ok', () {
      final last = DateTime.now().subtract(const Duration(minutes: 30));
      expect(TimeUtils.isOverdue(last, intervalCfg()), isFalse);
    });

    test('null returns false', () {
      expect(TimeUtils.isOverdue(null, intervalCfg()), isFalse);
    });
  });

  // ── Fixed-time mode ──────────────────────────────────────────────────────

  group('fixedTime mode – getState', () {
    test('ok: checked in after the last fixed deadline', () {
      final now = DateTime.now();
      // Deadline 2 hours ago; check-in 1 hour ago → ok
      final deadlineHour = now.subtract(const Duration(hours: 2)).hour;
      final cfg = fixedCfg(hour: deadlineHour, gracePeriodMinutes: 30);
      final last = now.subtract(const Duration(hours: 1));
      expect(TimeUtils.getState(last, cfg), CheckInState.ok);
    });

    test('overdue: missed deadline + grace elapsed', () {
      final now = DateTime.now();
      // Deadline 3 hours ago, grace 30 min, last check-in 25 hours ago
      final deadlineHour = now.subtract(const Duration(hours: 3)).hour;
      final cfg = fixedCfg(hour: deadlineHour, gracePeriodMinutes: 30);
      final last = now.subtract(const Duration(hours: 25));
      expect(TimeUtils.getState(last, cfg), CheckInState.overdue);
    });

    test('null lastCheckIn returns ok', () {
      expect(TimeUtils.getState(null, fixedCfg(hour: 9)), CheckInState.ok);
    });
  });

  group('fixedTime mode – nextDeadline', () {
    test('returns a future DateTime', () {
      final last = DateTime.now().subtract(const Duration(hours: 1));
      final deadline = TimeUtils.nextDeadline(last, fixedCfg(hour: 9));
      expect(deadline.isAfter(DateTime.now()), isTrue);
    });
  });

  // ── timeUntilDeadline ────────────────────────────────────────────────────

  group('timeUntilDeadline', () {
    test('positive when deadline in the future (interval)', () {
      final last = DateTime.now().subtract(const Duration(minutes: 10));
      final remaining = TimeUtils.timeUntilDeadline(last, intervalCfg(intervalMinutes: 60));
      expect(remaining.inMinutes, greaterThan(0));
    });

    test('Duration.zero when deadline passed (interval)', () {
      final last = DateTime.now().subtract(const Duration(hours: 3));
      final remaining = TimeUtils.timeUntilDeadline(last, intervalCfg(intervalMinutes: 60));
      expect(remaining, Duration.zero);
    });
  });
}
