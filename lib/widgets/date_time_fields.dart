import 'package:flutter/material.dart';

import '../app_scope.dart';

/// Date (calendar picker) and time (24h clock picker) of an event.
class DateTimeFields extends StatelessWidget {
  const DateTimeFields({super.key, required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    onChanged(DateTime(
        picked.year, picked.month, picked.day, value.hour, value.minute));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    onChanged(DateTime(
        value.year, value.month, value.day, picked.hour, picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return Column(
      children: [
        _PickerField(
          icon: Icons.calendar_month_outlined,
          label: s.dateLabel,
          text: s.longDate(value),
          onTap: () => _pickDate(context),
        ),
        const SizedBox(height: 12),
        _PickerField(
          icon: Icons.schedule,
          label: s.timeLabel,
          text: s.time(value),
          onTap: () => _pickTime(context),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
}
