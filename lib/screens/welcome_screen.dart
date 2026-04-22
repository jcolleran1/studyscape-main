import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/studyscape_background.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

/// Welcome screen: mesh background, centered “welcome” headline, peach + white pill CTAs.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _brandPeach = Color(0xFFEC8B46);
  static const Color _studyScapeTitle = Color(0xFF585552);

  /// StudyScape wordmark — 20 logical px (≈ 20pt at 1:1 device scale).
  static const double _studyScapeLogoFontSize = 20;

  /// SF Pro Text on Apple platforms; Inter medium elsewhere (SF is not bundled).
  static TextStyle _buttonLabelStyle(Color color) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text',
        );
      default:
        return GoogleFonts.inter(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: WelcomeBackgroundImage()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        'StudyScape',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: _studyScapeTitle.withValues(alpha: 0.4),
                          fontSize: _studyScapeLogoFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                    child: Text(
                      'welcome',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 80,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: -2,
                        color: const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 272),
                            child: Text(
                              'Sign up or login to join the world\nof active learners.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 88),
                        _WelcomePrimaryButton(
                          label: 'Create an Account',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _WelcomeSecondaryButton(
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
                        SizedBox(height: 80 + bottom),
                      ],
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

class _WelcomePrimaryButton extends StatelessWidget {
  const _WelcomePrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: WelcomeScreen._brandPeach,
        borderRadius: BorderRadius.circular(27),
        elevation: 0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(27),
          child: Center(
            child: Text(
              label,
              style: WelcomeScreen._buttonLabelStyle(Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeSecondaryButton extends StatelessWidget {
  const _WelcomeSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(27),
          child: Center(
            child: Text(
              label,
              style: WelcomeScreen._buttonLabelStyle(WelcomeScreen._brandPeach),
            ),
          ),
        ),
      ),
    );
  }
}
