import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Very subtle flat-top hexagon honeycomb for auth / welcome backgrounds.
class FaintHexagonalPatternPainter extends CustomPainter {
  const FaintHexagonalPatternPainter({required this.lineColor});

  final Color lineColor;

  /// Circumradius (center → vertex). ~similar density to old 52px square grid.
  static const double _r = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final sqrt3 = math.sqrt(3);
    final dx = sqrt3 * _r;
    final dy = 1.5 * _r;

    var row = 0;
    for (var cy = -dy; cy < size.height + dy * 2; cy += dy) {
      final xShift = row.isOdd ? dx * 0.5 : 0.0;
      for (var cx = -dx + xShift; cx < size.width + dx * 2; cx += dx) {
        _strokeFlatTopHex(canvas, Offset(cx, cy), _r, paint);
      }
      row++;
    }
  }

  static void _strokeFlatTopHex(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final theta = -math.pi / 6 + i * math.pi / 3;
      final x = c.dx + r * math.cos(theta);
      final y = c.dy + r * math.sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FaintHexagonalPatternPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
