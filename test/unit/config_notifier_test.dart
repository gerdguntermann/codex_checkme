import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/data/check_in_service.dart';
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

Future<int> _checkInCount(FakeFirebaseFirestore firestore) async {
  final snap = await firestore
      .collection('users')
      .doc(_uid)
      .collection('check_ins')
      .get();
  return snap.docs.length;
}

void main() {
  late FakeFirebaseFirestore firestore;
  late SharedPreferences prefs;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('ConfigNotifier.saveConfig – impliziter Check-in', () {
    test('schreibt Check-in wenn timingMode geändert wird', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      // Initialzustand laden
      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      final changed = CheckInConfig.defaults()
          .copyWith(timingMode: TimingMode.interval);
      await notifier.saveConfig(changed);

      expect(await _checkInCount(firestore), 1);
    });

    test('schreibt Check-in wenn checkInHour geändert wird', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      await notifier.saveConfig(CheckInConfig.defaults().copyWith(checkInHour: 10));

      expect(await _checkInCount(firestore), 1);
    });

    test('schreibt Check-in wenn intervalMinutes geändert wird', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      await notifier.saveConfig(CheckInConfig.defaults().copyWith(intervalMinutes: 60));

      expect(await _checkInCount(firestore), 1);
    });

    test('kein Check-in wenn nur gracePeriodMinutes geändert wird', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      await notifier.saveConfig(
          CheckInConfig.defaults().copyWith(gracePeriodMinutes: 60));

      expect(await _checkInCount(firestore), 0);
    });

    test('kein Check-in wenn maxNotifications geändert wird', () async {
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      await container.read(configNotifierProvider.future);

      await notifier.saveConfig(
          CheckInConfig.defaults().copyWith(maxNotifications: 5));

      expect(await _checkInCount(firestore), 0);
    });

    test('kein Check-in beim ersten Laden (kein vorheriger State)', () async {
      // Direkt saveConfig aufrufen ohne vorherigen build()-Durchlauf
      final container = _buildContainer(firestore, prefs);
      addTearDown(container.dispose);

      final notifier = container.read(configNotifierProvider.notifier);
      // build() noch nicht abgewartet → state ist AsyncLoading
      await notifier.saveConfig(CheckInConfig.defaults());

      expect(await _checkInCount(firestore), 0);
    });
  });
}
