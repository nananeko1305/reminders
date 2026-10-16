import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'planned_reminder.dart';

/// Data carried inside a scheduled notification: the diff key, the event and
/// whether it is the alarm. Short JSON keys keep the payload small; the Kotlin
/// side (MainActivity.kt) reads `a` to decide on showing over the lock screen.
class NotificationPayload {
  final String key;
  final String eventId;
  final bool alarm;

  const NotificationPayload({
    required this.key,
    required this.eventId,
    required this.alarm,
  });

  String encode() => jsonEncode({'k': key, 'e': eventId, 'a': alarm});

  /// Null for empty or foreign payloads (e.g. scheduled by an older build).
  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPayload(
        key: json['k'] as String,
        eventId: json['e'] as String,
        alarm: json['a'] as bool,
      );
    } catch (_) {
      return null;
    }
  }
}

/// A [PlannedReminder] ready for the OS: with its delivery mode. The mode is
/// part of the key so granting exact-alarm access later reschedules
/// everything exactly.
class NotificationRequest {
  final PlannedReminder reminder;
  final bool exactAllowed;

  const NotificationRequest(this.reminder, {required this.exactAllowed});

  String get key => '${reminder.key}|${exactAllowed ? 'exact' : 'inexact'}';

  /// The alarm uses the alarm-clock mode, which Android delivers on time even
  /// in deep idle; earlier reminders only need to be exact.
  AndroidScheduleMode get scheduleMode {
    if (!exactAllowed) return AndroidScheduleMode.inexactAllowWhileIdle;
    return reminder.isAlarm
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.exactAllowWhileIdle;
  }

  DateTimeComponents? get matchDateTimeComponents => switch (reminder.repeat) {
        RepeatKind.none => null,
        RepeatKind.daily => DateTimeComponents.time,
        RepeatKind.weekly => DateTimeComponents.dayOfWeekAndTime,
      };

  String get payload => NotificationPayload(
        key: key,
        eventId: reminder.eventId,
        alarm: reminder.isAlarm,
      ).encode();
}
