import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/studyscape_colors.dart';
import 'space_insights_screen.dart';

/// Pixel size of [images/scdi_floor_plan.png] — update if you replace the asset so markers stay aligned.
const Size _kScdiFloorPlanImageSize = Size(1200, 900);

class _RoomMarker {
  const _RoomMarker({
    required this.id,
    required this.label,
    required this.rx,
    required this.ry,
    required this.capacityPercent,
    required this.locationLine,
    required this.noiseLevel,
    required this.noiseHint,
  });

  /// Stable id for keys / future API.
  final String id;
  final String label;

  /// 0–1 left→right, top→bottom within the floor plan image.
  final double rx;
  final double ry;

  /// Live capacity / occupancy as a percentage (0–100).
  final int capacityPercent;

  /// e.g. "Level 2, East Wing"
  final String locationLine;
  final String noiseLevel;
  final String noiseHint;
}

/// Where the image sits with [BoxFit.contain] inside the available area (for marker alignment).
Rect _displayedImageRect(Size host, Size intrinsic) {
  final scale = math.min(host.width / intrinsic.width, host.height / intrinsic.height);
  final w = intrinsic.width * scale;
  final h = intrinsic.height * scale;
  final left = (host.width - w) / 2;
  final top = (host.height - h) / 2;
  return Rect.fromLTWH(left, top, w, h);
}

/// Building detail: full floor UI for SCDI (index 3); placeholder for other campus buildings.
class BuildingDetailScreen extends StatefulWidget {
  const BuildingDetailScreen({
    super.key,
    this.buildingIndex = 3,
    this.buildingName,
  });

  final int buildingIndex;
  final String? buildingName;

  @override
  State<BuildingDetailScreen> createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends State<BuildingDetailScreen> {
  /// Selected floor for SCDI (1–4).
  int _selectedFloor = 1;

  /// Clickable occupancy markers — only on floor 2. Tune [rx]/[ry] (0–1) to match your layout image.
  List<_RoomMarker> _markersForScdiFloor(int floor) {
    if (floor != 2) return const [];
    return const [
      _RoomMarker(
        id: 'scdi_f2_a',
        label: 'Study room A',
        rx: 0.40,
        ry: 0.45,
        capacityPercent: 58,
        locationLine: 'Level 2, East Wing',
        noiseLevel: 'Quiet Zone',
        noiseHint: '',
      ),
      _RoomMarker(
        id: 'scdi_f2_b',
        label: 'Kitchen',
        rx: 0.50,
        ry: 0.30,
        capacityPercent: 72,
        locationLine: 'Level 2, East Wing',
        noiseLevel: 'Moderate Buzz',
        noiseHint: 'Headphones Rec.',
      ),
      _RoomMarker(
        id: 'scdi_f2_c',
        label: 'Study room C',
        rx: 0.72,
        ry: 0.45,
        capacityPercent: 41,
        locationLine: 'Level 2, East Wing',
        noiseLevel: 'Low Hum',
        noiseHint: '',
      ),
    ];
  }

  static const Color _sheetNavy = Color(0xFF0C2D57);
  static const Color _sheetMuted = Color(0xFF6B7280);
  static const Color _sheetCardBg = Color(0xFFF4F5F7);
  static const Color _sheetOrange = Color(0xFFEC8B46);

  /// Space to leave above the screen bottom so the sheet clears the floating bottom nav
  /// (matches `Padding` below nav + `Container` vertical padding + icon row in `_buildScdiLayout`).
  static double _roomSheetBottomReserve(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    const outerGap = 16.0;
    const containerVertical = 24.0;
    const navRow = 48.0;
    return safe + outerGap + containerVertical + navRow;
  }

  void _showOccupancySheet(BuildContext context, _RoomMarker marker) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.none,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) {
        final bottomReserve = _roomSheetBottomReserve(ctx);
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(ctx).pop(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, bottomReserve),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Material(
                    color: Colors.white,
                    elevation: 16,
                    shadowColor: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(28),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (!context.mounted) return;
                                    Navigator.of(context).push<void>(
                                      MaterialPageRoute<void>(
                                        builder: (_) => SpaceInsightsScreen(
                                          spaceId: marker.id,
                                          spaceName: marker.label,
                                          locationLine: marker.locationLine,
                                          capacityPercent: marker.capacityPercent,
                                          noiseLevel: marker.noiseLevel,
                                          noiseHint: marker.noiseHint,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Text(
                                  marker.label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: _sheetNavy,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: _sheetMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      marker.locationLine,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _sheetMuted,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Material(
                            color: _sheetOrange,
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(10),
                              child: const Center(
                                child: Icon(Icons.bookmark_outline, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _sheetCardBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CAPACITY',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                      color: _sheetMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${marker.capacityPercent}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: _sheetNavy,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _sheetCardBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: _sheetOrange,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(14),
                                        bottomLeft: const Radius.circular(14),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'NOISE LEVEL',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.8,
                                              color: _sheetMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            marker.noiseLevel,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: _sheetOrange,
                                              height: 1.25,
                                            ),
                                          ),
                                          if (marker.noiseHint.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              marker.noiseHint,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    ],
    );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buildingIndex == 3) {
      return _buildScdiLayout(context);
    }
    return _buildOtherBuildingLayout(context);
  }

  /// Layout matching the SCDI screenshot: back + StudyScape, SCDI, Floor selector, floor plan, bottom nav.
  Widget _buildScdiLayout(BuildContext context) {
    const bgColor = Color(0xFFF5F4F0);
    const navBarColor = Color(0xFFE8E6E4);
    const unselectedIconColor = Color(0xFF212B58);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header: back + centered StudyScape (match home screen spacing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: unselectedIconColor,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'StudyScape',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: const Color(0xFF212B58),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Building name + Floor label + floor selector
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.buildingName ?? 'SCDI',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Floor',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(4, (i) {
                      final floor = i + 1;
                      final selected = _selectedFloor == floor;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selectedFloor = floor),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFFE8E4E0) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$floor',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.black87 : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Floor plan + clickable markers (positions are 0–1 relative to image — tune to your layout).
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final markers = _markersForScdiFloor(_selectedFloor);
                  final rect = _displayedImageRect(
                    Size(constraints.maxWidth, constraints.maxHeight),
                    _kScdiFloorPlanImageSize,
                  );
                  const markerHit = 48.0;

                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topLeft,
                    children: [
                      Positioned(
                        left: rect.left,
                        top: rect.top,
                        width: rect.width,
                        height: rect.height,
                        child: Image.asset(
                          'images/scdi_floor_plan.png',
                          fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.map, size: 120, color: Colors.grey),
                          ),
                        ),
                      ),
                      for (var i = 0; i < markers.length; i++)
                        Positioned(
                          left: rect.left +
                              markers[i].rx * rect.width -
                              markerHit / 2 +
                              (i == 2 ? 5.0 : 0.0),
                          top: rect.top +
                              markers[i].ry * rect.height -
                              markerHit / 2 +
                              ((i == 0 || i == 2) ? 35.0 : (i == 1 ? 5.0 : 0.0)) +
                              (i == 2 ? 35.0 : 0.0) -
                              15.0,
                          width: markerHit,
                          height: markerHit,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showOccupancySheet(context, markers[i]),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 42,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      size: 34,
                                      color: StudyScapeColors.vibeOptionOrange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            // Bottom nav (match home screen)
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
                    _BuildingDetailNavItem(icon: Icons.map, isSelected: true, onTap: () => Navigator.pop(context, 0)),
                    _BuildingDetailNavItem(
                      icon: Icons.auto_awesome,
                      isSelected: false,
                      onTap: () => Navigator.pop(context, 1),
                      useTwoSparkles: true,
                    ),
                    _BuildingDetailNavItem(icon: Icons.person_outline, isSelected: false, onTap: () => Navigator.pop(context, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Other buildings: same chrome as SCDI, no floor plan yet.
  Widget _buildOtherBuildingLayout(BuildContext context) {
    const bgColor = Color(0xFFF5F4F0);
    const navBarColor = Color(0xFFE8E6E4);
    const unselectedIconColor = Color(0xFF212B58);
    final title = widget.buildingName ?? 'Building';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: unselectedIconColor,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'StudyScape',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: const Color(0xFF212B58),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Study spaces for this building are coming soon.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
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
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BuildingDetailNavItem(icon: Icons.map, isSelected: true, onTap: () => Navigator.pop(context, 0)),
                    _BuildingDetailNavItem(
                      icon: Icons.auto_awesome,
                      isSelected: false,
                      onTap: () => Navigator.pop(context, 1),
                      useTwoSparkles: true,
                    ),
                    _BuildingDetailNavItem(icon: Icons.person_outline, isSelected: false, onTap: () => Navigator.pop(context, 2)),
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

class _BuildingDetailNavItem extends StatelessWidget {
  const _BuildingDetailNavItem({
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
