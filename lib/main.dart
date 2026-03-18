import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'background/background_service.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/service_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('Firebase initializing...', name: 'main');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Firebase initialized', name: 'main');

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    log('No current user – signing in anonymously', name: 'main');
    await auth.signInAnonymously();
  }
  final uid = auth.currentUser!.uid;
  log('Auth OK – uid: $uid', name: 'main');

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AppConstants.userIdKey, uid);

  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicTask();
  log('Background service registered', name: 'main');

  if (Platform.isAndroid) {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      log('Requesting battery optimization exemption', name: 'main');
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const CheckMeApp(),
  ));
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
