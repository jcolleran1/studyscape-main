import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_light_background.dart';
import '../widgets/studyscape_colors.dart';
import 'study_vibe_screen.dart';

class _PreferenceStep {
  const _PreferenceStep({required this.question, required this.options});
  final String question;
  final List<String> options;
}

class StudyPreferenceScreen extends StatefulWidget {
  const StudyPreferenceScreen({super.key, this.initialStep = 0});
  final int initialStep;

  @override
  State<StudyPreferenceScreen> createState() => _StudyPreferenceScreenState();
}

class _StudyPreferenceScreenState extends State<StudyPreferenceScreen> {
  static const Color _headlineInk = Color(0xFF141922);
  static const Color _subtitleInk = Color(0xFF5C6370);
  static const Color _optionSurface = Color(0xFFDDDCD4);

  static const List<_PreferenceStep> _steps = [
    _PreferenceStep(
      question: 'What are you studying for?',
      options: ['Career or Academic Goals', 'Certification or Training Program', 'Review or Self-Improvement'],
    ),
    _PreferenceStep(
      question: 'What helps you focus the most while studying?',
      options: ['Complete Silence', 'Soft Background Noise', 'Music or White Noise', 'Being Around Others Also Studying'],
    ),
    _PreferenceStep(
      question: 'How important is the study environment to your productivity?',
      options: ['Very Important', 'Somewhat Important', 'Not Important', 'Doesn\'t Affect Me'],
    ),
    _PreferenceStep(
      question: 'Where do you usually study?',
      options: ['Library', 'Cafe or Coffee Shop', 'Study Lounge or Area'],
    ),
    _PreferenceStep(
      question: 'What crowd level do you prefer when studying?',
      options: ['Empty', 'A Few People Nearby', 'Lively and Active', 'Moderately Busy'],
    ),
    _PreferenceStep(
      question: 'Would you like to see how busy a space is before going there?',
      options: ['Yes, that would be helpful', 'No I don\'t mind'],
    ),
  ];

  late int _stepIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _stepIndex = widget.initialStep.clamp(0, _steps.length - 1);
  }

  void _onNext() {
    if (_stepIndex + 1 >= _steps.length) {
      Navigator.pushReplacement(context, MaterialPageRoute<void>(builder: (context) => const StudyVibeScreen()));
      return;
    }
    setState(() {
      _stepIndex += 1;
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final progress = (_stepIndex + 1) / _steps.length;

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.7),
                      valueColor: const AlwaysStoppedAnimation<Color>(StudyScapeColors.vibeOptionOrange),
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          step.question,
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
                            itemCount: step.options.length,
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
                                                ? const Icon(Icons.circle, size: 12, color: StudyScapeColors.vibeOptionOrange)
                                                : null,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              step.options[index],
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
                          child: Column(
                            children: [
                              AuthPrimaryPillButton(
                                label: 'Continue',
                                onPressed: _selectedIndex != null ? _onNext : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_stepIndex + 1} / ${_steps.length}',
                                style: GoogleFonts.inter(
                                  color: _subtitleInk.withValues(alpha: 0.78),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
