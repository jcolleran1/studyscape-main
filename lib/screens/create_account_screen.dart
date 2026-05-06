import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_light_background.dart';
import '../widgets/frosted_text_field.dart';
import '../widgets/studyscape_colors.dart';
import 'login_screen.dart';
import 'study_preference_screen.dart';

/// Create account — matches welcome / login light layout and hue backdrop.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const Color _headlineInk = Color(0xFF141922);
  static const Color _subtitleInk = Color(0xFF5C6370);

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    setState(() => _loading = true);
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const StudyPreferenceScreen(),
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
                    'Create account',
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
                    'Set up your profile to personalize study recommendations.',
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
                                    builder: (context) => const LoginScreen(),
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
                                    const TextSpan(text: 'Already have an account? '),
                                    TextSpan(
                                      text: 'Log in',
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
                              controller: _nameController,
                              hintText: 'Name',
                              useLightSurface: true,
                            ),
                            const SizedBox(height: 14),
                            FrostedTextField(
                              controller: _usernameController,
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
