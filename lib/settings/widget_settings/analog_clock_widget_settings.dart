import 'package:flutter/material.dart';
import '../../home/ui/alignment_control.dart';
import '../../home/ui/custom_slider.dart';
import '../../home/ui/custom_switch.dart';
import '../../home/widget_store.dart';
import '../../utils/custom_observer.dart';
import 'package:provider/provider.dart';

class AnalogClockWidgetSettingsView extends StatelessWidget {
  const AnalogClockWidgetSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<WidgetStore>().analogueClockSettings;
    return Column(
      children: [
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Radius',
          builder: (context) {
            return CustomSlider(
              min: 10,
              max: 400,
              valueLabel: '${settings.radius.floor()} px',
              value: settings.radius,
              onChanged: (value) => settings.update(() => settings.radius = value),
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Position',
          builder: (context) {
            return AlignmentControl(
              alignment: settings.alignment,
              onChanged: (alignment) => settings.update(() => settings.alignment = alignment),
            );
          },
        ),
        const SizedBox(height: 16),
        CustomObserver(
          name: 'Show seconds',
          builder: (context) {
            return CustomSwitch(
              label: 'Show seconds',
              value: settings.showSecondsHand,
              onChanged: (value) => settings.update(() => settings.showSecondsHand = value),
            );
          },
        ),
        const SizedBox(height: 4),
        CustomObserver(
          name: 'Colored Second Hand',
          builder: (context) {
            return CustomSwitch(
              label: 'Colored Second Hand',
              value: settings.coloredSecondHand,
              onChanged: (value) => settings.update(() => settings.coloredSecondHand = value),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
