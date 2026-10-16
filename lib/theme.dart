import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Semantic colors for the app, resolved per light/dark theme via a
/// [ThemeExtension]. Access with [palette].
///
/// Concept: a calm evening blue for the calendar, a warm coral for the alarm.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color brand; // primary
  final Color alarm; // the at-event-time alarm, past/delete accents
  final Color muted; // checked items, secondary text
  final Color cardSurface;
  final Color cardBorder;
  final Color bannerBg; // notifications-off warning
  final Color bannerFg;

  const AppPalette({
    required this.brand,
    required this.alarm,
    required this.muted,
    required this.cardSurface,
    required this.cardBorder,
    required this.bannerBg,
    required this.bannerFg,
  });

  static const AppPalette light = AppPalette(
    brand: Color(0xFF3F51B5),
    alarm: Color(0xFFD9534F),
    muted: Color(0xFF8A8F98),
    cardSurface: Color(0xFFFFFFFF),
    cardBorder: Color(0x1A3F51B5),
    bannerBg: Color(0x1FD9534F),
    bannerFg: Color(0xFFA33A36),
  );

  static const AppPalette dark = AppPalette(
    brand: Color(0xFF8C9EFF),
    alarm: Color(0xFFFF8A80),
    muted: Color(0xFF7A808A),
    cardSurface: Color(0xFF181B26),
    cardBorder: Color(0x268C9EFF),
    bannerBg: Color(0x33FF8A80),
    bannerFg: Color(0xFFFFB3AD),
  );

  @override
  AppPalette copyWith({
    Color? brand,
    Color? alarm,
    Color? muted,
    Color? cardSurface,
    Color? cardBorder,
    Color? bannerBg,
    Color? bannerFg,
  }) =>
      AppPalette(
        brand: brand ?? this.brand,
        alarm: alarm ?? this.alarm,
        muted: muted ?? this.muted,
        cardSurface: cardSurface ?? this.cardSurface,
        cardBorder: cardBorder ?? this.cardBorder,
        bannerBg: bannerBg ?? this.bannerBg,
        bannerFg: bannerFg ?? this.bannerFg,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brand: Color.lerp(brand, other.brand, t)!,
      alarm: Color.lerp(alarm, other.alarm, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      bannerBg: Color.lerp(bannerBg, other.bannerBg, t)!,
      bannerFg: Color.lerp(bannerFg, other.bannerFg, t)!,
    );
  }
}

/// Shortcut to read the palette from a [BuildContext].
AppPalette palette(BuildContext context) =>
    Theme.of(context).extension<AppPalette>()!;

ThemeData buildLightTheme() => _build(
      AppPalette.light,
      Brightness.light,
      scaffold: const Color(0xFFF3F4FA),
      ink: const Color(0xFF1F2440),
    );

ThemeData buildDarkTheme() => _build(
      AppPalette.dark,
      Brightness.dark,
      scaffold: const Color(0xFF0F111A),
      ink: const Color(0xFFE6E8F5),
    );

/// Status and navigation bar icons: dark on the light theme, light on the
/// dark theme, over transparent bars. The navigation icons are set too:
/// SystemUiOverlayStyle.dark assumes a black navigation bar and would make
/// them light, invisible over the light theme.
SystemUiOverlayStyle overlayStyle(Brightness brightness) {
  final icons =
      brightness == Brightness.dark ? Brightness.light : Brightness.dark;
  return (brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark)
      .copyWith(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: icons,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: icons,
  );
}

ThemeData _build(AppPalette p, Brightness brightness,
    {required Color scaffold, required Color ink}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.brand,
    brightness: brightness,
    primary: p.brand,
    error: p.alarm,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffold,
    extensions: [p],
    // The bar takes the page colour, so the status bar above it needs dark
    // icons on the light theme; Flutter would infer light ones from a dark
    // bar, so the style is set explicitly from the theme.
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      surfaceTintColor: Colors.transparent,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: overlayStyle(brightness),
    ),
    cardTheme: CardThemeData(
      color: p.cardSurface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.cardBorder),
      ),
    ),
  );
}
