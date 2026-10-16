import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's language and theme-mode preferences, and whether the
/// first-run permission prompt has been shown, in [SharedPreferences].
class SettingsStore {
  static const _prefLocale = 'settings_locale';
  static const _prefThemeMode = 'settings_theme_mode';
  static const _prefPermissionsAsked = 'settings_permissions_asked';

  Future<String> loadLocale({String fallback = 'sr'}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefLocale) ?? fallback;
  }

  Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLocale, code);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return _themeModeFromString(prefs.getString(_prefThemeMode));
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, mode.name);
  }

  /// True the first time it is called, false ever after.
  Future<bool> takeFirstPermissionPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefPermissionsAsked) ?? false) return false;
    await prefs.setBool(_prefPermissionsAsked, true);
    return true;
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
