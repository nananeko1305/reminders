import 'dart:math';

import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';
import '../models/recurrence.dart';
import '../models/reminder_offset.dart';
import 'planned_reminder.dart';

/// Localized notification body for a reminder of an occurrence (offset null =
/// the alarm at the event time).
typedef ReminderBody = String Function(
    ReminderOffset? offset, DateTime occurrence);

/// Turns events into the notifications that should be scheduled right now.
/// Pure: no plugin, no clock — everything comes in as arguments.
///
/// Daily and weekly series are handed to the OS as repeating notifications so
/// they keep ringing even if the app is never opened again. Everything else
/// (one-time events, monthly series, and series whose start is still in the
/// future) becomes a batch of one-shots that the app tops up on every sync.
class ReminderPlanner {
  const ReminderPlanner({
    this.maxScheduled = 400,
    this.minLead = const Duration(seconds: 5),
  });

  /// Upper bound on scheduled notifications (Android allows ~500 alarms per
  /// app). Repeating series always fit; one-shots fill the rest, soonest first.
  final int maxScheduled;

  /// Anything due sooner than this is skipped: the OS would fire it at once.
  final Duration minLead;

  /// One-shots planned ahead for a repeating series that cannot (yet) be
  /// handed to the OS as a repeating notification.
  static const _oneShotsPerSeries = {
    Recurrence.daily: 14,
    Recurrence.weekly: 6,
    Recurrence.monthly: 12,
  };

  List<PlannedReminder> plan(
    Iterable<Event> events, {
    required tz.TZDateTime now,
    required ReminderBody body,
  }) {
    final repeating = <PlannedReminder>[];
    final oneShots = <PlannedReminder>[];
    for (final event in events) {
      for (final offset in <ReminderOffset?>[null, ...event.activeReminders]) {
        _planSeries(event, offset, now, body, repeating, oneShots);
      }
    }
    oneShots.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    final room = max(0, maxScheduled - repeating.length);
    return [...repeating, ...oneShots.take(room)];
  }

  void _planSeries(
    Event event,
    ReminderOffset? offset,
    tz.TZDateTime now,
    ReminderBody body,
    List<PlannedReminder> repeating,
    List<PlannedReminder> oneShots,
  ) {
    final fires = _fires(event, offset, now.add(minLead));
    PlannedReminder make(_Fire f, RepeatKind repeat) => PlannedReminder(
          eventId: event.id,
          offset: offset,
          fireAt: f.at,
          repeat: repeat,
          title: event.title,
          body: body(offset, f.occurrence),
        );

    final repeat = switch (event.recurrence) {
      Recurrence.daily => RepeatKind.daily,
      Recurrence.weekly => RepeatKind.weekly,
      _ => RepeatKind.none,
    };
    if (repeat != RepeatKind.none) {
      final first = fires.first;
      if (osFirstFire(first.at, now, repeat).isAtSameMomentAs(first.at)) {
        repeating.add(make(first, repeat));
        return;
      }
    }
    final count = _oneShotsPerSeries[event.recurrence] ?? 1;
    oneShots.addAll(fires.take(count).map((f) => make(f, RepeatKind.none)));
  }

  /// Fire times of [offset] for upcoming occurrences, none before [earliest].
  /// Infinite for repeating events; callers take what they need.
  Iterable<_Fire> _fires(
      Event event, ReminderOffset? offset, tz.TZDateTime earliest) sync* {
    final loc = earliest.location;
    final recurrence = event.recurrence;
    // Occurrences before `earliest` can only have fires before it too.
    final first = recurrence.firstIndexFrom(event.start, _wallClock(earliest));
    if (first == null) return;
    for (var n = first;; n++) {
      final occurrence = recurrence.occurrence(event.start, n);
      final at = tz.TZDateTime(loc, occurrence.year, occurrence.month,
          occurrence.day, occurrence.hour, occurrence.minute);
      final fireAt = offset?.before(at) ?? at;
      if (!fireAt.isBefore(earliest)) yield _Fire(occurrence, fireAt);
      if (recurrence == Recurrence.none) return;
    }
  }

  /// Where the OS would put the first fire of a repeating notification
  /// scheduled with [fireAt]: the first matching time of day (and weekday)
  /// not before [now]. Mirrors flutter_local_notifications'
  /// getNextFireDateMatchingDateTimeComponents, which ignores the date.
  static tz.TZDateTime osFirstFire(
      tz.TZDateTime fireAt, tz.TZDateTime now, RepeatKind repeat) {
    var shift = 0;
    tz.TZDateTime candidate() => tz.TZDateTime(now.location, now.year,
        now.month, now.day + shift, fireAt.hour, fireAt.minute, fireAt.second);
    var next = candidate();
    while (next.isBefore(now)) {
      shift++;
      next = candidate();
    }
    while (repeat == RepeatKind.weekly && next.weekday != fireAt.weekday) {
      shift++;
      next = candidate();
    }
    return next;
  }

  /// [t]'s wall-clock time as a local [DateTime], comparable with occurrences.
  static DateTime _wallClock(tz.TZDateTime t) =>
      DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
}

class _Fire {
  final DateTime occurrence;
  final tz.TZDateTime at;
  const _Fire(this.occurrence, this.at);
}
