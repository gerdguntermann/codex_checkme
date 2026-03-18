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
  group('ConfigPage – mode selector', () {
    testWidgets('shows SegmentedButton with both options', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Feste Uhrzeit'), findsOneWidget);
      expect(find.text('Intervall'), findsOneWidget);
    });

    testWidgets('fixedTime mode shows time picker tile', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      expect(find.text('Tägliche Check-in Zeit'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('interval mode shows interval slider, not time picker', (tester) async {
      await tester.pumpWidget(_buildConfigPage(
        CheckInConfig.defaults().copyWith(timingMode: TimingMode.interval),
      ));
      await tester.pump();

      expect(find.text('Check-in Intervall'), findsOneWidget);
      expect(find.text('Tägliche Check-in Zeit'), findsNothing);
    });

    testWidgets('switching to interval mode shows interval slider', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      await tester.tap(find.text('Intervall'));
      await tester.pump();

      expect(find.text('Check-in Intervall'), findsOneWidget);
      expect(find.text('Tägliche Check-in Zeit'), findsNothing);
    });

    testWidgets('switching back to fixedTime restores time picker', (tester) async {
      await tester.pumpWidget(_buildConfigPage(
        CheckInConfig.defaults().copyWith(timingMode: TimingMode.interval),
      ));
      await tester.pump();

      await tester.tap(find.text('Feste Uhrzeit'));
      await tester.pump();

      expect(find.text('Tägliche Check-in Zeit'), findsOneWidget);
      expect(find.text('Check-in Intervall'), findsNothing);
    });
  });

  group('ConfigPage – shared controls', () {
    testWidgets('shows grace period slider for both modes', (tester) async {
      for (final mode in TimingMode.values) {
        await tester.pumpWidget(
            _buildConfigPage(CheckInConfig.defaults().copyWith(timingMode: mode)));
        await tester.pump();
        expect(find.text('Karenzzeit'), findsOneWidget, reason: 'mode: $mode');
      }
    });

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

    testWidgets('save button enabled after switching mode', (tester) async {
      await tester.pumpWidget(_buildConfigPage(CheckInConfig.defaults()));
      await tester.pump();

      await tester.tap(find.text('Intervall'));
      await tester.pump();

      final saveBtn = tester.widget<IconButton>(
        find.ancestor(
            of: find.byIcon(Icons.save), matching: find.byType(IconButton)),
      );
      expect(saveBtn.onPressed, isNotNull);
    });
  });
}
