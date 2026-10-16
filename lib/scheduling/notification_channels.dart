import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/ring_settings.dart';
import 'notification_request.dart';
import 'reminder_texts.dart';

/// Android channels and per-notification details. Android freezes a channel's
/// sound and importance once it exists, so the ids carry a version, and the
/// channels that play the chosen sound carry a hash of it: a new sound means
/// a new channel, and the old one is deleted ([isStale]).
class NotificationChannels {
  static const reminderChannelId = 'reminders_v1';
  static const alarmChannelId = 'alarm_v1';
  static const silentChannelId = 'silent_v1';
  static const smallIcon = 'ic_stat_reminder';
  static const dismissActionId = 'dismiss';

  /// Notification.FLAG_INSISTENT: the sound repeats until the notification is
  /// dismissed or the shade is opened.
  static const _insistentFlag = 4;
  static const _defaultAlarmUri = 'content://settings/system/alarm_alert';

  /// The alarm channel for [sound]; the phone's default alarm keeps the
  /// original id so existing installs keep their channel.
  static String alarmIdFor(AlarmSound sound) =>
      sound.isDefault ? alarmChannelId : 'alarm_${_hash(sound.uri!)}';

  /// The event-start channel of notification mode; the default sound needs
  /// none and uses the reminders channel.
  static String? startIdFor(AlarmSound sound) =>
      sound.isDefault ? null : 'start_${_hash(sound.uri!)}';

  /// A sound-specific channel left over from an earlier choice.
  static bool isStale(String id, AlarmSound current) =>
      (id.startsWith('alarm_') || id.startsWith('start_')) &&
      id != alarmIdFor(current) &&
      id != startIdFor(current);

  /// Every channel the current settings use, created up front so the system
  /// settings list them before the first reminder fires.
  static List<AndroidNotificationChannel> all(
          ReminderTexts t, AlarmSound sound) =>
      [
        AndroidNotificationChannel(
          reminderChannelId,
          t.channelReminders,
          description: t.channelRemindersDescription,
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          alarmIdFor(sound),
          t.channelAlarm,
          description: t.channelAlarmDescription,
          importance: Importance.max,
          sound: _alarmSound(sound),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        AndroidNotificationChannel(
          silentChannelId,
          t.channelSilent,
          description: t.channelSilentDescription,
          importance: Importance.high,
          playSound: false,
        ),
        if (startIdFor(sound) case final id?)
          AndroidNotificationChannel(
            id,
            t.channelStart,
            description: t.channelStartDescription,
            importance: Importance.high,
            sound: UriAndroidNotificationSound(sound.uri!),
          ),
      ];

  static NotificationDetails forRequest(NotificationRequest r, ReminderTexts t) {
    final sound = r.ring.sound;
    return switch (r.style) {
      NotificationStyle.alarm => _alarm(t, sound, fullScreen: r.ring.fullScreen),
      NotificationStyle.sound when r.atEventTime && !sound.isDefault =>
        _start(t, sound),
      NotificationStyle.sound => _reminder(t),
      NotificationStyle.vibrate => _silent(t),
    };
  }

  static NotificationDetails _reminder(ReminderTexts t) => NotificationDetails(
        android: AndroidNotificationDetails(
          reminderChannelId,
          t.channelReminders,
          channelDescription: t.channelRemindersDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          icon: smallIcon,
        ),
      );

  /// Notification mode at the event time, with the chosen sound once.
  static NotificationDetails _start(ReminderTexts t, AlarmSound sound) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          startIdFor(sound)!,
          t.channelStart,
          channelDescription: t.channelStartDescription,
          importance: Importance.high,
          priority: Priority.high,
          sound: UriAndroidNotificationSound(sound.uri!),
          category: AndroidNotificationCategory.reminder,
          icon: smallIcon,
        ),
      );

  /// Heads-up and vibration, no sound.
  static NotificationDetails _silent(ReminderTexts t) => NotificationDetails(
        android: AndroidNotificationDetails(
          silentChannelId,
          t.channelSilent,
          channelDescription: t.channelSilentDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          category: AndroidNotificationCategory.reminder,
          icon: smallIcon,
        ),
      );

  /// Loud, repeating, on the alarm stream (so silent mode does not mute it),
  /// and full-screen over the lock screen when [fullScreen].
  static NotificationDetails _alarm(ReminderTexts t, AlarmSound sound,
          {required bool fullScreen}) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          alarmIdFor(sound),
          t.channelAlarm,
          channelDescription: t.channelAlarmDescription,
          importance: Importance.max,
          priority: Priority.max,
          sound: _alarmSound(sound),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          additionalFlags: Int32List.fromList([_insistentFlag]),
          fullScreenIntent: fullScreen,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          icon: smallIcon,
          actions: [
            AndroidNotificationAction(dismissActionId, t.dismissAlarm),
          ],
        ),
      );

  static UriAndroidNotificationSound _alarmSound(AlarmSound sound) =>
      UriAndroidNotificationSound(sound.uri ?? _defaultAlarmUri);

  /// FNV-1a: stable across runs and devices, unlike String.hashCode.
  static String _hash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
