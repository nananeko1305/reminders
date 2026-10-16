import 'checklist_strings_en.dart';
import 'event_strings_en.dart';
import 'strings.dart';
import 'update_strings_en.dart';

/// English translations.
class StringsEn extends AppStrings
    with EventStringsEn, ChecklistStringsEn, UpdateStringsEn {
  const StringsEn();

  @override
  String get localeCode => 'en';
  @override
  String get appName => 'Reminders';
  @override
  String get navEvents => 'Reminders';
  @override
  String get navLists => 'Lists';
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get rename => 'Rename';
  @override
  String get undo => 'Undo';
  @override
  String get settings => 'Settings';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get notificationsSection => 'Ringing and notifications';
  @override
  String get permNotifications => 'Notifications';
  @override
  String get permExactAlarms => 'Exact alarms';
  @override
  String get permFullScreen => 'Full-screen alarm';
  @override
  String get permFullScreenHint =>
      'Lets the alarm turn the screen on while the phone is locked (Android 14+).';
  @override
  String get permAllowed => 'Allowed';
  @override
  String get permMissing => 'Not allowed';
  @override
  String get permFix => 'Fix';
  @override
  String get testAlarm => 'Test alarm (in 10 s)';
  @override
  String get testAlarmScheduled =>
      'The alarm rings in 10 seconds — lock the phone to try it.';
  @override
  String get batteryHint =>
      'If the alarm is late or silent, turn off battery optimization for this app.';

  @override
  List<String> get weekdayNames => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

  @override
  List<String> get monthShortNames => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

  @override
  String get nowLabel => 'now';

  @override
  String inMinutes(int minutes) => 'in $minutes min';

  @override
  String inHours(int hours, int minutes) =>
      minutes == 0 ? 'in $hours h' : 'in $hours h $minutes min';

  @override
  String inDays(int days) => days == 1 ? 'in 1 day' : 'in $days days';

  @override
  String shortDate(DateTime d) => '${monthShortNames[d.month - 1]} ${d.day}';

  @override
  String longDate(DateTime d) => '${weekday(d)}, ${shortDate(d)}, ${d.year}';
}
