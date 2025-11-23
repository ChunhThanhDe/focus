/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: Ã°Å¸Å½Â¯ Happy coding and Have a nice day! Ã°Å¸Å’Â¤Ã¯Â¸Â
 */

// import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:provider/provider.dart';

import 'package:focus/common/widgets/observer/custom_observer.dart';
import 'package:focus/core/utils/extensions.dart';
import 'package:focus/domain/entities/widget_settings.dart';
import 'package:focus/common/widgets/time/digital_date.dart';

class DigitalDateWidget extends StatelessWidget {
  const DigitalDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final settings = context.read<WidgetStore>().digitalDateSettings;

    return CustomObserver(
      name: 'DigitalDateWidget',
      builder: (context) {
        final double borderWidth = (10 + settings.fontSize) * 0.15;
        final double paddingHorizontal = (20 + settings.fontSize) * 0.5;
        final double paddingVertical = (20 + settings.fontSize) * 0.4;
        final double round = (20 + settings.fontSize) * 0.5;
        String format = buildFormatString(
          settings.format,
          settings.separator.value,
        );

        if (settings.format == DateFormat.custom) {
          // Use the custom format if the special format is selected
          format = settings.customFormat;
        }

        return Padding(
          padding: EdgeInsets.all(
            settings.borderType == BorderType.none ? 0 : 48,
          ),
          child: Align(
            alignment: settings.alignment.flutterAlignment,
            child: FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DigitalDate(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                      vertical: paddingVertical,
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: settings.borderType == BorderType.rounded ? BorderRadius.circular(round) : BorderRadius.zero,
                        side:
                            settings.borderType != BorderType.none
                                ? BorderSide(
                                  color: backgroundStore.foregroundColor,
                                  width: borderWidth,
                                )
                                : BorderSide.none,
                      ),
                    ),
                    format: format,
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      letterSpacing: 4,
                      fontFamily: settings.fontFamily,
                      color: backgroundStore.foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String buildFormatString(DateFormat format, String separator) {
    // final random = Random();

    switch (format) {
      case DateFormat.dayMonthYear:
        return 'dd${separator}MM${separator}yyyy';
      case DateFormat.monthDayYear:
        return 'MM${separator}dd${separator}yyyy';
      case DateFormat.yearMonthDay:
        return 'yyyy${separator}MM${separator}dd';
      case DateFormat.custom:
        return 'dd $separator MMMM $separator yyyy';
      // case DateFormat.random:
      //   final components = ['dd', 'MM', 'yyyy']..shuffle(random);
      //   return components.join(separator);
      // ignore: unreachable_switch_default
      default:
        return 'dd${separator}MM${separator}yyyy'; // Default to a format
    }
  }
}
