import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/domain/entities/check_in_config.dart';
import 'package:checkme/presentation/pages/config/config_page.dart';
import 'package:checkme/presentation/providers/config_provider.dart';
import 'helpers.dart';

// Must extend the concrete ConfigNotifier type for overrideWith to type-check.
class _FakeConfigNotifier extends ConfigNotifier {
  final CheckInConfig _config;
  _FakeConfigNotifier(this._config);

  @override
  Future<CheckInConfig> build() async => _config;

  @override
  Future<void> saveConfig(CheckInConfig cfg) async {} // no-op in tests
}

Widget _buildConfigPage(CheckInConfig config) => buildTestApp(
      const ConfigPage(),
      overrides: [
        configNotifierProvider.overrideWith(() => _FakeConfigNotifier(config)),
      ],
    );

void main() {
  group('ConfigPage – window configuration', () {
    testWidgets('shows Fenster 1 card', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Fenster 1'), findsOneWidget);
    });

    testWidgets('shows start and end time picker tiles', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Fenster öffnet'), findsOneWidget);
      expect(find.text('Fenster schließt'), findsOneWidget);
    });

    testWidgets('shows add-second-window button when only 1 window',
        (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Zweites Zeitfenster hinzufügen'), findsOneWidget);
    });

    testWidgets('add-window button adds second window card', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      await tester.tap(find.text('Zweites Zeitfenster hinzufügen'));
      await tester.pump();

      expect(find.text('Fenster 1'), findsOneWidget);
      expect(find.text('Fenster 2'), findsOneWidget);
      expect(find.text('Zweites Zeitfenster hinzufügen'), findsNothing);
    });

    testWidgets('shows remove button when 2 windows exist', (tester) async {
      final config = CheckInConfig.defaults().copyWith(
        windows: const [
          CheckInWindow(startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
          CheckInWindow(
              startHour: 18, startMinute: 0, endHour: 19, endMinute: 0),
        ],
      );
      await tester.pumpWidget(_buildConfigPage(config));
      await tester.pump();

      expect(find.byIcon(Icons.remove_circle_outline), findsNWidgets(2));
    });

    testWidgets('no mode selector (SegmentedButton) present', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.byType(SegmentedButton<dynamic>), findsNothing);
    });
  });

  group('ConfigPage – shared controls', () {
    testWidgets('shows max notifications slider', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Max. Benachrichtigungen / Tag'), findsOneWidget);
    });

    testWidgets('shows monitoring active switch', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Monitoring aktiv'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });

  group('ConfigPage – save button', () {
    testWidgets('save button disabled before any change', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      final saveBtn = tester.widget<IconButton>(
        find.ancestor(
            of: find.byIcon(Icons.save), matching: find.byType(IconButton)),
      );
      expect(saveBtn.onPressed, isNull);
    });

    testWidgets('save button enabled after adding a second window',
        (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      await tester.tap(find.text('Zweites Zeitfenster hinzufügen'));
      await tester.pump();

      final saveBtn = tester.widget<IconButton>(
        find.ancestor(
            of: find.byIcon(Icons.save), matching: find.byType(IconButton)),
      );
      expect(saveBtn.onPressed, isNotNull);
    });
  });
}
