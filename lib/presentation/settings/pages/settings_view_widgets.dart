/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
* @ Message: ÃƒÂ°Ã…Â¸Ã…Â½Ã‚Â¯ Happy coding and Have a nice day! ÃƒÂ°Ã…Â¸Ã…â€™Ã‚Â¤ÃƒÂ¯Ã‚Â¸Ã‚Â
 */

import 'package:flutter/material.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/domain/entities/widget_settings.dart';
import 'package:focus/common/widgets/button/custom_dropdown.dart';
import 'package:focus/common/widgets/observer/custom_observer.dart';
import 'package:focus/core/utils/enum_extensions.dart';
import 'package:focus/presentation/settings/widget_settings/analog_clock_widget_settings.dart';
import 'package:focus/presentation/settings/widget_settings/digital_clock_widget_settings.dart';
import 'package:focus/presentation/settings/widget_settings/digital_date_widget_settings.dart';
import 'package:focus/presentation/settings/widget_settings/message_widget_settings.dart';
import 'package:focus/presentation/settings/widget_settings/timer_widget_settings.dart';
import 'package:focus/presentation/settings/widget_settings/weather_widget_settings.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class WidgetSettings extends StatelessWidget {
  const WidgetSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<WidgetStore>();
    return CustomObserver(
      name: 'WidgetSettings',
      builder: (context) {
        if (!store.initialized) return const SizedBox(height: 200);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledObserver(
              label: 'common.widget'.tr(),
              builder: (context) {
                return CustomDropdown<WidgetType>(
                  value: store.type,
                  isExpanded: true,
                  items: WidgetType.values,
                  itemBuilder: (context, item) => Text(item.localizedLabel),
                  onSelected: (type) => store.setType(type),
                );
              },
            ),
            CustomObserver(
              name: '_SettingsWidget',
              builder: (context) {
                switch (store.type) {
                  case WidgetType.none:
                    return const SizedBox(height: 16);
                  case WidgetType.digitalClock:
                    return const DigitalClockWidgetSettingsView();
                  case WidgetType.analogClock:
                    return const AnalogClockWidgetSettingsView();
                  case WidgetType.text:
                    return const MessageWidgetSettingsView();
                  case WidgetType.timer:
                    return const TimerWidgetSettingsView();
                  case WidgetType.weather:
                    return const WeatherWidgetSettingsView();
                  case WidgetType.digitalDate:
                    return const DigitalDateWidgetSettingsView();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
