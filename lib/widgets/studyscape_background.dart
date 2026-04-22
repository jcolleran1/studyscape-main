import 'package:flutter/material.dart';

import 'faint_hexagonal_pattern_painter.dart';

/// Blue gradient (used by default and by flows like study vibe / preferences).
const Color kStudyscapeBgStart = Color(0xFF14234B);
const Color kStudyscapeBgMid = Color(0xFF3A6DAF);
const Color kStudyscapeBgEnd = Color(0xFF94BAC4);
const Color kStudyscapePatternColor = Color(0x10FFFFFF);

/// Login / create account background.
const String kAuthBackgroundAsset = 'assets/images/auth_blue_background.png';

enum StudyscapeBackgroundPalette { blue, auth }

/// Full-screen [kAuthBackgroundAsset] ([BoxFit.cover] fills the screen so mesh colors show).
class AuthBackgroundImage extends StatelessWidget {
  const AuthBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        kAuthBackgroundAsset,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return ColoredBox(color: Theme.of(context).colorScheme.surface);
        },
      ),
    );
  }
}

/// Mesh background: rose, peach, apricot, periwinkle — softened with cream haze + edges.
class WelcomeBackgroundImage extends StatelessWidget {
  const WelcomeBackgroundImage({super.key});

  /// Base / edge — soft peach cream.
  static const Color _cream = Color(0xFFF3E9E0);

  /// Lighter cream overlay — cools chroma without going grey.
  static const Color _creamAir = Color(0xFFFCF8F4);

  /// Large warm wash upper center.
  static const Color _roseMist = Color(0xFFE0B5A5);

  /// Blue upper wash.
  static const Color _periwinkle = Color(0xFF94A8E8);

  /// Orange-peach accent left of center.
  static const Color _peach = Color(0xFFFF8348);

  /// Apricot lower half.
  static const Color _apricot = Color(0xFFFFB892);

  /// Mid blend — warm shell.
  static const Color _shell = Color(0xFFFFD9C8);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _cream),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.58),
                  radius: 1.35,
                  colors: [
                    _roseMist.withValues(alpha: 0.68),
                    _roseMist.withValues(alpha: 0.28),
                    _roseMist.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.08, -0.48),
                  radius: 1.3,
                  colors: [
                    _periwinkle.withValues(alpha: 0.57),
                    _periwinkle.withValues(alpha: 0.27),
                    _periwinkle.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.62, -0.08),
                  radius: 0.92,
                  colors: [
                    _peach.withValues(alpha: 0.74),
                    _peach.withValues(alpha: 0.3),
                    _peach.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.38, 0.82),
                  radius: 1.22,
                  colors: [
                    _apricot.withValues(alpha: 0.78),
                    _apricot.withValues(alpha: 0.36),
                    _apricot.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.15, 0.18),
                  radius: 1.08,
                  colors: [
                    _shell.withValues(alpha: 0.46),
                    _shell.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Broad cream haze — balances blue / orange so the mesh feels softer.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.02, 0.06),
                  radius: 1.5,
                  colors: [
                    _creamAir.withValues(alpha: 0.38),
                    _creamAir.withValues(alpha: 0.16),
                    _creamAir.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),
          // Light cream into edges (subtle vignette).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, 0.35),
                  colors: [
                    _cream.withValues(alpha: 0.38),
                    _cream.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: const Alignment(0, 0.55),
                  colors: [
                    _cream.withValues(alpha: 0.4),
                    _cream.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue: diagonal gradient + hex pattern. Auth: [AuthBackgroundImage].
class StudyscapeBackground extends StatelessWidget {
  const StudyscapeBackground({
    super.key,
    this.gradientBegin,
    this.gradientEnd,
    this.palette = StudyscapeBackgroundPalette.blue,
  });

  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final StudyscapeBackgroundPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
        final isAuth = palette == StudyscapeBackgroundPalette.auth;

        if (isAuth) {
          return SizedBox(
            width: w > 0 ? w : null,
            height: h > 0 ? h : null,
            child: const AuthBackgroundImage(),
          );
        }

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
                  painter: FaintHexagonalPatternPainter(
                    lineColor: kStudyscapePatternColor,
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
