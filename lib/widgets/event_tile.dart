import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../services/upcoming_events.dart';
import '../theme.dart';

/// One upcoming occurrence in the main list: time, title, countdown,
/// repetition and which reminders will fire.
class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.occurrence,
    required this.now,
    required this.onTap,
  });

  final EventOccurrence occurrence;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final text = Theme.of(context).textTheme;
    final event = occurrence.event;
    final meta = text.bodySmall?.copyWith(color: p.muted);
    final offsets = event.activeReminders.map(s.offsetShort).join(' · ');

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
        leading: Text(
          s.time(occurrence.at),
          style: text.titleMedium
              ?.copyWith(color: p.brand, fontWeight: FontWeight.w700),
        ),
        title: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Wrap(
            spacing: 10,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                s.countdown(occurrence.at, now),
                style: text.bodySmall
                    ?.copyWith(color: p.brand, fontWeight: FontWeight.w600),
              ),
              if (event.repeats)
                _IconText(Icons.repeat, s.recurrenceLabel(event.recurrence), meta),
              _IconText(Icons.alarm, offsets, meta, iconColor: p.alarm),
              if (event.note.isNotEmpty)
                Text(event.note,
                    style: meta, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText(this.icon, this.text, this.style, {this.iconColor});

  final IconData icon;
  final String text;
  final TextStyle? style;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? style?.color),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(text, style: style),
          ],
        ],
      );
}
