import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkme/data/config_service.dart';
import 'package:checkme/domain/entities/check_in_config.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ConfigService service;
  const uid = 'test_user';

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = ConfigService(firestore, prefs);
  });

  group('ConfigService.getConfig', () {
    test('returns defaults when no config stored', () async {
      final config = await service.getConfig(uid);
      expect(config, CheckInConfig.defaults());
    });

    test('returns stored config after save', () async {
      final saved = CheckInConfig(
        windows: const [
          CheckInWindow(startHour: 8, startMinute: 0, endHour: 9, endMinute: 0),
          CheckInWindow(
              startHour: 18, startMinute: 0, endHour: 19, endMinute: 0),
        ],
        maxNotifications: 5,
        isActive: false,
      );
      await service.saveConfig(uid, saved);
      final loaded = await service.getConfig(uid);
      expect(loaded, saved);
    });
  });

  group('ConfigService.saveConfig', () {
    test('persists to Firestore', () async {
      final cfg = CheckInConfig.defaults().copyWith(isActive: false);
      await service.saveConfig(uid, cfg);

      final snap = await firestore
          .collection('users')
          .doc(uid)
          .collection('config')
          .doc('user_config')
          .get();

      expect(snap.exists, isTrue);
      expect(snap.data()!['isActive'], isFalse);
    });

    test('caches to SharedPreferences (survives firestore downtime)', () async {
      final cfg = CheckInConfig(
        windows: const [
          CheckInWindow(startHour: 7, startMinute: 0, endHour: 8, endMinute: 0)
        ],
        maxNotifications: 3,
        isActive: true,
      );
      await service.saveConfig(uid, cfg);

      // New service with empty Firestore but same prefs → must use cache
      final emptyFirestore = FakeFirebaseFirestore();
      final prefs = await SharedPreferences.getInstance();
      final cachedService = ConfigService(emptyFirestore, prefs);
      final loaded = await cachedService.getConfig(uid);
      expect(loaded.windows.first.startHour, 7);
    });

    test('overwrites existing config', () async {
      await service.saveConfig(uid, CheckInConfig.defaults());
      final updated = CheckInConfig.defaults().copyWith(maxNotifications: 7);
      await service.saveConfig(uid, updated);

      final loaded = await service.getConfig(uid);
      expect(loaded.maxNotifications, 7);
    });
  });
}
