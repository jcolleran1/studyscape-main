import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

/// StudyScape welcome/onboarding screen with geometric pattern background,
/// translucent card, and Create Account / Login actions.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _bgDarkest = Color(0xFF14234B);
  static const Color _bgMid = Color(0xFF3A6DAF);
  static const Color _bgLightest = Color(0xFF94BAC4);
  static const Color _welcomeOrange = Color(0xFFE57D37);
  static const Color _buttonStart = Color(0xFFEFB880);
  static const Color _buttonEnd = Color(0xFFEAA870);
  static const Color _patternColor = Color(0x28FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDarkest,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient: topLeft → bottomRight, 5% / 51% / 100%
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_bgDarkest, _bgMid, _bgLightest],
                  stops: [0.05, 0.51, 1.0],
                ),
              ),
            ),
          ),
          // Outlined geometric pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(color: _patternColor),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                // App title
                Text(
                  'StudyScape',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Card at bottom with padding
                Padding(
                  padding: EdgeInsets.fromLTRB(28, 0, 28, 28 + MediaQuery.of(context).padding.bottom),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: GoogleFonts.poppins(
                                color: _welcomeOrange,
                                fontSize: 53,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.12),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to join the world of active learners.',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 56),
                            _WelcomeButton(
                              label: 'Create Account',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateAccountScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            _WelcomeButton(
                              label: 'Login',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped golden-tan gradient button.
class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              WelcomeScreen._buttonStart,
              WelcomeScreen._buttonEnd,
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(26),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a subtle outlined geometric pattern (circles, rounded squares, rounded triangles, rounded hexagons, rounded rectangles).
class _GeometricPatternPainter extends CustomPainter {
  _GeometricPatternPainter({required this.color});

  final Color color;

  static const double _sqrt3 = 1.7320508075688772;

  static Offset _along(Offset a, Offset b, double t) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len <= 0) return a;
    return Offset(a.dx + dx * t / len, a.dy + dy * t / len);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final random = _SeededRandom(9173);
    final shapes = <void Function(Canvas, double, double)>[
      (c, x, y) {
        c.drawCircle(Offset(x, y), 3 + random.next() * 6, strokePaint);
      },
      (c, x, y) {
        final r = 5 + random.next() * 8;
        final rect = Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r * 2);
        c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.6)), strokePaint);
      },
      (c, x, y) {
        final r = 4 + random.next() * 6;
        final cr = (r * 0.5).clamp(1.0, r * 0.4);
        final v0 = Offset(x, y - r);
        final v1 = Offset(x + r, y + r);
        final v2 = Offset(x - r, y + r);
        final p0a = _along(v0, v1, cr);
        final p0b = _along(v0, v2, cr);
        final p1a = _along(v1, v2, cr);
        final p1b = _along(v1, v0, cr);
        final p2a = _along(v2, v0, cr);
        final p2b = _along(v2, v1, cr);
        final path = Path()
          ..moveTo(p0a.dx, p0a.dy)
          ..lineTo(p1b.dx, p1b.dy)
          ..arcToPoint(p1a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p2b.dx, p2b.dy)
          ..arcToPoint(p2a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p0b.dx, p0b.dy)
          ..arcToPoint(p0a, radius: Radius.circular(cr), clockwise: false);
        c.drawPath(path, strokePaint);
      },
      (c, x, y) {
        // Rounded rectangle (wider or taller than square)
        final w = 5 + random.next() * 10;
        final h = 3 + random.next() * 6;
        final rect = Rect.fromCenter(center: Offset(x, y), width: w * 2, height: h * 2);
        final cr = math.min(w, h) * 0.5;
        c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cr)), strokePaint);
      },
      (c, x, y) {
        // Rounded hexagon (flat-top, radius r)
        final r = 3 + random.next() * 5;
        final cr = (r * 0.4).clamp(0.8, r * 0.35);
        final v0 = Offset(x + r, y);
        final v1 = Offset(x + r * 0.5, y + r * _sqrt3 * 0.5);
        final v2 = Offset(x - r * 0.5, y + r * _sqrt3 * 0.5);
        final v3 = Offset(x - r, y);
        final v4 = Offset(x - r * 0.5, y - r * _sqrt3 * 0.5);
        final v5 = Offset(x + r * 0.5, y - r * _sqrt3 * 0.5);
        final p0a = _along(v0, v1, cr);
        final p0b = _along(v0, v5, cr);
        final p1a = _along(v1, v2, cr);
        final p1b = _along(v1, v0, cr);
        final p2a = _along(v2, v3, cr);
        final p2b = _along(v2, v1, cr);
        final p3a = _along(v3, v4, cr);
        final p3b = _along(v3, v2, cr);
        final p4a = _along(v4, v5, cr);
        final p4b = _along(v4, v3, cr);
        final p5a = _along(v5, v0, cr);
        final p5b = _along(v5, v4, cr);
        final path = Path()
          ..moveTo(p0a.dx, p0a.dy)
          ..lineTo(p1b.dx, p1b.dy)
          ..arcToPoint(p1a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p2b.dx, p2b.dy)
          ..arcToPoint(p2a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p3b.dx, p3b.dy)
          ..arcToPoint(p3a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p4b.dx, p4b.dy)
          ..arcToPoint(p4a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p5b.dx, p5b.dy)
          ..arcToPoint(p5a, radius: Radius.circular(cr), clockwise: false)
          ..lineTo(p0b.dx, p0b.dy)
          ..arcToPoint(p0a, radius: Radius.circular(cr), clockwise: false);
        c.drawPath(path, strokePaint);
      },
    ];

    final count = 85 + (random.next() * 35).round();
    for (var i = 0; i < count; i++) {
      final x = random.next() * size.width;
      final y = random.next() * size.height;
      shapes[random.nextInt(shapes.length)](canvas, x, y);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple seeded random for deterministic pattern.
class _SeededRandom {
  _SeededRandom(this._seed);

  double _seed;

  double next() {
    _seed = (_seed * 1103515245 + 12345) % 0x100000000;
    return _seed / 0x100000000;
  }

  int nextInt(int max) => (next() * max).floor();
}
