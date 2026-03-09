// GENERATED FILE – DO NOT EDIT MANUALLY
//
// Run `flutterfire configure` to regenerate this file after creating
// your Firebase project at https://console.firebase.google.com
//
// Steps:
//   1. dart pub global activate flutterfire_cli
//   2. flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
//
// Then uncomment the Firebase.initializeApp line in lib/main.dart:
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDeaV76T2PGOSaYiRaoew7JXqJuvaeu14g',
    appId: '1:296849038791:web:89d40aa2b05708c8078de2',
    messagingSenderId: '296849038791',
    projectId: 'checkme-app-a0e9e',
    authDomain: 'checkme-app-a0e9e.firebaseapp.com',
    storageBucket: 'checkme-app-a0e9e.firebasestorage.app',
  );

  // ─── PLACEHOLDER VALUES – replace with your actual Firebase config ───────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPNZq_xhv5HfXZXRCn1QRPIvK0O16iLsg',
    appId: '1:296849038791:android:cc897d8073223223078de2',
    messagingSenderId: '296849038791',
    projectId: 'checkme-app-a0e9e',
    storageBucket: 'checkme-app-a0e9e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuMqRpGz5h7fWECLyg13yIUY9id5z7h1s',
    appId: '1:296849038791:ios:62c157e314a81b32078de2',
    messagingSenderId: '296849038791',
    projectId: 'checkme-app-a0e9e',
    storageBucket: 'checkme-app-a0e9e.firebasestorage.app',
    iosBundleId: 'de.mydigits.checkme',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuMqRpGz5h7fWECLyg13yIUY9id5z7h1s',
    appId: '1:296849038791:ios:62c157e314a81b32078de2',
    messagingSenderId: '296849038791',
    projectId: 'checkme-app-a0e9e',
    storageBucket: 'checkme-app-a0e9e.firebasestorage.app',
    iosBundleId: 'de.mydigits.checkme',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDeaV76T2PGOSaYiRaoew7JXqJuvaeu14g',
    appId: '1:296849038791:web:b259ef7df1b03a63078de2',
    messagingSenderId: '296849038791',
    projectId: 'checkme-app-a0e9e',
    authDomain: 'checkme-app-a0e9e.firebaseapp.com',
    storageBucket: 'checkme-app-a0e9e.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_LINUX_API_KEY',
    appId: 'REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.firebasestorage.app',
  );
}