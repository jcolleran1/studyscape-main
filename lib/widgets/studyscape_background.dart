import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gradient colors
const Color kStudyscapeBgStart = Color(0xFF14234B);
const Color kStudyscapeBgMid = Color(0xFF3A6DAF);
const Color kStudyscapeBgEnd = Color(0xFF94BAC4);
const Color kStudyscapePatternColor = Color(0x2AFFFFFF);

/// Full-screen background with diagonal gradient and geometric pattern.
class StudyscapeBackground extends StatelessWidget {
  const StudyscapeBackground({
    super.key,
    this.gradientBegin,
    this.gradientEnd,
  });

  final Alignment? gradientBegin;
  final Alignment? gradientEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
        return SizedBox(
          width: w > 0 ? w : null,
          height: h > 0 ? h : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: gradientBegin ?? Alignment.topLeft,
                      end: gradientEnd ?? Alignment.bottomRight,
                      colors: const [
                        kStudyscapeBgStart,
                        kStudyscapeBgMid,
                        kStudyscapeBgEnd,
                      ],
                      stops: const [0.05, 0.51, 0.93],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  size: Size(w, h),
                  painter: _GeometricPatternPainter(
                    color: kStudyscapePatternColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  _GeometricPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95;

    final random = _SeededRandom(42);

    final shapes = <void Function(Canvas, double, double)>[
      // Circle
      (c, x, y) =>
          c.drawCircle(Offset(x, y), 2.5 + random.next() * 5, strokePaint),

      // Rounded square
      (c, x, y) {
        final r = 4 + random.next() * 5;
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: r * 2,
          height: r * 2,
        );
        c.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(r * 0.6)),
          strokePaint,
        );
      },

      // Triangle
      (c, x, y) {
        final r = 3 + random.next() * 4;
        final path = Path()
          ..moveTo(x, y - r)
          ..lineTo(x + r, y + r)
          ..lineTo(x - r, y + r)
          ..close();
        c.drawPath(path, strokePaint);
      },

      // Pentagon
      (c, x, y) {
        final r = 2.5 + random.next() * 3.5;
        final path = Path();
        for (var i = 0; i < 5; i++) {
          final angle = (i * 72 - 90) * math.pi / 180;
          final px = x + r * math.cos(angle);
          final py = y + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        c.drawPath(path, strokePaint);
      },
    ];

    for (var i = 0; i < 120; i++) {
      final x = random.next() * size.width;
      final y = random.next() * size.height;
      shapes[random.nextInt(shapes.length)](canvas, x, y);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeededRandom {
  _SeededRandom(this._seed);

  double _seed;

  double next() {
    _seed = (_seed * 1103515245 + 12345) % 0x100000000;
    return _seed / 0x100000000;
  }

  int nextInt(int max) => (next() * max).floor();
}
