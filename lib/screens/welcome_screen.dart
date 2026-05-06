import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_light_background.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

/// Light onboarding welcome — soft blue + orange atmospheric hues, orange pill CTA.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _headlineInk = Color(0xFF212B58);
  static const Color _subtitleInk = Color(0xFF5C6370);
  static const Color _footerInk = Color(0xFF8E95A3);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: kAuthLightScaffoldBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthLightHueBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),
                  SizedBox(
                    height: 92,
                    child: Image.asset(
                      'images/studyscape_logo_mark.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Welcome to Studyscape',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -0.6,
                      color: _headlineInk,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find quieter study spaces on campus with live occupancy and noise cues.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: _subtitleInk,
                    ),
                  ),
                  const Spacer(flex: 3),
                  AuthPrimaryPillButton(
                    label: 'Get Started',
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const CreateAccountScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: _subtitleInk,
                            height: 1.4,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Log in',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _headlineInk,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40 + bottom),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
