import 'package:flutter/material.dart';

class TimeWindowPicker extends StatelessWidget {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  const TimeWindowPicker({
    super.key,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onChanged,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final startTime = TimeOfDay(hour: startHour, minute: startMinute);
    final endTime = TimeOfDay(hour: endHour, minute: endMinute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time Window', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start'),
                subtitle: Text(startTime.format(context)),
                leading: const Icon(Icons.play_arrow),
                onTap: () => _pickTime(context, startTime, onStartChanged),
              ),
            ),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End'),
                subtitle: Text(endTime.format(context)),
                leading: const Icon(Icons.stop),
                onTap: () => _pickTime(context, endTime, onEndChanged),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
