import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'app_services.dart';
import 'l10n/strings.dart';
import 'models/ring_settings.dart';
import 'scheduling/notification_bootstrap.dart';
import 'screens/alarm_screen.dart';
import 'screens/home_shell.dart';
import 'theme.dart';
import 'updates/update_checker.dart';
import 'widgets/update_dialog.dart';

/// Serbian with Latin script; plain 'sr' would give Cyrillic pickers.
const _serbianLatin = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

/// Root widget: owns the language / theme settings, keeps the reminder
/// schedule in sync (on start, on resume, on language change), routes alarm
/// notifications to the [AlarmScreen] and offers new app versions.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.services});

  final AppServices services;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLifecycleListener _lifecycle;
  late final StreamSubscription<NotificationTap> _taps;
  late final StreamSubscription<void> _releases;
  bool _updateDialogOpen = false;

  String _localeCode = 'sr';
  ThemeMode _themeMode = ThemeMode.system;
  RingSettings _ring = const RingSettings();

  AppServices get _services => widget.services;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _services.events.resync);
    _taps = _services.taps.listen(_openTap);
    // A release push (received in the foreground or tapped) re-runs the
    // update check, which then shows the download dialog.
    _releases = _services.push.onRelease.listen((_) => _checkForUpdate());
    _services.push.start();
    _start();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _taps.cancel();
    _releases.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final settings = _services.settings;
    final locale = await settings.loadLocale();
    final themeMode = await settings.loadThemeMode();
    final ring = await settings.loadRing();
    if (!mounted) return;
    setState(() {
      _localeCode = locale;
      _themeMode = themeMode;
      _ring = ring;
    });

    final launch = _services.launchTap;
    if (launch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openTap(launch));
    }
    await _services.scheduler.useTexts(AppStrings.of(locale));
    _services.scheduler.useRing(ring);
    await _services.events.resync();

    // Ask once, and not on top of a ringing alarm.
    if (launch != null) return;
    if (await settings.takeFirstPermissionPrompt()) {
      await _services.permissions.requestAll();
      await _services.events.resync(); // exact alarms may now be allowed
    }
    await _checkForUpdate();
  }

  /// On app start and on release pushes; silent when offline or already
  /// up to date, and never stacks a second dialog on an open one.
  Future<void> _checkForUpdate() async {
    if (_updateDialogOpen) return;
    final result = await _services.updates.check();
    if (result is! UpdateAvailable || _updateDialogOpen) return;
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    _updateDialogOpen = true;
    await showUpdateDialog(context, result);
    _updateDialogOpen = false;
  }

  /// Opens the alarm screen for a still-ringing alarm. Anything else just
  /// opens the app, so the lock-screen exception is dropped right away.
  Future<void> _openTap(NotificationTap tap) async {
    final payload = tap.payload;
    final ringing = payload != null &&
        payload.alarm &&
        await _services.scheduler.isShowing(tap.id);
    final navigator = _navigatorKey.currentState;
    if (!ringing || navigator == null) {
      await _services.lockScreen.release();
      return;
    }
    final event = await _services.events.byId(payload.eventId);
    await navigator.push(MaterialPageRoute<void>(
      builder: (_) => AlarmScreen(
        notificationId: tap.id,
        event: event,
        closeAppWhenDone: tap.coldStart,
      ),
    ));
  }

  Future<void> _setLocale(String code) async {
    setState(() => _localeCode = code);
    await _services.settings.saveLocale(code);
    await _services.scheduler.useTexts(AppStrings.of(code));
    await _services.events.resync();
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await _services.settings.saveThemeMode(mode);
  }

  /// Saves the settings and reschedules everything already scheduled to
  /// ring the new way.
  Future<void> _setRing(RingSettings ring) async {
    setState(() => _ring = ring);
    await _services.settings.saveRing(ring);
    _services.scheduler.useRing(ring);
    await _services.events.resync();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(_localeCode);
    return AppScope(
      strings: strings,
      themeMode: _themeMode,
      ring: _ring,
      services: _services,
      setLocale: _setLocale,
      setThemeMode: _setThemeMode,
      setRing: _setRing,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: strings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: _themeMode,
        locale: _localeCode == 'en' ? const Locale('en') : _serbianLatin,
        supportedLocales: const [_serbianLatin, Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}
