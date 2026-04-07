import 'package:checkme/core/utils/app_logger.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'background/background_service.dart';
import 'core/constants/app_constants.dart';
import 'data/check_in_service.dart';
import 'data/config_service.dart';
import 'domain/entities/check_in_config.dart';
import 'data/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/service_providers.dart';

/// Auf `true` setzen um die Flutter-App gegen den lokalen Firebase Emulator zu verbinden.
/// Starte den Emulator mit: `firebase emulators:start`
/// Starte die App mit Emulator: `flutter run --dart-define=USE_EMULATOR=true`
const bool kUseEmulator = bool.fromEnvironment('USE_EMULATOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.initialize();

  log('Firebase initializing...', name: 'main');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Firebase initialized', name: 'main');

  if (kUseEmulator) {
    log('Connecting to Firebase Emulator Suite...', name: 'main');
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    log('Emulator connected – Auth:9099, Firestore:8080', name: 'main');
  }

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    log('No current user – signing in anonymously', name: 'main');
    await auth.signInAnonymously();
  }
  final uid = auth.currentUser!.uid;
  log('Auth OK – uid: $uid', name: 'main');

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AppConstants.userIdKey, uid);

  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  log('NotificationService initialized', name: 'main');

  if (Platform.isAndroid) {
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    if (!batteryStatus.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  if (Platform.isAndroid) {
    await BackgroundService.initialize();
    // Register Workmanager with initialDelay tuned to the next window start.
    await _registerBackgroundTask(uid, prefs);
    log('Background service registered (Android)', name: 'main');
  } else {
    log('Background service skipped (not Android – no Workmanager)',
        name: 'main');
  }

  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const CheckMeApp(),
  ));
}

/// Loads config from Firestore/cache and registers the Workmanager task with
/// an [initialDelay] aligned to the next check-in window start.
Future<void> _registerBackgroundTask(
    String uid, SharedPreferences prefs) async {
  try {
    final config = await ConfigService(
            FirebaseFirestore.instance, prefs)
        .getConfig(uid);
    await BackgroundService.registerNextWindow(config);
  } catch (e) {
    log('Startup: failed to load config, using defaults: $e', name: 'main');
    await BackgroundService.registerNextWindow(
        CheckInConfig.defaults());
  }
}

class CheckMeApp extends ConsumerWidget {
  const CheckMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CheckMe',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
    );
  }
}
