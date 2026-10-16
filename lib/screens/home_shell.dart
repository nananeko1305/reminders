import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../widgets/settings_sheet.dart';
import 'checklists_screen.dart';
import 'events_screen.dart';

/// Two tabs — upcoming events and checklists — with settings in the app bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? s.navEvents : s.navLists),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settings,
            onPressed: () => showSettingsSheet(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [EventsScreen(), ChecklistsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: s.navEvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: s.navLists,
          ),
        ],
      ),
    );
  }
}
