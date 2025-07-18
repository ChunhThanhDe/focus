import 'package:flutter/material.dart';
import 'package:unsplash_client/unsplash_client.dart';

import '../home/model/background_settings.dart';
import '../home/model/color_gradient.dart';
import '../home/model/widget_settings.dart';

extension GradientExt on ColorGradient {
  LinearGradient toLinearGradient() {
    return LinearGradient(colors: colors, begin: begin, end: end, stops: stops);
  }
}

extension StringExt on String {
  String capitalize() {
    return characters.first.toUpperCase() + substring(1);
  }
}

extension AlignmentExt on AlignmentC {
  Alignment get flutterAlignment {
    switch (this) {
      case AlignmentC.topLeft:
        return Alignment.topLeft;
      case AlignmentC.topCenter:
        return Alignment.topCenter;
      case AlignmentC.topRight:
        return Alignment.topRight;
      case AlignmentC.centerLeft:
        return Alignment.centerLeft;
      case AlignmentC.center:
        return Alignment.center;
      case AlignmentC.centerRight:
        return Alignment.centerRight;
      case AlignmentC.bottomLeft:
        return Alignment.bottomLeft;
      case AlignmentC.bottomCenter:
        return Alignment.bottomCenter;
      case AlignmentC.bottomRight:
        return Alignment.bottomRight;
    }
  }

  TextAlign get textAlign {
    final alignment = flutterAlignment;
    if (alignment.x == 0) {
      return TextAlign.center;
    } else if (alignment.x < 0) {
      return TextAlign.left;
    } else {
      return TextAlign.right;
    }
  }
}

extension ColorFS on Color {
  /// converts a normal [Color] to material color with proper shades mixed
  /// with base color (white).
  MaterialColor toMaterialColor() {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        red + ((ds < 0 ? red : (255 - red)) * ds).round(),
        green + ((ds < 0 ? green : (255 - green)) * ds).round(),
        blue + ((ds < 0 ? blue : (255 - blue)) * ds).round(),
        1,
      );
    }
    return MaterialColor(value, swatch);
  }
}

extension ImageResolutionExt on ImageResolution {
  Size? toSize() {
    switch (this) {
      case ImageResolution.auto:
      case ImageResolution.original:
        return null;
      case ImageResolution.hd:
        return const Size(1280, 720);
      case ImageResolution.fullHd:
        return const Size(1920, 1080);
      case ImageResolution.quadHD:
        return const Size(2560, 1440);
      case ImageResolution.ultraHD:
        return const Size(3840, 2160);
      case ImageResolution.fiveK:
        return const Size(5120, 2880);
      case ImageResolution.eightK:
        return const Size(7680, 4320);
    }
  }

  String get sizeLabel {
    final size = toSize();
    if (size == null) {
      return 'Window size';
    } else {
      return '${size.width.toInt()} x ${size.height.toInt()}';
    }
  }
}

extension DateTimeExt on DateTime {
  DateTime copyWith({
    int? day,
    int? month,
    int? year,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  DateTime get startOfDay => DateTime(year, month, day);
}

extension TimerFormatExt on TimerFormat {
  bool get showsSeconds => this == TimerFormat.descriptiveWithSeconds || this == TimerFormat.seconds || this == TimerFormat.countdown;
}

extension ImageRefreshRateExt on BackgroundRefreshRate {
  /// Calculates the next refresh time for given refresh rate and
  /// last refresh time.
  /// For daily refresh rate, it will return the next day at 00:00:00.
  /// For weekly refresh rate, it will return the start of the next week
  /// at 00:00:00.
  DateTime? nextUpdateTime(DateTime lastRefresh) {
    switch (this) {
      case BackgroundRefreshRate.never:
      case BackgroundRefreshRate.newTab:
        return null;
      case BackgroundRefreshRate.minute:
      case BackgroundRefreshRate.fiveMinute:
      case BackgroundRefreshRate.fifteenMinute:
      case BackgroundRefreshRate.thirtyMinute:
      case BackgroundRefreshRate.hour:
        return lastRefresh.add(duration);
      case BackgroundRefreshRate.daily:
        // Reset at midnight: 00:00:00
        return lastRefresh.startOfDay.add(duration);
      case BackgroundRefreshRate.weekly:
        final now = DateTime.now();
        // next monday
        final DateTime nextMonday = DateTime(
          now.year,
          now.month,
          now.day + 7 - now.weekday + 1,
        );
        return nextMonday;
    }
  }
}

extension PhotoUrlsExt on PhotoUrls {
  String rawWith({
    Size? size,
    double? devicePixelRatio,
    String fit = 'crop',
    String crop = 'entropy',
  }) =>
      raw
          .replace(
            queryParameters: {
              ...raw.queryParameters,
              'crop': crop,
              'fit': fit,
              if (size != null) ...{
                'w': size.width.toStringAsFixed(0),
                'h': size.height.toStringAsFixed(0),
              },
              if (devicePixelRatio != null) 'dpr': devicePixelRatio.toStringAsFixed(1),
            },
          )
          .toString();
}

extension PhotoExt on Photo {
  String rawWith({
    Size? size,
    double? devicePixelRatio,
    String fit = 'crop',
    String crop = 'entropy',
  }) => urls.rawWith(
    size: size,
    devicePixelRatio: devicePixelRatio,
    fit: fit,
    crop: crop,
  );
}
