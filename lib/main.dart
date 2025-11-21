/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:09:32
* @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:focus/core/configs/theme/app_theme.dart';
import 'package:focus/data/sources/backend/backend_service.dart';
import 'package:focus/data/sources/backend/rest_backend_service.dart';
import 'package:focus/presentation/home/pages/home_page.dart';
import 'package:focus/core/services/geocoding_service.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';
import 'package:focus/core/services/weather_service.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  for (var view in binding.renderViews) {
    view.automaticSystemUiAdjustment = false;
  }
  await EasyLocalization.ensureInitialized();
  await initialize();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

late PackageInfo packageInfo;

Future<void> loadPackageInfo() async => packageInfo = await PackageInfo.fromPlatform();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugRender(
      debugHighlightObserverRebuild: false,
      child: MaterialApp(
        title: 'focus',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(context),
        home: const HomeWrapper(key: ValueKey('HomeWrapper')),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}

Future<void> initialize() async {
  await initializeBackend();

  final storage = await SharedPreferencesStorageManager.create();
  GetIt.instance.registerSingleton<LocalStorageManager>(storage);
  GetIt.instance.registerSingleton<WeatherService>(OpenMeteoWeatherService());
  GetIt.instance.registerSingleton<GeocodingService>(
    OpenMeteoGeocodingService(),
  );

  await GetIt.instance.allReady();
  await loadPackageInfo();
}

Future<void> initializeBackend() async {
  // Initialize
  final BackendService service = await getBackend();

  await service.init(local: useLocalServer);

  GetIt.instance.registerSingleton<BackendService>(service);
}

Future<BackendService> getBackend() async => RestBackendService();

 

class DebugRender extends InheritedWidget {
  final bool debugHighlightObserverRebuild;

  const DebugRender({
    super.key,
    this.debugHighlightObserverRebuild = false,
    required super.child,
  });

  static DebugRender? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DebugRender>();
  }

  @override
  bool updateShouldNotify(covariant DebugRender oldWidget) {
    return debugHighlightObserverRebuild != oldWidget.debugHighlightObserverRebuild;
  }
}
