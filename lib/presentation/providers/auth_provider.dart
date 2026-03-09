import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});

final signInAnonymouslyProvider = FutureProvider<User?>((ref) async {
  final auth = ref.read(firebaseAuthProvider);
  if (auth.currentUser != null) return auth.currentUser;
  final credential = await auth.signInAnonymously();
  return credential.user;
});
