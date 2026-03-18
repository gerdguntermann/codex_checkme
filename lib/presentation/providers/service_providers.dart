import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/check_in_service.dart';
import '../../data/config_service.dart';
import '../../data/contact_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// Overridden in main.dart via ProviderScope
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider not overridden'),
);

final checkInServiceProvider = Provider<CheckInService>((ref) {
  return CheckInService(ref.watch(firestoreProvider), ref.watch(uuidProvider));
});

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService(ref.watch(firestoreProvider), ref.watch(sharedPrefsProvider));
});

final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService(ref.watch(firestoreProvider), ref.watch(uuidProvider));
});
