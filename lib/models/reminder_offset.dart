import 'package:timezone/timezone.dart' as tz;

/// How long before an occurrence a reminder fires. The alarm at the event time
/// itself is always on and is not an offset.
enum ReminderOffset {
  week(days: 7),
  day(days: 1),
  hour(minutes: 60),
  halfHour(minutes: 30),
  tenMinutes(minutes: 10);

  const ReminderOffset({this.days = 0, this.minutes = 0});

  final int days;
  final int minutes;

  /// Fire time for an occurrence at [at]. Whole days use calendar arithmetic so
  /// the reminder keeps its wall-clock time across a DST change; hours and
  /// minutes are real elapsed time.
  tz.TZDateTime before(tz.TZDateTime at) => days > 0
      ? tz.TZDateTime(at.location, at.year, at.month, at.day - days, at.hour,
          at.minute)
      : at.subtract(Duration(minutes: minutes));

  static ReminderOffset? byName(String name) {
    for (final o in values) {
      if (o.name == name) return o;
    }
    return null;
  }
}
