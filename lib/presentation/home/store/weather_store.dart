import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

import 'package:focus/core/constants/storage_keys.dart';
import 'package:focus/core/services/weather_service.dart';
import 'package:focus/data/models/weather_info.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';
import 'package:focus/core/utils/utils.dart';

part 'weather_store.g.dart';

/// Duration between weather updates.
const Duration weatherUpdateDuration = Duration(minutes: 30);

// ignore: library_private_types_in_public_api
class WeatherStore = _WeatherStore with _$WeatherStore;

abstract class _WeatherStore with Store, LazyInitializationMixin {
  @observable
  WeatherInfo? weatherInfo;

  bool isLoadingWeather = false;
  bool initialized = false;

  final double latitude;
  final double longitude;

  late final LocalStorageManager storage = GetIt.instance.get<LocalStorageManager>();

  late final WeatherService weatherService = GetIt.instance.get<WeatherService>();

  DateTime? weatherLastUpdated;

  _WeatherStore(this.latitude, this.longitude) {
    init();
  }

  @override
  Future<void> init() async {
    weatherInfo = await storage.getSerializableObject<WeatherInfo>(
      StorageKeys.weatherInfo,
      WeatherInfo.fromJson,
    );

    // load image last updated time
    weatherLastUpdated = await storage.getInt(StorageKeys.weatherLastUpdated).then((value) {
      if (value == null) return DateTime.now();
      return DateTime.fromMillisecondsSinceEpoch(value);
    });

    /// Whether the weather info is outdated and needs to be updated.
    final bool isExpired = weatherLastUpdated!.add(weatherUpdateDuration).isBefore(DateTime.now());

    /// Whether the weather info is outdated and needs to be updated. This
    /// would be the case if the user has changed their location from settings
    /// and the weather info is still for the old location.
    final bool locationChanged = weatherInfo != null && (weatherInfo!.latitude != latitude || weatherInfo!.longitude != longitude);

    if (locationChanged) {
      log(
        'cached location: ${weatherInfo?.latitude}, ${weatherInfo?.longitude}',
      );
      log('current location: $latitude, $longitude');
    }

    // re-fetch weather info if expired or location changed or weather info is null.
    if (weatherInfo == null || isExpired || locationChanged) {
      weatherInfo = null;
      log('Immediately fetching weather info');
      refetchWeather();
    }

    initialized = true;
  }

  /// Refreshes the background image on timer callback.
  void onTimerCallback() async {
    final DateTime? weatherLastUpdated = this.weatherLastUpdated;
    if (weatherLastUpdated == null) return;
    // log('Auto weather refresh has been triggered');

    // Exit if it is not time to update weather.
    if (weatherLastUpdated.add(weatherUpdateDuration).isAfter(DateTime.now()) || isLoadingWeather) {
      // Enable this to see the remaining time in console.

      // final remainingTime = weatherLastUpdated
      //     .add(weatherUpdateDuration)
      //     .difference(DateTime.now());
      // log('Next weather update in ${remainingTime.inSeconds} seconds');
      return;
    }

    this.weatherLastUpdated = DateTime.now();

    // Update the background image.
    storage.setInt(
      StorageKeys.weatherLastUpdated,
      this.weatherLastUpdated!.millisecondsSinceEpoch,
    );

    // Log next background change time.
    _logNextWeatherUpdate();

    await refetchWeather();
  }

  @action
  Future<void> refetchWeather() async {
    return fetchWeather().then((value) {
      if (value == null) return;
      weatherInfo = value;

      // save weather info
      storage.setJson(StorageKeys.weatherInfo, value.toJson());

      // save last updated time
      weatherLastUpdated = DateTime.now();
      storage.setInt(
        StorageKeys.weatherLastUpdated,
        weatherLastUpdated!.millisecondsSinceEpoch,
      );
    });
  }

  /// Logs the next background change time.
  void _logNextWeatherUpdate() {
    final DateTime? weatherLastUpdated = this.weatherLastUpdated;
    if (weatherLastUpdated == null) return;

    final nextUpdateTime = weatherLastUpdated.add(weatherUpdateDuration);

    // ignore: avoid_print
    log('Next weather update at $nextUpdateTime');
  }

  Future<WeatherInfo?> fetchWeather() async {
    isLoadingWeather = true;
    try {
      log('Updating weather for location $latitude, $longitude');
      final info = await weatherService.fetchWeather(latitude, longitude);
      isLoadingWeather = false;
      return info;
    } catch (error, stacktrace) {
      log(error.toString());
      log(stacktrace.toString());
      isLoadingWeather = false;
      return null;
    }
  }
}
