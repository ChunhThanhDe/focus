/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

/// DigitalClock is a widget that displays the current time in a digital (text) format.
///
/// You can customize the text style, decoration, padding, and time format.
/// The widget automatically updates every second to keep the displayed time accurate.
class DigitalClock extends StatefulWidget {
  final TextStyle? style;
  final Decoration? decoration;
  final EdgeInsets? padding;
  final String format;

  const DigitalClock({
    super.key,
    this.style,
    this.decoration,
    this.padding,
    this.format = 'hh:mm',
  });

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late DateTime _initialTime;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _initialTime = _now = DateTime.now();
    _ticker = createTicker((elapsed) {
      final newTime = _initialTime.add(elapsed);
      // rebuild only if seconds changes instead of every frame
      if (_now.second != newTime.second) {
        setState(() => _now = newTime);
      }
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return _DigitalClockRenderer(
      time: _now,
      style: widget.style,
      decoration: widget.decoration,
      padding: widget.padding,
      format: widget.format,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// _DigitalClockRenderer builds the styled digital clock display from the current time.
///
/// It uses [DateFormat] to format the [time] and wraps the result in a decorated box
/// with optional padding and styling.
class _DigitalClockRenderer extends StatelessWidget {
  final DateTime time;
  final TextStyle? style;
  final Decoration? decoration;
  final EdgeInsets? padding;
  final String format;

  const _DigitalClockRenderer({
    required this.time,
    this.style,
    this.decoration,
    this.padding,
    this.format = 'hh:mm',
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat(format).format(time);
    return DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Text(timeString, textAlign: TextAlign.center, style: style),
      ),
    );
  }
}
