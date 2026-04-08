import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/data/models/check_in_record_model.dart';

void main() {
  final dt = DateTime(2025, 6, 15, 10, 30);

  group('CheckInRecordModel.fromJson', () {
    test('parses Timestamp', () {
      final model = CheckInRecordModel.fromJson({
        'id': 'r1',
        'userId': 'u1',
        'timestamp': Timestamp.fromDate(dt),
      });
      expect(model.timestamp, dt);
    });

    test('parses legacy int timestamp (milliseconds)', () {
      final model = CheckInRecordModel.fromJson({
        'id': 'r1',
        'userId': 'u1',
        'timestamp': dt.millisecondsSinceEpoch,
      });
      expect(model.timestamp, dt);
    });

    test('throws ArgumentError on unsupported timestamp type', () {
      expect(
        () => CheckInRecordModel.fromJson({
          'id': 'r1',
          'userId': 'u1',
          'timestamp': 'not-a-timestamp',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CheckInRecordModel.toDomain', () {
    test('maps all fields correctly', () {
      final record = CheckInRecordModel.fromJson({
        'id': 'r1',
        'userId': 'u1',
        'timestamp': Timestamp.fromDate(dt),
      }).toDomain();

      expect(record.id, 'r1');
      expect(record.userId, 'u1');
      expect(record.timestamp, dt);
    });
  });

  group('CheckInRecordModel.fromDomain round-trip', () {
    test('fromDomain → toDomain is lossless', () {
      final original = CheckInRecordModel(id: 'r2', userId: 'u2', timestamp: dt);
      final restored = CheckInRecordModel.fromDomain(original.toDomain()).toDomain();
      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.timestamp, original.timestamp);
    });
  });
}
