/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// GestureDetectorWithCursor is a widget that combines gesture detection, mouse cursor customization,
/// and optional tooltip display for its child widget.
///
/// This widget is especially useful for desktop and web apps, where mouse interaction and tooltips enhance user experience.
class GestureDetectorWithCursor extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final String? tooltip;
  final PointerEnterEventListener? onEnter;
  final PointerExitEventListener? onExit;
  final MouseCursor cursor;
  final Duration? tooltipWaitDuration;
  final HitTestBehavior behavior;
  final bool enableHoverEffect;

  const GestureDetectorWithCursor({
    super.key,
    this.onTap,
    required this.child,
    this.tooltip,
    this.onEnter,
    this.onExit,
    this.cursor = SystemMouseCursors.click,
    this.tooltipWaitDuration,
    this.behavior = HitTestBehavior.opaque,
    this.enableHoverEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content =
        enableHoverEffect
            ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: child,
            )
            : GestureDetector(
              onTap: onTap,
              behavior: behavior,
              child: child,
            );

    content = MouseRegion(
      cursor: cursor,
      onEnter: onEnter,
      onExit: onExit,
      child: Focus(
        canRequestFocus: true,
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) => onTap?.call(),
              ),
            },
            child: content,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        waitDuration: tooltipWaitDuration ?? const Duration(milliseconds: 300),
        child: content,
      );
    }

    return content;
  }
}
