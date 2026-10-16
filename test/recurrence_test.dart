import 'package:flutter_test/flutter_test.dart';

import 'package:reminders/models/recurrence.dart';
import 'package:reminders/models/reminder_offset.dart';

void main() {
  group('occurrence', () {
    test('monthly on the 31st clamps to short months without drifting', () {
      final anchor = DateTime(2027, 1, 31, 9, 15);
      final months = List.generate(
          5, (n) => Recurrence.monthly.occurrence(anchor, n));
      expect(months, [
        DateTime(2027, 1, 31, 9, 15),
        DateTime(2027, 2, 28, 9, 15),
        DateTime(2027, 3, 31, 9, 15),
        DateTime(2027, 4, 30, 9, 15),
        DateTime(2027, 5, 31, 9, 15),
      ]);
    });

    test('monthly crosses the year boundary', () {
      expect(Recurrence.monthly.occurrence(DateTime(2026, 11, 5, 8), 3),
          DateTime(2027, 2, 5, 8));
    });

    test('daily and weekly keep the wall-clock time across DST', () {
      // Belgrade leaves summer time on 2026-10-25.
      final anchor = DateTime(2026, 10, 24, 7, 30);
      expect(Recurrence.daily.occurrence(anchor, 2), DateTime(2026, 10, 26, 7, 30));
      expect(Recurrence.weekly.occurrence(anchor, 1), DateTime(2026, 10, 31, 7, 30));
    });
  });

  group('nextFrom', () {
    final now = DateTime(2026, 10, 16, 10, 0);

    test('one-time event: itself when upcoming, null when past', () {
      expect(Recurrence.none.nextFrom(DateTime(2026, 10, 20, 9), now),
          DateTime(2026, 10, 20, 9));
      expect(Recurrence.none.nextFrom(DateTime(2026, 10, 16, 9), now), isNull);
    });

    test('daily that started earlier moves to the next day after its time', () {
      expect(Recurrence.daily.nextFrom(DateTime(2026, 10, 1, 9), now),
          DateTime(2026, 10, 17, 9));
      expect(Recurrence.daily.nextFrom(DateTime(2026, 10, 1, 11), now),
          DateTime(2026, 10, 16, 11));
    });

    test('weekly keeps the weekday', () {
      // 2026-10-05 is a Monday.
      final next = Recurrence.weekly.nextFrom(DateTime(2026, 10, 5, 18), now)!;
      expect(next, DateTime(2026, 10, 19, 18));
      expect(next.weekday, DateTime.monday);
    });

    test('monthly finds the next month', () {
      expect(Recurrence.monthly.nextFrom(DateTime(2026, 1, 31, 12), now),
          DateTime(2026, 10, 31, 12));
      expect(Recurrence.monthly.nextFrom(DateTime(2026, 1, 10, 12), now),
          DateTime(2026, 11, 10, 12));
    });

    test('a future start is its own next occurrence', () {
      expect(Recurrence.daily.nextFrom(DateTime(2026, 12, 1, 9), now),
          DateTime(2026, 12, 1, 9));
    });
  });

  test('offsets as long as the period are not allowed', () {
    expect(Recurrence.daily.allowedOffsets,
        isNot(contains(ReminderOffset.day)));
    expect(Recurrence.daily.allowedOffsets,
        isNot(contains(ReminderOffset.week)));
    expect(Recurrence.weekly.allowedOffsets,
        isNot(contains(ReminderOffset.week)));
    expect(Recurrence.weekly.allowedOffsets, contains(ReminderOffset.day));
    expect(Recurrence.monthly.allowedOffsets, ReminderOffset.values.toSet());
  });
}
