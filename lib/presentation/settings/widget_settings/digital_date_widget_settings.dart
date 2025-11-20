/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide DateFormat;

import 'package:focus/domain/entities/widget_settings.dart';
import 'package:focus/common/widgets/alignment_control.dart';
import 'package:focus/common/widgets/custom_dropdown.dart';
import 'package:focus/common/widgets/custom_slider.dart';
import 'package:focus/common/widgets/text_input.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/core/configs/assets/fonts.dart';
import 'package:focus/core/utils/custom_observer.dart';
import 'package:focus/core/utils/enum_extensions.dart';

class DigitalDateWidgetSettingsView extends StatefulWidget {
  const DigitalDateWidgetSettingsView({super.key});

  @override
  State<DigitalDateWidgetSettingsView> createState() => _DigitalDateWidgetSettingsViewState();
}

class _DigitalDateWidgetSettingsViewState extends State<DigitalDateWidgetSettingsView> {
  @override
  Widget build(BuildContext context) {
    final settings = context.read<WidgetStore>().digitalDateSettings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Font',
          builder: (context) {
            return CustomDropdown<String>(
              isExpanded: true,
              value: settings.fontFamily,
              items: FontFamilies.fonts,
              onSelected: (family) {
                settings.update(() => settings.fontFamily = family);
                //clockSettings.update(() => clockSettings.fontFamily = family);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Font size',
          builder: (context) {
            return CustomSlider(
              min: 10,
              max: 400,
              valueLabel: '${settings.fontSize.floor().toString()} px',
              value: settings.fontSize,
              onChanged: (value) {
                settings.update(
                  () => settings.fontSize = value.floorToDouble(),
                );
                // clockSettings.update(
                //   () => clockSettings.fontSize = value.floorToDouble(),
                // );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Position',
          builder: (context) {
            return AlignmentControl(
              alignment: settings.alignment,
              onChanged: (alignment) {
                settings.update(() => settings.alignment = alignment);
                //clockSettings.update(() => clockSettings.alignment = alignment);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Border',
          builder: (context) {
            return CustomDropdown<BorderType>(
              isExpanded: true,
              value: settings.borderType,
              items: BorderType.values,
              itemBuilder: (context, type) => Text(type.label),
              onSelected: (value) {
                settings.update(() {
                  settings.borderType = value;
                  //clockSettings.borderType = value;
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Separator',
          builder: (context) {
            return CustomDropdown<DateSeparator>(
              isExpanded: true,
              value: settings.separator,
              items: DateSeparator.values,
              itemBuilder: (context, type) => Text(type.label),
              onSelected: (value) {
                settings.update(() => settings.separator = value);
                setState(() {});
              },
            );
          },
        ),
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Date Format',
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown<DateFormat>(
                  isExpanded: true,
                  value: settings.format,
                  items: DateFormat.values,
                  itemBuilder: (context, type) => Text(type.label),
                  onSelected: (value) => settings.update(() => settings.format = value),
                ),
                if (settings.format == DateFormat.custom) ...[
                  const SizedBox(height: 16),
                  Text('common.template'.tr()),
                  const SizedBox(height: 10),
                  TextInput(
                    initialValue: settings.customFormat,
                    onChanged:
                        (value) => settings.update(
                          save: true,
                          () => setState(() {
                            settings.customFormat = value;
                          }),
                        ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
