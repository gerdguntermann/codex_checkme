import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/data/models/check_in_config_model.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

void main() {
  group('CheckInConfigModel.fromJson – new windows format', () {
    test('parses windows array correctly', () {
      final model = CheckInConfigModel.fromJson({
        'windows': [
          {
            'startHour': 9,
            'startMinute': 0,
            'endHour': 10,
            'endMinute': 0,
          },
        ],
        'maxNotifications': 5,
        'isActive': false,
      });
      expect(model.windows.length, 1);
      expect(model.windows.first.startHour, 9);
      expect(model.windows.first.endHour, 10);
      expect(model.maxNotifications, 5);
      expect(model.isActive, isFalse);
    });

    test('parses two windows correctly', () {
      final model = CheckInConfigModel.fromJson({
        'windows': [
          {'startHour': 9, 'startMinute': 0, 'endHour': 10, 'endMinute': 0},
          {'startHour': 18, 'startMinute': 0, 'endHour': 19, 'endMinute': 0},
        ],
        'maxNotifications': 3,
        'isActive': true,
      });
      expect(model.windows.length, 2);
      expect(model.windows[1].startHour, 18);
    });
  });

  group('CheckInConfigModel.fromJson – backward compat (old format)', () {
    test('migrates checkInHour + gracePeriodMinutes to a single window', () {
      final model = CheckInConfigModel.fromJson({
        'checkInHour': 9,
        'checkInMinute': 0,
        'gracePeriodMinutes': 60,
        'maxNotifications': 3,
        'isActive': true,
      });
      expect(model.windows.length, 1);
      expect(model.windows.first.startHour, 9);
      expect(model.windows.first.startMinute, 0);
      // end = 9:00 + 60 min = 10:00
      expect(model.windows.first.endHour, 10);
      expect(model.windows.first.endMinute, 0);
    });

    test('uses defaults when checkInHour absent', () {
      final model = CheckInConfigModel.fromJson({
        'maxNotifications': 3,
        'isActive': true,
      });
      expect(model.windows.length, 1);
      expect(model.windows.first.startHour, 9);
    });
  });

  group('CheckInConfigModel.toJson', () {
    test('serializes windows array', () {
      const model = CheckInConfigModel(
        windows: [
          CheckInWindowModel(
              startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
        ],
        maxNotifications: 3,
        isActive: true,
      );
      final json = model.toJson();
      final windows = json['windows'] as List;
      expect(windows.length, 1);
      expect((windows.first as Map)['startHour'], 9);
      expect(json['isActive'], isTrue);
    });
  });

  group('CheckInConfigModel domain round-trip', () {
    test('fromDomain → toJson → fromJson → toDomain is lossless', () {
      final original = CheckInConfig(
        windows: const [
          CheckInWindow(startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
          CheckInWindow(
              startHour: 18, startMinute: 0, endHour: 19, endMinute: 0),
        ],
        maxNotifications: 5,
        isActive: false,
      );
      final restored =
          CheckInConfigModel.fromJson(CheckInConfigModel.fromDomain(original).toJson())
              .toDomain();
      expect(restored, original);
    });

    test('defaults survive round-trip', () {
      final original = CheckInConfig.defaults();
      final restored =
          CheckInConfigModel.fromJson(CheckInConfigModel.fromDomain(original).toJson())
              .toDomain();
      expect(restored, original);
    });
  });
}
