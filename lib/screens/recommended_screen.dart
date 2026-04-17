import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/studyscape_colors.dart';

/// Full-page Recommended spots screen: matches Profile/tab layout (header, content, bottom nav).
class RecommendedScreen extends StatelessWidget {
  const RecommendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF5F4F0);
    const cardColor = Color(0xFFE8E6E4);
    const navBarColor = Color(0xFFE8E6E4);
    const darkText = Color(0xFF212B58);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'StudyScape',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: darkText,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Recommended spots for you',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: _recommendedSpots.length,
                itemBuilder: (context, index) {
                  final spot = _recommendedSpots[index];
                  return _RecommendedSpotCard(
                    spot: spot,
                    cardColor: cardColor,
                    darkText: darkText,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: navBarColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RecommendedNavItem(icon: Icons.map, isSelected: false, onTap: () => Navigator.pop(context, 0)),
                    _RecommendedNavItem(
                      icon: Icons.auto_awesome,
                      isSelected: true,
                      onTap: () {},
                      useTwoSparkles: true,
                    ),
                    _RecommendedNavItem(icon: Icons.person_outline, isSelected: false, onTap: () => Navigator.pop(context, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedSpot {
  const _RecommendedSpot({
    required this.name,
    required this.roomNumber,
    required this.lastStudied,
    required this.filledSeats,
    required this.totalSeats,
    required this.occupancyLabel,
    required this.occupancyColor,
    this.imagePath,
  });
  final String name;
  final String roomNumber;
  final String lastStudied;
  final int filledSeats;
  final int totalSeats;
  final String occupancyLabel;
  final Color occupancyColor;
  final String? imagePath;
}

const List<_RecommendedSpot> _recommendedSpots = [
  _RecommendedSpot(
    name: 'Library Commons',
    roomNumber: 'Room 101',
    lastStudied: '—',
    filledSeats: 12,
    totalSeats: 60,
    occupancyLabel: 'Empty',
    occupancyColor: Color(0xFF4CAF50),
    imagePath: 'assets/images/library.png',
  ),
  _RecommendedSpot(
    name: 'Campus Cafe',
    roomNumber: 'Main Floor',
    lastStudied: '—',
    filledSeats: 8,
    totalSeats: 24,
    occupancyLabel: 'Medium',
    occupancyColor: Color(0xFFFFC107),
    imagePath: 'assets/images/scdi.png',
  ),
  _RecommendedSpot(
    name: 'Study Lounge',
    roomNumber: 'Room 205',
    lastStudied: '—',
    filledSeats: 3,
    totalSeats: 20,
    occupancyLabel: 'Empty',
    occupancyColor: Color(0xFF4CAF50),
    imagePath: 'assets/images/dowd.png',
  ),
];

class _RecommendedSpotCard extends StatelessWidget {
  const _RecommendedSpotCard({
    required this.spot,
    required this.cardColor,
    required this.darkText,
  });
  final _RecommendedSpot spot;
  final Color cardColor;
  final Color darkText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: spot.imagePath != null
                ? Image.asset(
                    spot.imagePath!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.name,
                  style: GoogleFonts.poppins(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  spot.roomNumber,
                  style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Studied: ${spot.lastStudied}',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: spot.occupancyColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${spot.filledSeats}/${spot.totalSeats} seats',
                      style: GoogleFonts.poppins(color: darkText.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey.shade300,
      child: Icon(Icons.account_balance, color: Colors.grey.shade600, size: 40),
    );
  }
}

class _RecommendedNavItem extends StatelessWidget {
  const _RecommendedNavItem({
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.useTwoSparkles = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool useTwoSparkles;

  static const Color _unselectedIconColor = Color(0xFF212B58);
  static const Color _selectedOrange = Color(0xFFD4A574);

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? StudyScapeColors.vibeOptionOrange : _unselectedIconColor;
    final child = useTwoSparkles
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: iconColor, size: 20),
              const SizedBox(width: 4),
              Icon(Icons.auto_awesome, color: iconColor, size: 20),
            ],
          )
        : Icon(icon, color: iconColor, size: 26);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: isSelected && useTwoSparkles
              ? BoxDecoration(
                  color: _selectedOrange.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(24),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}
