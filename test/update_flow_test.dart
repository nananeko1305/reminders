import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/app.dart';
import 'package:reminders/updates/update_checker.dart';

import 'fakes/fakes.dart';

const _release = ReleaseInfo(
  version: '1.2.0',
  build: 9,
  downloadUrl: 'https://example.com/reminders.apk',
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(
      {'settings_permissions_asked': true}));

  testWidgets('offers a newer version on start', (tester) async {
    final updates = FakeUpdateChecker()
      ..result = const UpdateAvailable(_release, '1.0.0');
    await tester.pumpWidget(AppRoot(services: fakeServices(updates: updates)));
    await tester.pumpAndSettle();

    expect(find.text('Dostupna je nova verzija'), findsOneWidget);
    expect(find.text('Verzija 1.2.0 je spremna za preuzimanje. Ti imaš 1.0.0.'),
        findsOneWidget);

    await tester.tap(find.text('Kasnije'));
    await tester.pumpAndSettle();
    expect(find.text('Dostupna je nova verzija'), findsNothing);
  });

  testWidgets('a release push re-checks, never stacking dialogs',
      (tester) async {
    final updates = FakeUpdateChecker();
    final push = FakePushService();
    await tester.pumpWidget(
        AppRoot(services: fakeServices(updates: updates, push: push)));
    await tester.pumpAndSettle();

    expect(push.started, isTrue);
    expect(updates.checks, 1);
    expect(find.text('Dostupna je nova verzija'), findsNothing);

    updates.result = const UpdateAvailable(_release, '1.0.0');
    push.simulateRelease();
    await tester.pumpAndSettle();
    push.simulateRelease();
    await tester.pumpAndSettle();

    expect(find.text('Dostupna je nova verzija'), findsOneWidget);
  });

  testWidgets('settings show the version and check on tap', (tester) async {
    await tester.pumpWidget(AppRoot(services: fakeServices()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Proveri ažuriranja'), 100,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Verzija 1.0.0'), findsOneWidget);

    await tester.tap(find.text('Proveri ažuriranja'));
    await tester.pumpAndSettle();
    expect(find.text('Imaš najnoviju verziju.'), findsOneWidget);
  });
}
