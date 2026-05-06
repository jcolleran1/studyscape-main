import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/studyscape_colors.dart';
import 'studyscape_palette.dart';

ThemeData buildStudyscapeTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? StudyscapePalette.dark : StudyscapePalette.light;

  final baseScheme = ColorScheme.fromSeed(
    seedColor: StudyScapeColors.primaryBlue,
    brightness: brightness,
    primary: StudyScapeColors.vibeOptionOrange,
    surface: palette.pageBackground,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    extensions: [palette],
    scaffoldBackgroundColor: palette.pageBackground,
    colorScheme: baseScheme.copyWith(
      surface: palette.pageBackground,
      onSurface: palette.titleInk,
      surfaceContainerHighest: palette.cardRaised,
    ),
    dividerTheme: DividerThemeData(color: palette.divider),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.pageBackground,
      foregroundColor: palette.titleInk,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF2C3140) : const Color(0xFF323232),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFF3B7DD8);
        return isDark ? Colors.grey.shade400 : Colors.grey.shade100;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFF3B7DD8).withValues(alpha: 0.38);
        return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: StudyScapeColors.vibeOptionOrange,
      inactiveTrackColor: palette.divider,
      thumbColor: StudyScapeColors.vibeOptionOrange,
      overlayColor: StudyScapeColors.vibeOptionOrange.withValues(alpha: 0.2),
    ),
  );
}
