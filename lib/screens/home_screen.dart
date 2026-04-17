import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_routes.dart';
import '../widgets/studyscape_colors.dart';
import 'building_detail_screen.dart';
import 'profile_screen.dart';
import 'recommended_screen.dart';

/// Home screen: campus map, tap buildings to explore; bottom nav to Recommended and Profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.autoShowRecommendations = false});

  /// When true, the recommended spots tab overlay auto-opens after ~1.5 seconds.
  final bool autoShowRecommendations;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Simple polygon shape for a building on the map.
class _BuildingShape {
  const _BuildingShape(this.offsets);
  final List<Offset> offsets;
}

/// Five building polygons matching Campus Map image (relative 0–1).
/// Aligned for BoxFit.cover so image fills map area.
const List<_BuildingShape> _buildingShapes = [
  // 1. Top-left: long horizontal, stepped/serrated bottom (~top 5–20%, left 5–40%)
  _BuildingShape([
    Offset(0.05, 0.08), Offset(0.40, 0.08), Offset(0.40, 0.20), Offset(0.35, 0.20), Offset(0.35, 0.16),
    Offset(0.28, 0.16), Offset(0.28, 0.20), Offset(0.22, 0.20), Offset(0.22, 0.16), Offset(0.12, 0.16),
    Offset(0.12, 0.20), Offset(0.05, 0.20),
  ]),
  // 2. Top-right: large block, concave arc lower-left (~top 5–35%, right 40%)
  _BuildingShape([
    Offset(0.55, 0.06), Offset(0.96, 0.06), Offset(0.96, 0.35), Offset(0.80, 0.32), Offset(0.68, 0.35),
    Offset(0.55, 0.35),
  ]),
  // 3. Mid-left: tall I/T shape (Heafey) — shifted right to sit on footprint
  _BuildingShape([
    Offset(0.19, 0.32), Offset(0.33, 0.32), Offset(0.33, 0.38), Offset(0.39, 0.38), Offset(0.39, 0.44),
    Offset(0.33, 0.44), Offset(0.33, 0.60), Offset(0.19, 0.60), Offset(0.19, 0.52), Offset(0.13, 0.52),
    Offset(0.13, 0.48), Offset(0.19, 0.48),
  ]),
  // 4. Mid-right: L/C blocky with left cut-out (~35–60% from top, right 30%)
  _BuildingShape([
    Offset(0.58, 0.36), Offset(0.92, 0.36), Offset(0.92, 0.40), Offset(0.88, 0.40), Offset(0.88, 0.44),
    Offset(0.92, 0.44), Offset(0.92, 0.52), Offset(0.62, 0.52), Offset(0.62, 0.56), Offset(0.92, 0.56),
    Offset(0.92, 0.62), Offset(0.58, 0.62), Offset(0.58, 0.56), Offset(0.62, 0.56), Offset(0.62, 0.52),
    Offset(0.58, 0.52), Offset(0.58, 0.40),
  ]),
  // 5. Bottom-right: staircase/terraced bottom-left (~60–95% from top, right 40%)
  _BuildingShape([
    // Start slightly lower than SCDI's bottom edge (0.62) to keep a tappable gap.
    Offset(0.55, 0.64), Offset(0.96, 0.64), Offset(0.96, 0.96), Offset(0.90, 0.96), Offset(0.90, 0.90),
    Offset(0.84, 0.90), Offset(0.84, 0.84), Offset(0.78, 0.84), Offset(0.78, 0.78), Offset(0.55, 0.78),
  ]),
];

/// Labels for each campus map zone (index 3 is SCDI).
const List<String> _buildingNames = [
  'Dowd',
  'Lucas',
  'Heafey',
  'SCDI',
  'Library',
];

/// Map image scale within available map canvas (>1.0 extends past padded bounds, centered).
const double _mapScale = 1.14;

/// Hand-tuned label positions on the map image (normalized 0–1), aligned with each tap zone.
/// Index order matches [_buildingNames] / [_buildingShapes].
const List<Offset> _buildingLabelAnchors = [
  Offset(0.24, 0.12), // top-left footprint (label: Dowd)
  Offset(0.65, 0.17), // top-right footprint (label: Lucas)
  Offset(0.23, 0.52), // mid-left footprint (label: Heafey)
  Offset(0.66, 0.48), // SCDI — inner courtyard (not polygon centroid)
  Offset(0.70, 0.92), // bottom-right footprint (label: Library), placed off-building
];

/// Normalized (0–1) position for the building name label on the map image.
Offset _labelAnchorForBuilding(int index) {
  return _buildingLabelAnchors[index];
}

/// Ray-cast point-in-polygon test (relative coordinates 0–1).
bool _pointInPolygon(Offset p, List<Offset> polygon) {
  if (polygon.length < 3) return false;
  bool inside = false;
  final n = polygon.length;
  for (int i = 0, j = n - 1; i < n; j = i++) {
    if (((polygon[i].dy > p.dy) != (polygon[j].dy > p.dy)) &&
        (p.dx < (polygon[j].dx - polygon[i].dx) * (p.dy - polygon[i].dy) / (polygon[j].dy - polygon[i].dy) + polygon[i].dx)) {
      inside = !inside;
    }
  }
  return inside;
}

/// Aspect ratio of the campus map image (width/height). Use 1.0 for square.
const double _campusMapAspectRatio = 1.0;

/// Hit-test order: polygons listed before SCDI (index 3) win when taps fall in overlapping areas.
const List<int> _mapTapOrder = [0, 1, 2, 4, 3];

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0; // 0 = map, 1 = recommendations, 2 = profile

  /// Screen behind the map: ultra-soft radial grey (symmetric on all sides).
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
    return Scaffold(
      backgroundColor: _mapBgRadialCenter,
      body: Stack(
        children: [
          // Map view: centered campus map with margins, landing zones for 5 buildings
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
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'StudyScape',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: _buildingColor,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.06),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Map + building labels + taps (single layout so everything aligns)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        final padL = 8.0;
                        final padR = 8.0;
                        final padT = 46.0;
                        final padB = 8.0;
                        final contentW = w - padL - padR;
                        final contentH = h - padT - padB;
                        var imageW = _campusMapAspectRatio >= contentW / contentH
                            ? contentW
                            : contentH * _campusMapAspectRatio;
                        var imageH = imageW / _campusMapAspectRatio;
                        imageW *= _mapScale;
                        imageH *= _mapScale;
                        final left = padL + (contentW - imageW) / 2;
                        final top = padT + (contentH - imageH) / 2;

                        void onMapTap(Offset local) {
                          final ix = local.dx / imageW;
                          final iy = local.dy / imageH;
                          if (ix < 0 || ix > 1 || iy < 0 || iy > 1) return;
                          final pt = Offset(ix, iy);
                          for (final i in _mapTapOrder) {
                            if (_pointInPolygon(pt, _buildingShapes[i].offsets)) {
                              Navigator.push<int?>(
                                context,
                                fadeRoute<int?>(
                                  BuildingDetailScreen(
                                    buildingIndex: i,
                                    buildingName: _buildingNames[i],
                                  ),
                                ),
                              ).then((value) {
                                if (mounted && value != null && value >= 0 && value <= 2) {
                                  setState(() => _selectedNavIndex = value);
                                }
                              });
                              return;
                            }
                          }
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: left,
                              top: top,
                              width: imageW,
                              height: imageH,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                  child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned.fill(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset(
                                            'images/campus_map.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTapUp: (details) => onMapTap(details.localPosition),
                                          child: const ColoredBox(color: Colors.transparent),
                                        ),
                                      ),
                                      ...List<Widget>.generate(_buildingShapes.length, (i) {
                                        final c = _labelAnchorForBuilding(i);
                                        return Align(
                                          alignment: Alignment(2 * c.dx - 1, 2 * c.dy - 1),
                                          child: Transform.translate(
                                            offset: i == 4 ? const Offset(-45, 20) : Offset.zero,
                                            child: IgnorePointer(
                                              child: Padding(
                                                padding: const EdgeInsets.all(4),
                                                child: _BuildingNameChip(
                                                  name: _buildingNames[i],
                                                  color: _buildingColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: MediaQuery.of(context).padding.bottom + 100,
                              child: Center(
                                child: Text(
                                  'Tap a building to explore',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: _buildingColor.withOpacity(0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom nav: Map (active = orange circle), two sparkles (Recommended), Profile
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
                    color: Colors.black.withOpacity(0.08),
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
}

class _BuildingNameChip extends StatelessWidget {
  const _BuildingNameChip({
    required this.name,
    required this.color,
  });
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.25,
        shadows: [
          Shadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(0, 0),
            blurRadius: 4,
          ),
        ],
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
  static const Color _selectedOrange = Color(0xFFD4A574); // light orange-brown circle

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
                  color: _selectedOrange.withOpacity(0.35),
                  shape: BoxShape.circle,
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}
