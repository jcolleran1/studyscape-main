import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/studyscape_palette.dart';
import '../utils/app_routes.dart';
import '../widgets/scroll_top_edge_fade.dart';
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
    required this.loadFraction,
    this.imagePath,
  });

  final int index;
  final String name;
  final String subtitle;
  /// 0–1 occupancy for the mini load bar (demo data until live feeds exist).
  final double loadFraction;
  final String? imagePath;
}

const List<_BuildingCardData> _buildingCards = [
  _BuildingCardData(
    index: 0,
    name: 'Dowd',
    subtitle: 'Quiet corners',
    loadFraction: 0.32,
    imagePath: 'assets/images/dowd_campus_tile.jpg',
  ),
  _BuildingCardData(
    index: 1,
    name: 'Lucas',
    subtitle: 'Bright study areas',
    loadFraction: 0.58,
    imagePath: 'assets/images/lucas_campus_tile.png',
  ),
  _BuildingCardData(
    index: 2,
    name: 'Heafey',
    subtitle: 'Collaborative vibe',
    loadFraction: 0.71,
    imagePath: 'assets/images/heafey_campus_tile.jpg',
  ),
  _BuildingCardData(
    index: 3,
    name: 'SCDI',
    subtitle: 'Live occupancy',
    loadFraction: 0.45,
    imagePath: 'assets/images/scdi_tile_final.png',
  ),
  _BuildingCardData(
    index: 4,
    name: 'Library',
    subtitle: 'Deep focus zones',
    loadFraction: 0.88,
    imagePath: 'assets/images/library_campus_tile.png',
  ),
];

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0; // 0 = map, 1 = recommendations, 2 = profile

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
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const SizedBox(height: 46),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    /// Same bottom inset as [RecommendedScreen] so the last row clears the nav area.
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 136),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tileGap = 16.0;
                        final tileSize = (constraints.maxWidth - tileGap) / 2;
                        final rowExtent = tileSize + _SquareBuildingTile._captionStripHeight;
                        final ink = palette.titleInk;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Campus Locations',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap a location to see real time insights.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: ink.withValues(alpha: 0.62),
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
                  ScrollTopEdgeFade(fadeColor: palette.pageBackground),
                ],
              ),
            ),
            ColoredBox(
              color: palette.navPillSurface,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: palette.navPillSurface,
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
                      isSelected: _selectedNavIndex == 1,
                      onTap: () {
                        setState(() => _selectedNavIndex = 1);
                        Navigator.push<int?>(
                          context,
                          fadeRoute<int?>(const RecommendedScreen()),
                        ).then((value) {
                          if (!mounted) return;
                          if (value != null && value >= 0 && value <= 2) {
                            setState(() => _selectedNavIndex = value);
                          } else {
                            setState(() => _selectedNavIndex = 0);
                          }
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
                            setState(() => _selectedNavIndex = 1);
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
            ),
          ],
        ),
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
  static const double _captionStripHeight = 106;

  static const Color _loadGreen = Color(0xFF18B663);
  static const Color _loadAmber = Color(0xFFE6A23C);
  static const Color _loadRed = Color(0xFFDC3545);

  static Color _loadColor(double fraction) {
    final v = fraction.clamp(0.0, 1.0);
    if (v < 0.42) return _loadGreen;
    if (v < 0.70) return _loadAmber;
    return _loadRed;
  }

  final _BuildingCardData data;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ink = palette.titleInk;
    final hasImage = (data.imagePath?.isNotEmpty ?? false);
    final loadValue = data.loadFraction.clamp(0.0, 1.0);
    final loadBarColor = _loadColor(loadValue);
    final loadPercent = (loadValue * 100).round();

    return SizedBox(
      width: size,
      child: Material(
        color: palette.buildingTileBg,
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
                            color: ink.withValues(alpha: 0.65),
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
                                      color: ink.withValues(alpha: 0.65),
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
                                        color: ink.withValues(alpha: 0.7),
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
                  decoration: BoxDecoration(
                    color: palette.captionBand,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: ink.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 11),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Load',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: ink.withValues(alpha: 0.45),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$loadPercent% full',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: loadBarColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                minHeight: 5,
                                value: loadValue,
                                valueColor: AlwaysStoppedAnimation<Color>(loadBarColor),
                                backgroundColor: ink.withValues(alpha: 0.08),
                              ),
                            ),
                          ],
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

  static const Color _selectedOrange = Color(0xFFD4A574);

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? StudyScapeColors.vibeOptionOrange : context.palette.titleInk;
    final child = Icon(icon, color: iconColor, size: 26);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: isSelected && (icon == Icons.map || useTwoSparkles)
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
