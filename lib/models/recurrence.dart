import 'dart:math';

import 'reminder_offset.dart';

/// How an event repeats. Occurrences are computed from the original start
/// (the anchor) by calendar arithmetic, so they keep their wall-clock time
/// across DST and a monthly event on the 31st falls on the last day of shorter
/// months without drifting.
enum Recurrence {
  none,
  daily,
  weekly,
  monthly;

  /// Reminder offsets that make sense for this recurrence: an offset as long
  /// as the period itself would just duplicate the previous occurrence.
  Set<ReminderOffset> get allowedOffsets => switch (this) {
        none || monthly => ReminderOffset.values.toSet(),
        daily => {
            ReminderOffset.hour,
            ReminderOffset.halfHour,
            ReminderOffset.tenMinutes,
          },
        weekly => {
            ReminderOffset.day,
            ReminderOffset.hour,
            ReminderOffset.halfHour,
            ReminderOffset.tenMinutes,
          },
      };

  /// The [n]th occurrence of an event starting at [anchor] (n = 0 is the
  /// anchor itself). A one-time event only has n = 0.
  DateTime occurrence(DateTime anchor, int n) => switch (this) {
        none => anchor,
        daily => _shiftDays(anchor, n),
        weekly => _shiftDays(anchor, 7 * n),
        monthly => _shiftMonths(anchor, n),
      };

  /// Index of the first occurrence at or after [from], or null when a
  /// one-time event is already in the past.
  int? firstIndexFrom(DateTime anchor, DateTime from) {
    if (this == none) return anchor.isBefore(from) ? null : 0;
    // Start just below the estimate (DST can shorten a day) and walk forward.
    var n = max(0, _estimate(anchor, from) - 1);
    while (occurrence(anchor, n).isBefore(from)) {
      n++;
    }
    return n;
  }

  /// The first occurrence at or after [from], or null if there is none.
  DateTime? nextFrom(DateTime anchor, DateTime from) {
    final n = firstIndexFrom(anchor, from);
    return n == null ? null : occurrence(anchor, n);
  }

  int _estimate(DateTime anchor, DateTime from) {
    if (!from.isAfter(anchor)) return 0;
    return switch (this) {
      none => 0,
      daily => from.difference(anchor).inDays,
      weekly => from.difference(anchor).inDays ~/ 7,
      monthly =>
        (from.year - anchor.year) * 12 + from.month - anchor.month - 1,
    };
  }

  static DateTime _shiftDays(DateTime a, int days) =>
      DateTime(a.year, a.month, a.day + days, a.hour, a.minute);

  static DateTime _shiftMonths(DateTime a, int months) {
    final month = DateTime(a.year, a.month + months);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(
        month.year, month.month, min(a.day, lastDay), a.hour, a.minute);
  }

  static Recurrence byName(String? name) =>
      values.firstWhere((r) => r.name == name, orElse: () => none);
}
