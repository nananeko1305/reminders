import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/screens/checklist_screen.dart';

import 'fakes/fakes.dart';

/// The closest text style around [text] (Material adds more further up).
TextDecoration? decorationOf(WidgetTester tester, String text) => tester
    .widget<AnimatedDefaultTextStyle>(find
        .ancestor(
          of: find.text(text),
          matching: find.byType(AnimatedDefaultTextStyle),
        )
        .first)
    .style
    .decoration;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('checking an item strikes it through and persists', (tester) async {
    final services = fakeServices();
    final list = await services.checklists.addList('Prodavnica');
    await services.checklists.addItem(list.id, 'mleko');

    await tester.pumpWidget(wrapInApp(ChecklistScreen(listId: list.id), services));
    await tester.pumpAndSettle();

    expect(find.text('Prodavnica'), findsOneWidget);
    expect(decorationOf(tester, 'mleko'), isNot(TextDecoration.lineThrough));

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(decorationOf(tester, 'mleko'), TextDecoration.lineThrough);
    expect(find.text('1/1'), findsOneWidget);
    expect((await services.checklists.byId(list.id))!.items.single.done, isTrue);
  });

  testWidgets('quick add appends items', (tester) async {
    final services = fakeServices();
    final list = await services.checklists.addList('Za put');

    await tester.pumpWidget(wrapInApp(ChecklistScreen(listId: list.id), services));
    await tester.pumpAndSettle();
    expect(find.text('Lista je prazna — dodaj stavku ispod'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pasoš');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'punjač');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text('pasoš'), findsOneWidget);
    expect(find.text('punjač'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
  });
}
