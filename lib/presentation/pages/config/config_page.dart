import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../providers/config_provider.dart';
import '../../../domain/entities/check_in_config.dart';
import 'widgets/interval_slider.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  CheckInConfig? _editingConfig;
  bool _saving = false;

  Future<void> _pickCheckInTime(CheckInConfig editing) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: editing.checkInHour, minute: editing.checkInMinute),
    );
    if (picked != null) {
      setState(() => _editingConfig = editing.copyWith(
            checkInHour: picked.hour,
            checkInMinute: picked.minute,
          ));
    }
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_editingConfig == null) return;
    setState(() => _saving = true);
    await ref.read(configNotifierProvider.notifier).saveConfig(_editingConfig!);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSaved)),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (_saving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _editingConfig != null ? () => _save(l10n) : null,
            ),
        ],
      ),
      body: configState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.genericError(err.toString()))),
        data: (config) {
          _editingConfig ??= config;
          final editing = _editingConfig!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Mode selector ────────────────────────────
                        Text(l10n.timingModeLabel,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<TimingMode>(
                          segments: [
                            ButtonSegment(
                              value: TimingMode.fixedTime,
                              label: Text(l10n.timingModeFixedTime),
                              icon: const Icon(Icons.schedule),
                            ),
                            ButtonSegment(
                              value: TimingMode.interval,
                              label: Text(l10n.timingModeInterval),
                              icon: const Icon(Icons.timer),
                            ),
                          ],
                          selected: {editing.timingMode},
                          onSelectionChanged: (s) => setState(
                              () => _editingConfig =
                                  editing.copyWith(timingMode: s.first)),
                        ),
                        const Divider(height: 24),

                        // ── Fixed time controls ──────────────────────
                        if (editing.timingMode == TimingMode.fixedTime) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.access_time),
                            title: Text(l10n.dailyCheckInTime),
                            subtitle: Text(
                              '${editing.checkInHour.toString().padLeft(2, '0')}:${editing.checkInMinute.toString().padLeft(2, '0')}${l10n.timeUnitSuffix}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            trailing: const Icon(Icons.edit),
                            onTap: () => _pickCheckInTime(editing),
                          ),
                        ],

                        // ── Interval controls ────────────────────────
                        if (editing.timingMode == TimingMode.interval) ...[
                          IntervalSlider(
                            label: l10n.checkInIntervalLabel,
                            value: editing.intervalMinutes,
                            min: 5,
                            max: 1440,
                            step: 5,
                            formatValue: (v) {
                              if (v < 60) return '$v min';
                              final h = v ~/ 60;
                              final m = v % 60;
                              return m == 0 ? '${h}h' : '${h}h ${m}min';
                            },
                            onChanged: (v) => setState(() =>
                                _editingConfig =
                                    editing.copyWith(intervalMinutes: v)),
                          ),
                        ],

                        const Divider(height: 24),

                        // ── Shared controls ──────────────────────────
                        IntervalSlider(
                          label: l10n.gracePeriodLabel,
                          value: editing.gracePeriodMinutes,
                          min: 0,
                          max: 120,
                          unit: l10n.minuteUnit,
                          onChanged: (v) => setState(() => _editingConfig =
                              editing.copyWith(gracePeriodMinutes: v)),
                        ),
                        const Divider(height: 24),
                        IntervalSlider(
                          label: l10n.maxNotificationsLabel,
                          value: editing.maxNotifications,
                          min: 1,
                          max: 10,
                          onChanged: (v) => setState(() => _editingConfig =
                              editing.copyWith(maxNotifications: v)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.monitoringActive),
                    subtitle: Text(l10n.monitoringSubtitle),
                    value: editing.isActive,
                    onChanged: (v) => setState(
                        () => _editingConfig = editing.copyWith(isActive: v)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
