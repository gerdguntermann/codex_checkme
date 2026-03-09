import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/check_in_provider.dart';
import '../../../providers/config_provider.dart';
import '../../../../core/utils/time_utils.dart';

class StatusIndicator extends ConsumerWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final configState = ref.watch(configNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: checkInState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
          data: (lastCheckIn) {
            if (lastCheckIn == null) {
              return const _StatusRow(
                icon: Icons.info_outline,
                color: Colors.grey,
                label: 'No check-ins yet',
                value: 'Press the button to start',
              );
            }

            final config = configState.valueOrNull;
            final formatter = DateFormat('dd.MM.yyyy HH:mm');
            final timeStr = formatter.format(lastCheckIn.timestamp);

            if (config != null) {
              final overdue = TimeUtils.isOverdue(lastCheckIn.timestamp, config);
              final remaining = TimeUtils.timeUntilDeadline(lastCheckIn.timestamp, config);
              final hours = remaining.inHours;
              final minutes = remaining.inMinutes % 60;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusRow(
                    icon: overdue ? Icons.warning : Icons.check_circle,
                    color: overdue ? Colors.red : Colors.green,
                    label: overdue ? 'OVERDUE' : 'OK',
                    value: overdue ? 'Check-in required!' : 'All good',
                  ),
                  const Divider(),
                  _StatusRow(
                    icon: Icons.access_time,
                    color: Colors.blue,
                    label: 'Last check-in',
                    value: timeStr,
                  ),
                  if (!overdue)
                    _StatusRow(
                      icon: Icons.timer_outlined,
                      color: Colors.orange,
                      label: 'Next deadline in',
                      value: '${hours}h ${minutes}m',
                    ),
                ],
              );
            }

            return _StatusRow(
              icon: Icons.check_circle,
              color: Colors.green,
              label: 'Last check-in',
              value: timeStr,
            );
          },
        ),
      ),
    );
  }
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
