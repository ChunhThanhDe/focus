/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: Ã°Å¸Å½Â¯ Happy coding and Have a nice day! Ã°Å¸Å’Â¤Ã¯Â¸Â
 */

import 'package:flutter/material.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:provider/provider.dart';

import 'package:focus/common/widgets/observer/custom_observer.dart';
import 'package:focus/core/utils/extensions.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final settings = context.read<WidgetStore>().messageSettings;

    return CustomObserver(
      name: 'MessageWidget',
      builder: (context) {
        return Align(
          alignment: settings.alignment.flutterAlignment,
          child: Padding(
            padding: const EdgeInsets.all(56),
            child: Text(
              settings.message,
              textAlign: settings.alignment.textAlign,
              style: TextStyle(
                color: backgroundStore.foregroundColor,
                fontSize: settings.fontSize,
                fontFamily: settings.fontFamily,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
