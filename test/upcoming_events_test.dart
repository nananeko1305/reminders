import 'package:flutter_test/flutter_test.dart';

import 'package:reminders/models/event.dart';
import 'package:reminders/models/recurrence.dart';
import 'package:reminders/services/upcoming_events.dart';

void main() {
  final now = DateTime(2026, 10, 16, 12);

  Event event(String id, DateTime start, [Recurrence r = Recurrence.none]) =>
      Event(id: id, title: id, start: start, recurrence: r);

  test('groups next occurrences by day, soonest first', () {
    final upcoming = UpcomingEvents.from([
      event('sutra', DateTime(2026, 10, 17, 9)),
      event('kasnije danas', DateTime(2026, 10, 16, 18)),
      event('danas', DateTime(2026, 10, 16, 13)),
      event('dnevno', DateTime(2026, 10, 1, 8), Recurrence.daily),
    ], now);

    expect(upcoming.days.map((d) => d.day),
        [DateTime(2026, 10, 16), DateTime(2026, 10, 17)]);
    expect(upcoming.days[0].items.map((o) => o.event.id),
        ['danas', 'kasnije danas']);
    expect(upcoming.days[1].items.map((o) => o.event.id), ['dnevno', 'sutra']);
    expect(upcoming.days[1].items.first.at, DateTime(2026, 10, 17, 8));
  });

  test('one-time events that started go to past, most recent first', () {
    final upcoming = UpcomingEvents.from([
      event('staro', DateTime(2026, 9, 1, 9)),
      event('jutros', DateTime(2026, 10, 16, 8)),
    ], now);

    expect(upcoming.days, isEmpty);
    expect(upcoming.past.map((e) => e.id), ['jutros', 'staro']);
  });

  test('empty when there is nothing', () {
    expect(UpcomingEvents.from(const [], now).isEmpty, isTrue);
  });
}
