import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'reminder_texts.dart';

/// Android channels and per-notification details. Android freezes a channel's
/// sound and importance once it exists, so the ids carry a version: changing
/// either means bumping the id.
class NotificationChannels {
  static const reminderChannelId = 'reminders_v1';
  static const alarmChannelId = 'alarm_v1';
  static const smallIcon = 'ic_stat_reminder';
  static const dismissActionId = 'dismiss';

  /// Notification.FLAG_INSISTENT: the sound repeats until the notification is
  /// dismissed or the shade is opened.
  static const _insistentFlag = 4;
  static const _alarmSound =
      UriAndroidNotificationSound('content://settings/system/alarm_alert');

  static AndroidNotificationChannel reminderChannel(ReminderTexts t) =>
      AndroidNotificationChannel(
        reminderChannelId,
        t.channelReminders,
        description: t.channelRemindersDescription,
        importance: Importance.high,
      );

  static AndroidNotificationChannel alarmChannel(ReminderTexts t) =>
      AndroidNotificationChannel(
        alarmChannelId,
        t.channelAlarm,
        description: t.channelAlarmDescription,
        importance: Importance.max,
        sound: _alarmSound,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

  static NotificationDetails reminder(ReminderTexts t) => NotificationDetails(
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

  /// Loud, repeating, on the alarm stream (so silent mode does not mute it),
  /// and full-screen over the lock screen.
  static NotificationDetails alarm(ReminderTexts t) => NotificationDetails(
        android: AndroidNotificationDetails(
          alarmChannelId,
          t.channelAlarm,
          channelDescription: t.channelAlarmDescription,
          importance: Importance.max,
          priority: Priority.max,
          sound: _alarmSound,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          additionalFlags: Int32List.fromList([_insistentFlag]),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          icon: smallIcon,
          actions: [
            AndroidNotificationAction(dismissActionId, t.dismissAlarm),
          ],
        ),
      );
}
