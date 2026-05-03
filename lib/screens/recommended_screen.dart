import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_routes.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../widgets/studyscape_colors.dart';

/// Full-page Recommended spots screen with featured recommendation, campus load,
/// and nearby locations cards.
class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  bool _showBuildingDropdown = false;
  Set<String> _draftSelectedBuildings = <String>{};
  Set<String> _appliedSelectedBuildings = <String>{};

  static const List<String> _buildingNames = <String>[
    'Dowd',
    'Lucas',
    'Heafey',
    'SCDI',
    'Library',
  ];

  List<_SpaceItem> _filteredSpaces() {
    if (_appliedSelectedBuildings.isEmpty) return _spaceItems;
    return _spaceItems
        .where((space) => _appliedSelectedBuildings.contains(space.building))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF0F1F4);
    const navBarColor = Color(0xFFE8E6E4);
    const darkText = Color(0xFF082D5E);
    const mutedText = Color(0xFF4A4D57);
    const accentOrange = Color(0xFFFF9F1A);
    const quietGreen = Color(0xFF18B663);
    const chipGrey = Color(0xFFE9EAED);
    final spaces = _filteredSpaces();
    final featuredSpace = spaces.isNotEmpty ? spaces.first : null;
    final nearbySpaces = spaces.length > 1 ? spaces.sublist(1) : const <_SpaceItem>[];

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
                color: const Color(0xFF585552).withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 136),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your focus\nzone.',
                      style: GoogleFonts.poppins(
                        fontSize: 46,
                        fontWeight: FontWeight.w600,
                        height: 1.06,
                        letterSpacing: -1.4,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Intelligent real-time tracking for academic\nenvironments. Navigate silence with\nprecision.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.42,
                        color: mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _AllSpacesButton(
                      onTap: () {
                        setState(() {
                          _draftSelectedBuildings = {..._appliedSelectedBuildings};
                          _showBuildingDropdown = !_showBuildingDropdown;
                        });
                      },
                    ),
                    if (_showBuildingDropdown) ...[
                      const SizedBox(height: 10),
                      _BuildingDropdownCard(
                        buildingNames: _buildingNames,
                        selectedBuildings: _draftSelectedBuildings,
                        onToggleBuilding: (building) {
                          setState(() {
                            if (_draftSelectedBuildings.contains(building)) {
                              _draftSelectedBuildings.remove(building);
                            } else {
                              _draftSelectedBuildings.add(building);
                            }
                          });
                        },
                        onApplyFilter: () {
                          setState(() {
                            _appliedSelectedBuildings = {..._draftSelectedBuildings};
                            _showBuildingDropdown = false;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 28),
                    if (featuredSpace != null)
                      _FeaturedSpotCard(
                        title: featuredSpace.title,
                        imagePath: featuredSpace.imagePath,
                        occupancyLabel: featuredSpace.occupancyLabel,
                        soundLabel: featuredSpace.soundLabel,
                        darkText: darkText,
                        quietGreen: quietGreen,
                      ),
                    const SizedBox(height: 28),
                    _CampusLoadCard(
                      darkText: darkText,
                      accentOrange: accentOrange,
                      quietGreen: quietGreen,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Nearby Locations',
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              letterSpacing: -1.2,
                              color: darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF8A6B2E),
                            textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          child: const Text('See all\nspaces'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (nearbySpaces.isEmpty)
                      Text(
                        'No additional spaces for this filter.',
                        style: GoogleFonts.inter(
                          color: mutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    for (var i = 0; i < nearbySpaces.length; i++) ...[
                      _NearbySpotCard(
                        imagePath: nearbySpaces[i].imagePath,
                        title: nearbySpaces[i].title.replaceAll('\n', ' '),
                        subtitle: nearbySpaces[i].subtitle,
                        darkText: darkText,
                        badgeLeft: nearbySpaces[i].badgeLeft,
                        badgeRight: nearbySpaces[i].badgeRight,
                        extraTagLabel: nearbySpaces[i].extraTagLabel,
                        extraTagIcon: nearbySpaces[i].extraTagIcon,
                        chipGrey: chipGrey,
                        darkButton: darkText,
                      ),
                      if (i != nearbySpaces.length - 1) const SizedBox(height: 22),
                    ],
                  ],
                ),
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
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RecommendedNavItem(
                      icon: Icons.map,
                      isSelected: false,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          fadeRoute(const HomeScreen()),
                        );
                      },
                    ),
                    _RecommendedNavItem(
                      icon: Icons.auto_awesome,
                      isSelected: true,
                      onTap: () {},
                      useTwoSparkles: true,
                    ),
                    _RecommendedNavItem(
                      icon: Icons.person_outline,
                      isSelected: false,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          fadeRoute(const ProfileScreen()),
                        );
                      },
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
}

class _AllSpacesButton extends StatelessWidget {
  const _AllSpacesButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF072F63),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'All Spaces',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _BuildingDropdownCard extends StatelessWidget {
  const _BuildingDropdownCard({
    required this.buildingNames,
    required this.selectedBuildings,
    required this.onToggleBuilding,
    required this.onApplyFilter,
  });

  final List<String> buildingNames;
  final Set<String> selectedBuildings;
  final ValueChanged<String> onToggleBuilding;
  final VoidCallback onApplyFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9DDE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final building in buildingNames)
            InkWell(
              onTap: () => onToggleBuilding(building),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedBuildings.contains(building),
                      onChanged: (_) => onToggleBuilding(building),
                      activeColor: const Color(0xFF072F63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      building,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF213047),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApplyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF072F63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Filter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSpotCard extends StatelessWidget {
  const _FeaturedSpotCard({
    required this.title,
    required this.imagePath,
    required this.occupancyLabel,
    required this.soundLabel,
    required this.darkText,
    required this.quietGreen,
  });

  final String title;
  final String imagePath;
  final String occupancyLabel;
  final String soundLabel;
  final Color darkText;
  final Color quietGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 470,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: const Color(0xFFD6D9DF)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.58),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA218),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'RECOMMENDED FOR YOU',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w600,
                    height: 1.06,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: quietGreen),
                    const SizedBox(width: 8),
                    Text(
                      occupancyLabel,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.volume_up_outlined, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(width: 8),
                    Text(
                      soundLabel,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
}

class _CampusLoadCard extends StatelessWidget {
  const _CampusLoadCard({
    required this.darkText,
    required this.accentOrange,
    required this.quietGreen,
  });

  final Color darkText;
  final Color accentOrange;
  final Color quietGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 34),
      decoration: BoxDecoration(
        color: darkText,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Campus Load',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          _LoadBar(label: 'Main Library', value: 0.88, text: '88% Full', color: accentOrange),
          const SizedBox(height: 16),
          _LoadBar(label: 'Engineering Wing', value: 0.24, text: '24% Full', color: quietGreen),
          const SizedBox(height: 16),
          _LoadBar(label: 'Student Union', value: 0.62, text: '62% Full', color: accentOrange),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  fadeRoute(const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: accentOrange,
                foregroundColor: darkText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('View Live Map  ↗'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadBar extends StatelessWidget {
  const _LoadBar({
    required this.label,
    required this.value,
    required this.text,
    required this.color,
  });

  final String label;
  final double value;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              text,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _BadgeData {
  const _BadgeData({
    required this.label,
    required this.dotColor,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color dotColor;
  final Color background;
  final Color textColor;
}

class _SpaceItem {
  const _SpaceItem({
    required this.building,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.occupancyLabel,
    required this.soundLabel,
    required this.badgeLeft,
    required this.badgeRight,
    required this.extraTagLabel,
    required this.extraTagIcon,
  });

  final String building;
  final String title;
  final String subtitle;
  final String imagePath;
  final String occupancyLabel;
  final String soundLabel;
  final _BadgeData badgeLeft;
  final _BadgeData badgeRight;
  final String extraTagLabel;
  final IconData extraTagIcon;
}

const List<_SpaceItem> _spaceItems = [
  _SpaceItem(
    building: 'SCDI',
    title: 'SCDI - 2nd Floor\nCentral',
    subtitle: 'Level 2, East Wing • 90m away',
    imagePath: 'assets/images/scdi_tile_final.png',
    occupancyLabel: 'Low Occupancy',
    soundLabel: 'Silent Zone',
    badgeLeft: _BadgeData(
      label: 'Very Quiet',
      dotColor: Color(0xFF18B663),
      background: Color(0xFFE8F6ED),
      textColor: Color(0xFF2C8D56),
    ),
    badgeRight: _BadgeData(
      label: 'Moderately Full',
      dotColor: Color(0xFFFF9F1A),
      background: Color(0xFFF8EFE2),
      textColor: Color(0xFFA7661B),
    ),
    extraTagLabel: 'High Speed WiFi',
    extraTagIcon: Icons.wifi_rounded,
  ),
  _SpaceItem(
    building: 'Heafey',
    title: 'Heafey Law Library',
    subtitle: 'North Wing, 3rd Floor • 120m away',
    imagePath: 'assets/images/heafey_campus_tile.jpg',
    occupancyLabel: 'Low Occupancy',
    soundLabel: 'Quiet Zone',
    badgeLeft: _BadgeData(
      label: 'Very Quiet',
      dotColor: Color(0xFF18B663),
      background: Color(0xFFE8F6ED),
      textColor: Color(0xFF2C8D56),
    ),
    badgeRight: _BadgeData(
      label: 'Moderately Full',
      dotColor: Color(0xFFFF9F1A),
      background: Color(0xFFF8EFE2),
      textColor: Color(0xFFA7661B),
    ),
    extraTagLabel: 'High Speed WiFi',
    extraTagIcon: Icons.wifi_rounded,
  ),
  _SpaceItem(
    building: 'Lucas',
    title: 'Learning Commons - Pod B',
    subtitle: 'Main Level • 450m away',
    imagePath: 'assets/images/lucas_campus_tile.png',
    occupancyLabel: 'Medium Occupancy',
    soundLabel: 'Lively Zone',
    badgeLeft: _BadgeData(
      label: 'High Noise',
      dotColor: Color(0xFFD92B2B),
      background: Color(0xFFF9E9E9),
      textColor: Color(0xFFBE2C2C),
    ),
    badgeRight: _BadgeData(
      label: 'Plenty of Seating',
      dotColor: Color(0xFF18B663),
      background: Color(0xFFE8F6ED),
      textColor: Color(0xFF2C8D56),
    ),
    extraTagLabel: 'Cafe Nearby',
    extraTagIcon: Icons.local_cafe_outlined,
  ),
  _SpaceItem(
    building: 'Dowd',
    title: 'Dowd Study Hall',
    subtitle: '2nd Floor • 300m away',
    imagePath: 'assets/images/dowd_campus_tile.jpg',
    occupancyLabel: 'Low Occupancy',
    soundLabel: 'Quiet Zone',
    badgeLeft: _BadgeData(
      label: 'Quiet',
      dotColor: Color(0xFF18B663),
      background: Color(0xFFE8F6ED),
      textColor: Color(0xFF2C8D56),
    ),
    badgeRight: _BadgeData(
      label: 'Open Seats',
      dotColor: Color(0xFF18B663),
      background: Color(0xFFE8F6ED),
      textColor: Color(0xFF2C8D56),
    ),
    extraTagLabel: 'Power Outlets',
    extraTagIcon: Icons.power_outlined,
  ),
  _SpaceItem(
    building: 'Library',
    title: 'Main Library Atrium',
    subtitle: 'Ground Floor • 210m away',
    imagePath: 'assets/images/library_campus_tile.png',
    occupancyLabel: 'High Occupancy',
    soundLabel: 'Mixed Zone',
    badgeLeft: _BadgeData(
      label: 'Moderate Noise',
      dotColor: Color(0xFFFF9F1A),
      background: Color(0xFFF8EFE2),
      textColor: Color(0xFFA7661B),
    ),
    badgeRight: _BadgeData(
      label: 'Busy',
      dotColor: Color(0xFFFF9F1A),
      background: Color(0xFFF8EFE2),
      textColor: Color(0xFFA7661B),
    ),
    extraTagLabel: 'Cafe Nearby',
    extraTagIcon: Icons.local_cafe_outlined,
  ),
];

class _NearbySpotCard extends StatelessWidget {
  const _NearbySpotCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.darkText,
    required this.badgeLeft,
    required this.badgeRight,
    required this.extraTagLabel,
    required this.extraTagIcon,
    required this.chipGrey,
    required this.darkButton,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final Color darkText;
  final _BadgeData badgeLeft;
  final _BadgeData badgeRight;
  final String extraTagLabel;
  final IconData extraTagIcon;
  final Color chipGrey;
  final Color darkButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 128,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: double.infinity,
                height: 128,
                color: const Color(0xFFD9DCE3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF4A4D57),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.bookmark_border_rounded, color: const Color(0xFF4A4D57), size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusBadge(data: badgeLeft),
              const SizedBox(width: 10),
              _StatusBadge(data: badgeRight),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: chipGrey,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(extraTagIcon, size: 15, color: const Color(0xFF4A4D57)),
                const SizedBox(width: 8),
                Text(
                  extraTagLabel,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4A4D57),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  fadeRoute(const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: darkButton,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Navigate'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.data});
  final _BadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: data.dotColor),
          const SizedBox(width: 8),
          Text(
            data.label,
            style: GoogleFonts.inter(
              color: data.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
          child: child,
        ),
      ),
    );
  }
}
