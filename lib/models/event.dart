import 'recurrence.dart';
import 'reminder_offset.dart';

/// Something scheduled in the calendar. [start] is a local wall-clock time
/// (no zone); for a repeating event it is the first occurrence.
class Event {
  final String id;
  String title;
  String note;
  DateTime start;
  Recurrence recurrence;
  Set<ReminderOffset> reminders;

  Event({
    required this.id,
    required this.title,
    required this.start,
    this.note = '',
    this.recurrence = Recurrence.none,
    Set<ReminderOffset>? reminders,
  }) : reminders = reminders ?? {};

  /// Chosen reminders that are valid for the recurrence, in display order
  /// (longest first).
  List<ReminderOffset> get activeReminders => ReminderOffset.values
      .where((o) => reminders.contains(o) && recurrence.allowedOffsets.contains(o))
      .toList();

  bool get repeats => recurrence != Recurrence.none;

  /// The occurrence at or after [from]; null for a one-time event in the past.
  DateTime? nextOccurrence(DateTime from) => recurrence.nextFrom(start, from);

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        note: json['note'] as String? ?? '',
        start: DateTime.parse(json['start'] as String),
        recurrence: Recurrence.byName(json['recurrence'] as String?),
        reminders: (json['reminders'] as List<dynamic>? ?? [])
            .map((n) => ReminderOffset.byName(n as String))
            .whereType<ReminderOffset>()
            .toSet(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'start': start.toIso8601String(),
        'recurrence': recurrence.name,
        'reminders': activeReminders.map((o) => o.name).toList(),
      };
}
