import '../models/reminder_offset.dart';
import '../scheduling/reminder_texts.dart';
import 'checklist_strings.dart';
import 'event_strings.dart';
import 'strings_en.dart';
import 'strings_sr.dart';
import 'update_strings.dart';

/// Contract for all user-facing strings plus locale-aware formatting.
///
/// Translations live in one file per language: Serbian (Latin) in
/// [StringsSr], English in [StringsEn]. Feature strings are declared in their
/// own contracts ([EventStrings], [ChecklistStrings], [UpdateStrings]), each
/// implemented per language in its own file. Shared formatting is
/// implemented here.
abstract class AppStrings
    with EventStrings, ChecklistStrings, UpdateStrings
    implements ReminderTexts {
  const AppStrings();

  String get localeCode;
  String get appName;
  String get navEvents;
  String get navLists;
  // Common
  String get save;
  String get cancel;
  String get delete;
  String get rename;
  String get undo;
  // Settings
  String get settings;
  String get language;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get notificationsSection;
  String get permNotifications;
  String get permExactAlarms;
  String get permFullScreen;
  String get permFullScreenHint;
  String get permAllowed;
  String get permMissing;
  String get permFix;
  String get testAlarm;
  String get testAlarmScheduled;
  String get batteryHint;

  /// Monday first.
  List<String> get weekdayNames;
  List<String> get monthShortNames;

  // ---- Locale-specific phrases (implemented per language) ----

  String get nowLabel;
  String inMinutes(int minutes);
  String inHours(int hours, int minutes);
  String inDays(int days);

  /// "18. okt" / "Oct 18".
  String shortDate(DateTime d);

  /// "Subota, 18. okt 2026." / "Saturday, Oct 18, 2026".
  String longDate(DateTime d);

  // ---- Shared, language-neutral formatting ----

  String time(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

  String weekday(DateTime d) => weekdayNames[d.weekday - 1];

  /// Time left until [at], rounded up to the minute: "za 2 h 10 min".
  String countdown(DateTime at, DateTime now) {
    final minutes = (at.difference(now).inSeconds + 59) ~/ 60;
    if (minutes <= 0) return nowLabel;
    if (minutes < 60) return inMinutes(minutes);
    if (minutes < 24 * 60) return inHours(minutes ~/ 60, minutes % 60);
    return inDays(daysBetween(now, at));
  }

  /// "Danas", "Sutra" or "Subota, 18. okt".
  String dayHeader(DateTime day, DateTime now) => switch (daysBetween(now, day)) {
        0 => today,
        1 => tomorrow,
        _ => '${weekday(day)}, ${shortDate(day)}',
      };

  String progress(int done, int total) => '$done/$total';

  @override
  String reminderBody(ReminderOffset? offset, DateTime occurrence) =>
      '${offset == null ? startsNow : offsetPhrase(offset)} · ${time(occurrence)}';

  /// Calendar days from [from] to [to], DST-proof.
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    return (b.difference(a).inHours / 24).round();
  }

  static AppStrings of(String code) =>
      code == 'en' ? const StringsEn() : const StringsSr();

  static String _two(int v) => v.toString().padLeft(2, '0');
}
