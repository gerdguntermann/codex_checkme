import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkme/l10n/app_localizations.dart';

/// Wraps [child] with ProviderScope + de-localised MaterialApp.
/// [overrides] are forwarded to ProviderScope.
Widget buildTestApp(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => Scaffold(body: child)),
    GoRoute(path: '/config', builder: (_, __) => Scaffold(body: child)),
    GoRoute(path: '/contacts', builder: (_, __) => Scaffold(body: child)),
  ]);

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('de'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de'), Locale('en')],
    ),
  );
}
