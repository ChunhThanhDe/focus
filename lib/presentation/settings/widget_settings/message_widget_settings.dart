/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:focus/common/widgets/layout/alignment_control.dart';
import 'package:focus/common/widgets/button/custom_dropdown.dart';
import 'package:focus/common/widgets/input/custom_slider.dart';
import 'package:focus/common/widgets/input/resizable_text_input.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/core/configs/assets/fonts.dart';
import 'package:focus/common/widgets/observer/custom_observer.dart';

class MessageWidgetSettingsView extends StatelessWidget {
  const MessageWidgetSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<WidgetStore>().messageSettings;
    return Column(
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
                  (value) => settings.update(() => settings.fontSize = value.floorToDouble()),
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
        ResizableTextInput(
          label: 'common.message'.tr(),
          initialHeight: 150,
          initialValue: settings.message,
          onChanged: (message) => settings.update(save: false, () => settings.message = message),
          onSubmitted: (message) => settings.update(() => settings.message = message),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
