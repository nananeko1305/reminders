import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/recurrence.dart';

/// Picks how an event repeats. Chips wrap, so long labels never overflow.
class RecurrenceSelector extends StatelessWidget {
  const RecurrenceSelector(
      {super.key, required this.value, required this.onChanged});

  final Recurrence value;
  final ValueChanged<Recurrence> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final r in Recurrence.values)
          ChoiceChip(
            label: Text(s.recurrenceLabel(r)),
            selected: r == value,
            onSelected: (_) => onChanged(r),
          ),
      ],
    );
  }
}
