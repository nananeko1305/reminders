import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../widgets/settings_sheet.dart';
import 'events_screen.dart';

/// Upcoming events, with settings in the app bar.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.navEvents),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settings,
            onPressed: () => showSettingsSheet(context),
          ),
        ],
      ),
      body: const EventsScreen(),
    );
  }
}
