import 'package:flutter/material.dart';
import 'package:focus/home/background_store.dart';
import 'package:focus/home/widget_store.dart';
import 'package:focus/utils/custom_observer.dart';
import 'package:focus/utils/extensions.dart';
import 'package:provider/provider.dart';

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
