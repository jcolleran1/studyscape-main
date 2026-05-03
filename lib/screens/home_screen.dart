import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_routes.dart';
import '../widgets/studyscape_colors.dart';
import 'building_detail_screen.dart';
import 'profile_screen.dart';
import 'recommended_screen.dart';

/// Home screen: five square building cards with image slots.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.autoShowRecommendations = false});

  /// When true, the recommended spots tab overlay auto-opens after ~1.5 seconds.
  final bool autoShowRecommendations;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _BuildingCardData {
  const _BuildingCardData({
    required this.index,
    required this.name,
    required this.subtitle,
    this.imagePath,
  });

  final int index;
  final String name;
  final String subtitle;
  final String? imagePath;
}

const List<_BuildingCardData> _buildingCards = [
  _BuildingCardData(
    index: 0,
    name: 'Dowd',
    subtitle: 'Quiet corners',
    imagePath: 'assets/images/dowd_campus_tile.jpg',
  ),
  _BuildingCardData(
    index: 1,
    name: 'Lucas',
    subtitle: 'Bright study areas',
    imagePath: 'assets/images/lucas_campus_tile.png',
  ),
  _BuildingCardData(
    index: 2,
    name: 'Heafey',
    subtitle: 'Collaborative vibe',
    imagePath: 'assets/images/heafey_campus_tile.jpg',
  ),
  _BuildingCardData(
    index: 3,
    name: 'SCDI',
    subtitle: 'Live occupancy',
    imagePath: 'assets/images/scdi_tile_final.png',
  ),
  _BuildingCardData(
    index: 4,
    name: 'Library',
    subtitle: 'Deep focus zones',
    imagePath: 'assets/images/library_campus_tile.png',
  ),
];

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0; // 0 = map, 1 = recommendations, 2 = profile

  /// Screen behind cards: ultra-soft radial grey (same vibe as app).
  static const Color _mapBgRadialCenter = Color(0xFFFEFEFE);
  static const Color _mapBgRadialEdge = Color(0xFFFAFAFC);
  static const Color _buildingColor = Color(0xFF212B58);

  @override
  void initState() {
    super.initState();
    if (widget.autoShowRecommendations) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _selectedNavIndex = 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final navOffset = bottomSafe + 108;

    return Scaffold(
      backgroundColor: _mapBgRadialCenter,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 2.15,
                  colors: [
                    _mapBgRadialCenter,
                    Color.lerp(_mapBgRadialCenter, _mapBgRadialEdge, 0.22)!,
                    Color.lerp(_mapBgRadialCenter, _mapBgRadialEdge, 0.48)!,
                    Color.lerp(_mapBgRadialCenter, _mapBgRadialEdge, 0.76)!,
                    _mapBgRadialEdge,
                  ],
                  stops: const [0.0, 0.35, 0.62, 0.86, 1.0],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 40, 24, navOffset),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tileGap = 16.0;
                      final tileSize = (constraints.maxWidth - tileGap) / 2;
                      final rowExtent = tileSize + _SquareBuildingTile._captionStripHeight;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'StudyScape',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: const Color(0xFF585552).withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            'Campus spaces',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: _buildingColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap a square to explore building insights.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _buildingColor.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 6, // 2 columns x 3 rows
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: tileGap,
                              mainAxisSpacing: tileGap,
                              mainAxisExtent: rowExtent,
                            ),
                            itemBuilder: (context, index) {
                              if (index >= _buildingCards.length) {
                                return const SizedBox.shrink();
                              }
                              final building = _buildingCards[index];
                              return Align(
                                alignment: Alignment.topCenter,
                                child: _SquareBuildingTile(
                                  data: building,
                                  size: tileSize,
                                  onTap: () => _openBuilding(building),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Bottom nav: Map (active), Recommended, Profile
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E6E4),
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
                  _NavItem(icon: Icons.map, isSelected: _selectedNavIndex == 0, onTap: () => setState(() => _selectedNavIndex = 0)),
                  _NavItem(
                    icon: Icons.auto_awesome,
                    isSelected: false,
                    onTap: () {
                      Navigator.push<int?>(
                        context,
                        fadeRoute<int?>(const RecommendedScreen()),
                      ).then((value) {
                        if (!mounted) return;
                        if (value != null && value == 2) {
                          Navigator.push<int?>(
                            context,
                            fadeRoute<int?>(const ProfileScreen()),
                          ).then((value) {
                            if (!mounted) return;
                            if (value != null && value == 1) {
                              Navigator.push<int?>(
                                context,
                                fadeRoute<int?>(const RecommendedScreen()),
                              );
                            }
                          });
                        }
                      });
                    },
                    useTwoSparkles: true,
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    isSelected: _selectedNavIndex == 2,
                    onTap: () {
                      Navigator.push<int?>(
                        context,
                        fadeRoute<int?>(const ProfileScreen()),
                      ).then((value) {
                        if (!mounted) return;
                        if (value != null && value == 1) {
                          Navigator.push<int?>(
                            context,
                            fadeRoute<int?>(const RecommendedScreen()),
                          );
                        } else if (value != null && value >= 0 && value <= 2) {
                          setState(() => _selectedNavIndex = value);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openBuilding(_BuildingCardData data) {
    Navigator.push<int?>(
      context,
      fadeRoute<int?>(
        BuildingDetailScreen(
          buildingIndex: data.index,
          buildingName: data.name,
        ),
      ),
    ).then((value) {
      if (!mounted) return;
      if (value != null && value >= 0 && value <= 2) {
        setState(() => _selectedNavIndex = value);
      }
    });
  }
}

class _SquareBuildingTile extends StatelessWidget {
  const _SquareBuildingTile({
    required this.data,
    required this.size,
    required this.onTap,
  });

  /// Caption pane height — matches grid `mainAxisExtent - tileSize` so titles/subtitles align across cards.
  static const double _captionStripHeight = 88;

  final _BuildingCardData data;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = (data.imagePath?.isNotEmpty ?? false);

    return SizedBox(
      width: size,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  gradient: !hasImage
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE8EEF5), Color(0xFFDCE4EE)],
                        )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: !hasImage
                      ? Center(
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: const Color(0xFF212B58).withValues(alpha: 0.65),
                            size: 28,
                          ),
                        )
                      : Image.asset(
                          data.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      color: const Color(0xFF212B58).withValues(alpha: 0.65),
                                      size: 24,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data.imagePath ?? 'image missing',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        color: const Color(0xFF212B58).withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              SizedBox(
                height: _captionStripHeight,
                width: size,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F1F4),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: const Color(0xFF212B58),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              data.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                                color: const Color(0xFF212B58).withValues(alpha: 0.65),
                              ),
                            ),
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
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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
          decoration: isSelected && icon == Icons.map
              ? BoxDecoration(
                  color: _selectedOrange.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}
