import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/studyscape_background.dart';
import '../widgets/circular_submit_button.dart';
import 'study_vibe_screen.dart';

/// One step in the "how you study" flow: question + options.
class _PreferenceStep {
  const _PreferenceStep({required this.question, required this.options});
  final String question;
  final List<String> options;
}

/// Screens after login to gauge how the user likes to study. Multiple steps, same-size option boxes.
class StudyPreferenceScreen extends StatefulWidget {
  const StudyPreferenceScreen({super.key, this.initialStep = 0});

  final int initialStep;

  @override
  State<StudyPreferenceScreen> createState() => _StudyPreferenceScreenState();
}

class _StudyPreferenceScreenState extends State<StudyPreferenceScreen> {
  static const Color _studyScapeTitle = Color(0xFF585552);
  static const double _studyScapeLogoFontSize = 20;
  static const Color _pillOrangeBg = Color(0xFFEC8B46);

  static const List<_PreferenceStep> _steps = [
    _PreferenceStep(
      question: 'What are you studying for?',
      options: [
        'Career or Academic Goals',
        'Certification or Training Program',
        'Review or Self-Improvement',
      ],
    ),
    _PreferenceStep(
      question: 'What helps you focus the most while studying?',
      options: [
        'Complete Silence',
        'Soft Background Noise',
        'Music or White Noise',
        'Being Around Others Also Studying',
      ],
    ),
    _PreferenceStep(
      question: 'How important is the study environment to your productivity?',
      options: [
        'Very Important', 
        'Somewhat Important', 
        'Not Important', 
        'Doesn\'t Affect Me'
      ],
    ),
    _PreferenceStep(
      question: 'Where do you usually study?',
      options: ['Library',
       'Cafe or Coffee Shop',
        'Study Lounge or Area'],
    ),
    _PreferenceStep(
      question: 'What crowd level do you prefer when studying?',
      options: [
        'Empty',
        'A Few People Nearby',
        'Lively and Active',
        'Moderately Busy',
      ],
    ),
    _PreferenceStep(
      question: 'Would you like to see how busy a space is before going there?',
      options: [
        'Yes, that would be helpful',
        'No I don\'t mind',
      ],
    ),
  ];

  static const double _pillHeight = 44;

  late int _stepIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _stepIndex = widget.initialStep.clamp(0, _steps.length - 1);
  }

  void _onNext() {
    if (_stepIndex + 1 >= _steps.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudyVibeScreen()),
      );
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
    final currentPage = _stepIndex + 1;
    final totalPages = _steps.length;

    return Scaffold(
      backgroundColor: kStudyscapeBgStart,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: WelcomeBackgroundImage(),
            ),
            SafeArea(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32, left: 56),
                    child: Text(
                      "Let's\nunderstand\nhow you\nstudy...",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                      strutStyle: StrutStyle.fromTextStyle(
                        GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                        height: 1.0,
                        leading: 0,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 75),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, flexibleConstraints) {
                      return SizedBox(
                        height: flexibleConstraints.maxHeight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color.lerp(
                                          Colors.blueGrey.withOpacity(0.12),
                                          Colors.white.withOpacity(0.2),
                                          0.5,
                                        )!,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                                      child: Text(
                                        step.question,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(step.options.length, (index) {
                                          final isSelected = _selectedIndex == index;
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => setState(() => _selectedIndex = index),
                                                borderRadius: BorderRadius.circular(22),
                                                child: Container(
                                                  height: _pillHeight,
                                                  width: double.infinity,
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? _pillOrangeBg
                                                        : Colors.white.withOpacity(0.22),
                                                    borderRadius: BorderRadius.circular(22),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.white.withOpacity(0.6)
                                                          : Colors.white.withOpacity(0.25),
                                                      width: isSelected ? 2 : 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    step.options[index],
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : const Color(0xFFEC8B46),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(32, 40, 32, 28 + MediaQuery.of(context).padding.bottom),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$currentPage of $totalPages',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              CircularSubmitButton(
                                                onPressed: _selectedIndex != null ? _onNext : null,
                                              ),
                                            ],
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
                    );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
