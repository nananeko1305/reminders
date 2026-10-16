import '../models/recurrence.dart';
import '../models/reminder_offset.dart';
import 'event_strings.dart';

/// English event strings.
mixin EventStringsEn implements EventStrings {
  @override
  String get today => 'Today';
  @override
  String get tomorrow => 'Tomorrow';
  @override
  String get noEvents => 'Nothing scheduled';
  @override
  String get noEventsHint => 'Add your first event with +';
  @override
  String get pastSection => 'Past';
  @override
  String get deletePast => 'Delete past';
  @override
  String get deletePastMsg => 'Delete all past one-time events?';
  @override
  String get newEvent => 'New event';
  @override
  String get editEvent => 'Edit event';
  @override
  String get titleLabel => 'What is it';
  @override
  String get titleHint => 'e.g. Dentist';
  @override
  String get titleRequired => 'Enter a title';
  @override
  String get dateLabel => 'Date';
  @override
  String get timeLabel => 'Time';
  @override
  String get noteLabel => 'Note';
  @override
  String get noteHint => 'Optional';
  @override
  String get repeatLabel => 'Repeat';
  @override
  String get remindersLabel => 'Remind me';
  @override
  String get atEventTime => 'At the event time (alarm)';
  @override
  String get someRemindersUnavailable =>
      'Some reminders are not available for this repeat.';
  @override
  String get startsInPast => 'This time has already passed.';
  @override
  String get deleteEventTitle => 'Delete event?';
  @override
  String get notificationsOffBanner =>
      'Notifications are off — reminders will not ring.';
  @override
  String get turnOn => 'Turn on';
  @override
  String get dismissAlarm => 'Dismiss';
  @override
  String get startsNow => 'Starting now';
  @override
  String get channelReminders => 'Reminders';
  @override
  String get channelRemindersDescription => 'Reminders before events';
  @override
  String get channelAlarm => 'Alarm';
  @override
  String get channelAlarmDescription => 'Rings when an event starts';
  @override
  String get testAlarmTitle => 'Test alarm';

  @override
  String deleteEventMsg(String title) => '"$title" will be deleted.';

  @override
  String recurrenceLabel(Recurrence r) => switch (r) {
        Recurrence.none => 'No',
        Recurrence.daily => 'Daily',
        Recurrence.weekly => 'Weekly',
        Recurrence.monthly => 'Monthly',
      };

  @override
  String offsetLabel(ReminderOffset o) => '${offsetShort(o)} before';

  @override
  String offsetShort(ReminderOffset o) => switch (o) {
        ReminderOffset.week => '7 days',
        ReminderOffset.day => '1 day',
        ReminderOffset.hour => '1 h',
        ReminderOffset.halfHour => '30 min',
        ReminderOffset.tenMinutes => '10 min',
      };

  @override
  String offsetPhrase(ReminderOffset o) => switch (o) {
        ReminderOffset.week => 'In 7 days',
        ReminderOffset.day => 'Tomorrow',
        ReminderOffset.hour => 'In 1 hour',
        ReminderOffset.halfHour => 'In 30 minutes',
        ReminderOffset.tenMinutes => 'In 10 minutes',
      };
}
