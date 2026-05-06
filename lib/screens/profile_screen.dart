import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'account_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'login_screen.dart';
import 'privacy_commitment_screen.dart';
import '../theme/studyscape_palette.dart';
import '../widgets/auth_light_background.dart';
import '../widgets/studyscape_colors.dart';

/// Vertical gap between major blocks on the account sheet.
const double _accountBlockSpacing = 35;

/// Full-page Profile / account: header on soft tint, sheet with activity, settings, study prefs accordion, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _displayName = 'Guest User';
  double _envSliderValue = 0.2;
  double _peopleSliderValue = 0.15;
  int _locationIndex = 2;

  double _savedEnvSliderValue = 0.2;
  double _savedPeopleSliderValue = 0.15;
  int _savedLocationIndex = 2;
  bool _justSaved = false;
  bool _studyPrefsExpanded = false;

  static const List<String> _locationOptions = ['Heafey', 'SCDI', 'Lucas', 'Dowd', 'Library'];

  bool get _hasPreferenceChanges =>
      _envSliderValue != _savedEnvSliderValue ||
      _peopleSliderValue != _savedPeopleSliderValue ||
      _locationIndex != _savedLocationIndex;

  String get _initials {
    final parts = _displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'GU';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _savePreferences() {
    setState(() {
      _savedEnvSliderValue = _envSliderValue;
      _savedPeopleSliderValue = _peopleSliderValue;
      _savedLocationIndex = _locationIndex;
      _justSaved = true;
    });
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const navReserve = 108.0;
    final navShadowAlpha = isDark ? 0.35 : 0.08;

    return Scaffold(
      backgroundColor: isDark ? palette.sheetSurface : kAuthLightScaffoldBg,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!isDark) const AuthLightHueBackground(),
            SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        const SizedBox(height: 50),
                        const SizedBox(height: 55),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE8A0C4),
                                Color(0xFFC9A0E8),
                                Color(0xFF9B8AE8),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: palette.muted,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'edit',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          _displayName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: palette.muted,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: palette.sheetSurface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(22, 30, 22, bottomSafe + navReserve),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Activity',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: palette.titleInk,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _ActivityGradientCard(),
                          const SizedBox(height: _accountBlockSpacing),
                          _SettingsGreyGroup(
                            onAccountSettings: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const AccountSettingsScreen()),
                              );
                            },
                            onPrivacy: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const PrivacyCommitmentScreen()),
                              );
                            },
                            onAppearance: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const AppearanceSettingsScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: _accountBlockSpacing),
                          _StudyPreferencesAccordion(
                            expanded: _studyPrefsExpanded,
                            onToggle: () => setState(() => _studyPrefsExpanded = !_studyPrefsExpanded),
                            hasChanges: _hasPreferenceChanges,
                            justSaved: _justSaved,
                            onSave: _hasPreferenceChanges ? _savePreferences : null,
                            envSliderValue: _envSliderValue,
                            peopleSliderValue: _peopleSliderValue,
                            locationIndex: _locationIndex,
                            locationOptions: _locationOptions,
                            onEnvChanged: (v) => setState(() {
                              _envSliderValue = v;
                              _justSaved = false;
                            }),
                            onPeopleChanged: (v) => setState(() {
                              _peopleSliderValue = v;
                              _justSaved = false;
                            }),
                            onLocationChanged: (i) => setState(() {
                              _locationIndex = i;
                              _justSaved = false;
                            }),
                          ),
                          const SizedBox(height: _accountBlockSpacing),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _logout,
                              style: FilledButton.styleFrom(
                                backgroundColor: StudyScapeColors.vibeOptionOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Logout',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 24,
              child: SizedBox(
                width: 50,
                height: 50,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Color(0xFFEC8B46), BlendMode.srcIn),
                  child: Image.asset('images/studyscape_logo_mark.png', fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: palette.navPillSurface,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, bottomSafe + 16),
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
                        _ProfileNavItem(icon: Icons.map, isSelected: false, onTap: () => Navigator.pop(context, 0)),
                        _ProfileNavItem(
                          icon: Icons.auto_awesome,
                          isSelected: false,
                          onTap: () => Navigator.pop(context, 1),
                          useTwoSparkles: true,
                        ),
                        _ProfileNavItem(icon: Icons.person_outline, isSelected: true, onTap: () {}),
                      ],
                    ),
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

class _ActivityGradientCard extends StatelessWidget {
  const _ActivityGradientCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? <Color>[
            const Color(0xFF243044),
            const Color(0xFF1C2430),
            palette.sheetSurface,
          ]
        : <Color>[
            const Color(0xFFE4F0FF),
            const Color(0xFFF0F4FA),
            palette.sheetSurface,
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
        border: Border.all(color: palette.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Frequent Study Spot',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: palette.titleInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SCDI',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGreyGroup extends StatelessWidget {
  const _SettingsGreyGroup({
    required this.onAccountSettings,
    required this.onPrivacy,
    required this.onAppearance,
  });

  final VoidCallback onAccountSettings;
  final VoidCallback onPrivacy;
  final VoidCallback onAppearance;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dividerLine = palette.divider;
    final ink = palette.titleInk;
    return Container(
      decoration: BoxDecoration(
        color: palette.settingsSectionBg,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _greySettingsRow(Icons.settings_outlined, 'Account Settings', ink, onTap: onAccountSettings),
          Divider(height: 1, thickness: 1, color: dividerLine),
          _greySettingsRow(Icons.lock_outline_rounded, 'Privacy', ink, onTap: onPrivacy),
          Divider(height: 1, thickness: 1, color: dividerLine),
          _greySettingsRow(Icons.palette_outlined, 'Display & Accessibility', ink, onTap: onAppearance),
        ],
      ),
    );
  }

  static Widget _greySettingsRow(IconData icon, String title, Color ink, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          child: Row(
            children: [
              Icon(icon, size: 20, color: ink.withValues(alpha: 0.35)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ink,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: ink.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyPreferencesAccordion extends StatelessWidget {
  const _StudyPreferencesAccordion({
    required this.expanded,
    required this.onToggle,
    required this.hasChanges,
    required this.justSaved,
    required this.onSave,
    required this.envSliderValue,
    required this.peopleSliderValue,
    required this.locationIndex,
    required this.locationOptions,
    required this.onEnvChanged,
    required this.onPeopleChanged,
    required this.onLocationChanged,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final bool hasChanges;
  final bool justSaved;
  final VoidCallback? onSave;
  final double envSliderValue;
  final double peopleSliderValue;
  final int locationIndex;
  final List<String> locationOptions;
  final ValueChanged<double> onEnvChanged;
  final ValueChanged<double> onPeopleChanged;
  final ValueChanged<int> onLocationChanged;

  static const Color _savedPillBlue = Color(0xFF3B7DD8);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkText = palette.titleInk;
    final mutedText = palette.muted;
    final gradientColors = isDark
        ? <Color>[
            const Color(0xFF2A2520),
            palette.settingsSectionBg,
            palette.sheetSurface,
          ]
        : <Color>[
            const Color(0xFFFFF2E8),
            const Color(0xFFF8F4F2),
            palette.sheetSurface,
          ];
    final borderColor = isDark ? palette.subtleBorder : const Color(0xFFF0E4DC);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Study Preferences',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ),
                      if (!hasChanges) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _savedPillBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Saved',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      if (hasChanges && !justSaved) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: StudyScapeColors.vibeOptionOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Unsaved',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: StudyScapeColors.vibeOptionOrange,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        turns: expanded ? 0.5 : 0,
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 24,
                          color: darkText.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  if (!expanded) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Sound, crowd level, and campus spot',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: mutedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Divider(height: 1, thickness: 1, color: darkText.withValues(alpha: 0.08)),
                          const SizedBox(height: 18),
                          Text(
                            'I prefer my study environment to be...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: StudyScapeColors.vibeOptionOrange,
                              inactiveTrackColor: darkText.withValues(alpha: 0.08),
                              thumbColor: StudyScapeColors.vibeOptionOrange,
                              overlayColor: WidgetStateColor.resolveWith(
                                (states) => StudyScapeColors.vibeOptionOrange.withValues(alpha: 0.18),
                              ),
                              trackHeight: 3.5,
                            ),
                            child: Slider(
                              value: envSliderValue,
                              onChanged: onEnvChanged,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'silent',
                                style: GoogleFonts.inter(fontSize: 11, color: mutedText, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'soft background noise',
                                style: GoogleFonts.inter(fontSize: 11, color: mutedText, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'busy/lively',
                                style: GoogleFonts.inter(fontSize: 11, color: mutedText, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'I prefer my study environment to have...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: StudyScapeColors.vibeOptionOrange,
                              inactiveTrackColor: darkText.withValues(alpha: 0.08),
                              thumbColor: StudyScapeColors.vibeOptionOrange,
                              trackHeight: 3.5,
                            ),
                            child: Slider(
                              value: peopleSliderValue,
                              onChanged: onPeopleChanged,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('no people', style: GoogleFonts.inter(fontSize: 10, color: mutedText, fontWeight: FontWeight.w500)),
                              Text('a few', style: GoogleFonts.inter(fontSize: 10, color: mutedText, fontWeight: FontWeight.w500)),
                              Text('moderate', style: GoogleFonts.inter(fontSize: 10, color: mutedText, fontWeight: FontWeight.w500)),
                              Text('busy', style: GoogleFonts.inter(fontSize: 10, color: mutedText, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Where do you usually like to study?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(locationOptions.length, (i) {
                            final selected = locationIndex == i;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onLocationChanged(i),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        size: 22,
                                        color: selected ? StudyScapeColors.vibeOptionOrange : mutedText,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        locationOptions[i],
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: darkText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (hasChanges) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: onSave,
                                style: FilledButton.styleFrom(
                                  backgroundColor: StudyScapeColors.vibeOptionOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Save',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                  )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  const _ProfileNavItem({
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
          decoration: isSelected && (icon == Icons.person_outline || useTwoSparkles)
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
