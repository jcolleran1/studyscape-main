import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'studyscape_colors.dart';

/// Matches [WelcomeScreen] scaffold fill — center stop for the diagonal gradient.
const Color kAuthLightScaffoldBg = Color(0xFFF5F7FB);

/// Same blue / peach atmospheric wash as the welcome screen.
class AuthLightHueBackground extends StatelessWidget {
  const AuthLightHueBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDDE8FA),
                kAuthLightScaffoldBg,
                Color(0xFFFFEDE5),
              ],
              stops: [0.0, 0.48, 1.0],
            ),
          ),
        ),
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.65, -0.75),
                      radius: 1.02,
                      colors: [
                        const Color(0xFF4F83EB).withValues(alpha: 0.42),
                        const Color(0xFF93C5FD).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.38, 1.0],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(1.05, -0.25),
                      radius: 0.95,
                      colors: [
                        const Color(0xFFFF8C4A).withValues(alpha: 0.38),
                        const Color(0xFFFFDCC4).withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.34, 1.0],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.15, 1.12),
                      radius: 0.82,
                      colors: [
                        const Color(0xFFFFA066).withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// White rounded panel for auth forms (replaces frosted glass on mesh).
class AuthFormSurface extends StatelessWidget {
  const AuthFormSurface({super.key, required this.child});

  final Widget child;

  static const Color _borderInk = Color(0xFF212B58);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderInk.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Full-width orange pill — same language as welcome “Get Started”.
class AuthPrimaryPillButton extends StatelessWidget {
  const AuthPrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: StudyScapeColors.vibeOptionOrange.withValues(alpha: 0.26),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: StudyScapeColors.vibeOptionOrange,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
