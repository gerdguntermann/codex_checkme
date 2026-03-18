/// Integration tests for the CheckMe UI.
///
/// These tests run on a real device/emulator but bypass Firebase by overriding
/// all Riverpod providers with in-memory fakes. No network access required.
///
/// Run with:
///   flutter test integration_test/app_flow_test.dart
///   flutter drive --driver=test_driver/integration_test.dart \
///                 --target=integration_test/app_flow_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:checkme/domain/entities/check_in_config.dart';
import 'package:checkme/domain/entities/check_in_record.dart';
import 'package:checkme/domain/entities/contact.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:checkme/presentation/pages/config/config_page.dart';
import 'package:checkme/presentation/pages/contacts/contacts_page.dart';
import 'package:checkme/presentation/pages/home/home_page.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:checkme/presentation/providers/auth_provider.dart';
import 'package:checkme/presentation/providers/check_in_provider.dart';
import 'package:checkme/presentation/providers/config_provider.dart';
import 'package:checkme/presentation/providers/contact_provider.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

class _FakeCheckInNotifier extends CheckInNotifier {
  CheckInRecord? _record;
  _FakeCheckInNotifier(this._record);

  @override
  Future<CheckInRecord?> build() async => _record;

  @override
  Future<void> performCheckIn() async {
    _record = CheckInRecord(
      id: 'test-id',
      userId: 'test-uid',
      timestamp: DateTime.now(),
    );
    state = AsyncData(_record);
  }
}

class _FakeConfigNotifier extends ConfigNotifier {
  CheckInConfig _config;
  _FakeConfigNotifier(this._config);

  @override
  Future<CheckInConfig> build() async => _config;

  @override
  Future<void> saveConfig(CheckInConfig cfg) async {
    _config = cfg;
    state = AsyncData(cfg);
  }
}

class _FakeContactsNotifier extends ContactsNotifier {
  final List<Contact> _contacts;
  _FakeContactsNotifier(this._contacts);

  @override
  Future<List<Contact>> build() async => _contacts;
}

// ── Test app ──────────────────────────────────────────────────────────────────

Widget _buildTestApp({
  CheckInRecord? lastCheckIn,
  CheckInConfig? config,
  List<Contact> contacts = const [],
}) {
  final router = GoRouter(initialLocation: '/', routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/config', builder: (_, __) => const ConfigPage()),
    GoRoute(path: '/contacts', builder: (_, __) => const ContactsPage()),
  ]);

  final effectiveConfig = config ?? CheckInConfig.defaults();
  final mockUser = MockUser(uid: 'test-uid');

  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
      currentUserIdProvider.overrideWithValue('test-uid'),
      checkInNotifierProvider.overrideWith(
          () => _FakeCheckInNotifier(lastCheckIn)),
      configNotifierProvider.overrideWith(
          () => _FakeConfigNotifier(effectiveConfig)),
      contactsNotifierProvider.overrideWith(
          () => _FakeContactsNotifier(contacts)),
    ],
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

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home screen', () {
    testWidgets('shows app title and action icons', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('CheckMe'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows check-in button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Ich bin OK'), findsOneWidget);
    });

    testWidgets('no check-in yet shows placeholder message', (tester) async {
      await tester.pumpWidget(_buildTestApp(lastCheckIn: null));
      await tester.pumpAndSettle();

      expect(find.text('Noch keine Check-ins: '), findsOneWidget);
    });

    testWidgets('existing check-in shows OK status', (tester) async {
      final record = CheckInRecord(
        id: 'r1',
        userId: 'test-uid',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      await tester.pumpWidget(_buildTestApp(lastCheckIn: record));
      await tester.pumpAndSettle();

      expect(find.text('OK: '), findsOneWidget);
      expect(find.text('Alles gut'), findsOneWidget);
    });

    testWidgets('overdue check-in shows ÜBERFÄLLIG status', (tester) async {
      final record = CheckInRecord(
        id: 'r1',
        userId: 'test-uid',
        timestamp: DateTime.now().subtract(const Duration(minutes: 75)),
      );
      final cfg = CheckInConfig.defaults().copyWith(
        timingMode: TimingMode.interval,
        intervalMinutes: 60,
        gracePeriodMinutes: 10,
      );
      await tester.pumpWidget(_buildTestApp(lastCheckIn: record, config: cfg));
      await tester.pumpAndSettle();

      expect(find.text('ÜBERFÄLLIG: '), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('settings icon navigates to config page', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Einstellungen'), findsOneWidget);
    });

    testWidgets('contacts icon navigates to contacts page', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      expect(find.text('Kontakte'), findsOneWidget);
    });

    testWidgets('back arrow on config page returns to home', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('CheckMe'), findsOneWidget);
    });
  });

  group('Config page – mode switching', () {
    testWidgets('can switch to interval mode', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Intervall'));
      await tester.pumpAndSettle();

      expect(find.text('Check-in Intervall'), findsOneWidget);
      expect(find.text('Tägliche Check-in Zeit'), findsNothing);
    });

    testWidgets('switching mode enables save button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Intervall'));
      await tester.pumpAndSettle();

      final saveBtn = tester.widget<IconButton>(
        find.ancestor(
            of: find.byIcon(Icons.save), matching: find.byType(IconButton)),
      );
      expect(saveBtn.onPressed, isNotNull);
    });
  });

  group('Contacts page', () {
    testWidgets('shows empty state when no contacts', (tester) async {
      await tester.pumpWidget(_buildTestApp(contacts: []));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      expect(find.text('Noch keine Kontakte'), findsOneWidget);
    });

    testWidgets('shows contact names when contacts exist', (tester) async {
      final contacts = [
        const Contact(id: '1', name: 'Anna', email: 'anna@example.com'),
        const Contact(id: '2', name: 'Bob', email: 'bob@example.com'),
      ];
      await tester.pumpWidget(_buildTestApp(contacts: contacts));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
  });
}
