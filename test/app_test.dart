import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/app.dart';

import 'fakes/fakes.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starts in Serbian, syncs reminders, asks permissions once',
      (tester) async {
    final scheduler = FakeReminderScheduler();
    final services = fakeServices(scheduler: scheduler);
    final permissions = services.permissions as FakePermissions;

    await tester.pumpWidget(AppRoot(services: services));
    await tester.pumpAndSettle();

    expect(find.text('Nema zakazanih događaja'), findsOneWidget);
    expect(scheduler.texts?.channelAlarm, 'Alarm');
    expect(scheduler.syncs, isNotEmpty);
    expect(permissions.prompts, 1);

    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    expect(find.text('Nema lista'), findsOneWidget);

    // A second launch does not ask again.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(AppRoot(services: services));
    await tester.pumpAndSettle();
    expect(permissions.prompts, 1);
  });

  testWidgets('switching to English re-syncs with English texts', (tester) async {
    final scheduler = FakeReminderScheduler();
    await tester.pumpWidget(AppRoot(services: fakeServices(scheduler: scheduler)));
    await tester.pumpAndSettle();
    final syncsBefore = scheduler.syncs.length;

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(scheduler.texts?.channelReminders, 'Reminders');
    expect(scheduler.syncs.length, greaterThan(syncsBefore));
  });
}
