import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/studyscape_palette.dart';
import '../widgets/scroll_top_edge_fade.dart';

/// Privacy/data transparency page shown from Settings.
class PrivacyCommitmentScreen extends StatelessWidget {
  const PrivacyCommitmentScreen({super.key});

  static const Color _gold = Color(0xFF9C5B06);
  static const Color _goldLightBg = Color(0xFFEDE3D3);
  static const double _studyScapeLogoFontSize = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? const Color(0xFF3D3528) : _goldLightBg;

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(Color(0xFFEC8B46), BlendMode.srcIn),
                      child: Image.asset('images/studyscape_logo_mark.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            color: palette.headerBackInk,
                            onPressed: () => Navigator.pop(context),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield, size: 14, color: _gold),
                              const SizedBox(width: 6),
                              Text(
                                'DATA SECURITY',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: _gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Our Commitment to\nPrivacy',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            height: 1.06,
                            fontWeight: FontWeight.w700,
                            color: palette.titleInk,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'At StudyScape, your academic focus is our priority. We believe that finding a quiet '
                          'space should never come at the cost of your personal privacy. Our systems are designed '
                          'from the ground up to be anonymous by default.',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            height: 1.45,
                            color: palette.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 26),
                        _lightCard(
                          context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'How We Track\nOccupancy',
                                      style: GoogleFonts.poppins(
                                        fontSize: 27,
                                        height: 1.06,
                                        fontWeight: FontWeight.w600,
                                        color: palette.titleInk,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: palette.settingsSectionBg,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.equalizer_rounded,
                                      size: 40,
                                      color: palette.divider,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(fontSize: 16, height: 1.45, color: palette.muted),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'To provide real-time updates on study hall availability, we utilize high-precision '
                                          'environmental sensors and computer vision modules. ',
                                    ),
                                    TextSpan(
                                      text: 'These technologies do not record video or audio.',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        height: 1.45,
                                        color: palette.titleInk,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _featureRow(
                                context,
                                icon: Icons.center_focus_strong,
                                title: 'CAMERA SENSORS',
                                body: 'Detects number of people to verify seat occupancy without facial details.',
                              ),
                              const SizedBox(height: 20),
                              _featureRow(
                                context,
                                icon: Icons.blur_on,
                                title: 'NOISE FLOOR',
                                body: 'Monitors decibel levels only, ensuring no conversation is decipherable.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: palette.brandHeroBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Identifiable Data\nRecorded',
                                style: GoogleFonts.poppins(
                                  fontSize: 27,
                                  height: 1.06,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'We have engineered a strict data firewall. StudyScape is legally and technically '
                                'incapable of matching occupancy data to a specific student ID or persona.',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  height: 1.45,
                                  color: Colors.white.withValues(alpha: 0.56),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _bullet('No facial recognition algorithms'),
                              _bullet('No storage of biometric templates'),
                              _bullet('Real-time data purging every 15 minutes'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _lightCard(
                          context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Why We Use This Data',
                                style: GoogleFonts.poppins(
                                  fontSize: 27,
                                  height: 1.06,
                                  fontWeight: FontWeight.w600,
                                  color: palette.titleInk,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Our sole objective is to optimize the "Modern Scholar" experience. By analyzing '
                                'foot traffic patterns, we help you:',
                                style: GoogleFonts.inter(fontSize: 16, height: 1.45, color: palette.muted),
                              ),
                              const SizedBox(height: 14),
                              _benefitPill(context, 'Avoid crowded peaks'),
                              const SizedBox(height: 10),
                              _benefitPill(context, 'Find the absolute quietest zones'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Divider(color: palette.divider, height: 1),
                        const SizedBox(height: 22),
                        Text(
                          '"Transparency is the foundation of a focused mind. '
                          'We are here to support your studies, not to track your life."',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            height: 1.45,
                            color: palette.muted,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.brandHeroBg,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('I Understand'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'LAST UPDATED: OCTOBER 2023  VERSION 2.4.0',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              color: palette.muted.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  ScrollTopEdgeFade(fadeColor: palette.pageBackground),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lightCard(BuildContext context, {required Widget child}) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.cardRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.subtleBorder),
      ),
      child: child,
    );
  }

  Widget _featureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26, color: _gold),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: palette.titleInk,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.3,
            color: palette.muted,
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, size: 20, color: Color(0xFFEC8B46)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitPill(BuildContext context, String text) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? palette.buildingTileBg : Colors.white.withValues(alpha: 0.95);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(4),
        border: isDark ? Border.all(color: palette.subtleBorder) : null,
      ),
      child: Row(
        children: [
          Container(width: 3, height: 24, color: _gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.titleInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
