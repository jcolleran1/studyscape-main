import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'privacy_commitment_screen.dart';
import '../widgets/studyscape_colors.dart';

/// Full-page Profile screen: avatar, Activity, Study Preferences (sliders + location), Settings, bottom nav.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _envSliderValue = 0.2; // silent
  double _peopleSliderValue = 0.15; // no people
  int _locationIndex = 2; // Lucas

  double _savedEnvSliderValue = 0.2;
  double _savedPeopleSliderValue = 0.15;
  int _savedLocationIndex = 2;
  bool _justSaved = false;

  static const List<String> _locationOptions = ['Heafey', 'SCDI', 'Lucas', 'Dowd', 'Library'];

  bool get _hasPreferenceChanges =>
      _envSliderValue != _savedEnvSliderValue ||
      _peopleSliderValue != _savedPeopleSliderValue ||
      _locationIndex != _savedLocationIndex;

  void _savePreferences() {
    setState(() {
      _savedEnvSliderValue = _envSliderValue;
      _savedPeopleSliderValue = _peopleSliderValue;
      _savedLocationIndex = _locationIndex;
      _justSaved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF5F4F0);
    const cardColor = Color(0xFFE8E6E4);
    const navBarColor = Color(0xFFE8E6E4);
    const darkText = Color(0xFF212B58);

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
                color: darkText,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Profile: circle with initials, edit, name
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8D7DA),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'SA',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'edit',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sanaa Ahmed',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Activity
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Activity',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _activityRow('Most Frequent Study Spot', 'SCDI'),
                          const SizedBox(height: 12),
                          _activityRow('Most Active Study Time', 'Afternoon'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Study Preferences
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Study Preferences',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        if (_hasPreferenceChanges || _justSaved)
                          TextButton(
                            onPressed: _hasPreferenceChanges ? _savePreferences : null,
                            style: TextButton.styleFrom(
                              backgroundColor: _justSaved ? Colors.grey : StudyScapeColors.vibeOptionOrange,
                              foregroundColor: const Color(0xFFEC8B46),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _justSaved ? 'Saved' : 'Save',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I prefer my study environment to be...',
                            style: GoogleFonts.poppins(fontSize: 14, color: darkText, fontWeight: FontWeight.w500),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: StudyScapeColors.vibeOptionOrange,
                              thumbColor: StudyScapeColors.vibeOptionOrange,
                              overlayColor: StudyScapeColors.vibeOptionOrange.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _envSliderValue,
                              onChanged: (v) => setState(() {
                                _envSliderValue = v;
                                _justSaved = false;
                              }),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('silent', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                              Text('soft background noise', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                              Text('busy/lively', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'I prefer my study environment to have...',
                            style: GoogleFonts.poppins(fontSize: 14, color: darkText, fontWeight: FontWeight.w500),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: StudyScapeColors.vibeOptionOrange,
                              thumbColor: StudyScapeColors.vibeOptionOrange,
                            ),
                            child: Slider(
                              value: _peopleSliderValue,
                              onChanged: (v) => setState(() {
                                _peopleSliderValue = v;
                                _justSaved = false;
                              }),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('no people', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                              Text('a few people', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                              Text('moderate', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                              Text('busy', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Where do you usually like to study?',
                            style: GoogleFonts.poppins(fontSize: 14, color: darkText, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(_locationOptions.length, (i) {
                            return RadioListTile<int>(
                              value: i,
                              groupValue: _locationIndex,
                              onChanged: (v) => setState(() {
                                _locationIndex = v ?? 0;
                                _justSaved = false;
                              }),
                              activeColor: StudyScapeColors.vibeOptionOrange,
                              title: Text(
                                _locationOptions[i],
                                style: GoogleFonts.poppins(fontSize: 14, color: darkText),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Settings
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _settingsTile(
                            context,
                            Icons.settings,
                            'Account Settings',
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                          _settingsTile(
                            context,
                            Icons.lock_outline,
                            'Privacy',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PrivacyCommitmentScreen()),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                          _settingsTile(
                            context,
                            Icons.palette_outlined,
                            'Appearance',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom nav
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
          ],
        ),
      ),
    );
  }

  Widget _activityRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF212B58)),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF212B58)),
        ),
      ],
    );
  }

  Widget _settingsTile(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: Colors.grey.shade700),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF212B58))),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
      onTap: onTap,
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
          decoration: isSelected && icon == Icons.person_outline
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
