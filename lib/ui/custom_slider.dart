import 'package:flutter/material.dart';

/// CustomSlider is a customizable slider widget.
///
/// This widget displays a labeled slider with an optional value label next to it.
/// The minimum and maximum values, as well as the slider's current value, can be set via parameters.
/// The appearance of the slider can be customized, and its value changes are reported via the [onChanged] callback.
class CustomSlider extends StatelessWidget {
  final ValueChanged<double> onChanged;
  final double value;
  final double? min;
  final double? max;
  final String? label;
  final String? valueLabel;

  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.label,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    trackHeight: 6,
                    activeTrackColor: theme.colorScheme.primary.withOpacity(0.9),
                    inactiveTrackColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: value,
                    min: min ?? 0,
                    max: max ?? 100,
                    onChanged: onChanged,
                  ),
                ),
              ),
              if (valueLabel != null) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    valueLabel!,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
