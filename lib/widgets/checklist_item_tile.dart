import 'package:flutter/material.dart';

import '../models/checklist_item.dart';
import '../theme.dart';

/// A checklist line. Checking it strikes the text through and mutes it.
class ChecklistItemTile extends StatelessWidget {
  const ChecklistItemTile({super.key, required this.item, required this.onToggle});

  final ChecklistItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final base = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    return CheckboxListTile(
      value: item.done,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      title: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: item.done
            ? base.copyWith(
                color: p.muted,
                decoration: TextDecoration.lineThrough,
                decorationColor: p.muted,
                decorationThickness: 2,
              )
            : base,
        child: Text(item.text),
      ),
    );
  }
}
