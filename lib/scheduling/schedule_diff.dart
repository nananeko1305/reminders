/// A notification the OS already has scheduled; [key] is null when its
/// payload could not be decoded.
class PendingNotification {
  final int id;
  final String? key;
  const PendingNotification(this.id, this.key);
}

/// What to change so the OS schedule matches the wanted keys: cancel what is
/// no longer wanted (or duplicated), schedule what is missing under fresh ids.
/// Pure, so it can be tested without the plugin.
class ScheduleDiff {
  final List<int> cancel;

  /// Key → id to schedule it under.
  final Map<String, int> schedule;

  const ScheduleDiff({required this.cancel, required this.schedule});

  bool get isEmpty => cancel.isEmpty && schedule.isEmpty;

  /// [busyIds] are ids that must not be reused: notifications currently on
  /// screen (a reused id would replace a ringing alarm) and reserved ids.
  factory ScheduleDiff.compute({
    required Iterable<String> wantedKeys,
    required Iterable<PendingNotification> pending,
    required Set<int> busyIds,
  }) {
    final wanted = wantedKeys.toSet();
    final kept = <String>{};
    final cancel = <int>[];
    final taken = {...busyIds};
    for (final p in pending) {
      final key = p.key;
      if (key != null && wanted.contains(key) && kept.add(key)) {
        taken.add(p.id);
      } else {
        cancel.add(p.id);
      }
    }

    final schedule = <String, int>{};
    var nextId = 1;
    for (final key in wanted.difference(kept)) {
      while (taken.contains(nextId)) {
        nextId++;
      }
      schedule[key] = nextId;
      taken.add(nextId);
    }
    return ScheduleDiff(cancel: cancel, schedule: schedule);
  }
}
