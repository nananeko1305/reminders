import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/reminder_offset.dart';
import '../models/ring_mode.dart';
import '../theme.dart';

/// The always-on reminder at the event time (its icon shows the ring mode),
/// plus a chip per optional reminder.
/// Offsets not [allowed] for the current recurrence are shown disabled.
class ReminderChips extends StatelessWidget {
  const ReminderChips({
    super.key,
    required this.selected,
    required this.allowed,
    required this.onChanged,
  });

  final Set<ReminderOffset> selected;
  final Set<ReminderOffset> allowed;
  final ValueChanged<Set<ReminderOffset>> onChanged;

  void _toggle(ReminderOffset o, bool on) =>
      onChanged(on ? {...selected, o} : ({...selected}..remove(o)));

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final p = palette(context);
    final mode = scope.ring.mode;
    final atTimeIcon = switch (mode) {
      RingMode.alarm => Icons.alarm,
      RingMode.notification => Icons.notifications_active_outlined,
      RingMode.vibrate => Icons.vibration,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          avatar: Icon(atTimeIcon, color: p.alarm),
          label: Text('${s.atEventTime} · ${s.ringModeLabel(mode)}'),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final o in ReminderOffset.values)
              FilterChip(
                label: Text(s.offsetLabel(o)),
                selected: allowed.contains(o) && selected.contains(o),
                onSelected: allowed.contains(o) ? (on) => _toggle(o, on) : null,
              ),
          ],
        ),
        if (allowed.length < ReminderOffset.values.length)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              s.someRemindersUnavailable,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: p.muted),
            ),
          ),
      ],
    );
  }
}
