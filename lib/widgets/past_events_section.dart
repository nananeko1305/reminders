import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/event.dart';
import '../theme.dart';

/// Collapsed list of one-time events that already happened, with a button to
/// clear them all.
class PastEventsSection extends StatelessWidget {
  const PastEventsSection({
    super.key,
    required this.events,
    required this.onTap,
    required this.onDeleteAll,
  });

  final List<Event> events;
  final ValueChanged<Event> onTap;
  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final muted = TextStyle(color: p.muted);

    return Card(
      child: ExpansionTile(
        shape: const Border(),
        leading: Icon(Icons.history, color: p.muted),
        title: Text('${s.pastSection} (${events.length})', style: muted),
        children: [
          for (final e in events)
            ListTile(
              dense: true,
              onTap: () => onTap(e),
              title: Text(e.title, style: muted),
              trailing: Text('${s.shortDate(e.start)} ${s.time(e.start)}',
                  style: muted),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDeleteAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: Text(s.deletePast),
              style: TextButton.styleFrom(foregroundColor: p.alarm),
            ),
          ),
        ],
      ),
    );
  }
}
