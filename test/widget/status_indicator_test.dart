import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/domain/entities/check_in_config.dart';
import 'package:checkme/domain/entities/check_in_record.dart';
import 'package:checkme/presentation/pages/home/widgets/status_indicator.dart';
import 'package:checkme/presentation/providers/check_in_provider.dart';
import 'package:checkme/presentation/providers/config_provider.dart';
import 'helpers.dart';

// ── Fake notifiers (must extend the concrete provider notifier type) ───────────

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

// ── Helpers ───────────────────────────────────────────────────────────────────

List<Override> _overrides({CheckInRecord? record, required CheckInConfig config}) => [
      checkInNotifierProvider.overrideWith(() => _FakeCheckInNotifier(record)),
      configNotifierProvider.overrideWith(() => _FakeConfigNotifier(config)),
    ];

CheckInConfig _intervalCfg({
  int intervalMinutes = 60,
  int gracePeriodMinutes = 10,
  int preDeadlineMinutes = 0,
}) =>
    CheckInConfig.defaults().copyWith(
      timingMode: TimingMode.interval,
      intervalMinutes: intervalMinutes,
      gracePeriodMinutes: gracePeriodMinutes,
      preDeadlineMinutes: preDeadlineMinutes,
    );

CheckInRecord _record(Duration ago) => CheckInRecord(
      id: 'r1',
      userId: 'u1',
      timestamp: DateTime.now().subtract(ago),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

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

  group('StatusIndicator – interval mode', () {
    testWidgets('OK state: shows "OK" and "Alles gut"', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 10)),
          config: _intervalCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('OK: '), findsOneWidget);
      expect(find.text('Alles gut'), findsOneWidget);
    });

    testWidgets('grace state: shows "KARENZZEIT"', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 65)),
          config: _intervalCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('KARENZZEIT: '), findsOneWidget);
      expect(find.text('Check-in bald erforderlich'), findsOneWidget);
    });

    testWidgets('overdue state: shows "ÜBERFÄLLIG"', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 75)),
          config: _intervalCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('ÜBERFÄLLIG: '), findsOneWidget);
      expect(find.text('Check-in erforderlich!'), findsOneWidget);
    });

    testWidgets('windowOpen state: shows "FENSTER OFFEN"', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 50)),
          config: _intervalCfg(intervalMinutes: 60, preDeadlineMinutes: 20),
        ),
      ));
      await tester.pump();

      expect(find.text('FENSTER OFFEN: '), findsOneWidget);
      expect(find.text('Check-in Fenster offen'), findsOneWidget);
    });

    testWidgets('shows next deadline label', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const StatusIndicator(),
        overrides: _overrides(
          record: _record(const Duration(minutes: 10)),
          config: _intervalCfg(),
        ),
      ));
      await tester.pump();

      expect(find.text('Nächste Deadline: '), findsOneWidget);
    });
  });

  group('StatusIndicator – fixedTime mode', () {
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
}
