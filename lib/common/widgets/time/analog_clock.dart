/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// AnalogClock is a widget that displays a real-time analog clock.
///
/// - [radius]: The radius of the clock face.
/// - [color]: Optional base color for the clock.
/// - [showSecondsHand]: Whether to display the seconds hand.
/// - [secondHandColor]: Optional color for the seconds hand.
///
/// This widget uses a Ticker to update the time and triggers repaints only when the minute or (optionally) second changes.
class AnalogClock extends StatefulWidget {
  final double radius;
  final Color? color;
  final bool showSecondsHand;
  final Color? secondHandColor;

  const AnalogClock({
    super.key,
    required this.radius,
    this.color,
    this.showSecondsHand = true,
    this.secondHandColor,
  });

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

/// State for [AnalogClock] which handles time updates via a Ticker.
class _AnalogClockState extends State<AnalogClock> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _ticker = createTicker((elapsed) {
      final newTime = DateTime.now();
      if (_now.second != newTime.second && widget.showSecondsHand) {
        setState(() => _now = newTime);
      } else if (_now.minute != newTime.minute) {
        setState(() => _now = newTime);
      }
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.radius * 2,
      child: CustomPaint(
        painter: AnalogClockPainter(
          time: _now,
          color: widget.color,
          secondHandColor: widget.secondHandColor,
          showSecondHand: widget.showSecondsHand,
          radius: widget.radius,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// If [color] is provided then it will be used to paint everything.
///
/// [AnalogClockPainter] draws the analog clock on a canvas.
///
/// It draws the dial, the hour hand, minute hand, and (optionally) the seconds hand.
/// The hands are calculated based on the provided [time]
class AnalogClockPainter extends CustomPainter {
  final DateTime time;
  final Color? dialColor;
  final Color? hourHandColor;
  final Color? minuteHandColor;
  final Color? secondHandColor;
  final bool showSecondHand;
  final Color? color;
  final double secondHandThickness;
  final double minuteHandThickness;
  final double hourHandThickness;
  final double dialThickness;
  final double radius;

  static const double angleAtNoon = -pi / 2; // in radians.
  static const double angleOfASecond = 2 * pi / 60; // in radians.
  static const double angleOfAMinute = 2 * pi / 60; // in radians.
  static const double angleOfAnHour = 2 * pi / 12; // in radians.

  AnalogClockPainter({
    required this.time,
    required this.radius,
    this.color,
    this.dialColor,
    this.hourHandColor,
    this.minuteHandColor,
    this.secondHandColor,
    this.showSecondHand = true,
    this.secondHandThickness = 2,
    this.minuteHandThickness = 4,
    this.hourHandThickness = 6,
    this.dialThickness = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - dynamicStroke(dialThickness, 0.5),
    );

    _drawDial(canvas, rect, center);
    _drawHourHand(canvas, rect, center);
    _drawMinuteHand(canvas, rect, center);
    if (showSecondHand) _drawSecondHand(canvas, rect, center);

    _drawCenterDot(canvas, center);
    _drawOuterDots(canvas, center, rect);
  }

  double dynamicStroke(double base, double factor) => base + factor * (radius / 100);

  void _drawDial(Canvas canvas, Rect rect, Offset center) {
    final dialRadius = rect.center.dx + dynamicStroke(dialThickness, 0.5) / 2;

    final double offset = dynamicStroke(2, 0.5);

    // Highlight border on the top-left
    final Paint topLightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = dynamicStroke(dialThickness, 0.5)
          ..isAntiAlias = true;

    // Shadow border on the bottom-right
    final Paint bottomShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = dynamicStroke(dialThickness, 0.5)
          ..isAntiAlias = true;

    // Draw shadow border shifted down-right
    canvas.save();
    canvas.translate(offset, offset);
    canvas.drawCircle(center, dialRadius, bottomShadowPaint);
    canvas.restore();

    // Draw highlight border shifted up-left
    canvas.save();
    canvas.translate(-offset, -offset);
    canvas.drawCircle(center, dialRadius, topLightPaint);
    canvas.restore();

    // Draw main middle border (keep base color)
    final Paint dialPaint =
        Paint()
          ..color = dialColor ?? color ?? Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = dynamicStroke(dialThickness, 0.5)
          ..isAntiAlias = true;

    canvas.drawCircle(center, dialRadius, dialPaint);
  }

  void _drawSecondHand(Canvas canvas, Rect rect, Offset center) {
    final double padding = dynamicStroke(8, 2.0);
    final double handLength = (rect.width / 2 * 0.9) - padding;

    final double angle = angleAtNoon + angleOfASecond * (time.second + 1);

    final Paint paint =
        Paint()
          ..color = secondHandColor ?? color?.withOpacity(0.4) ?? Colors.red
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = dynamicStroke(secondHandThickness, 0.5)
          ..isAntiAlias = true;

    final double x = center.dx + (handLength * cos(angle));
    final double y = center.dy + (handLength * sin(angle));

    canvas.drawLine(center, Offset(x, y), paint);
  }

  void _drawMinuteHand(Canvas canvas, Rect rect, Offset center) {
    final sizePercent = showSecondHand ? 0.8 : 0.85;
    final double padding = dynamicStroke(8, 2.0);
    final double handLength = (rect.width / 2 * sizePercent) - padding;

    final double angle = angleAtNoon + angleOfAMinute * time.minute;

    final Paint paint =
        Paint()
          ..color = minuteHandColor ?? color?.withOpacity(0.6) ?? Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = dynamicStroke(minuteHandThickness, 1.2)
          ..isAntiAlias = true;

    final double x = center.dx + (handLength * cos(angle));
    final double y = center.dy + (handLength * sin(angle));

    canvas.drawLine(center, Offset(x, y), paint);
  }

  void _drawHourHand(Canvas canvas, Rect rect, Offset center) {
    final sizePercent = showSecondHand ? 0.6 : 0.65;
    final double padding = dynamicStroke(8, 2.0);
    final double handLength = (rect.width / 2 * sizePercent) - padding;

    final double angle = angleAtNoon + angleOfAnHour * time.hour + angleOfAMinute * (time.minute / 60);

    final Paint paint =
        Paint()
          ..color = hourHandColor ?? color ?? Colors.black
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = dynamicStroke(hourHandThickness, 1.5)
          ..isAntiAlias = true;

    final double x = center.dx + (handLength * cos(angle));
    final double y = center.dy + (handLength * sin(angle));

    canvas.drawLine(center, Offset(x, y), paint);
  }

  void _drawCenterDot(Canvas canvas, Offset center) {
    final double dotSize = dynamicStroke(10, 1.0); // Larger and proportional to radius

    final Paint dotPaint =
        Paint()
          ..color = color ?? Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotSize / 2, dotPaint);
  }

  void _drawOuterDots(Canvas canvas, Offset center, Rect rect) {
    final double baseDotRadius = dynamicStroke(2, 0.3);
    final double bigDotRadius = dynamicStroke(4, 0.6);

    final double outerRadius = rect.width / 2 * 0.95;

    final Paint dotPaint =
        Paint()
          ..color = color ?? Colors.white
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final double angle = (2 * pi / 12) * i - pi / 2;
      final Offset dotCenter = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      final bool isMainDot = i % 3 == 0; // 12h, 3h, 6h, 9h
      final double currentDotRadius = isMainDot ? bigDotRadius : baseDotRadius;

      canvas.drawCircle(dotCenter, currentDotRadius / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.color != color ||
      oldDelegate.dialColor != dialColor ||
      oldDelegate.hourHandColor != hourHandColor ||
      oldDelegate.minuteHandColor != minuteHandColor ||
      oldDelegate.secondHandColor != secondHandColor ||
      oldDelegate.showSecondHand != showSecondHand ||
      oldDelegate.secondHandThickness != secondHandThickness ||
      oldDelegate.minuteHandThickness != minuteHandThickness ||
      oldDelegate.hourHandThickness != hourHandThickness ||
      oldDelegate.dialThickness != dialThickness ||
      oldDelegate.radius != radius;
}
