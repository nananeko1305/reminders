/// How reminders ring. One setting for all events.
enum RingMode {
  /// At the event time a loud alarm rings until dismissed, over the lock
  /// screen; earlier reminders are notifications with sound.
  alarm,

  /// Every reminder, the one at the event time included, is a notification
  /// with a single sound.
  notification,

  /// Every reminder only vibrates.
  vibrate;

  static RingMode byName(String? name) =>
      values.firstWhere((m) => m.name == name, orElse: () => alarm);
}
