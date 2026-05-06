import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_light_background.dart';
import '../widgets/studyscape_colors.dart';
import 'recommended_screen.dart';

/// Final onboarding step for choosing preferred study vibe.
class StudyVibeScreen extends StatefulWidget {
  const StudyVibeScreen({super.key});

  @override
  State<StudyVibeScreen> createState() => _StudyVibeScreenState();
}

class _StudyVibeScreenState extends State<StudyVibeScreen> {
  static const Color _headlineInk = Color(0xFF141922);
  static const Color _subtitleInk = Color(0xFF5C6370);
  static const Color _optionSurface = Color(0xFFDDDCD4);

  int? _selectedIndex;

  final List<String> _options = const [
    'Quiet and mostly empty',
    'Low buzz, a few people around',
    'Some background noise, feels alive',
    'Lively and social',
  ];

  void _onContinue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (context) => const RecommendedScreen()),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 110),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Choose your\nstudy vibe...',
                          style: GoogleFonts.poppins(
                            color: _headlineInk,
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            height: 0.95,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'Please select one option:',
                          style: GoogleFonts.inter(
                            color: _subtitleInk,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _options.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedIndex = index),
                                    borderRadius: BorderRadius.circular(25),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? StudyScapeColors.vibeOptionOrange : _optionSurface,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(alpha: isSelected ? 0.9 : 0.55),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.75),
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.circle,
                                                    size: 12,
                                                    color: StudyScapeColors.vibeOptionOrange,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              _options[index],
                                              style: GoogleFonts.inter(
                                                color: isSelected ? Colors.white : const Color(0xFF2F3138),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 50 + MediaQuery.of(context).padding.bottom),
                          child: AuthPrimaryPillButton(
                            label: 'Continue',
                            onPressed: _selectedIndex != null ? _onContinue : null,
                          ),
                        ),
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
