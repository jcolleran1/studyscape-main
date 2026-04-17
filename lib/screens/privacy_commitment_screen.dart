import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Privacy/data transparency page shown from Settings.
class PrivacyCommitmentScreen extends StatelessWidget {
  const PrivacyCommitmentScreen({super.key});

  static const Color _pageBg = Color(0xFFF2F3F5);
  static const Color _ink = Color(0xFF0C2D57);
  static const Color _body = Color(0xFF49505A);
  static const Color _gold = Color(0xFF9C5B06);
  static const Color _goldLight = Color(0xFFEDE3D3);
  static const Color _cardLight = Color(0xFFF7F7F8);
  static const Color _cardDark = Color(0xFF072A57);

  /// Same wordmark as welcome / login / create account / study vibe.
  static const Color _studyScapeTitle = Color(0xFF585552);
  static const double _studyScapeLogoFontSize = 20;
  static const Color _headerInk = Color(0xFF212B58);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'StudyScape',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: _studyScapeTitle.withValues(alpha: 0.4),
                    fontSize: _studyScapeLogoFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: _headerInk,
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield, size: 14, color: _gold),
                    const SizedBox(width: 6),
                    Text(
                      'DATA SECURITY',
                      style: GoogleFonts.poppins(
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
                  color: _ink,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'At StudyScape, your academic focus is our priority. We believe that finding a quiet '
                'space should never come at the cost of your personal privacy. Our systems are designed '
                'from the ground up to be anonymous by default.',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  height: 1.45,
                  color: _body,
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 26),
              _lightCard(
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
                              color: _ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.equalizer_rounded, size: 40, color: Color(0xFFE2E2E5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 16, height: 1.45, color: _body),
                        children: [
                          const TextSpan(
                            text:
                                'To provide real-time updates on study hall availability, we utilize high-precision '
                                'environmental sensors and computer vision modules. ',
                          ),
                          TextSpan(
                            text: 'These technologies do not record video or audio.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              height: 1.45,
                              color: _ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _featureRow(
                      icon: Icons.center_focus_strong,
                      title: 'CAMERA SENSORS',
                      body: 'Detects number of people to verify seat occupancy without facial details.',
                    ),
                    const SizedBox(height: 20),
                    _featureRow(
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
                  color: _cardDark,
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
                      style: GoogleFonts.poppins(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why We Use This Data',
                      style: GoogleFonts.poppins(
                        fontSize: 27,
                        height: 1.06,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our sole objective is to optimize the "Modern Scholar" experience. By analyzing '
                      'foot traffic patterns, we help you:',
                      style: GoogleFonts.poppins(fontSize: 16, height: 1.45, color: _body),
                    ),
                    const SizedBox(height: 14),
                    _benefitPill('Avoid crowded peaks'),
                    const SizedBox(height: 10),
                    _benefitPill('Find the absolute quietest zones'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 22),
              Text(
                '"Transparency is the foundation of a focused mind. '
                'We are here to support your studies, not to track your life."',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  height: 1.45,
                  color: _body,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cardDark,
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
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lightCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _featureRow({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26, color: _gold),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.3,
            color: _body,
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitPill(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(4),
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
                color: const Color(0xFF26282C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
