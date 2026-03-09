import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/config_provider.dart';
import '../../../domain/entities/check_in_config.dart';
import 'widgets/time_window_picker.dart';
import 'widgets/interval_slider.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  CheckInConfig? _editingConfig;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(configNotifierProvider).valueOrNull;
      if (config != null) {
        setState(() => _editingConfig = config);
      }
    });
  }

  Future<void> _save() async {
    if (_editingConfig == null) return;
    setState(() => _saving = true);
    await ref.read(configNotifierProvider.notifier).saveConfig(_editingConfig!);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (_saving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _editingConfig != null ? _save : null,
            ),
        ],
      ),
      body: configState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
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
                        IntervalSlider(
                          label: 'Check-in Interval',
                          value: editing.intervalHours,
                          min: 1,
                          max: 48,
                          unit: 'hours',
                          onChanged: (v) => setState(() =>
                              _editingConfig = editing.copyWith(intervalHours: v)),
                        ),
                        const Divider(),
                        IntervalSlider(
                          label: 'Grace Period',
                          value: editing.gracePeriodMinutes,
                          min: 0,
                          max: 120,
                          unit: 'min',
                          onChanged: (v) => setState(() =>
                              _editingConfig = editing.copyWith(gracePeriodMinutes: v)),
                        ),
                        const Divider(),
                        IntervalSlider(
                          label: 'Max Notifications / Day',
                          value: editing.maxNotifications,
                          min: 1,
                          max: 10,
                          unit: '',
                          onChanged: (v) => setState(() =>
                              _editingConfig = editing.copyWith(maxNotifications: v)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TimeWindowPicker(
                      startHour: editing.timeWindowStartHour,
                      startMinute: editing.timeWindowStartMinute,
                      endHour: editing.timeWindowEndHour,
                      endMinute: editing.timeWindowEndMinute,
                      onStartChanged: (t) => setState(() => _editingConfig =
                          editing.copyWith(
                            timeWindowStartHour: t.hour,
                            timeWindowStartMinute: t.minute,
                          )),
                      onEndChanged: (t) => setState(() => _editingConfig =
                          editing.copyWith(
                            timeWindowEndHour: t.hour,
                            timeWindowEndMinute: t.minute,
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    title: const Text('Monitoring Active'),
                    subtitle: const Text('Enable/disable all notifications'),
                    value: editing.isActive,
                    onChanged: (v) =>
                        setState(() => _editingConfig = editing.copyWith(isActive: v)),
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
