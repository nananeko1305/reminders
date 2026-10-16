import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:reminders/models/event.dart';
import 'package:reminders/models/recurrence.dart';
import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/scheduling/planned_reminder.dart';
import 'package:reminders/scheduling/reminder_planner.dart';

late tz.Location belgrade;

tz.TZDateTime at(int y, int m, int d, [int h = 0, int min = 0]) =>
    tz.TZDateTime(belgrade, y, m, d, h, min);

List<PlannedReminder> plan(Event event, tz.TZDateTime now) =>
    const ReminderPlanner().plan([event], now: now, body: (_, _) => '');

Event daily(DateTime start) => Event(
    id: 'e', title: 'x', start: start, recurrence: Recurrence.daily);

void main() {
  // Before any group body runs, since those build times eagerly.
  tzdata.initializeTimeZones();
  belgrade = tz.getLocation('Europe/Belgrade');

  group('future start', () {
    final now = at(2026, 10, 16, 12);

    test('daily starting in two weeks is planned as one-shots from its start', () {
      final planned = plan(daily(DateTime(2026, 11, 1, 9)), now);
      expect(planned, hasLength(14));
      expect(planned.every((p) => p.repeat == RepeatKind.none), isTrue);
      expect(planned.first.fireAt, at(2026, 11, 1, 9));
      expect(planned.last.fireAt, at(2026, 11, 14, 9));
    });

    test('daily starting at the next matching time can repeat right away', () {
      final planned = plan(daily(DateTime(2026, 10, 17, 9)), now);
      expect(planned.single.repeat, RepeatKind.daily);
      expect(planned.single.fireAt, at(2026, 10, 17, 9));
    });

    test('daily starting the day after next would fire a day early, so no repeat', () {
      final planned = plan(daily(DateTime(2026, 10, 18, 9)), now);
      expect(planned.first.repeat, RepeatKind.none);
      expect(planned.first.fireAt, at(2026, 10, 18, 9));
    });

    test('weekly starting within the coming week repeats right away', () {
      // Friday now; the event starts next Tuesday.
      final event = Event(
          id: 'e',
          title: 'x',
          start: DateTime(2026, 10, 20, 9),
          recurrence: Recurrence.weekly);
      expect(plan(event, now).single.repeat, RepeatKind.weekly);
    });
  });

  group('DST (Belgrade leaves summer time on 2026-10-25)', () {
    final now = at(2026, 10, 16, 12);

    test('"1 day before" keeps the wall-clock time across the change', () {
      final event = Event(
          id: 'e',
          title: 'x',
          start: DateTime(2026, 10, 26, 9),
          reminders: {ReminderOffset.day});
      final fire = plan(event, now)
          .firstWhere((p) => p.offset == ReminderOffset.day)
          .fireAt;
      expect([fire.month, fire.day, fire.hour], [10, 25, 9]);
      expect(fire.timeZoneOffset, const Duration(hours: 1));
    });

    test('"7 days before" lands in summer time at the same hour', () {
      final event = Event(
          id: 'e',
          title: 'x',
          start: DateTime(2026, 10, 30, 9),
          reminders: {ReminderOffset.week});
      final fire = plan(event, now)
          .firstWhere((p) => p.offset == ReminderOffset.week)
          .fireAt;
      expect([fire.month, fire.day, fire.hour], [10, 23, 9]);
      expect(fire.timeZoneOffset, const Duration(hours: 2));
    });
  });

  group('osFirstFire mirrors the plugin', () {
    final now = at(2026, 10, 16, 12); // Friday

    test('daily: today if the time is still ahead, otherwise tomorrow', () {
      expect(ReminderPlanner.osFirstFire(at(2026, 12, 1, 15), now, RepeatKind.daily),
          at(2026, 10, 16, 15));
      expect(ReminderPlanner.osFirstFire(at(2026, 12, 1, 9), now, RepeatKind.daily),
          at(2026, 10, 17, 9));
    });

    test('weekly: the next matching weekday, ignoring the date', () {
      // 2026-12-01 is a Tuesday.
      expect(ReminderPlanner.osFirstFire(at(2026, 12, 1, 9), now, RepeatKind.weekly),
          at(2026, 10, 20, 9));
    });
  });
}
