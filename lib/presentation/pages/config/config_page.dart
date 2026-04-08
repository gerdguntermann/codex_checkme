import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../data/notification_service.dart';
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

  Future<void> _pickTime(int windowIndex, bool isStart) async {
    final editing = _editingConfig!;
    final window = editing.windows[windowIndex];
    final initial = isStart
        ? TimeOfDay(hour: window.startHour, minute: window.startMinute)
        : TimeOfDay(hour: window.endHour, minute: window.endMinute);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final updated = isStart
        ? window.copyWith(startHour: picked.hour, startMinute: picked.minute)
        : window.copyWith(endHour: picked.hour, endMinute: picked.minute);
    final windows = List<CheckInWindow>.from(editing.windows);
    windows[windowIndex] = updated;
    setState(() => _editingConfig = editing.copyWith(windows: windows));
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
                // ── Windows ─────────────────────────────────────────
                for (int i = 0; i < editing.windows.length; i++) ...[
                  _WindowCard(
                    index: i,
                    window: editing.windows[i],
                    canRemove: editing.windows.length > 1,
                    onPickStart: () => _pickTime(i, true),
                    onPickEnd: () => _pickTime(i, false),
                    onRemove: () {
                      final windows =
                          List<CheckInWindow>.from(editing.windows)
                            ..removeAt(i);
                      setState(() =>
                          _editingConfig = editing.copyWith(windows: windows));
                    },
                    l10n: l10n,
                  ),
                  const SizedBox(height: 8),
                ],
                if (editing.windows.length < 2)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addWindow),
                    onPressed: () {
                      final windows =
                          List<CheckInWindow>.from(editing.windows)
                            ..add(const CheckInWindow(
                              startHour: 18,
                              startMinute: 0,
                              endHour: 19,
                              endMinute: 0,
                            ));
                      setState(() =>
                          _editingConfig = editing.copyWith(windows: windows));
                    },
                  ),
                const SizedBox(height: 8),

                // ── Max notifications ────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IntervalSlider(
                      label: l10n.maxNotificationsLabel,
                      value: editing.maxNotifications,
                      min: 1,
                      max: 10,
                      onChanged: (v) => setState(() => _editingConfig =
                          editing.copyWith(maxNotifications: v)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Monitoring toggle ────────────────────────────────
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.monitoringActive),
                    subtitle: Text(l10n.monitoringSubtitle),
                    value: editing.isActive,
                    onChanged: (v) => setState(
                        () => _editingConfig = editing.copyWith(isActive: v)),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Test notification ────────────────────────────────
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Test-Benachrichtigung'),
                    subtitle: const Text(
                        'Sofortige Benachrichtigung senden um Berechtigungen zu prüfen'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await NotificationService.requestPermissions();
                      await NotificationService.showTest();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Benachrichtigung gesendet – erscheint sie?'),
                          ),
                        );
                      }
                    },
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

class _WindowCard extends StatelessWidget {
  final int index;
  final CheckInWindow window;
  final bool canRemove;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onRemove;
  final AppLocalizations l10n;

  const _WindowCard({
    required this.index,
    required this.window,
    required this.canRemove,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onRemove,
    required this.l10n,
  });

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} Uhr';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Fenster ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_open),
              title: Text(l10n.windowStartLabel),
              subtitle: Text(
                _fmt(window.startHour, window.startMinute),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: const Icon(Icons.edit),
              onTap: onPickStart,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock),
              title: Text(l10n.windowEndLabel),
              subtitle: Text(
                _fmt(window.endHour, window.endMinute),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: const Icon(Icons.edit),
              onTap: onPickEnd,
            ),
          ],
        ),
      ),
    );
  }
}
