import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/circular_submit_button.dart';
import '../widgets/frosted_text_field.dart';
import '../widgets/auth_headline_fitted.dart';
import '../widgets/studyscape_background.dart';
import 'login_screen.dart';
import 'study_preference_screen.dart';

/// Create account screen matching welcome design: gradient, pattern, frosted card.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const Color _headerInk = Color(0xFF212B58);
  static const Color _bodyText = Color(0xFF4A5568);

  /// Same wordmark as [WelcomeScreen].
  static const Color _studyScapeTitle = Color(0xFF585552);
  static const double _studyScapeLogoFontSize = 20;

  /// Tight line box so “create” / “account” sit flush without overlapping.
  static const double _createHeadlineLineHeight = 0.62;

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const StudyPreferenceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createHeadlineStyle = GoogleFonts.poppins(
      fontSize: 80,
      fontWeight: FontWeight.w700,
      height: _createHeadlineLineHeight,
      letterSpacing: -2,
      color: const Color(0xFFFFFFFF).withValues(alpha: 0.5),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: WelcomeBackgroundImage(),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Back arrow left, StudyScape centered — matches welcome wordmark
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          color: _headerInk,
                          onPressed: () => Navigator.pop(context),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ),
                    ),
                    Text(
                      'StudyScape',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _studyScapeTitle.withValues(alpha: 0.4),
                        fontSize: _studyScapeLogoFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 88),
                AuthHeadlineFitted(
                  text: 'create\naccount',
                  style: createHeadlineStyle,
                  strutStyle: StrutStyle.fromTextStyle(
                    createHeadlineStyle,
                    height: _createHeadlineLineHeight,
                    leading: 0,
                  ),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                // Frosted card at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.72,
                          ),
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.56),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: _headerInk.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: _bodyText,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Already have an account? '),
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: _bodyText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              FrostedTextField(
                                controller: _nameController,
                                hintText: 'Name',
                                useLightSurface: true,
                              ),
                              const SizedBox(height: 16),
                              FrostedTextField(
                                controller: _usernameController,
                                hintText: 'Username',
                                useLightSurface: true,
                              ),
                              const SizedBox(height: 16),
                              FrostedTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                obscureText: true,
                                useLightSurface: true,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CircularSubmitButton(
                                    onPressed: _submit,
                                    loading: _loading,
                                  ),
                                ],
                              ),
                            ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
