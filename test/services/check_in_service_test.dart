import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/data/check_in_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CheckInService service;
  const uid = 'test_user';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = CheckInService(firestore, const Uuid());
  });

  group('CheckInService.performCheckIn', () {
    test('writes a record and returns it', () async {
      final before = DateTime.now();
      final record = await service.performCheckIn(uid);
      final after = DateTime.now();

      expect(record.userId, uid);
      expect(record.id, isNotEmpty);
      expect(
        record.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(record.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('persists record to Firestore', () async {
      final record = await service.performCheckIn(uid);

      final snap = await firestore
          .collection('users')
          .doc(uid)
          .collection('check_ins')
          .doc(record.id)
          .get();

      expect(snap.exists, isTrue);
      expect(snap.data()!['userId'], uid);
    });

    test('each call creates a unique id', () async {
      final r1 = await service.performCheckIn(uid);
      final r2 = await service.performCheckIn(uid);
      expect(r1.id, isNot(equals(r2.id)));
    });
  });

  group('CheckInService.getLastCheckIn', () {
    test('returns null when no check-ins exist', () async {
      final result = await service.getLastCheckIn(uid);
      expect(result, isNull);
    });

    test('returns the most recent check-in', () async {
      await service.performCheckIn(uid);
      await Future.delayed(const Duration(milliseconds: 10));
      final latest = await service.performCheckIn(uid);

      final result = await service.getLastCheckIn(uid);
      expect(result?.id, latest.id);
    });

    test('is scoped per user', () async {
      await service.performCheckIn('user_a');
      final result = await service.getLastCheckIn('user_b');
      expect(result, isNull);
    });
  });
}
