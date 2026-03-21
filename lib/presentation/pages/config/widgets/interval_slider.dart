import 'package:flutter/material.dart';

class IntervalSlider extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;
  final String label;
  final String unit;
  final String Function(int)? formatValue;

  const IntervalSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
    this.step = 1,
    this.unit = '',
    this.formatValue,
  });

  String _display(int v) =>
      formatValue != null ? formatValue!(v) : '$v${unit.isNotEmpty ? ' $unit' : ''}';

  @override
  Widget build(BuildContext context) {
    final divisions = (max - min) ~/ step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(_display(value), style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: divisions,
          label: _display(value),
          onChanged: (v) => onChanged(((v / step).round() * step).clamp(min, max)),
        ),
      ],
    );
  }
}
