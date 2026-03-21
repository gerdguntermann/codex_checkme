import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../providers/check_in_provider.dart';
import '../../../providers/config_provider.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../domain/entities/check_in_config.dart';

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
    // Rebuild every 30 s so grace/overdue transitions appear without interaction.
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
              final state =
                  TimeUtils.getState(lastCheckIn.timestamp, config);
              final deadline =
                  TimeUtils.nextDeadline(lastCheckIn.timestamp, config);
              final deadlineStr = _formatDeadline(deadline, config, l10n);

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
                CheckInState.grace => (
                    Icons.warning_amber,
                    Colors.orange,
                    l10n.statusGrace,
                    l10n.graceMessage,
                  ),
                CheckInState.overdue => (
                    Icons.warning,
                    Colors.red,
                    l10n.statusOverdue,
                    l10n.checkInRequired,
                  ),
              };

              final windowStart =
                  TimeUtils.checkInWindowStart(lastCheckIn.timestamp, config);
              final windowStartStr =
                  DateFormat('HH:mm').format(windowStart);

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
                  _StatusRow(
                    icon: Icons.timer_outlined,
                    color: state == CheckInState.ok || state == CheckInState.windowOpen
                        ? Colors.orange
                        : color,
                    label: l10n.nextDeadline,
                    value: deadlineStr,
                  ),
                  if (state == CheckInState.ok)
                    _StatusRow(
                      icon: Icons.lock_clock,
                      color: Colors.grey,
                      label: l10n.checkInWindowStartLabel,
                      value: windowStartStr,
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

String _formatDeadline(
    DateTime deadline, CheckInConfig config, AppLocalizations l10n) {
  if (config.timingMode == TimingMode.interval) {
    return DateFormat('dd.MM.yyyy HH:mm').format(deadline);
  }
  final isToday = deadline.day == DateTime.now().day;
  return isToday
      ? DateFormat('HH:mm').format(deadline)
      : '${l10n.tomorrow} ${DateFormat('HH:mm').format(deadline)}';
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
