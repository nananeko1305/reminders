import '../models/ring_mode.dart';
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
  String get ringSection => 'Ringing';
  @override
  String get soundLabel => 'Sound';
  @override
  String get soundDefault => 'Default alarm sound';
  @override
  String get soundPickerTitle => 'Reminder sound';
  @override
  String get fullScreenLabel => 'Full-screen alarm';
  @override
  String get fullScreenOnHint =>
      'The alarm turns the screen on, even when the phone is locked.';
  @override
  String get fullScreenOffHint =>
      'The alarm rings as a notification without turning the screen on.';
  @override
  String get fullScreenNeedsPermission =>
      'The phone does not allow it yet — tap Fix.';
  @override
  String get notificationsSection => 'Permissions';
  @override
  String get permNotifications => 'Notifications';
  @override
  String get permExactAlarms => 'Exact alarms';
  @override
  String get permAllowed => 'Allowed';
  @override
  String get permMissing => 'Not allowed';
  @override
  String get permFix => 'Fix';
  @override
  String get testAlarm => 'Try the ringing (in 10 s)';
  @override
  String get testAlarmScheduled =>
      'It rings in 10 seconds — lock the phone to try it.';
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
  String ringModeLabel(RingMode mode) => switch (mode) {
        RingMode.alarm => 'Alarm',
        RingMode.notification => 'Notification',
        RingMode.vibrate => 'Vibrate only',
      };

  @override
  String soundSubtitle(String title) => '$title · plays at the event time';

  @override
  String ringModeHint(RingMode mode) => switch (mode) {
        RingMode.alarm =>
          'Loud and repeating until you dismiss it, even over the lock screen. Earlier reminders are notifications.',
        RingMode.notification =>
          'One sound, like a message. Applies to all reminders.',
        RingMode.vibrate =>
          'No sound, just vibration. Applies to all reminders.',
      };

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
