import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';

import 'backend/backend_service.dart';
import 'backend/rest_backend_service.dart';
import 'home/home.dart';
import 'utils/geocoding_service.dart';
import 'utils/storage_manager.dart';
import 'utils/weather_service.dart';

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
        title: 'main.title'.tr(),
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
  // Initialize Celest
  final BackendService service = await getBackend();

  await service.init(local: useLocalServer);

  GetIt.instance.registerSingleton<BackendService>(service);
}

Future<BackendService> getBackend() async => RestBackendService();

ThemeData buildTheme(BuildContext context) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.redAccent, // Màu vàng từ logo
      brightness: Brightness.dark,
      primary: Colors.amber, // Hồng tâm nổi bật
      secondary: Colors.cyanAccent, // Mũi tên năng động
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    dividerColor: Colors.white.withOpacity(0.1),
    hoverColor: Colors.amber.withOpacity(0.05), // Hiệu ứng hover nhẹ
    focusColor: Colors.amber.withOpacity(0.1), // Hiệu ứng focus
    splashFactory: InkRipple.splashFactory,
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(4),
      thumbVisibility: WidgetStateProperty.all(true),
      thumbColor: WidgetStateProperty.all(Colors.white24),
      radius: const Radius.circular(8),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      verticalOffset: 18,
      textStyle: const TextStyle(fontSize: 12, color: Colors.white70),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Colors.grey.shade900,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
      displayMedium: TextStyle(color: Colors.white.withOpacity(0.9)),
      displaySmall: TextStyle(color: Colors.white.withOpacity(0.9)),
      headlineMedium: TextStyle(color: Colors.white.withOpacity(0.85)),
      headlineSmall: TextStyle(color: Colors.white.withOpacity(0.85)),
      titleLarge: TextStyle(color: Colors.white.withOpacity(0.85)),
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white60),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
    ),
  );
}

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
