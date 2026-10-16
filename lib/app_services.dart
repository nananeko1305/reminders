import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'scheduling/alarm_lock_screen.dart';
import 'scheduling/local_notification_scheduler.dart';
import 'scheduling/local_timezone.dart';
import 'scheduling/notification_bootstrap.dart';
import 'scheduling/notification_permissions.dart';
import 'scheduling/reminder_scheduler.dart';
import 'services/app_data_store.dart';
import 'services/checklist_repository.dart';
import 'services/event_repository.dart';
import 'services/settings_store.dart';
import 'updates/push_service.dart';
import 'updates/update_checker.dart';

/// Composition root: one instance of every service, shared through
/// [AppScope]. Tests build it with fakes via the default constructor.
class AppServices {
  final SettingsStore settings;
  final EventRepository events;
  final ChecklistRepository checklists;
  final ReminderScheduler scheduler;
  final NotificationPermissions permissions;
  final AlarmLockScreen lockScreen;
  final UpdateChecker updates;
  final PushService push;

  /// Notification taps while the app runs.
  final Stream<NotificationTap> taps;

  /// The notification that launched the app, if any.
  final NotificationTap? launchTap;

  const AppServices({
    required this.settings,
    required this.events,
    required this.checklists,
    required this.scheduler,
    required this.permissions,
    required this.taps,
    required this.updates,
    required this.push,
    this.lockScreen = const AlarmLockScreen(),
    this.launchTap,
  });

  /// Wires the real Android-backed services.
  static Future<AppServices> create() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final bootstrap = NotificationBootstrap(plugin);
    final launchTap = await bootstrap.initialize();
    final permissions = NotificationPermissions(plugin);
    final scheduler = LocalNotificationScheduler(
      plugin: plugin,
      timezone: LocalTimezone(),
      permissions: permissions,
    );
    final store = AppDataStore();
    return AppServices(
      settings: SettingsStore(),
      events: EventRepository(scheduler: scheduler, store: store),
      checklists: ChecklistRepository(store: store),
      scheduler: scheduler,
      permissions: permissions,
      taps: bootstrap.taps,
      updates: UpdateChecker(),
      push: PushService(),
      launchTap: launchTap,
    );
  }
}
