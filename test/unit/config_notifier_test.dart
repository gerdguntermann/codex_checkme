import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/data/config_service.dart';
import 'package:checkme/domain/entities/check_in_config.dart';
import 'package:checkme/presentation/providers/config_provider.dart';
import 'package:checkme/presentation/providers/service_providers.dart';
import 'package:checkme/presentation/providers/auth_provider.dart';

const _uid = 'test_user';

ProviderContainer _buildContainer(
    FakeFirebaseFirestore firestore, SharedPreferences prefs) {
  return ProviderContainer(overrides: [
    firestoreProvider.overrideWithValue(firestore),
    uuidProvider.overrideWithValue(const Uuid()),
    sharedPrefsProvider.overrideWithValue(prefs),
    currentUserIdProvider.overrideWith((ref) => _uid),
  ]);
}

Future<Map<String, dynamic>?> _loadStoredConfig(
    FakeFirebaseFirestore firestore) async {
  final snap = await firestore
      .collection('users')
      .doc(_uid)
      .collection('config')
      .doc('user_config')
      .get();
  return snap.data();
}

void main() {
  late FakeFirebaseFirestore firestore;
  late SharedPreferences prefs;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('ConfigNotifier.saveConfig', () {
    test('persists config to Firestore', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      final cfg = CheckInConfig.defaults().copyWith(maxNotifications: 5);
      await notifier.saveConfig(cfg);

      final stored = await _loadStoredConfig(firestore);
      expect(stored, isNotNull);
      expect(stored!['maxNotifications'], 5);
    });

    test('updates provider state immediately', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      final cfg = CheckInConfig.defaults().copyWith(isActive: false);
      await notifier.saveConfig(cfg);

      expect(
          container.read(configNotifierProvider).valueOrNull?.isActive, isFalse);
    });

    test('can save two windows', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      final cfg = CheckInConfig(
        windows: const [
          CheckInWindow(startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
          CheckInWindow(startHour: 18, startMinute: 0, endHour: 19, endMinute: 0),
        ],
        maxNotifications: 3,
        isActive: true,
      );
      await notifier.saveConfig(cfg);

      final stored = await _loadStoredConfig(firestore);
      final windows = stored!['windows'] as List;
      expect(windows.length, 2);
    });
  });
}
