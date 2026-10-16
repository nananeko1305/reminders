import '../models/reminder_offset.dart';

/// The localized texts the scheduler puts into notifications. Implemented by
/// the app strings, so scheduling does not depend on the widget layer.
abstract interface class ReminderTexts {
  String get channelReminders;
  String get channelRemindersDescription;
  String get channelAlarm;
  String get channelAlarmDescription;
  String get channelSilent;
  String get channelSilentDescription;
  String get channelStart;
  String get channelStartDescription;
  String get dismissAlarm;
  String get testAlarmTitle;

  /// Body of a reminder for an occurrence (offset null = the alarm itself).
  String reminderBody(ReminderOffset? offset, DateTime occurrence);
}
