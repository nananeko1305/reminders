import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/reminder_offset.dart';
import '../theme.dart';

/// The always-on alarm at the event time, plus a chip per optional reminder.
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
    final s = AppScope.of(context).strings;
    final p = palette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          avatar: Icon(Icons.alarm, color: p.alarm),
          label: Text(s.atEventTime),
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
