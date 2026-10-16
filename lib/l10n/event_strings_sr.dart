import '../models/recurrence.dart';
import '../models/reminder_offset.dart';
import 'event_strings.dart';

/// Serbian (Latin) event strings.
mixin EventStringsSr implements EventStrings {
  @override
  String get today => 'Danas';
  @override
  String get tomorrow => 'Sutra';
  @override
  String get noEvents => 'Nema zakazanih događaja';
  @override
  String get noEventsHint => 'Dodaj prvi sa dugmetom +';
  @override
  String get pastSection => 'Prošlo';
  @override
  String get deletePast => 'Obriši prošle';
  @override
  String get deletePastMsg => 'Obrisati sve prošle jednokratne događaje?';
  @override
  String get newEvent => 'Novi događaj';
  @override
  String get editEvent => 'Izmeni događaj';
  @override
  String get titleLabel => 'Šta imaš';
  @override
  String get titleHint => 'npr. Zubar';
  @override
  String get titleRequired => 'Upiši naziv';
  @override
  String get dateLabel => 'Datum';
  @override
  String get timeLabel => 'Vreme';
  @override
  String get noteLabel => 'Napomena';
  @override
  String get noteHint => 'Opciono';
  @override
  String get repeatLabel => 'Ponavljanje';
  @override
  String get remindersLabel => 'Podseti me';
  @override
  String get atEventTime => 'U trenutku događaja (alarm)';
  @override
  String get someRemindersUnavailable =>
      'Neki podsetnici nisu dostupni za ovo ponavljanje.';
  @override
  String get startsInPast => 'Ovo vreme je već prošlo.';
  @override
  String get deleteEventTitle => 'Obrisati događaj?';
  @override
  String get notificationsOffBanner =>
      'Notifikacije su isključene — podsetnici neće zvoniti.';
  @override
  String get turnOn => 'Uključi';
  @override
  String get dismissAlarm => 'Ugasi';
  @override
  String get startsNow => 'Počinje sada';
  @override
  String get channelReminders => 'Podsetnici';
  @override
  String get channelRemindersDescription => 'Podsetnici pre događaja';
  @override
  String get channelAlarm => 'Alarm';
  @override
  String get channelAlarmDescription => 'Zvoni u trenutku događaja';
  @override
  String get testAlarmTitle => 'Test alarm';

  @override
  String deleteEventMsg(String title) => '„$title" će biti obrisan.';

  @override
  String recurrenceLabel(Recurrence r) => switch (r) {
        Recurrence.none => 'Ne',
        Recurrence.daily => 'Dnevno',
        Recurrence.weekly => 'Nedeljno',
        Recurrence.monthly => 'Mesečno',
      };

  @override
  String offsetLabel(ReminderOffset o) => '${offsetShort(o)} pre';

  @override
  String offsetShort(ReminderOffset o) => switch (o) {
        ReminderOffset.week => '7 dana',
        ReminderOffset.day => '1 dan',
        ReminderOffset.hour => '1 h',
        ReminderOffset.halfHour => '30 min',
        ReminderOffset.tenMinutes => '10 min',
      };

  @override
  String offsetPhrase(ReminderOffset o) => switch (o) {
        ReminderOffset.week => 'Za 7 dana',
        ReminderOffset.day => 'Sutra',
        ReminderOffset.hour => 'Za 1 sat',
        ReminderOffset.halfHour => 'Za 30 minuta',
        ReminderOffset.tenMinutes => 'Za 10 minuta',
      };
}
