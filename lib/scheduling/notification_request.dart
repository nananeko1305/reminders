import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/ring_mode.dart';
import '../models/ring_settings.dart';
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

/// How a notification presents itself; each maps to its own Android channel.
enum NotificationStyle {
  /// Loud and repeating on the alarm stream; full-screen over the lock screen
  /// unless turned off.
  alarm,

  /// A normal notification with one sound.
  sound,

  /// Vibration only, no sound.
  vibrate,
}

/// A [PlannedReminder] ready for the OS: with its delivery mode and how it
/// rings. Both are part of the key, so granting exact-alarm access or
/// changing the ring settings reschedules everything accordingly.
class NotificationRequest {
  final PlannedReminder reminder;
  final bool exactAllowed;
  final RingSettings ring;

  const NotificationRequest(
    this.reminder, {
    required this.exactAllowed,
    this.ring = const RingSettings(),
  });

  String get key => [
        reminder.key,
        exactAllowed ? 'exact' : 'inexact',
        ring.mode.name,
        if (atEventTime && style != NotificationStyle.vibrate)
          ring.sound.uri ?? 'default-sound',
        if (style == NotificationStyle.alarm && !ring.fullScreen) 'no-full-screen',
      ].join('|');

  /// The reminder at the event time is the one that uses the chosen sound.
  bool get atEventTime => reminder.isAlarm;

  NotificationStyle get style => switch (ring.mode) {
        RingMode.vibrate => NotificationStyle.vibrate,
        RingMode.notification => NotificationStyle.sound,
        RingMode.alarm =>
          atEventTime ? NotificationStyle.alarm : NotificationStyle.sound,
      };

  /// Only a full-screen alarm takes over the screen (see MainActivity.kt and
  /// the alarm screen); otherwise a tap just opens the app.
  bool get takesOverScreen =>
      style == NotificationStyle.alarm && ring.fullScreen;

  /// The alarm uses the alarm-clock mode, which Android delivers on time even
  /// in deep idle; everything else only needs to be exact.
  AndroidScheduleMode get scheduleMode {
    if (!exactAllowed) return AndroidScheduleMode.inexactAllowWhileIdle;
    return style == NotificationStyle.alarm
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
        alarm: takesOverScreen,
      ).encode();
}
