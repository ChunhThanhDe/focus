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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: cursor,
        onEnter: onEnter,
        onExit: onExit,
        child:
            tooltip != null
                ? Tooltip(
                  message: tooltip,
                  waitDuration: tooltipWaitDuration,
                  preferBelow: false,
                  child: child,
                )
                : child,
      ),
    );
  }
}
