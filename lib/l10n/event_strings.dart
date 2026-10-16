import '../models/recurrence.dart';
import '../models/reminder_offset.dart';

/// Strings for events, the event form, the alarm and notifications. Mixed
/// into [AppStrings]; each language implements it in its own file.
mixin EventStrings {
  String get today;
  String get tomorrow;
  String get noEvents;
  String get noEventsHint;
  String get pastSection;
  String get deletePast;
  String get deletePastMsg;
  String get newEvent;
  String get editEvent;
  String get titleLabel;
  String get titleHint;
  String get titleRequired;
  String get dateLabel;
  String get timeLabel;
  String get noteLabel;
  String get noteHint;
  String get repeatLabel;
  String get remindersLabel;
  String get atEventTime;
  String get someRemindersUnavailable;
  String get startsInPast;
  String get deleteEventTitle;
  String get notificationsOffBanner;
  String get turnOn;
  String get dismissAlarm;
  String get startsNow;
  // Notification channels
  String get channelReminders;
  String get channelRemindersDescription;
  String get channelAlarm;
  String get channelAlarmDescription;
  String get channelSilent;
  String get channelSilentDescription;
  String get channelStart;
  String get channelStartDescription;
  String get testAlarmTitle;

  String deleteEventMsg(String title);
  String recurrenceLabel(Recurrence r);

  /// Chip in the form: "1 dan pre".
  String offsetLabel(ReminderOffset o);

  /// Compact form for the list: "1 dan".
  String offsetShort(ReminderOffset o);

  /// Lead-in of a reminder notification: "Sutra", "Za 1 sat".
  String offsetPhrase(ReminderOffset o);
}
