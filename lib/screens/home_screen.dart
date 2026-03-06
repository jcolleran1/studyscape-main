import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/studyscape_colors.dart';

/// Home screen with map and "Where You've Studied" overlay.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.autoShowRecommendations = false});

  /// When true, the recommended spots tab overlay auto-opens after ~1.5 seconds.
  final bool autoShowRecommendations;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum OccupancyLevel { full, medium, empty }

class _StudyLocation {
  const _StudyLocation({
    required this.name,
    required this.roomNumber,
    required this.lastStudied,
    required this.filledSeats,
    required this.totalSeats,
    required this.occupancy,
    this.imagePath,
  });
  final String name;
  final String roomNumber;
  final String lastStudied;
  final int filledSeats;
  final int totalSeats;
  final OccupancyLevel occupancy;
  final String? imagePath;
}

const List<_StudyLocation> _studiedLocationsList = [
  _StudyLocation(
    name: 'Library Commons',
    roomNumber: 'Room #',
    lastStudied: '12/04/2025',
    filledSeats: 52,
    totalSeats: 60,
    occupancy: OccupancyLevel.full,
    imagePath: 'assets/images/library.png',
  ),
  _StudyLocation(
    name: 'Sobrato Campus for Discovery and Innovation',
    roomNumber: 'Room #',
    lastStudied: '12/04/2025',
    filledSeats: 30,
    totalSeats: 50,
    occupancy: OccupancyLevel.medium,
    imagePath: 'assets/images/scdi.png',
  ),
  _StudyLocation(
    name: 'Edward M. Dowd Art and Art History Building',
    roomNumber: 'Room #',
    lastStudied: '12/04/2025',
    filledSeats: 12,
    totalSeats: 50,
    occupancy: OccupancyLevel.empty,
    imagePath: 'assets/images/dowd.png',
  ),
];

const List<_StudyLocation> _recommendedSpotsList = [
  _StudyLocation(
    name: 'Library Commons',
    roomNumber: 'Room 101',
    lastStudied: '—',
    filledSeats: 12,
    totalSeats: 60,
    occupancy: OccupancyLevel.empty,
    imagePath: 'assets/images/library.png',
  ),
  _StudyLocation(
    name: 'Campus Cafe',
    roomNumber: 'Main Floor',
    lastStudied: '—',
    filledSeats: 8,
    totalSeats: 24,
    occupancy: OccupancyLevel.medium,
    imagePath: 'assets/images/scdi.png',
  ),
  _StudyLocation(
    name: 'Study Lounge',
    roomNumber: 'Room 205',
    lastStudied: '—',
    filledSeats: 3,
    totalSeats: 20,
    occupancy: OccupancyLevel.empty,
    imagePath: 'assets/images/dowd.png',
  ),
];

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0; // 0 = map, 1 = home, 2 = recommendations

  static const Color _sheetBg = Color(0xFF14234B);
  static const Color _cardBg = Color(0xFF2A3A5C);

  @override
  void initState() {
    super.initState();
    if (widget.autoShowRecommendations) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _selectedNavIndex = 2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          SafeArea(
            child: Center(
              child: Text(
                'StudyScape',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: MediaQuery.of(context).padding.top + 60,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.people),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: MediaQuery.of(context).padding.top + 60,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          if (_selectedNavIndex == 1 || _selectedNavIndex == 2)
            Positioned.fill(
              child: _WhereYouveStudiedOverlay(
                selectedIndex: _selectedNavIndex,
                onNavTap: (i) => setState(() => _selectedNavIndex = i),
              ),
            ),
          // Bottom nav bar always at the bottom of the screen
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(icon: Icons.map, isSelected: _selectedNavIndex == 0, onTap: () => setState(() => _selectedNavIndex = 0)),
                  _NavItem(icon: Icons.home, isSelected: _selectedNavIndex == 1, onTap: () => setState(() => _selectedNavIndex = 1)),
                  _NavItem(icon: Icons.auto_awesome, isSelected: _selectedNavIndex == 2, onTap: () => setState(() => _selectedNavIndex = 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhereYouveStudiedOverlay extends StatefulWidget {
  const _WhereYouveStudiedOverlay({required this.selectedIndex, required this.onNavTap});
  final int selectedIndex;
  final ValueChanged<int> onNavTap;

  @override
  State<_WhereYouveStudiedOverlay> createState() => _WhereYouveStudiedOverlayState();
}

class _WhereYouveStudiedOverlayState extends State<_WhereYouveStudiedOverlay> {
  static const Color _sheetBg = Color(0xFF14234B);
  static const Color _cardBg = Color(0xFF2A3A5C);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _occupancyColor(OccupancyLevel level) {
    switch (level) {
      case OccupancyLevel.full:
        return const Color(0xFFE53935);
      case OccupancyLevel.medium:
        return const Color(0xFFFFC107);
      case OccupancyLevel.empty:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onNavTap(0),
            child: const Spacer(),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.72 - 72 - bottomPadding,
            decoration: const BoxDecoration(
              color: _sheetBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 44),
                Text(
                  widget.selectedIndex == 2
                      ? "Recommended spots for you"
                      : "Where You've Studied",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 36),
                Expanded(
                  child: Stack(
                    children: [
                      Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                          itemCount: widget.selectedIndex == 2
                              ? _recommendedSpotsList.length
                              : _studiedLocationsList.length,
                          itemBuilder: (context, index) {
                            if (widget.selectedIndex == 2) {
                              final spot = _recommendedSpotsList[index];
                              return _StudyLocationCard(
                                location: spot,
                                occupancyColor: _occupancyColor(spot.occupancy),
                                cardBg: _cardBg,
                              );
                            }
                            final loc = _studiedLocationsList[index];
                            return _StudyLocationCard(
                              location: loc,
                              occupancyColor: _occupancyColor(loc.occupancy),
                              cardBg: _cardBg,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 0, right: 0, top: 0, height: 24,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_sheetBg, _sheetBg.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0, right: 0, bottom: 0, height: 24,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_sheetBg.withOpacity(0), _sheetBg],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _StudyLocationCard extends StatelessWidget {
  const _StudyLocationCard({required this.location, required this.occupancyColor, required this.cardBg});
  final _StudyLocation location;
  final Color occupancyColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: location.imagePath != null
                ? Image.asset(
                    location.imagePath!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  location.roomNumber,
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Studied: ${location.lastStudied}',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: occupancyColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${location.filledSeats}/${location.totalSeats} seats',
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13),
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

  Widget _placeholderImage() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.white.withOpacity(0.15),
      child: Icon(Icons.account_balance, color: Colors.white.withOpacity(0.5), size: 48),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.onTap, this.isSelected = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: isSelected ? StudyScapeColors.vibeOptionOrange : Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
