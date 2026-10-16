import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/event.dart';
import '../models/recurrence.dart';
import '../models/reminder_offset.dart';
import '../theme.dart';
import '../widgets/date_time_fields.dart';
import '../widgets/dialogs.dart';
import '../widgets/recurrence_selector.dart';
import '../widgets/reminder_chips.dart';

/// Create or edit an event. Pops `true` when something was saved or deleted.
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});

  /// Null for a new event.
  final Event? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _note;
  late DateTime _start;
  late Recurrence _recurrence;
  late Set<ReminderOffset> _reminders;
  bool _saving = false;

  bool get _isNew => widget.event == null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    final now = DateTime.now();
    _title = TextEditingController(text: e?.title ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    // New events default to the next full hour.
    _start = e?.start ?? DateTime(now.year, now.month, now.day, now.hour + 1);
    _recurrence = e?.recurrence ?? Recurrence.none;
    _reminders = {...?e?.reminders};
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = AppScope.of(context).services.events;
    final existing = widget.event;
    if (existing == null) {
      await repo.add(
        title: _title.text,
        note: _note.text,
        start: _start,
        recurrence: _recurrence,
        reminders: _reminders,
      );
    } else {
      await repo.save(Event(
        id: existing.id,
        title: _title.text,
        note: _note.text,
        start: _start,
        recurrence: _recurrence,
        reminders: _reminders,
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final scope = AppScope.of(context);
    final event = widget.event!;
    final ok = await showConfirmDialog(context,
        title: scope.strings.deleteEventTitle,
        message: scope.strings.deleteEventMsg(event.title));
    if (!ok) return;
    await scope.services.events.delete(event.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final label = Theme.of(context).textTheme.titleSmall;
    final inPast = _recurrence == Recurrence.none && _start.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? s.newEvent : s.editEvent),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: s.delete,
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              autofocus: _isNew,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.titleLabel,
                hintText: s.titleHint,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? s.titleRequired : null,
            ),
            const SizedBox(height: 16),
            DateTimeFields(
              value: _start,
              onChanged: (d) => setState(() => _start = d),
            ),
            if (inPast)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(s.startsInPast, style: TextStyle(color: p.alarm)),
              ),
            const SizedBox(height: 20),
            Text(s.repeatLabel, style: label),
            const SizedBox(height: 8),
            RecurrenceSelector(
              value: _recurrence,
              onChanged: (r) => setState(() => _recurrence = r),
            ),
            const SizedBox(height: 20),
            Text(s.remindersLabel, style: label),
            const SizedBox(height: 8),
            ReminderChips(
              selected: _reminders,
              allowed: _recurrence.allowedOffsets,
              onChanged: (r) => setState(() => _reminders = r),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.noteLabel,
                hintText: s.noteHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: Text(s.save),
          ),
        ),
      ),
    );
  }
}
