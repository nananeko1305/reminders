import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/app.dart';
import 'package:reminders/models/ring_mode.dart';
import 'package:reminders/models/ring_settings.dart';

import 'fakes/fakes.dart';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

Future<void> tapInSheet(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(find.text(text), 100,
      scrollable: find.byType(Scrollable).last);
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

const oxygen = AlarmSound(
    uri: 'content://media/internal/audio/media/7', title: 'Oxygen');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(
      {'settings_permissions_asked': true}));

  testWidgets('choosing a ring mode saves it and reschedules', (tester) async {
    final scheduler = FakeReminderScheduler();
    await tester.pumpWidget(AppRoot(services: fakeServices(scheduler: scheduler)));
    await tester.pumpAndSettle();
    expect(scheduler.ring.mode, RingMode.alarm);
    final syncsBefore = scheduler.syncs.length;

    await openSettings(tester);
    await tapInSheet(tester, 'Samo vibracija');

    expect(scheduler.ring.mode, RingMode.vibrate);
    expect(scheduler.syncs.length, greaterThan(syncsBefore));
    // Vibration has no sound and no full screen to choose.
    expect(find.text('Melodija'), findsNothing);
    expect(find.text('Alarm preko celog ekrana'), findsNothing);

    final restarted = FakeReminderScheduler();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(AppRoot(services: fakeServices(scheduler: restarted)));
    await tester.pumpAndSettle();
    expect(restarted.ring.mode, RingMode.vibrate);
  });

  testWidgets('a picked phone sound is used, shown and kept', (tester) async {
    final scheduler = FakeReminderScheduler();
    final sounds = FakeSoundPicker();
    await tester.pumpWidget(AppRoot(
        services: fakeServices(scheduler: scheduler, sounds: sounds)));
    await tester.pumpAndSettle();
    await openSettings(tester);
    expect(find.text('Podrazumevani zvuk alarma · u trenutku događaja'),
        findsOneWidget);

    // Cancelling the picker changes nothing.
    await tapInSheet(tester, 'Melodija');
    expect(sounds.picks, 1);
    expect(scheduler.ring.sound.isDefault, isTrue);

    sounds.next = oxygen;
    await tapInSheet(tester, 'Melodija');
    expect(scheduler.ring.sound.uri, oxygen.uri);
    expect(find.text('Oxygen · u trenutku događaja'), findsOneWidget);

    final restarted = FakeReminderScheduler();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(AppRoot(services: fakeServices(scheduler: restarted)));
    await tester.pumpAndSettle();
    expect(restarted.ring.sound.uri, oxygen.uri);
    expect(restarted.ring.sound.title, 'Oxygen');
  });

  testWidgets('full screen shows its real permission and can be turned off',
      (tester) async {
    final scheduler = FakeReminderScheduler();
    final permissions = FakePermissions()..fullScreen = false;
    await tester.pumpWidget(AppRoot(
        services: fakeServices(scheduler: scheduler, permissions: permissions)));
    await tester.pumpAndSettle();
    await openSettings(tester);

    expect(find.text('Telefon još ne dozvoljava — dodirni Podesi.'),
        findsOneWidget);
    expect(find.text('Podesi'), findsOneWidget);
    await tapInSheet(tester, 'Podesi');
    expect(permissions.prompts, 1);

    // Granted in system settings, back in the app.
    permissions.fullScreen = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Alarm pali ekran i kad je telefon zaključan.'),
        findsOneWidget);
    expect(find.text('Podesi'), findsNothing);

    await tapInSheet(tester, 'Alarm preko celog ekrana');
    expect(scheduler.ring.fullScreen, isFalse);
    expect(find.text('Alarm zvoni kao notifikacija, ne pali ekran.'),
        findsOneWidget);
  });

  testWidgets('the test button rings with the current settings',
      (tester) async {
    final scheduler = FakeReminderScheduler();
    await tester.pumpWidget(AppRoot(services: fakeServices(scheduler: scheduler)));
    await tester.pumpAndSettle();

    await openSettings(tester);
    await tapInSheet(tester, 'Notifikacija');
    await tapInSheet(tester, 'Probaj zvonjenje (za 10 s)');

    expect(scheduler.ring.mode, RingMode.notification);
    expect(scheduler.testAlarms, 1);
  });
}
