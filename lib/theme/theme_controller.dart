import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts light / dark / system appearance.
class ThemeController extends ChangeNotifier {
  ThemeController();

  static const _keyUseSystem = 'studyscape_theme_use_system';
  static const _keyManualDark = 'studyscape_theme_manual_dark';

  bool _useSystem = false;
  bool _manualDark = false;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get useSystemTheme => _useSystem;
  bool get manualIsDark => _manualDark;

  ThemeMode get themeMode {
    if (_useSystem) return ThemeMode.system;
    return _manualDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _useSystem = prefs.getBool(_keyUseSystem) ?? false;
    _manualDark = prefs.getBool(_keyManualDark) ?? false;
    _loaded = true;
    notifyListeners();
  }

  /// Updates the UI on this frame; writes prefs in the background so taps feel instant.
  void setUseSystemTheme(bool value) {
    _useSystem = value;
    notifyListeners();
    unawaited(_persistUseSystem(value));
  }

  /// Updates the UI on this frame; writes prefs in the background.
  void setManualTheme({required bool dark}) {
    _manualDark = dark;
    _useSystem = false;
    notifyListeners();
    unawaited(_persistManualTheme(dark));
  }

  Future<void> _persistUseSystem(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyUseSystem, value);
    } catch (_) {}
  }

  Future<void> _persistManualTheme(bool dark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyUseSystem, false);
      await prefs.setBool(_keyManualDark, dark);
    } catch (_) {}
  }
}
