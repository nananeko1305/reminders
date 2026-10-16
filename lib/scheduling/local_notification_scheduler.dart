import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';
import 'local_timezone.dart';
import 'notification_channels.dart';
import 'notification_permissions.dart';
import 'notification_request.dart';
import 'reminder_planner.dart';
import 'reminder_scheduler.dart';
import 'reminder_texts.dart';
import 'schedule_diff.dart';

/// [ReminderScheduler] on top of flutter_local_notifications. Each sync plans
/// from scratch, then only cancels and schedules the difference from what
/// Android already has, so unchanged notifications (and ringing ones) are left
/// alone. Syncs run one at a time; requests arriving meanwhile coalesce into
/// one more run with the latest events.
class LocalNotificationScheduler implements ReminderScheduler {
  LocalNotificationScheduler({
    required this._plugin,
    required this._timezone,
    required this._permissions,
    this._planner = const ReminderPlanner(),
  });

  /// Never handed out by sync, so the test alarm survives it.
  static const testAlarmId = 0;

  final FlutterLocalNotificationsPlugin _plugin;
  final LocalTimezone _timezone;
  final NotificationPermissions _permissions;
  final ReminderPlanner _planner;

  ReminderTexts? _texts;
  List<Event> _latest = const [];
  Future<void>? _running;
  bool _again = false;

  @override
  Future<void> useTexts(ReminderTexts texts) async {
    _texts = texts;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
        NotificationChannels.reminderChannel(texts));
    await android
        ?.createNotificationChannel(NotificationChannels.alarmChannel(texts));
  }

  @override
  Future<void> sync(List<Event> events) {
    _latest = events;
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _drain();
  }

  Future<void> _drain() async {
    try {
      do {
        _again = false;
        await _syncOnce(_latest);
      } while (_again);
    } finally {
      _running = null;
    }
  }

  Future<void> _syncOnce(List<Event> events) async {
    final texts = _texts;
    if (texts == null) return;
    try {
      final location = await _timezone.refresh();
      final exact = await _permissions.exactAlarmsAllowed();
      final planned = _planner.plan(events,
          now: tz.TZDateTime.now(location), body: texts.reminderBody);
      final requests = {
        for (final r in planned)
          NotificationRequest(r, exactAllowed: exact).key:
              NotificationRequest(r, exactAllowed: exact),
      };
      final pending = await _plugin.pendingNotificationRequests();
      final active = await _plugin.getActiveNotifications();
      final diff = ScheduleDiff.compute(
        wantedKeys: requests.keys,
        pending: pending.where((p) => p.id != testAlarmId).map((p) =>
            PendingNotification(p.id, NotificationPayload.decode(p.payload)?.key)),
        busyIds: {testAlarmId, ...active.map((a) => a.id).whereType<int>()},
      );
      for (final id in diff.cancel) {
        await _plugin.cancel(id: id);
      }
      for (final MapEntry(:key, value: id) in diff.schedule.entries) {
        await _schedule(id, requests[key]!, texts);
      }
    } catch (e, stack) {
      debugPrint('Reminder sync failed: $e\n$stack');
    }
  }

  Future<void> _schedule(
      int id, NotificationRequest request, ReminderTexts texts) async {
    final r = request.reminder;
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: r.title,
        body: r.body,
        scheduledDate: r.fireAt,
        notificationDetails: r.isAlarm
            ? NotificationChannels.alarm(texts)
            : NotificationChannels.reminder(texts),
        androidScheduleMode: request.scheduleMode,
        matchDateTimeComponents: request.matchDateTimeComponents,
        payload: request.payload,
      );
    } catch (e) {
      // E.g. the time passed while syncing; the next sync re-plans.
      debugPrint('Could not schedule ${request.key}: $e');
    }
  }

  @override
  Future<void> dismiss(int notificationId) =>
      _plugin.cancel(id: notificationId);

  @override
  Future<bool> isShowing(int notificationId) async {
    final active = await _plugin.getActiveNotifications();
    return active.any((a) => a.id == notificationId);
  }

  @override
  Future<void> scheduleTestAlarm() async {
    final texts = _texts;
    if (texts == null) return;
    final location = await _timezone.refresh();
    final at = tz.TZDateTime.now(location).add(const Duration(seconds: 10));
    final exact = await _permissions.exactAlarmsAllowed();
    await _plugin.zonedSchedule(
      id: testAlarmId,
      title: texts.testAlarmTitle,
      body: texts.reminderBody(null, at),
      scheduledDate: at,
      notificationDetails: NotificationChannels.alarm(texts),
      androidScheduleMode: exact
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: const NotificationPayload(key: 'test', eventId: '', alarm: true)
          .encode(),
    );
  }
}
