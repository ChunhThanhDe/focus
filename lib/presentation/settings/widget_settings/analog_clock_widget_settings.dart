/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: ÃƒÂ°Ã…Â¸Ã…Â½Ã‚Â¯ Happy coding and Have a nice day! ÃƒÂ°Ã…Â¸Ã…â€™Ã‚Â¤ÃƒÂ¯Ã‚Â¸Ã‚Â
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:focus/common/widgets/layout/alignment_control.dart';
import 'package:focus/common/widgets/input/custom_slider.dart';
import 'package:focus/common/widgets/button/custom_switch.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/common/widgets/observer/custom_observer.dart';

class AnalogClockWidgetSettingsView extends StatelessWidget {
  const AnalogClockWidgetSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<WidgetStore>().analogueClockSettings;
    return Column(
      children: [
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'settings.widget.radius'.tr(),
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
          label: 'common.position'.tr(),
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
              label: 'settings.widget.showSeconds'.tr(),
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
              label: 'settings.widget.coloredSecondHand'.tr(),
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
