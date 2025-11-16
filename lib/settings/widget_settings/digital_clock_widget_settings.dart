/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../home/model/widget_settings.dart';
import '../../ui/alignment_control.dart';
import '../../ui/custom_dropdown.dart';
import '../../ui/custom_slider.dart';
import '../../home/widget_store.dart';
import '../../resources/fonts.dart';
import '../../utils/custom_observer.dart';

import '../../utils/enum_extensions.dart';

class DigitalClockWidgetSettingsView extends StatelessWidget {
  const DigitalClockWidgetSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<WidgetStore>().digitalClockSettings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'common.font'.tr(),
          builder: (context) {
            return CustomDropdown<String>(
              isExpanded: true,
              value: settings.fontFamily,
              items: FontFamilies.fonts,
              onSelected: (family) => settings.update(() => settings.fontFamily = family),
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'common.fontSize'.tr(),
          builder: (context) {
            return CustomSlider(
              min: 10,
              max: 400,
              valueLabel: '${settings.fontSize.floor().toString()} px',
              value: settings.fontSize,
              onChanged:
                  (value) => settings.update(
                    () => settings.fontSize = value.floorToDouble(),
                  ),
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
        LabeledObserver(
          label: 'common.border'.tr(),
          builder: (context) {
            return CustomDropdown<BorderType>(
              isExpanded: true,
              value: settings.borderType,
              items: BorderType.values,
              itemBuilder: (context, type) => Text(type.label),
              onSelected: (value) => settings.update(() => settings.borderType = value),
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'common.separator'.tr(),
          builder: (context) {
            return CustomDropdown<Separator>(
              isExpanded: true,
              value: settings.separator,
              items: Separator.values,
              itemBuilder: (context, type) => Text(type.label),
              onSelected: (value) => settings.update(() => settings.separator = value),
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'common.format'.tr(),
          builder: (context) {
            return CustomDropdown<ClockFormat>(
              isExpanded: true,
              value: settings.format,
              items: ClockFormat.values,
              itemBuilder: (context, type) => Text(type.label),
              onSelected: (value) => settings.update(() => settings.format = value),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
