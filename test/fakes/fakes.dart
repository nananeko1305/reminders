import 'dart:async';

import 'package:flutter/material.dart';

import 'package:reminders/app_scope.dart';
import 'package:reminders/app_services.dart';
import 'package:reminders/l10n/strings.dart';
import 'package:reminders/models/event.dart';
import 'package:reminders/scheduling/notification_permissions.dart';
import 'package:reminders/scheduling/reminder_scheduler.dart';
import 'package:reminders/scheduling/reminder_texts.dart';
import 'package:reminders/services/app_data_store.dart';
import 'package:reminders/services/checklist_repository.dart';
import 'package:reminders/services/event_repository.dart';
import 'package:reminders/services/settings_store.dart';
import 'package:reminders/theme.dart';
import 'package:reminders/updates/push_service.dart';
import 'package:reminders/updates/update_checker.dart';

/// Records what the app asks of the scheduler instead of talking to Android.
class FakeReminderScheduler implements ReminderScheduler {
  final syncs = <List<String>>[];
  final dismissed = <int>[];
  ReminderTexts? texts;
  int testAlarms = 0;

  /// Event ids of the latest sync.
  List<String> get lastSync => syncs.last;

  @override
  Future<void> useTexts(ReminderTexts t) async => texts = t;

  @override
  Future<void> sync(List<Event> events) async =>
      syncs.add([for (final e in events) e.id]);

  @override
  Future<void> dismiss(int notificationId) async => dismissed.add(notificationId);

  @override
  Future<bool> isShowing(int notificationId) async => false;

  @override
  Future<void> scheduleTestAlarm() async => testAlarms++;
}

/// Everything allowed; prompts are counted.
class FakePermissions implements NotificationPermissions {
  int prompts = 0;

  @override
  Future<bool> notificationsEnabled() async => true;
  @override
  Future<bool> exactAlarmsAllowed() async => true;
  @override
  Future<void> requestNotifications() async => prompts++;
  @override
  Future<void> requestExactAlarms() async => prompts++;
  @override
  Future<void> requestFullScreen() async => prompts++;
  @override
  Future<void> openNotificationSettings() async {}
  @override
  Future<void> requestAll() async => prompts++;
}

/// Answers update checks with [result] (up to date unless set).
class FakeUpdateChecker implements UpdateChecker {
  UpdateResult result = const UpToDate();
  int checks = 0;

  @override
  Future<String> currentVersion() async => '1.0.0';

  @override
  Future<UpdateResult> check() async {
    checks++;
    return result;
  }
}

/// Release pushes on demand via [simulateRelease].
class FakePushService implements PushService {
  final _releases = StreamController<void>.broadcast();
  bool started = false;

  void simulateRelease() => _releases.add(null);

  @override
  Stream<void> get onRelease => _releases.stream;

  @override
  Future<void> start() async => started = true;
}

AppServices fakeServices({
  FakeReminderScheduler? scheduler,
  FakeUpdateChecker? updates,
  FakePushService? push,
}) {
  final s = scheduler ?? FakeReminderScheduler();
  final store = AppDataStore();
  return AppServices(
    settings: SettingsStore(),
    events: EventRepository(scheduler: s, store: store),
    checklists: ChecklistRepository(store: store),
    scheduler: s,
    permissions: FakePermissions(),
    taps: const Stream.empty(),
    updates: updates ?? FakeUpdateChecker(),
    push: push ?? FakePushService(),
  );
}

/// [child] inside the app's scope and theme, in Serbian.
Widget wrapInApp(Widget child, AppServices services) => AppScope(
      strings: AppStrings.of('sr'),
      themeMode: ThemeMode.light,
      services: services,
      setLocale: (_) {},
      setThemeMode: (_) {},
      child: MaterialApp(theme: buildLightTheme(), home: child),
    );
