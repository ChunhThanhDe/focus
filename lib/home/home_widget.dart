import 'package:flutter/material.dart';
import 'package:focus/home/model/widget_settings.dart';
import 'package:focus/home/widget_store.dart';
import 'package:focus/home/widgets/analog_clock_widget.dart';
import 'package:focus/home/widgets/digital_clock_widget.dart';
import 'package:focus/home/widgets/digital_date_widget.dart';
import 'package:focus/home/widgets/message_widget.dart';
import 'package:focus/home/widgets/timer_widget.dart';
import 'package:focus/home/widgets/weather_widget.dart';
import 'package:focus/utils/custom_observer.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<WidgetStore>();
    return CustomObserver(
      name: 'HomeWidget',
      builder: (context) {
        if (!store.initialized) return const SizedBox.shrink();
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
