import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_offset.dart';

/// How the OS repeats a scheduled notification on its own.
enum RepeatKind { none, daily, weekly }

/// One notification the app wants scheduled: the reminder [offset] of an
/// event (null = the alarm at the event time) firing at [fireAt], optionally
/// repeated by the OS.
class PlannedReminder {
  final String eventId;
  final ReminderOffset? offset;
  final tz.TZDateTime fireAt;
  final RepeatKind repeat;
  final String title;
  final String body;

  const PlannedReminder({
    required this.eventId,
    required this.offset,
    required this.fireAt,
    required this.title,
    required this.body,
    this.repeat = RepeatKind.none,
  });

  bool get isAlarm => offset == null;

  /// Identity used to diff against what is already scheduled. A repeating
  /// series is identified by its time of day (and weekday) rather than its
  /// next date, so it stays the same series from one day to the next.
  String get key {
    final hhmm = '${fireAt.hour}:${fireAt.minute}';
    final when = switch (repeat) {
      RepeatKind.none => fireAt.toIso8601String(),
      RepeatKind.daily => hhmm,
      RepeatKind.weekly => '${fireAt.weekday}@$hhmm',
    };
    return [
      eventId,
      offset?.name ?? 'at',
      repeat.name,
      when,
      fireAt.location.name,
      title,
      body,
    ].join('|');
  }
}
