import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminders/app.dart';

import 'fakes/fakes.dart';

/// The overlay style the home screen's app bar asks Android for.
SystemUiOverlayStyle appBarStyle(WidgetTester tester) => tester
    .widget<AnnotatedRegion<SystemUiOverlayStyle>>(find
        .descendant(
          of: find.byType(AppBar),
          matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        )
        .first)
    .value;

void main() {
  Future<void> start(WidgetTester tester, String theme) async {
    SharedPreferences.setMockInitialValues({
      'settings_permissions_asked': true,
      'settings_theme_mode': theme,
    });
    await tester.pumpWidget(AppRoot(services: fakeServices()));
    await tester.pumpAndSettle();
  }

  testWidgets('light theme: dark status-bar icons over a light bar',
      (tester) async {
    await start(tester, 'light');
    expect(appBarStyle(tester).statusBarIconBrightness, Brightness.dark);
    expect(appBarStyle(tester).systemNavigationBarIconBrightness,
        Brightness.dark);
  });

  testWidgets('dark theme: light status-bar icons', (tester) async {
    await start(tester, 'dark');
    expect(appBarStyle(tester).statusBarIconBrightness, Brightness.light);
    expect(appBarStyle(tester).systemNavigationBarIconBrightness,
        Brightness.light);
  });
}
