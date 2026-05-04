import 'package:flutter/material.dart';
import '../widgets/studyscape_colors.dart';
import 'home_screen.dart';

/// Screen to set up study profile (e.g. focus area).
class StudyProfileScreen extends StatefulWidget {
  const StudyProfileScreen({super.key});

  @override
  State<StudyProfileScreen> createState() => _StudyProfileScreenState();
}

class _StudyProfileScreenState extends State<StudyProfileScreen> {
  static const Color _bgBlue = Color(0xFF212B58);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _bgBlue,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text(
                  'Almost there',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Text(
                  'Set up your study profile to get personalized recommendations.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudyScapeColors.vibeOptionOrange,
                      foregroundColor: const Color(0xFFEC8B46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text('Go to Home'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
