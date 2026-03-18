import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/data/models/check_in_config_model.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

void main() {
  group('CheckInConfigModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = CheckInConfigModel.fromJson({
        'timingMode': 'interval',
        'checkInHour': 10,
        'checkInMinute': 30,
        'intervalMinutes': 120,
        'gracePeriodMinutes': 15,
        'maxNotifications': 5,
        'isActive': false,
      });
      expect(model.timingMode, 'interval');
      expect(model.checkInHour, 10);
      expect(model.checkInMinute, 30);
      expect(model.intervalMinutes, 120);
      expect(model.gracePeriodMinutes, 15);
      expect(model.maxNotifications, 5);
      expect(model.isActive, isFalse);
    });

    test('uses defaults for missing timingMode and intervalMinutes (backward compat)', () {
      final model = CheckInConfigModel.fromJson({
        'gracePeriodMinutes': 30,
        'maxNotifications': 3,
        'isActive': true,
      });
      expect(model.timingMode, 'fixedTime');
      expect(model.checkInHour, 9);
      expect(model.checkInMinute, 0);
      expect(model.intervalMinutes, 240);
    });
  });

  group('CheckInConfigModel.toJson', () {
    test('serializes all fields', () {
      const model = CheckInConfigModel(
        timingMode: 'interval',
        checkInHour: 8,
        checkInMinute: 0,
        intervalMinutes: 60,
        gracePeriodMinutes: 10,
        maxNotifications: 3,
        isActive: true,
      );
      final json = model.toJson();
      expect(json['timingMode'], 'interval');
      expect(json['intervalMinutes'], 60);
      expect(json['isActive'], isTrue);
    });
  });

  group('CheckInConfigModel domain round-trip', () {
    test('fromDomain → toJson → fromJson → toDomain is lossless', () {
      final original = CheckInConfig.defaults().copyWith(
        timingMode: TimingMode.interval,
        intervalMinutes: 90,
        gracePeriodMinutes: 20,
      );
      final restored =
          CheckInConfigModel.fromJson(CheckInConfigModel.fromDomain(original).toJson())
              .toDomain();
      expect(restored, original);
    });

    test('toDomain with unknown timingMode falls back to fixedTime', () {
      const model = CheckInConfigModel(
        timingMode: 'unknownMode',
        checkInHour: 9,
        checkInMinute: 0,
        intervalMinutes: 240,
        gracePeriodMinutes: 30,
        maxNotifications: 3,
        isActive: true,
      );
      expect(model.toDomain().timingMode, TimingMode.fixedTime);
    });

    test('both TimingMode values survive round-trip', () {
      for (final mode in TimingMode.values) {
        final cfg = CheckInConfig.defaults().copyWith(timingMode: mode);
        final restored = CheckInConfigModel.fromDomain(cfg).toDomain();
        expect(restored.timingMode, mode);
      }
    });
  });
}
