import 'package:flutter/material.dart';
import 'package:focus/home/ui/alignment_control.dart';
import 'package:focus/home/ui/custom_dropdown.dart';
import 'package:focus/home/ui/custom_slider.dart';
import 'package:focus/home/ui/resizable_text_input.dart';
import 'package:focus/home/widget_store.dart';
import 'package:focus/resources/fonts.dart';
import 'package:focus/utils/custom_observer.dart';
import 'package:provider/provider.dart';

class MessageWidgetSettingsView extends StatelessWidget {
  const MessageWidgetSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<WidgetStore>().messageSettings;
    return Column(
      children: [
        const SizedBox(height: 16),
        LabeledObserver(
          label: 'Font',
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
          label: 'Font size',
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
          label: 'Position',
          builder: (context) {
            return AlignmentControl(
              alignment: settings.alignment,
              onChanged: (alignment) => settings.update(() => settings.alignment = alignment),
            );
          },
        ),
        const SizedBox(height: 16),
        ResizableTextInput(
          label: 'Message',
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
