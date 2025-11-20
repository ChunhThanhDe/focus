/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/presentation/home/widgets/todo/todo_widget.dart';
import 'package:provider/provider.dart';
import 'package:focus/core/utils/custom_observer.dart';
import 'package:focus/domain/entities/widget_settings.dart';
import 'package:focus/presentation/home/widgets/analog_clock_widget.dart';
import 'package:focus/presentation/home/widgets/digital_clock_widget.dart';
import 'package:focus/presentation/home/widgets/digital_date_widget.dart';
import 'package:focus/presentation/home/widgets/message_widget.dart';
import 'package:focus/presentation/home/widgets/timer_widget.dart';
import 'package:focus/presentation/home/widgets/weather_widget.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<WidgetStore>();
    final background = context.read<BackgroundStore>();
    return CustomObserver(
      name: 'HomeWidget',
      builder: (context) {
        if (!store.initialized) return const SizedBox.shrink();
        if (background.isTodoMode) return const TodoWidget();
        switch (store.type) {
          case WidgetType.none:
            return const SizedBox.shrink();
          case WidgetType.digitalClock:
            return const DigitalClockWidget();
          case WidgetType.analogClock:
            return const AnalogClockWidget();
          case WidgetType.text:
            return const MessageWidget();
          case WidgetType.timer:
            return const TimerWidget();
          case WidgetType.weather:
            final latitude = store.weatherSettings.location.latitude;
            final longitude = store.weatherSettings.location.longitude;
            return WeatherWidgetWrapper(
              key: ValueKey('$latitude, $longitude'),
              latitude: latitude,
              longitude: longitude,
            );
          case WidgetType.digitalDate:
            return const DigitalDateWidget();
        }
        // Fallback in case a new WidgetType is added in the future
      },
    );
  }
}
