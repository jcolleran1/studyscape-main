import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/studyscape_palette.dart';
import '../widgets/scroll_top_edge_fade.dart';
import '../widgets/studyscape_colors.dart';

/// Account credentials — expandable sections mirror compact accordion UX.
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _usernameExpanded = false;
  bool _passwordExpanded = false;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: 'Guest User');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    StudyscapePalette p, {
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: p.muted.withValues(alpha: 0.75),
      ),
      filled: true,
      fillColor: p.buildingTileBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.subtleBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.subtleBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B7DD8), width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  void _toast(String message) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleUsername() {
    setState(() {
      _usernameExpanded = !_usernameExpanded;
      if (_usernameExpanded) _passwordExpanded = false;
    });
  }

  void _togglePassword() {
    setState(() {
      _passwordExpanded = !_passwordExpanded;
      if (_passwordExpanded) _usernameExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final subtitleStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: palette.muted,
      height: 1.35,
    );
    final fieldLabelStyle = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: palette.muted);

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
                          'Account Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: palette.titleInk,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ExpandableAccountCard(
                          palette: palette,
                          expanded: _usernameExpanded,
                          onToggle: _toggleUsername,
                          headerTitle: 'Change username',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This name appears on your profile.',
                                style: subtitleStyle,
                              ),
                              const SizedBox(height: 14),
                              Text('Username', style: fieldLabelStyle),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _usernameController,
                                textCapitalization: TextCapitalization.words,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: palette.titleInk,
                                ),
                                decoration: _fieldDecoration(palette, hint: 'Your display name'),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: () => _toast('Username saved (demo)'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: StudyScapeColors.vibeOptionOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Save username',
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ExpandableAccountCard(
                          palette: palette,
                          expanded: _passwordExpanded,
                          onToggle: _togglePassword,
                          headerTitle: 'Change password',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use a strong password you don\'t reuse elsewhere.',
                                style: subtitleStyle,
                              ),
                              const SizedBox(height: 14),
                              Text('Current password', style: fieldLabelStyle),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _currentPasswordController,
                                obscureText: _obscureCurrent,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: palette.titleInk,
                                ),
                                decoration: _fieldDecoration(
                                  palette,
                                  hint: '••••••••',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    color: palette.muted,
                                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text('New password', style: fieldLabelStyle),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: palette.titleInk,
                                ),
                                decoration: _fieldDecoration(
                                  palette,
                                  hint: '••••••••',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    color: palette.muted,
                                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text('Confirm new password', style: fieldLabelStyle),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: palette.titleInk,
                                ),
                                decoration: _fieldDecoration(
                                  palette,
                                  hint: '••••••••',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    color: palette.muted,
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: () => _toast('Password updated (demo)'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: StudyScapeColors.vibeOptionOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Save password',
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
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
  }
}

class _ExpandableAccountCard extends StatelessWidget {
  const _ExpandableAccountCard({
    required this.palette,
    required this.expanded,
    required this.onToggle,
    required this.headerTitle,
    required this.child,
  });

  final StudyscapePalette palette;
  final bool expanded;
  final VoidCallback onToggle;
  final String headerTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.cardRaised,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, expanded ? 16 : 14, 18, expanded ? 18 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        headerTitle,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.titleInk,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      turns: expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 26,
                        color: palette.headerBackInk.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: child,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
