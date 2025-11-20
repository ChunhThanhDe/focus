/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:provider/provider.dart';

import 'package:focus/core/utils/custom_observer.dart';
import 'package:focus/core/utils/extensions.dart';
import 'package:focus/common/widgets/analog_clock.dart';

class AnalogClockWidget extends StatelessWidget {
  const AnalogClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final settings = context.read<WidgetStore>().analogueClockSettings;

    return CustomObserver(
      name: 'Analog Clock',
      builder: (context) {
        return Align(
          alignment: settings.alignment.flutterAlignment,
          child: Padding(
            padding: const EdgeInsets.all(56),
            child: FittedBox(
              child: AnalogClock(
                showSecondsHand: settings.showSecondsHand,
                secondHandColor: settings.coloredSecondHand ? Colors.red : null,
                radius: settings.radius,
                color: backgroundStore.foregroundColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
