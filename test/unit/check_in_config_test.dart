import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

void main() {
  group('CheckInConfig.defaults', () {
    test('returns expected default values', () {
      final cfg = CheckInConfig.defaults();
      expect(cfg.timingMode, TimingMode.fixedTime);
      expect(cfg.checkInHour, 9);
      expect(cfg.checkInMinute, 0);
      expect(cfg.intervalMinutes, 240);
      expect(cfg.gracePeriodMinutes, 30);
      expect(cfg.maxNotifications, 3);
      expect(cfg.isActive, isTrue);
    });
  });

  group('CheckInConfig.copyWith', () {
    final base = CheckInConfig.defaults();

    test('overrides only specified fields', () {
      final copy = base.copyWith(
        timingMode: TimingMode.interval,
        intervalMinutes: 120,
        isActive: false,
      );
      expect(copy.timingMode, TimingMode.interval);
      expect(copy.intervalMinutes, 120);
      expect(copy.isActive, isFalse);
      // unchanged
      expect(copy.checkInHour, base.checkInHour);
      expect(copy.checkInMinute, base.checkInMinute);
      expect(copy.gracePeriodMinutes, base.gracePeriodMinutes);
      expect(copy.maxNotifications, base.maxNotifications);
    });

    test('without arguments returns equal object', () {
      expect(base.copyWith(), base);
    });
  });

  group('CheckInConfig equality (Equatable)', () {
    test('two defaults are equal', () {
      expect(CheckInConfig.defaults(), CheckInConfig.defaults());
    });

    test('different timingMode → not equal', () {
      final a = CheckInConfig.defaults();
      final b = a.copyWith(timingMode: TimingMode.interval);
      expect(a, isNot(equals(b)));
    });

    test('different intervalMinutes → not equal', () {
      final a = CheckInConfig.defaults();
      final b = a.copyWith(intervalMinutes: 60);
      expect(a, isNot(equals(b)));
    });

    test('different isActive → not equal', () {
      final a = CheckInConfig.defaults();
      final b = a.copyWith(isActive: false);
      expect(a, isNot(equals(b)));
    });
  });
}
