import 'package:flutter/material.dart';

import '../theme.dart';

/// Section title above the events of one day: "Danas", "Sutra", "Subota, 18. okt".
class DayHeader extends StatelessWidget {
  const DayHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette(context).brand,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}
