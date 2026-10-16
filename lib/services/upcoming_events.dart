import '../models/event.dart';

/// An event at one specific occurrence.
class EventOccurrence {
  final Event event;
  final DateTime at;
  const EventOccurrence(this.event, this.at);
}

/// Upcoming occurrences on one calendar day.
class DaySection {
  final DateTime day;
  final List<EventOccurrence> items;
  const DaySection(this.day, this.items);
}

/// What the main list shows: each event at its next occurrence, grouped by
/// day, soonest first, plus one-time events that already started.
class UpcomingEvents {
  final List<DaySection> days;

  /// One-time events in the past, most recent first.
  final List<Event> past;

  const UpcomingEvents(this.days, this.past);

  bool get isEmpty => days.isEmpty && past.isEmpty;

  factory UpcomingEvents.from(Iterable<Event> events, DateTime now) {
    final upcoming = <EventOccurrence>[];
    final past = <Event>[];
    for (final event in events) {
      final next = event.nextOccurrence(now);
      if (next != null) {
        upcoming.add(EventOccurrence(event, next));
      } else {
        past.add(event);
      }
    }
    upcoming.sort((a, b) {
      final byTime = a.at.compareTo(b.at);
      return byTime != 0 ? byTime : a.event.title.compareTo(b.event.title);
    });
    past.sort((a, b) => b.start.compareTo(a.start));

    final days = <DaySection>[];
    for (final o in upcoming) {
      final day = DateTime(o.at.year, o.at.month, o.at.day);
      if (days.isEmpty || days.last.day != day) {
        days.add(DaySection(day, []));
      }
      days.last.items.add(o);
    }
    return UpcomingEvents(days, past);
  }
}
