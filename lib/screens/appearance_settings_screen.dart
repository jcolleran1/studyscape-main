import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/studyscape_palette.dart';
import '../theme/theme_controller_scope.dart';
import '../widgets/scroll_top_edge_fade.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  static const Color _switchBlue = Color(0xFF3B7DD8);

  bool _boldText = false;
  double _fontScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeControllerScope.of(context);
    final scalePercent = (_fontScale * 100).round();

    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        final palette = context.palette;
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final previewDark = theme.useSystemTheme ? (platformBrightness == Brightness.dark) : theme.manualIsDark;
        final bodyLabelOnSurface = palette.titleInk.withValues(alpha: 0.92);

        return Scaffold(
          backgroundColor: palette.pageBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
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
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new),
                                color: palette.headerBackInk,
                                onPressed: () => Navigator.pop(context),
                                padding: const EdgeInsets.all(12),
                                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Appearance',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: palette.titleInk,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SettingsCard(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ModePreview(
                                          label: 'Light',
                                          selected: !previewDark,
                                          onTap: () => theme.setManualTheme(dark: false),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _ModePreview(
                                          label: 'Dark',
                                          selected: previewDark,
                                          onTap: () => theme.setManualTheme(dark: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Divider(height: 1, color: palette.divider),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Automatic',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: bodyLabelOnSurface,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: theme.useSystemTheme,
                                        onChanged: (value) => theme.setUseSystemTheme(value),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _SettingsCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Text Size',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: bodyLabelOnSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$scalePercent%',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: palette.muted,
                                    ),
                                  ),
                                  Slider(
                                    value: _fontScale,
                                    min: 0.85,
                                    max: 1.4,
                                    divisions: 11,
                                    onChanged: (value) => setState(() => _fontScale = value),
                                  ),
                                  const SizedBox(height: 6),
                                  Divider(height: 1, color: palette.divider),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Bold Text',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: bodyLabelOnSurface,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _boldText,
                                        onChanged: (value) => setState(() => _boldText = value),
                                        activeThumbColor: _switchBlue,
                                        activeTrackColor: _switchBlue.withValues(alpha: 0.38),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScrollTopEdgeFade(fadeColor: palette.pageBackground),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardRaised,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _ModePreview extends StatelessWidget {
  const _ModePreview({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _switchBlue = Color(0xFF3B7DD8);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phoneBezel = isDark ? const Color(0xFF4A5160) : const Color(0xFFCACACE);
    final innerScreen = isDark ? palette.cardRaised : Colors.white.withValues(alpha: 0.88);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Align(
              child: SizedBox(
                width: 62,
                child: AspectRatio(
                  aspectRatio: 108 / 220,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: phoneBezel,
                      borderRadius: BorderRadius.circular(14),
                      border: selected ? Border.all(color: _switchBlue, width: 2) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ColoredBox(
                          color: innerScreen,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 5,
                                child: Container(
                                  height: 4,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.photo_size_select_large_outlined,
                                size: 22,
                                color: palette.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 21,
                  color: selected ? _switchBlue : palette.muted.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: selected ? _switchBlue : bodyLabelOnSurface(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color bodyLabelOnSurface(BuildContext context) {
    return context.palette.titleInk.withValues(alpha: 0.92);
  }
}
