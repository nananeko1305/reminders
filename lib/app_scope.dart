import 'package:flutter/material.dart';

import 'app_services.dart';
import 'l10n/strings.dart';

/// Exposes the current language, theme mode, localized strings and the shared
/// services to the widget tree, along with callbacks to change the settings.
class AppScope extends InheritedWidget {
  final AppStrings strings;
  final ThemeMode themeMode;
  final AppServices services;
  final ValueChanged<String> setLocale;
  final ValueChanged<ThemeMode> setThemeMode;

  const AppScope({
    super.key,
    required this.strings,
    required this.themeMode,
    required this.services,
    required this.setLocale,
    required this.setThemeMode,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      strings.localeCode != oldWidget.strings.localeCode ||
      themeMode != oldWidget.themeMode;
}
