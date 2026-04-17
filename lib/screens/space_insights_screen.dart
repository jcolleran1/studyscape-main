import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/studyscape_colors.dart';

/// Deeper insights for a study space (from map marker / card title).
class SpaceInsightsScreen extends StatelessWidget {
  const SpaceInsightsScreen({
    super.key,
    required this.spaceId,
    required this.spaceName,
    required this.locationLine,
    required this.capacityPercent,
    required this.noiseLevel,
    this.noiseHint = '',
  });

  final String spaceId;
  final String spaceName;
  final String locationLine;
  final int capacityPercent;
  final String noiseLevel;
  final String noiseHint;

  static const Color _navy = Color(0xFF0C2D57);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _orange = Color(0xFFEC8B46);
  static const Color _blue = Color(0xFF6BA3D0);

  String get _description {
    switch (spaceId) {
      case 'scdi_f2_b':
        return 'Optimized for deep work with sound-dampening acoustic panels and individual task lighting.';
      case 'scdi_f2_a':
        return 'Compact focus zone with natural light and adjustable seating for solo study sessions.';
      case 'scdi_f2_c':
        return 'Open collaboration-friendly area with flexible seating and shared power.';
      default:
        return 'Live occupancy, noise, and environment data help you pick the right moment to study here.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trafficNavy = const Color(0xFF0E1A3A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: StudyScapeColors.primaryBlue,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'StudyScape',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: StudyScapeColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spaceName,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: _muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            locationLine,
                            style: GoogleFonts.poppins(fontSize: 14, color: _muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About this space',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _description,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _chip('$capacityPercent% capacity', _orange),
                              if (noiseHint.isNotEmpty) _chip(noiseHint, _muted),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: trafficNavy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REAL-TIME TRAFFIC',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Occupancy',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$capacityPercent%',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (capacityPercent.clamp(0, 100)) / 100.0,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(_orange),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Noise level',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            noiseLevel,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.45,
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Updated moments ago',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
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
    );
  }

  Widget _chip(String text, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fg == _orange ? _orange.withValues(alpha: 0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg == _orange ? _orange : fg,
        ),
      ),
    );
  }
}
