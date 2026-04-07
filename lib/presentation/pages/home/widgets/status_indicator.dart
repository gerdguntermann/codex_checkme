import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../providers/check_in_provider.dart';
import '../../../providers/config_provider.dart';
import '../../../../core/utils/time_utils.dart';

class StatusIndicator extends ConsumerStatefulWidget {
  const StatusIndicator({super.key});

  @override
  ConsumerState<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends ConsumerState<StatusIndicator> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rebuild every 30 s so windowOpen/overdue transitions appear without interaction.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final configState = ref.watch(configNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: checkInState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(l10n.genericError(err.toString()),
              style: const TextStyle(color: Colors.red)),
          data: (lastCheckIn) {
            if (lastCheckIn == null) {
              return _StatusRow(
                icon: Icons.info_outline,
                color: Colors.grey,
                label: l10n.noCheckInsYet,
                value: l10n.pressButtonToStart,
              );
            }

            final config = configState.valueOrNull;
            final formatter = DateFormat('dd.MM.yyyy HH:mm');
            final timeStr = formatter.format(lastCheckIn.timestamp);

            if (config != null) {
              final state = TimeUtils.getState(lastCheckIn.timestamp, config);
              final timeFormat = DateFormat('HH:mm');

              final (icon, color, statusLabel, statusValue) = switch (state) {
                CheckInState.ok => (
                    Icons.check_circle,
                    Colors.green,
                    l10n.statusOk,
                    l10n.allGood,
                  ),
                CheckInState.windowOpen => (
                    Icons.lock_open,
                    Colors.amber,
                    l10n.statusWindowOpen,
                    l10n.windowOpenMessage,
                  ),
                CheckInState.overdue => (
                    Icons.warning,
                    Colors.red,
                    l10n.statusOverdue,
                    l10n.checkInRequired,
                  ),
              };

              final windowEnd = TimeUtils.currentWindowEnd(config);
              final nextStart = TimeUtils.nextWindowStart(config);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusRow(
                    icon: icon,
                    color: color,
                    label: statusLabel,
                    value: statusValue,
                  ),
                  const Divider(),
                  _StatusRow(
                    icon: Icons.access_time,
                    color: Colors.blue,
                    label: l10n.lastCheckIn,
                    value: timeStr,
                  ),
                  if (state == CheckInState.windowOpen && windowEnd != null)
                    _StatusRow(
                      icon: Icons.timer_outlined,
                      color: Colors.amber,
                      label: l10n.windowEndsAtLabel,
                      value: timeFormat.format(windowEnd),
                    ),
                  if (state != CheckInState.windowOpen)
                    _StatusRow(
                      icon: Icons.timer_outlined,
                      color: Colors.orange,
                      label: l10n.nextWindowLabel,
                      value: _formatNextWindow(nextStart, l10n),
                    ),
                ],
              );
            }

            return _StatusRow(
              icon: Icons.check_circle,
              color: Colors.green,
              label: l10n.lastCheckIn,
              value: timeStr,
            );
          },
        ),
      ),
    );
  }
}

String _formatNextWindow(DateTime dt, AppLocalizations l10n) {
  final now = DateTime.now();
  final isToday =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  return isToday
      ? DateFormat('HH:mm').format(dt)
      : '${l10n.tomorrow} ${DateFormat('HH:mm').format(dt)}';
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatusRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
