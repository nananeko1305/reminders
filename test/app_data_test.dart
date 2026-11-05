import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/models/app_data.dart';
import 'package:reminders/models/event.dart';
import 'package:reminders/models/recurrence.dart';
import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/services/app_data_store.dart';

void main() {
  test('round-trips events through JSON', () {
    final data = AppData(
      events: [
        Event(
          id: 'e',
          title: 'Zubar',
          note: 'ponesi karton',
          start: DateTime(2026, 10, 20, 14, 30),
          recurrence: Recurrence.weekly,
          reminders: {ReminderOffset.day, ReminderOffset.tenMinutes},
        ),
      ],
    );

    final back = AppData.fromJson(
        jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>);
    final e = back.events.single;
    expect(e.title, 'Zubar');
    expect(e.note, 'ponesi karton');
    expect(e.start, DateTime(2026, 10, 20, 14, 30));
    expect(e.recurrence, Recurrence.weekly);
    expect(e.reminders, {ReminderOffset.day, ReminderOffset.tenMinutes});
  });

  test('unknown values fall back instead of failing', () {
    final e = Event.fromJson({
      'id': 'e',
      'title': 'x',
      'start': '2026-10-20T09:00:00.000',
      'recurrence': 'yearly',
      'reminders': ['day', 'fortnight'],
    });
    expect(e.recurrence, Recurrence.none);
    expect(e.reminders, {ReminderOffset.day});
  });

  test('store recovers from a corrupt payload', () async {
    SharedPreferences.setMockInitialValues({'reminders_app_data': '{oops'});
    final data = await AppDataStore().read();
    expect(data.events, isEmpty);
  });

  // Lists moved to the Shopping List app. Phones updating from an older
  // version still hold them in the same blob next to their events.
  test('data with old lists keeps its events and drops the lists', () async {
    SharedPreferences.setMockInitialValues({
      'reminders_app_data': jsonEncode({
        'events': [
          {'id': 'e', 'title': 'Zubar', 'start': '2026-10-20T09:00:00.000'},
        ],
        'checklists': [
          {'id': 'c', 'name': 'Prodavnica', 'items': []},
        ],
      }),
    });
    final store = AppDataStore();
    expect((await store.read()).events.single.title, 'Zubar');

    await store.update((data) => data.events.single.title = 'Lekar');

    final prefs = await SharedPreferences.getInstance();
    final saved =
        jsonDecode(prefs.getString('reminders_app_data')!) as Map<String, dynamic>;
    expect(saved.containsKey('checklists'), isFalse);
    expect((await store.read()).events.single.title, 'Lekar');
  });
}
