import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/circular_submit_button.dart';
import '../widgets/frosted_text_field.dart';
import '../widgets/auth_headline_fitted.dart';
import '../widgets/studyscape_background.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';

/// Login screen matching create account layout: Welcome Back title, account prompt, Forgot Password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _linkBlue = Color(0xFF6BA3D0);
  static const Color _headerInk = Color(0xFF212B58);
  static const Color _bodyText = Color(0xFF4A5568);

  /// Same wordmark as [WelcomeScreen] / create account.
  static const Color _studyScapeTitle = Color(0xFF585552);
  static const double _studyScapeLogoFontSize = 20;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signIn(_emailController.text, _passwordController.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginHeadlineStyle = GoogleFonts.poppins(
      fontSize: 80,
      fontWeight: FontWeight.w700,
      height: 1.0,
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
                  text: 'login',
                  style: loginHeadlineStyle,
                ),
                const Spacer(),
                const SizedBox(height: 20),
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
                                      builder: (context) => const CreateAccountScreen(),
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
                                      const TextSpan(text: "Don't have an account?  "),
                                      TextSpan(
                                        text: 'Create Account',
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
                                controller: _emailController,
                                hintText: 'Email',
                                useLightSurface: true,
                              ),
                              const SizedBox(height: 16),
                              FrostedTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                obscureText: true,
                                useLightSurface: true,
                              ),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    color: _linkBlue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _linkBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
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
