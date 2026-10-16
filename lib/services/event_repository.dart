import '../models/event.dart';
import '../models/recurrence.dart';
import '../models/reminder_offset.dart';
import '../scheduling/reminder_scheduler.dart';
import 'app_data_store.dart';
import 'id_generator.dart';

/// CRUD for events. Every change is followed by a reminder [ReminderScheduler.sync]
/// so the OS schedule never lags behind what is stored.
class EventRepository {
  EventRepository({
    required this._scheduler,
    required this._store,
    IdGenerator? ids,
  }) : _ids = ids ?? IdGenerator();

  final ReminderScheduler _scheduler;
  final AppDataStore _store;
  final IdGenerator _ids;

  Future<List<Event>> events() async => (await _store.read()).events;

  Future<Event?> byId(String id) async {
    for (final e in await events()) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<Event> add({
    required String title,
    required DateTime start,
    String note = '',
    Recurrence recurrence = Recurrence.none,
    Set<ReminderOffset> reminders = const {},
  }) async {
    final event = _sanitized(Event(
      id: _ids.next(),
      title: title,
      note: note,
      start: start,
      recurrence: recurrence,
      reminders: {...reminders},
    ));
    await _store.update((data) => data.events.add(event));
    await resync();
    return event;
  }

  /// Replaces the stored event with the same id.
  Future<void> save(Event event) async {
    final clean = _sanitized(event);
    await _store.update((data) {
      final i = data.events.indexWhere((e) => e.id == clean.id);
      if (i >= 0) data.events[i] = clean;
    });
    await resync();
  }

  Future<void> delete(String id) async {
    await _store.update((data) => data.events.removeWhere((e) => e.id == id));
    await resync();
  }

  /// Removes one-time events that have already started.
  Future<void> deletePast(DateTime now) async {
    await _store.update((data) => data.events
        .removeWhere((e) => !e.repeats && e.start.isBefore(now)));
    await resync();
  }

  /// Re-plans every reminder from what is stored, e.g. when the app resumes.
  Future<void> resync() async => _scheduler.sync(await events());

  /// Trimmed title and note, minute precision, only valid reminders.
  static Event _sanitized(Event e) {
    final s = e.start;
    return Event(
      id: e.id,
      title: e.title.trim(),
      note: e.note.trim(),
      start: DateTime(s.year, s.month, s.day, s.hour, s.minute),
      recurrence: e.recurrence,
      reminders: e.activeReminders.toSet(),
    );
  }
}
