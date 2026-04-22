import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/studyscape_background.dart';
import '../widgets/circular_submit_button.dart';
import 'home_screen.dart';

/// Study vibe selection screen: same layout as study preference (gradient header, frosted card, pills, next button).
class StudyVibeScreen extends StatefulWidget {
  const StudyVibeScreen({super.key});

  @override
  State<StudyVibeScreen> createState() => _StudyVibeScreenState();
}

class _StudyVibeScreenState extends State<StudyVibeScreen> {
  int? _selectedIndex;

  /// Same wordmark as welcome / login / create account.
  static const Color _studyScapeTitle = Color(0xFF585552);
  static const double _studyScapeLogoFontSize = 20;

  // Match study preference screen colors
  static const Color _pillOrangeBg = Color(0xFFEC8B46);
  static const double _pillHeight = 44;

  /// Tight stacked lines — same approach as [CreateAccountScreen] headline.
  static const double _vibeHeadlineLineHeight = 1.1;

  final List<String> _options = [
    'Quiet and mostly empty',
    'Low buzz, a few people around',
    'Some background noise, feels alive',
    'Lively and social',
  ];

  @override
  Widget build(BuildContext context) {
    final vibeHeadlineStyle = GoogleFonts.poppins(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 50,
      fontWeight: FontWeight.bold,
      height: _vibeHeadlineLineHeight,
      letterSpacing: -2,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: WelcomeBackgroundImage(),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const SizedBox(height: 64),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        'choose your\nstudy vibe...',
                        textAlign: TextAlign.right,
                        style: vibeHeadlineStyle,
                        strutStyle: StrutStyle.fromTextStyle(
                          vibeHeadlineStyle,
                          height: _vibeHeadlineLineHeight,
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
                                                    padding: const EdgeInsets.fromLTRB(32, 42, 32, 16),
                                                    child: Text(
                                                      'Pick the vibe that fits you right now.',
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
                                                      children: List.generate(_options.length, (index) {
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
                                                                  _options[index],
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
                                            padding: EdgeInsets.fromLTRB(32, 30, 32, 18 + MediaQuery.of(context).padding.bottom),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                CircularSubmitButton(
                                                  onPressed: _selectedIndex != null
                                                      ? () {
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => const HomeScreen(
                                                                autoShowRecommendations: true,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      : null,
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
