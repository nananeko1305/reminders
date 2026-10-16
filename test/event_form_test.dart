import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/models/recurrence.dart';
import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/screens/event_form_screen.dart';

import 'fakes/fakes.dart';

FilterChip chip(WidgetTester tester, String label) => tester.widget<FilterChip>(
    find.ancestor(of: find.text(label), matching: find.byType(FilterChip)));

/// Opens the form on a phone-sized screen (360x800).
Future<void> openForm(WidgetTester tester, Widget app) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Scrolls [label] into view first: the form is longer than the screen.
Future<void> tapText(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Widget launcher() => Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute<bool>(builder: (_) => const EventFormScreen())),
        child: const Text('open'),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('daily repeat locks the day-long reminders', (tester) async {
    await openForm(tester, wrapInApp(launcher(), fakeServices()));

    expect(chip(tester, '7 dana pre').onSelected, isNotNull);
    await tapText(tester, 'Dnevno');

    expect(chip(tester, '7 dana pre').onSelected, isNull);
    expect(chip(tester, '1 dan pre').onSelected, isNull);
    expect(chip(tester, '10 min pre').onSelected, isNotNull);
    expect(find.text('Neki podsetnici nisu dostupni za ovo ponavljanje.'),
        findsOneWidget);
  });

  testWidgets('title is required, then the event is saved and synced',
      (tester) async {
    final scheduler = FakeReminderScheduler();
    final services = fakeServices(scheduler: scheduler);
    await openForm(tester, wrapInApp(launcher(), services));

    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Upiši naziv'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Zubar');
    await tapText(tester, 'Nedeljno');
    await tapText(tester, '1 dan pre');
    await tapText(tester, '10 min pre');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();

    expect(find.byType(EventFormScreen), findsNothing);
    final saved = (await services.events.events()).single;
    expect(saved.title, 'Zubar');
    expect(saved.recurrence, Recurrence.weekly);
    expect(saved.reminders, {ReminderOffset.day, ReminderOffset.tenMinutes});
    expect(scheduler.lastSync, [saved.id]);
  });
}
