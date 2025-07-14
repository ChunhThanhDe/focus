import 'package:flutter/widgets.dart';

/// Paints a grid of dots for use as a decorative texture or background.
///
/// - [color]: The color of the dots.
/// - [spacing]: The distance between the centers of two adjacent dots.
/// - [radius]: The radius of each dot.
/// - [offset]: The starting offset for the grid on both axes.
///
/// **Note:** This painter should only be used in a bounded area (finite size).
class TexturePainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double offset;
  final double radius;

  TexturePainter({
    required this.color,
    this.spacing = 30,
    this.offset = 16,
    this.radius = 1,
  }) : assert(spacing > 0 && spacing < double.infinity),
       assert(radius >= 0 && radius <= double.infinity);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate drawable area after applying the offset
    final double drawableWidth = size.width - offset;
    final double drawableHeight = size.height - offset;

    // Ensure the area is valid and finite
    assert(drawableWidth > 0 && drawableWidth < double.infinity);
    assert(drawableHeight > 0 && drawableHeight < double.infinity);

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Number of dots that fit horizontally and vertically
    final int columns = (drawableWidth / spacing).ceil();
    final int rows = (drawableHeight / spacing).ceil();

    // Draw the dots grid
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final double x = (col * spacing) + offset;
        final double y = (row * spacing) + offset;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TexturePainter oldDelegate) {
    return radius != oldDelegate.radius || spacing != oldDelegate.spacing || color != oldDelegate.color || offset != oldDelegate.offset;
  }
}
