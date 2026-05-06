import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/studyscape_palette.dart';
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

/// Hit-test bounds for a floor-plan marker (must stay in sync with pin positioning).
Rect _markerHitRect(Rect rect, List<_RoomMarker> markers, int i, double markerHit) {
  final left = rect.left + markers[i].rx * rect.width - markerHit / 2 + (i == 2 ? 5.0 : 0.0);
  final top = rect.top +
      markers[i].ry * rect.height -
      markerHit / 2 +
      ((i == 0 || i == 2) ? 35.0 : (i == 1 ? 5.0 : 0.0)) +
      (i == 2 ? 35.0 : 0.0) -
      15.0;
  return Rect.fromLTWH(left, top, markerHit, markerHit);
}

List<Rect> _otherMarkerRectsInflated(
  Rect imageRect,
  List<_RoomMarker> markers,
  int activeIndex,
  double markerHit, {
  double inflate = 8,
}) {
  final out = <Rect>[];
  for (var j = 0; j < markers.length; j++) {
    if (j == activeIndex) continue;
    out.add(_markerHitRect(imageRect, markers, j, markerHit).inflate(inflate));
  }
  return out;
}

double _popupOverlapPenalty(Rect popup, List<Rect> obstacles) {
  var penalty = 0.0;
  for (final m in obstacles) {
    final inter = popup.intersect(m);
    if (inter.width > 0 && inter.height > 0) {
      penalty += inter.width * inter.height;
    }
  }
  return penalty;
}

/// Picks [left],[top] for a fixed-size popup near [tip] without covering other pins when possible.
({double left, double top}) _pickPopupPosition({
  required Offset tip,
  required double popupWidth,
  required double popupHeight,
  required double maxW,
  required double maxH,
  required List<Rect> otherPins,
}) {
  const edgePad = 8.0;
  const gap = 12.0;

  double clampLeft(double x) => x.clamp(edgePad, maxW - popupWidth - edgePad);
  double clampTop(double y) => y.clamp(edgePad, maxH - popupHeight - edgePad);

  Rect rectAt(double l, double t) => Rect.fromLTWH(l, t, popupWidth, popupHeight);

  final candidates = <Offset>[
    Offset(tip.dx + gap, tip.dy - popupHeight * 0.45),
    Offset(tip.dx - popupWidth - gap, tip.dy - popupHeight * 0.45),
    Offset(tip.dx - popupWidth / 2, tip.dy + gap),
    Offset(tip.dx - popupWidth / 2, tip.dy - popupHeight - gap),
    Offset(tip.dx + gap, tip.dy + gap),
    Offset(tip.dx - popupWidth - gap, tip.dy + gap),
    Offset(tip.dx + gap, tip.dy - popupHeight - gap),
    Offset(tip.dx - popupWidth - gap, tip.dy - popupHeight - gap),
    Offset(maxW - popupWidth - edgePad, edgePad),
    Offset(edgePad, edgePad),
    Offset(edgePad, maxH - popupHeight - edgePad),
    Offset(maxW - popupWidth - edgePad, maxH - popupHeight - edgePad),
  ];

  double? bestLeft;
  double? bestTop;
  var bestPenalty = double.infinity;

  for (final o in candidates) {
    final l = clampLeft(o.dx);
    final t = clampTop(o.dy);
    final pr = rectAt(l, t);
    final p = _popupOverlapPenalty(pr, otherPins);
    if (p == 0) {
      return (left: l, top: t);
    }
    if (p < bestPenalty) {
      bestPenalty = p;
      bestLeft = l;
      bestTop = t;
    }
  }

  if (bestLeft != null && bestTop != null) {
    return (left: bestLeft, top: bestTop);
  }

  final fallbackL = clampLeft(tip.dx + gap);
  final fallbackT = clampTop(tip.dy - popupHeight - gap);
  return (left: fallbackL, top: fallbackT);
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

  /// Inline map popup for the marker at this index; null when hidden.
  int? _popupMarkerIndex;

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

  static const Color _sheetOrange = Color(0xFFEC8B46);

  void _openSpaceInsights(_RoomMarker marker) {
    setState(() => _popupMarkerIndex = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
  }

  Widget _buildMarkerPopup({
    required Rect imageRect,
    required List<_RoomMarker> markers,
    required BoxConstraints constraints,
    required double markerHit,
  }) {
    final idx = _popupMarkerIndex;
    if (idx == null || idx < 0 || idx >= markers.length) {
      return const SizedBox.shrink();
    }
    final marker = markers[idx];
    final hit = _markerHitRect(imageRect, markers, idx, markerHit);
    const popupWidth = 216.0;
    const approxHeight = 132.0;
    final tip = Offset(hit.center.dx, hit.bottom - 4);

    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;

    final otherPins = _otherMarkerRectsInflated(imageRect, markers, idx, markerHit);
    final pos = _pickPopupPosition(
      tip: tip,
      popupWidth: popupWidth,
      popupHeight: approxHeight,
      maxW: maxW,
      maxH: maxH,
      otherPins: otherPins,
    );
    final left = pos.left;
    final top = pos.top;
    final palette = context.palette;

    return Positioned(
      left: left,
      top: top,
      width: popupWidth,
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        color: palette.buildingTileBg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _openSpaceInsights(marker),
                      borderRadius: BorderRadius.circular(6),
                      child: Text(
                        marker.label,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: palette.titleInk,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _popupMarkerIndex = null),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.close, size: 18, color: palette.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(Icons.location_on_outlined, size: 13, color: palette.muted),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      marker.locationLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        height: 1.25,
                        color: palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${marker.capacityPercent}% · ',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.titleInk,
                      ),
                    ),
                    TextSpan(
                      text: marker.noiseLevel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _sheetOrange,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (marker.noiseHint.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  marker.noiseHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 10, color: palette.muted),
                ),
              ],
            ],
          ),
        ),
      ),
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
    final palette = context.palette;
    final bgColor = palette.pageBackground;
    final navShadowAlpha = Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: palette.headerBackInk,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ),
            ),
            // Building name + Floor label + floor selector
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.buildingName ?? 'SCDI',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: palette.titleInk,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 168,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/scdi_interior_hero.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: palette.divider,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined, color: palette.muted),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Floor',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: palette.muted,
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
                              onTap: () => setState(() {
                                _selectedFloor = floor;
                                _popupMarkerIndex = null;
                              }),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? palette.captionBand : palette.buildingTileBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: palette.subtleBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$floor',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? palette.titleInk : palette.muted,
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
                  final inner = Rect.fromLTWH(0, 0, rect.width, rect.height);
                  final popupClamp = BoxConstraints(maxWidth: rect.width, maxHeight: rect.height);
                  const markerHit = 48.0;
                  final mapOnWhite = Theme.of(context).brightness == Brightness.dark;

                  return Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: mapOnWhite ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: mapOnWhite
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: SizedBox(
                      width: rect.width,
                      height: rect.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topLeft,
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _popupMarkerIndex = null),
                              child: Image.asset(
                                'images/scdi_floor_plan.png',
                                fit: BoxFit.fill,
                                alignment: Alignment.center,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    Icons.map,
                                    size: 120,
                                    color: mapOnWhite ? const Color(0xFF9CA3AF) : palette.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...List<Widget>.generate(markers.length, (i) {
                            final hit = _markerHitRect(inner, markers, i, markerHit);
                            return Positioned(
                              left: hit.left,
                              top: hit.top,
                              width: markerHit,
                              height: markerHit,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => setState(() {
                                    _popupMarkerIndex = _popupMarkerIndex == i ? null : i;
                                  }),
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
                                              color: Colors.black.withValues(alpha: 0.35),
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
                            );
                          }),
                          _buildMarkerPopup(
                            imageRect: inner,
                            markers: markers,
                            constraints: popupClamp,
                            markerHit: markerHit,
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
            // Bottom nav (match home screen)
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
                        color: Colors.black.withValues(alpha: navShadowAlpha),
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
            ),
          ],
        ),
      ),
    );
  }

  /// Other buildings: same chrome as SCDI, no floor plan yet.
  Widget _buildOtherBuildingLayout(BuildContext context) {
    final palette = context.palette;
    final bgColor = palette.pageBackground;
    final navShadowAlpha = Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08;
    final title = widget.buildingName ?? 'Building';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: palette.headerBackInk,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: palette.titleInk,
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
                      color: palette.muted,
                      height: 1.4,
                    ),
                  ),
                ),
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
                        color: Colors.black.withValues(alpha: navShadowAlpha),
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
