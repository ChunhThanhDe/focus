import 'package:easy_localization/easy_localization.dart';
import '../home/model/widget_settings.dart' as ws;

/// Extensions to provide localized labels for enums
extension WidgetTypeExtension on ws.WidgetType {
  String get label {
    switch (this) {
      case ws.WidgetType.none:
        return 'enums.widgetType.none'.tr();
      case ws.WidgetType.digitalClock:
        return 'enums.widgetType.digitalClock'.tr();
      case ws.WidgetType.analogClock:
        return 'enums.widgetType.analogClock'.tr();
      case ws.WidgetType.text:
        return 'enums.widgetType.text'.tr();
      case ws.WidgetType.timer:
        return 'enums.widgetType.timer'.tr();
      case ws.WidgetType.weather:
        return 'enums.widgetType.weather'.tr();
      case ws.WidgetType.digitalDate:
        return 'enums.widgetType.digitalDate'.tr();
    }
  }

  String get localizedLabel => label;
}

extension BorderTypeExtension on ws.BorderType {
  String get label {
    switch (this) {
      case ws.BorderType.none:
        return 'enums.borderType.none'.tr();
      case ws.BorderType.solid:
        return 'enums.borderType.solid'.tr();
      case ws.BorderType.rounded:
        return 'enums.borderType.rounded'.tr();
    }
  }
}

extension ClockFormatExtension on ws.ClockFormat {
  String get label {
    switch (this) {
      case ws.ClockFormat.twelveHour:
        return 'enums.clockFormat.twelveHour'.tr();
      case ws.ClockFormat.twelveHoursWithAmPm:
        return 'enums.clockFormat.twelveHoursWithAmPm'.tr();
      case ws.ClockFormat.twentyFourHour:
        return 'enums.clockFormat.twentyFourHour'.tr();
    }
  }
}

extension AlignmentCExtension on ws.AlignmentC {
  String get label {
    switch (this) {
      case ws.AlignmentC.topLeft:
        return 'enums.alignment.topLeft'.tr();
      case ws.AlignmentC.topCenter:
        return 'enums.alignment.topCenter'.tr();
      case ws.AlignmentC.topRight:
        return 'enums.alignment.topRight'.tr();
      case ws.AlignmentC.centerLeft:
        return 'enums.alignment.centerLeft'.tr();
      case ws.AlignmentC.center:
        return 'enums.alignment.center'.tr();
      case ws.AlignmentC.centerRight:
        return 'enums.alignment.centerRight'.tr();
      case ws.AlignmentC.bottomLeft:
        return 'enums.alignment.bottomLeft'.tr();
      case ws.AlignmentC.bottomCenter:
        return 'enums.alignment.bottomCenter'.tr();
      case ws.AlignmentC.bottomRight:
        return 'enums.alignment.bottomRight'.tr();
    }
  }
}

extension SeparatorExtension on ws.Separator {
  String get label {
    switch (this) {
      case ws.Separator.nothing:
        return 'enums.separator.nothing'.tr();
      case ws.Separator.dot:
        return 'enums.separator.dot'.tr();
      case ws.Separator.colon:
        return 'enums.separator.colon'.tr();
      case ws.Separator.dash:
        return 'enums.separator.dash'.tr();
      case ws.Separator.space:
        return 'enums.separator.space'.tr();
      case ws.Separator.newLine:
        return 'enums.separator.newLine'.tr();
    }
  }
}

extension DateSeparatorExtension on ws.DateSeparator {
  String get label {
    switch (this) {
      case ws.DateSeparator.dash:
        return 'enums.dateSeparator.dash'.tr();
      case ws.DateSeparator.dot:
        return 'enums.dateSeparator.dot'.tr();
      case ws.DateSeparator.slash:
        return 'enums.dateSeparator.slash'.tr();
    }
  }
}

extension DateFormatExtension on ws.DateFormat {
  String get label {
    switch (this) {
      case ws.DateFormat.dayMonthYear:
        return 'enums.dateFormat.dayMonthYear'.tr();
      case ws.DateFormat.monthDayYear:
        return 'enums.dateFormat.monthDayYear'.tr();
      case ws.DateFormat.yearMonthDay:
        return 'enums.dateFormat.yearMonthDay'.tr();
      case ws.DateFormat.custom:
        return 'enums.dateFormat.custom'.tr();
    }
  }
}

extension WeatherFormatExtension on ws.WeatherFormat {
  String get localizedLabel {
    return label; // WeatherFormat already has localized labels
  }
}

extension TemperatureUnitExtension on ws.TemperatureUnit {
  String get localizedLabel {
    return label; // TemperatureUnit already has localized labels
  }
}

extension TimerFormatExtension on ws.TimerFormat {
  String get localizedLabel {
    return label; // TimerFormat already has localized labels
  }
}