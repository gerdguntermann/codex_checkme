import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

void main() {
  group('CheckInConfig.defaults', () {
    test('returns expected default values', () {
      final cfg = CheckInConfig.defaults();
      expect(cfg.windows.length, 1);
      expect(cfg.windows.first.startHour, 9);
      expect(cfg.windows.first.startMinute, 0);
      expect(cfg.windows.first.endHour, 10);
      expect(cfg.windows.first.endMinute, 0);
      expect(cfg.maxNotifications, 3);
      expect(cfg.isActive, isTrue);
    });
  });

  group('CheckInConfig.copyWith', () {
    final base = CheckInConfig.defaults();

    test('overrides only specified fields', () {
      const newWindow = CheckInWindow(
          startHour: 18, startMinute: 0, endHour: 19, endMinute: 0);
      final copy = base.copyWith(
        windows: [newWindow],
        isActive: false,
      );
      expect(copy.windows.first.startHour, 18);
      expect(copy.isActive, isFalse);
      // unchanged
      expect(copy.maxNotifications, base.maxNotifications);
    });

    test('without arguments returns equal object', () {
      expect(base.copyWith(), base);
    });
  });

  group('CheckInWindow.copyWith', () {
    const w = CheckInWindow(
        startHour: 9, startMinute: 0, endHour: 10, endMinute: 0);

    test('overrides only specified fields', () {
      final copy = w.copyWith(startHour: 8, endHour: 9);
      expect(copy.startHour, 8);
      expect(copy.startMinute, 0);
      expect(copy.endHour, 9);
      expect(copy.endMinute, 0);
    });

    test('without arguments returns equal object', () {
      expect(w.copyWith(), w);
    });
  });

  group('CheckInConfig equality (Equatable)', () {
    test('two defaults are equal', () {
      expect(CheckInConfig.defaults(), CheckInConfig.defaults());
    });

    test('different windows → not equal', () {
      final a = CheckInConfig.defaults();
      const newWindow = CheckInWindow(
          startHour: 18, startMinute: 0, endHour: 19, endMinute: 0);
      final b = a.copyWith(windows: [newWindow]);
      expect(a, isNot(equals(b)));
    });

    test('different maxNotifications → not equal', () {
      final a = CheckInConfig.defaults();
      final b = a.copyWith(maxNotifications: 5);
      expect(a, isNot(equals(b)));
    });

    test('different isActive → not equal', () {
      final a = CheckInConfig.defaults();
      final b = a.copyWith(isActive: false);
      expect(a, isNot(equals(b)));
    });
  });
}
