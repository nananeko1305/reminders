import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/models/recurrence.dart';
import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/services/app_data_store.dart';
import 'package:reminders/services/event_repository.dart';

import 'fakes/fakes.dart';

void main() {
  late FakeReminderScheduler scheduler;
  late EventRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    scheduler = FakeReminderScheduler();
    repo = EventRepository(scheduler: scheduler, store: AppDataStore());
  });

  test('add stores a cleaned-up event and syncs reminders', () async {
    final event = await repo.add(
      title: '  Trening ',
      start: DateTime(2026, 10, 20, 7, 30, 42),
      recurrence: Recurrence.daily,
      reminders: {ReminderOffset.week, ReminderOffset.tenMinutes},
    );

    final stored = (await repo.events()).single;
    expect(stored.title, 'Trening');
    expect(stored.start, DateTime(2026, 10, 20, 7, 30));
    expect(stored.reminders, {ReminderOffset.tenMinutes});
    expect(scheduler.lastSync, [event.id]);
  });

  test('save replaces by id and syncs', () async {
    final event = await repo.add(title: 'A', start: DateTime(2026, 10, 20, 9));
    event
      ..title = 'B'
      ..reminders = {ReminderOffset.hour};
    await repo.save(event);

    final stored = (await repo.events()).single;
    expect(stored.title, 'B');
    expect(stored.reminders, {ReminderOffset.hour});
    expect(scheduler.syncs, hasLength(2));
  });

  test('delete removes the event and its reminders', () async {
    final a = await repo.add(title: 'A', start: DateTime(2026, 10, 20, 9));
    final b = await repo.add(title: 'B', start: DateTime(2026, 10, 21, 9));
    await repo.delete(a.id);

    expect((await repo.events()).map((e) => e.id), [b.id]);
    expect(scheduler.lastSync, [b.id]);
  });

  test('deletePast keeps future and repeating events', () async {
    final now = DateTime(2026, 10, 16, 12);
    await repo.add(title: 'past', start: DateTime(2026, 10, 1, 9));
    await repo.add(title: 'future', start: DateTime(2026, 10, 30, 9));
    await repo.add(
        title: 'daily', start: DateTime(2026, 9, 1, 9), recurrence: Recurrence.daily);

    await repo.deletePast(now);
    expect((await repo.events()).map((e) => e.title),
        unorderedEquals(['future', 'daily']));
  });

  test('byId finds an event or returns null', () async {
    final a = await repo.add(title: 'A', start: DateTime(2026, 10, 20, 9));
    expect((await repo.byId(a.id))?.title, 'A');
    expect(await repo.byId('missing'), isNull);
  });
}
