import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:reminders/models/event.dart';
import 'package:reminders/models/recurrence.dart';
import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/scheduling/planned_reminder.dart';
import 'package:reminders/scheduling/reminder_planner.dart';

late tz.Location belgrade;

tz.TZDateTime at(int y, int m, int d, [int h = 0, int min = 0, int s = 0]) =>
    tz.TZDateTime(belgrade, y, m, d, h, min, s);

String body(ReminderOffset? offset, DateTime occurrence) =>
    '${offset?.name ?? 'now'} ${occurrence.toIso8601String()}';

List<PlannedReminder> plan(List<Event> events, tz.TZDateTime now,
        {ReminderPlanner planner = const ReminderPlanner()}) =>
    planner.plan(events, now: now, body: body);

void main() {
  // Before any group body runs, since those build times eagerly.
  tzdata.initializeTimeZones();
  belgrade = tz.getLocation('Europe/Belgrade');

  final now = DateTime(2026, 10, 16, 12);

  test('one-time event gets the alarm plus each chosen reminder', () {
    final event = Event(
      id: 'e',
      title: 'Zubar',
      start: DateTime(2026, 10, 20, 14, 30),
      reminders: {ReminderOffset.hour, ReminderOffset.day},
    );
    final planned = plan([event], at(2026, 10, 16, 12));

    expect(planned.map((p) => p.fireAt), [
      at(2026, 10, 19, 14, 30),
      at(2026, 10, 20, 13, 30),
      at(2026, 10, 20, 14, 30),
    ]);
    expect(planned.map((p) => p.isAlarm), [false, false, true]);
    expect(planned.every((p) => p.repeat == RepeatKind.none), isTrue);
    expect(planned.first.title, 'Zubar');
    expect(planned.first.body, 'day 2026-10-20T14:30:00.000');
  });

  test('reminders already in the past, or due within seconds, are skipped', () {
    final event = Event(
      id: 'e',
      title: 'Sastanak',
      start: DateTime(2026, 10, 16, 12, 20),
      reminders: {ReminderOffset.tenMinutes, ReminderOffset.hour},
    );
    expect(plan([event], at(2026, 10, 16, 12, 15)).map((p) => p.offset),
        [null]);

    final imminent = Event(id: 'i', title: 'x', start: DateTime(2026, 10, 16, 12, 0, 3));
    expect(plan([imminent], at(2026, 10, 16, 12)), isEmpty);
  });

  test('past one-time events plan nothing', () {
    final event = Event(id: 'e', title: 'x', start: DateTime(2026, 10, 1, 9));
    expect(plan([event], at(2026, 10, 16, 12)), isEmpty);
  });

  test('offsets invalid for the recurrence are ignored', () {
    final event = Event(
      id: 'e',
      title: 'Trening',
      start: DateTime(2026, 10, 1, 7),
      recurrence: Recurrence.daily,
      reminders: {ReminderOffset.week, ReminderOffset.day, ReminderOffset.hour},
    );
    expect(plan([event], at(2026, 10, 16, 12)).map((p) => p.offset),
        unorderedEquals([null, ReminderOffset.hour]));
  });

  test('daily series that already started is handed to the OS', () {
    final event = Event(
      id: 'e',
      title: 'Lek',
      start: DateTime(2026, 10, 1, 8),
      recurrence: Recurrence.daily,
      reminders: {ReminderOffset.tenMinutes},
    );
    final planned = plan([event], at(2026, 10, 16, 12));
    expect(planned, hasLength(2));
    expect(planned.every((p) => p.repeat == RepeatKind.daily), isTrue);
    expect(planned.map((p) => p.fireAt),
        unorderedEquals([at(2026, 10, 17, 8), at(2026, 10, 17, 7, 50)]));
  });

  test('weekly "1 day before" repeats on the previous weekday', () {
    // 2026-10-05 is a Monday.
    final event = Event(
      id: 'e',
      title: 'Engleski',
      start: DateTime(2026, 10, 5, 18),
      recurrence: Recurrence.weekly,
      reminders: {ReminderOffset.day},
    );
    final reminder = plan([event], at(2026, 10, 16, 12))
        .firstWhere((p) => p.offset == ReminderOffset.day);
    expect(reminder.repeat, RepeatKind.weekly);
    expect(reminder.fireAt, at(2026, 10, 18, 18));
    expect(reminder.fireAt.weekday, DateTime.sunday);
  });

  test('monthly series becomes 12 one-shots per reminder', () {
    final event = Event(
      id: 'e',
      title: 'Kirija',
      start: DateTime(2026, 1, 31, 10),
      recurrence: Recurrence.monthly,
      reminders: {ReminderOffset.week},
    );
    final planned = plan([event], at(2026, 10, 16, 12));
    expect(planned, hasLength(24));
    expect(planned.every((p) => p.repeat == RepeatKind.none), isTrue);
    final alarms = planned.where((p) => p.isAlarm).map((p) => p.fireAt);
    expect(alarms.take(3),
        [at(2026, 10, 31, 10), at(2026, 11, 30, 10), at(2026, 12, 31, 10)]);
  });

  test('cap keeps repeating series and the soonest one-shots', () {
    final daily = Event(
      id: 'd',
      title: 'd',
      start: DateTime(2026, 10, 1, 8),
      recurrence: Recurrence.daily,
    );
    final oneTime = List.generate(
      10,
      (i) => Event(
        id: 'o$i',
        title: 'o$i',
        start: now.add(Duration(days: i + 1)),
        reminders: ReminderOffset.values.toSet(),
      ),
    );
    final planned = plan([...oneTime, daily], at(2026, 10, 16, 12),
        planner: const ReminderPlanner(maxScheduled: 20));

    expect(planned, hasLength(20));
    expect(planned.first.eventId, 'd');
    final oneShots = planned.skip(1).map((p) => p.fireAt).toList();
    expect(oneShots, orderedEquals([...oneShots]..sort()));
    // 19 one-shots fit: days 1-3 hold 18 (incl. the "7 days before" of the
    // furthest events), then 11:00 on day 4.
    expect(planned.last.fireAt, at(2026, 10, 20, 11));
  });

  test('keys differ per event, offset and text', () {
    final a = Event(id: 'a', title: 'A', start: DateTime(2026, 10, 20, 9));
    final b = Event(id: 'b', title: 'A', start: DateTime(2026, 10, 20, 9));
    final keys = plan([a, b], at(2026, 10, 16, 12)).map((p) => p.key).toSet();
    expect(keys, hasLength(2));

    final renamed = Event(id: 'a', title: 'B', start: DateTime(2026, 10, 20, 9));
    expect(plan([renamed], at(2026, 10, 16, 12)).single.key,
        isNot(plan([a], at(2026, 10, 16, 12)).single.key));
  });
}
