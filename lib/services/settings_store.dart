import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ring_mode.dart';
import '../models/ring_settings.dart';

/// Persists the user's language, theme mode and ring settings, and whether
/// the first-run permission prompt has been shown, in [SharedPreferences].
class SettingsStore {
  static const _prefLocale = 'settings_locale';
  static const _prefThemeMode = 'settings_theme_mode';
  static const _prefPermissionsAsked = 'settings_permissions_asked';
  static const _prefRingMode = 'settings_ring_mode';
  static const _prefSoundUri = 'settings_ring_sound_uri';
  static const _prefSoundTitle = 'settings_ring_sound_title';
  static const _prefFullScreen = 'settings_ring_full_screen';

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

  Future<RingSettings> loadRing() async {
    final prefs = await SharedPreferences.getInstance();
    return RingSettings(
      mode: RingMode.byName(prefs.getString(_prefRingMode)),
      sound: AlarmSound(
        uri: prefs.getString(_prefSoundUri),
        title: prefs.getString(_prefSoundTitle),
      ),
      fullScreen: prefs.getBool(_prefFullScreen) ?? true,
    );
  }

  Future<void> saveRing(RingSettings ring) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefRingMode, ring.mode.name);
    await _setOrRemove(prefs, _prefSoundUri, ring.sound.uri);
    await _setOrRemove(prefs, _prefSoundTitle, ring.sound.title);
    await prefs.setBool(_prefFullScreen, ring.fullScreen);
  }

  static Future<void> _setOrRemove(
          SharedPreferences prefs, String key, String? value) =>
      value == null ? prefs.remove(key) : prefs.setString(key, value);

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
