import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/event.dart';
import '../services/upcoming_events.dart';
import '../theme.dart';
import '../widgets/day_header.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_tile.dart';
import '../widgets/minute_ticker.dart';
import '../widgets/notifications_banner.dart';
import '../widgets/past_events_section.dart';
import 'event_form_screen.dart';

/// The main list: what is next, grouped by day, with live countdowns.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final AppLifecycleListener _lifecycle;
  List<Event>? _events;
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _reload);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final services = AppScope.of(context).services;
    final events = await services.events.events();
    final notificationsOn = await services.permissions.notificationsEnabled();
    if (!mounted) return;
    setState(() {
      _events = events;
      _notificationsOn = notificationsOn;
    });
  }

  Future<void> _openForm([Event? event]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
    );
    if (changed == true) await _reload();
  }

  Future<bool> _confirmDelete(Event event) {
    final s = AppScope.of(context).strings;
    return showConfirmDialog(context,
        title: s.deleteEventTitle, message: s.deleteEventMsg(event.title));
  }

  Future<void> _delete(Event event) async {
    final repo = AppScope.of(context).services.events;
    // Drop it from the tree right away; Dismissible requires that.
    setState(() => _events?.removeWhere((e) => e.id == event.id));
    await repo.delete(event.id);
    await _reload();
  }

  Future<void> _deletePast() async {
    final scope = AppScope.of(context);
    final ok = await showConfirmDialog(context,
        title: scope.strings.deletePast, message: scope.strings.deletePastMsg);
    if (!ok) return;
    await scope.services.events.deletePast(DateTime.now());
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final events = _events;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // Both tabs stay mounted in an IndexedStack; tags must differ.
        heroTag: 'events-fab',
        onPressed: _openForm,
        tooltip: s.newEvent,
        child: const Icon(Icons.add),
      ),
      body: events == null
          ? const Center(child: CircularProgressIndicator())
          : MinuteTicker(
              builder: (context, now) =>
                  _list(UpcomingEvents.from(events, now), now),
            ),
    );
  }

  Widget _list(UpcomingEvents upcoming, DateTime now) {
    final s = AppScope.of(context).strings;
    final services = AppScope.of(context).services;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (!_notificationsOn)
          NotificationsBanner(
            onFix: () => services.permissions
                .requestNotifications()
                .then((_) => services.permissions.openNotificationSettings()),
          ),
        if (upcoming.days.isEmpty)
          EmptyState(
            icon: Icons.event_available_outlined,
            title: s.noEvents,
            hint: s.noEventsHint,
          ),
        for (final day in upcoming.days) ...[
          DayHeader(s.dayHeader(day.day, now)),
          for (final o in day.items) _dismissible(o, now),
        ],
        if (upcoming.past.isNotEmpty) ...[
          const SizedBox(height: 16),
          PastEventsSection(
            events: upcoming.past,
            onTap: _openForm,
            onDeleteAll: _deletePast,
          ),
        ],
      ],
    );
  }

  Widget _dismissible(EventOccurrence o, DateTime now) => Dismissible(
        key: ValueKey(o.event.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(o.event),
        onDismissed: (_) => _delete(o.event),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 28),
          child: Icon(Icons.delete_outline, color: palette(context).alarm),
        ),
        child: EventTile(
          occurrence: o,
          now: now,
          onTap: () => _openForm(o.event),
        ),
      );
}
