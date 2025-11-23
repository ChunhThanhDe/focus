/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:provider/provider.dart';

import 'package:focus/common/widgets/observer/custom_observer.dart';
import 'package:focus/core/utils/extensions.dart';
import 'package:focus/data/models/weather_info.dart';
import 'package:focus/domain/entities/widget_settings.dart';
import 'package:focus/presentation/home/store/weather_store.dart';

class WeatherWidgetWrapper extends StatelessWidget {
  final double latitude;
  final double longitude;

  const WeatherWidgetWrapper({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Provider<WeatherStore>(
      create: (context) => WeatherStore(latitude, longitude),
      child: const WeatherWidget(),
    );
  }
}

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> with SingleTickerProviderStateMixin {
  Timer? _timer;

  late final WeatherStore store = context.read<WeatherStore>();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => store.onTimerCallback());
  }

  @override
  Widget build(BuildContext context) {
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final settings = context.read<WidgetStore>().weatherSettings;

    return CustomObserver(
      name: 'WeatherWidget',
      builder: (context) {
        return Align(
          alignment: settings.alignment.flutterAlignment,
          child: Padding(
            padding: const EdgeInsets.all(56),
            child: FittedBox(
              child: Text(
                buildText(store.weatherInfo, settings),
                textAlign: settings.alignment.textAlign,
                style: TextStyle(
                  color: backgroundStore.foregroundColor,
                  fontSize: settings.fontSize,
                  fontFamily: settings.fontFamily,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String buildText(WeatherInfo? weatherInfo, WeatherWidgetSettingsStore settings) {
    if (weatherInfo == null) return '_ _';
    final String temperature;
    if (settings.temperatureUnit == TemperatureUnit.celsius) {
      temperature = '${weatherInfo.temperature.round()}°';
    } else {
      temperature = '${(weatherInfo.temperature * 9 / 5 + 32).round()}°F';
    }
    switch (settings.format) {
      case WeatherFormat.temperature:
        return temperature;
      case WeatherFormat.temperatureAndSummary:
        return '$temperature ${weatherInfo.weatherCode.label}';
      // ignore: unreachable_switch_default
      default:
        return temperature;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
