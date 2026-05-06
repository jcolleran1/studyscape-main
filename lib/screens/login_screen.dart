import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_light_background.dart';
import '../widgets/frosted_text_field.dart';
import '../widgets/studyscape_colors.dart';
import 'create_account_screen.dart';
import 'study_vibe_screen.dart';

/// Log in — same light hue backdrop and centered typography as [WelcomeScreen].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _headlineInk = Color(0xFF141922);
  static const Color _subtitleInk = Color(0xFF5C6370);
  static const Color _linkBlue = Color(0xFF3B7DD8);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const StudyVibeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 60),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: _headlineInk,
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Log in',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -0.6,
                      color: _headlineInk,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: StudyScapeColors.vibeOptionOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome back — enter your details to continue.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: _subtitleInk,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: AuthFormSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => const CreateAccountScreen(),
                                  ),
                                );
                              },
                              child: Text.rich(
                                TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    height: 1.45,
                                    color: _subtitleInk,
                                  ),
                                  children: [
                                    const TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: 'Create account',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _headlineInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FrostedTextField(
                              controller: _emailController,
                              hintText: 'Username',
                              useLightSurface: true,
                            ),
                            const SizedBox(height: 14),
                            FrostedTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: true,
                              useLightSurface: true,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: _linkBlue,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _linkBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Padding(
                              padding: EdgeInsets.only(bottom: 50 + MediaQuery.of(context).padding.bottom),
                              child: AuthPrimaryPillButton(
                                label: 'Continue',
                                loading: _loading,
                                onPressed: _submit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
