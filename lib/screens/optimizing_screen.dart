import 'package:flutter/material.dart';
import 'study_profile_screen.dart';

/// "Optimizing your experience" screen shown after signup/login.
class OptimizingScreen extends StatefulWidget {
  const OptimizingScreen({super.key});

  @override
  State<OptimizingScreen> createState() => _OptimizingScreenState();
}

class _OptimizingScreenState extends State<OptimizingScreen> {
  static const Color _bgBlue = Color(0xFF212B58);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudyProfileScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _bgBlue,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
                const SizedBox(height: 24),
                Text(
                  'Optimizing your experience...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
