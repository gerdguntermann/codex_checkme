// Note: Tests that create windows relative to DateTime.now() may produce
// unexpected results within 2h of midnight (day-boundary edge cases).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/domain/entities/check_in_config.dart';
import 'package:checkme/domain/entities/check_in_record.dart';
import 'package:checkme/presentation/pages/home/widgets/status_indicator.dart';
import 'package:checkme/presentation/providers/check_in_provider.dart';
import 'package:checkme/presentation/providers/config_provider.dart';
import 'helpers.dart';

// ── Fake notifiers ─────────────────────────────────────────────────────────

class _FakeCheckInNotifier extends CheckInNotifier {
  final CheckInRecord? _record;
  _FakeCheckInNotifier(this._record);
  @override
  Future<CheckInRecord?> build() async => _record;
}

class _FakeConfigNotifier extends ConfigNotifier {
  final CheckInConfig _config;
  _FakeConfigNotifier(this._config);
  @override
  Future<CheckInConfig> build() async => _config;
}

// ── Helpers ────────────────────────────────────────────────────────────────

List<Override> _overrides(
        {CheckInRecord? record, required CheckInConfig config}) =>
    [
      checkInNotifierProvider.overrideWith(() => _FakeCheckInNotifier(record)),
      configNotifierProvider.overrideWith(() => _FakeConfigNotifier(config)),
    ];

CheckInRecord _record(Duration ago) => CheckInRecord(
      id: 'r1',
      userId: 'u1',
      timestamp: DateTime.now().subtract(ago),
    );

/// Window that started [startMinsAgo] minutes ago, ends [endMinsFromNow] from now.
CheckInConfig _openWindowCfg(
    {int startMinsAgo = 30, int endMinsFromNow = 30}) {
  final now = DateTime.now();
  final s = now.subtract(Duration(minutes: startMinsAgo));
  final e = now.add(Duration(minutes: endMinsFromNow));
  return CheckInConfig(
    windows: [
      CheckInWindow(
          startHour: s.hour,
          startMinute: s.minute,
          endHour: e.hour,
          endMinute: e.minute),
    ],
    maxNotifications: 3,
    isActive: true,
  );
}

/// Window that started [startMinsAgo] minutes ago, ended [endMinsAgo] ago.
CheckInConfig _closedWindowCfg(
    {int startMinsAgo = 70, int endMinsAgo = 10}) {
  final now = DateTime.now();
  final s = now.subtract(Duration(minutes: startMinsAgo));
  final e = now.subtract(Duration(minutes: endMinsAgo));
  return CheckInConfig(
    windows: [
      CheckInWindow(
          startHour: s.hour,
          startMinute: s.minute,
          endHour: e.hour,
          endMinute: e.minute),
    ],
    maxNotifications: 3,
    isActive: true,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('StatusIndicator – no check-in', () {
    testWidgets('shows "Noch keine Check-ins"', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(record: null, config: CheckInConfig.defaults()),
      ));
      await tester.pump();

      expect(find.text('Noch keine Check-ins: '), findsOneWidget);
    });
  });

  group('StatusIndicator – window open', () {
    testWidgets('shows FENSTER OFFEN when window is open and no check-in done',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(hours: 25)), // old check-in
          config: _openWindowCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('FENSTER OFFEN: '), findsOneWidget);
      expect(find.text('Check-in Fenster offen'), findsOneWidget);
    });

    testWidgets('shows "Fenster endet:" label during open window',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(hours: 25)),
          config: _openWindowCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('Fenster endet: '), findsOneWidget);
    });
  });

  group('StatusIndicator – ok state', () {
    testWidgets('shows OK and Alles gut after check-in during open window',
        (tester) async {
      final cfg = _openWindowCfg(startMinsAgo: 30, endMinsFromNow: 30);
      // Checked in 10 min ago = within the window
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 10)),
          config: cfg,
        ),
      ));
      await tester.pump();

      expect(find.text('OK: '), findsOneWidget);
      expect(find.text('Alles gut'), findsOneWidget);
    });

    testWidgets('shows "Nächstes Fenster:" label in OK state', (tester) async {
      final cfg = _openWindowCfg(startMinsAgo: 30, endMinsFromNow: 30);
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 10)),
          config: cfg,
        ),
      ));
      await tester.pump();

      expect(find.text('Nächstes Fenster: '), findsOneWidget);
    });

    testWidgets('shows last check-in label', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 5)),
          config: CheckInConfig.defaults(),
        ),
      ));
      await tester.pump();

      expect(find.text('Letzter Check-in: '), findsOneWidget);
    });
  });

  group('StatusIndicator – overdue state', () {
    testWidgets('shows ÜBERFÄLLIG when window closed and no check-in',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(hours: 25)),
          config: _closedWindowCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('ÜBERFÄLLIG: '), findsOneWidget);
      expect(find.text('Check-in erforderlich!'), findsOneWidget);
    });

    testWidgets('shows "Nächstes Fenster:" label when overdue', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(hours: 25)),
          config: _closedWindowCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('Nächstes Fenster: '), findsOneWidget);
    });
  });
}
