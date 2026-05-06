import 'package:flutter/material.dart';

/// Custom colors used across StudyScape screens (light + dark).
@immutable
class StudyscapePalette extends ThemeExtension<StudyscapePalette> {
  const StudyscapePalette({
    required this.pageBackground,
    required this.navPillSurface,
    required this.sheetSurface,
    required this.settingsSectionBg,
    required this.cardRaised,
    required this.titleInk,
    required this.muted,
    required this.divider,
    required this.wordmark,
    required this.buildingTileBg,
    required this.captionBand,
    required this.subtleBorder,
    required this.headerBackInk,
    required this.brandHeroBg,
  });

  final Color pageBackground;
  final Color navPillSurface;
  final Color sheetSurface;
  final Color settingsSectionBg;
  final Color cardRaised;
  final Color titleInk;
  final Color muted;
  final Color divider;
  final Color wordmark;
  final Color buildingTileBg;
  final Color captionBand;
  final Color subtleBorder;
  final Color headerBackInk;
  /// Large branded panels (e.g. campus load card) — dark blue in light theme.
  final Color brandHeroBg;

  static const StudyscapePalette light = StudyscapePalette(
    pageBackground: Color(0xFFF0F1F4),
    navPillSurface: Color(0xFFF6F7FA),
    sheetSurface: Color(0xFFF6F7FA),
    settingsSectionBg: Color(0xFFF0F2F6),
    cardRaised: Color(0xFFEDEDEF),
    titleInk: Color(0xFF212B58),
    muted: Color(0xFF6B6B6B),
    divider: Color(0xFFD8D9DE),
    wordmark: Color(0xFF585552),
    buildingTileBg: Colors.white,
    captionBand: Color(0xFFE4E6EC),
    subtleBorder: Color(0xFFE8ECF2),
    headerBackInk: Color(0xFF212B58),
    brandHeroBg: Color(0xFF082D5E),
  );

  static const StudyscapePalette dark = StudyscapePalette(
    pageBackground: Color(0xFF12141A),
    navPillSurface: Color(0xFF1A1E28),
    sheetSurface: Color(0xFF171A22),
    settingsSectionBg: Color(0xFF22262F),
    cardRaised: Color(0xFF262B36),
    titleInk: Color(0xFFE6E8EC),
    muted: Color(0xFF9AA3B2),
    divider: Color(0xFF353B48),
    wordmark: Color(0xFF9EA3B0),
    buildingTileBg: Color(0xFF2A303C),
    captionBand: Color(0xFF323844),
    subtleBorder: Color(0xFF3A4150),
    headerBackInk: Color(0xFFB8C0D4),
    brandHeroBg: Color(0xFF152238),
  );

  @override
  StudyscapePalette copyWith({
    Color? pageBackground,
    Color? navPillSurface,
    Color? sheetSurface,
    Color? settingsSectionBg,
    Color? cardRaised,
    Color? titleInk,
    Color? muted,
    Color? divider,
    Color? wordmark,
    Color? buildingTileBg,
    Color? captionBand,
    Color? subtleBorder,
    Color? headerBackInk,
    Color? brandHeroBg,
  }) {
    return StudyscapePalette(
      pageBackground: pageBackground ?? this.pageBackground,
      navPillSurface: navPillSurface ?? this.navPillSurface,
      sheetSurface: sheetSurface ?? this.sheetSurface,
      settingsSectionBg: settingsSectionBg ?? this.settingsSectionBg,
      cardRaised: cardRaised ?? this.cardRaised,
      titleInk: titleInk ?? this.titleInk,
      muted: muted ?? this.muted,
      divider: divider ?? this.divider,
      wordmark: wordmark ?? this.wordmark,
      buildingTileBg: buildingTileBg ?? this.buildingTileBg,
      captionBand: captionBand ?? this.captionBand,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      headerBackInk: headerBackInk ?? this.headerBackInk,
      brandHeroBg: brandHeroBg ?? this.brandHeroBg,
    );
  }

  @override
  StudyscapePalette lerp(ThemeExtension<StudyscapePalette>? other, double t) {
    if (other is! StudyscapePalette) return this;
    return StudyscapePalette(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      navPillSurface: Color.lerp(navPillSurface, other.navPillSurface, t)!,
      sheetSurface: Color.lerp(sheetSurface, other.sheetSurface, t)!,
      settingsSectionBg: Color.lerp(settingsSectionBg, other.settingsSectionBg, t)!,
      cardRaised: Color.lerp(cardRaised, other.cardRaised, t)!,
      titleInk: Color.lerp(titleInk, other.titleInk, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      wordmark: Color.lerp(wordmark, other.wordmark, t)!,
      buildingTileBg: Color.lerp(buildingTileBg, other.buildingTileBg, t)!,
      captionBand: Color.lerp(captionBand, other.captionBand, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      headerBackInk: Color.lerp(headerBackInk, other.headerBackInk, t)!,
      brandHeroBg: Color.lerp(brandHeroBg, other.brandHeroBg, t)!,
    );
  }
}

extension StudyscapePaletteX on BuildContext {
  StudyscapePalette get palette => Theme.of(this).extension<StudyscapePalette>() ?? StudyscapePalette.light;
}
