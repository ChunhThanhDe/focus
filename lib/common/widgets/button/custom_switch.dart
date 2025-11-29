/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
* @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:focus/common/widgets/input/gesture_detector_with_cursor.dart';

class CustomSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: GestureDetectorWithCursor(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSwitchWithGrantButton extends StatelessWidget {
  final String label;
  final bool requesting;
  final VoidCallback? onPressed;

  const CustomSwitchWithGrantButton({
    super.key,
    required this.label,
    required this.requesting,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !requesting && onPressed != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: isEnabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEnabled ? Colors.amber.withOpacity(0.8) : Colors.amber.withOpacity(0.3),
                foregroundColor: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
                disabledBackgroundColor: Colors.amber.withOpacity(0.3),
                disabledForegroundColor: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        isEnabled ? Colors.amber.withOpacity(0.9) : Colors.amber.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                elevation: isEnabled ? 2 : 0,
                shadowColor: Colors.amber.withOpacity(0.3),
              ),
              child: Text(
                requesting ? 'permission.button.requesting'.tr() : 'permission.button.grant'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
