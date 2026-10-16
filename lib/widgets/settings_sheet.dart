import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'permission_tile.dart';
import 'ring_section.dart';
import 'update_tile.dart';

/// Language, theme, how reminders ring (mode, sound, full screen, a test),
/// the permissions reminders need, and the update check.
Future<void> showSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SettingsSheet(),
    );

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late final AppLifecycleListener _lifecycle;
  bool? _notifications;
  bool? _exact;

  @override
  void initState() {
    super.initState();
    // Back from a system settings screen: show the new status.
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final services = AppScope.of(context).services;
    final notifications = await services.permissions.notificationsEnabled();
    final exact = await services.permissions.exactAlarmsAllowed();
    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      _exact = exact;
    });
  }

  Future<void> _testAlarm() async {
    final scope = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await scope.services.scheduler.scheduleTestAlarm();
    messenger.showSnackBar(
        SnackBar(content: Text(scope.strings.testAlarmScheduled)));
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final permissions = scope.services.permissions;
    final sectionStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: palette(context).brand);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.settings, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(s.language, style: sectionStyle),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'sr', label: Text('Srpski')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {s.localeCode},
              onSelectionChanged: (v) => scope.setLocale(v.first),
            ),
            const SizedBox(height: 16),
            Text(s.theme, style: sectionStyle),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(s.themeSystem)),
                ButtonSegment(value: ThemeMode.light, label: Text(s.themeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark)),
              ],
              selected: {scope.themeMode},
              onSelectionChanged: (v) => scope.setThemeMode(v.first),
            ),
            const SizedBox(height: 20),
            Text(s.ringSection, style: sectionStyle),
            const RingSection(),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _testAlarm,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(s.testAlarm),
              ),
            ),
            const SizedBox(height: 20),
            Text(s.notificationsSection, style: sectionStyle),
            PermissionTile(
              title: s.permNotifications,
              allowed: _notifications,
              onFix: () async {
                await permissions.requestNotifications();
                if (await permissions.notificationsEnabled()) return _refresh();
                await permissions.openNotificationSettings();
              },
            ),
            PermissionTile(
              title: s.permExactAlarms,
              allowed: _exact,
              onFix: () => permissions.requestExactAlarms().then((_) => _refresh()),
            ),
            const SizedBox(height: 4),
            Text(s.batteryHint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: palette(context).muted)),
            const Divider(height: 32),
            const UpdateTile(),
          ],
        ),
      ),
    );
  }
}
