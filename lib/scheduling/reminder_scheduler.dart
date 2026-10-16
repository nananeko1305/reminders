import '../models/event.dart';
import '../models/ring_settings.dart';
import 'reminder_texts.dart';

/// Keeps the OS notification schedule in line with the events. The real one
/// talks to Android; tests use a fake.
abstract interface class ReminderScheduler {
  /// Language for notification texts and channel names. Takes effect on the
  /// next [sync].
  Future<void> useTexts(ReminderTexts texts);

  /// How reminders ring (mode, sound, full screen). Takes effect on the next
  /// [sync], which reschedules whatever is scheduled with other settings.
  void useRing(RingSettings ring);

  /// Schedules what [events] need and cancels what they no longer need.
  Future<void> sync(List<Event> events);

  /// Silences the alarm notification [notificationId]. Removing it can also
  /// drop the next occurrence of a repeating series, so call [sync] after.
  Future<void> dismiss(int notificationId);

  /// Whether [notificationId] is still on screen (so a stale tap from Recents
  /// does not reopen an alarm that was already silenced).
  Future<bool> isShowing(int notificationId);

  /// Rings like a reminder at the event time in a few seconds, with the
  /// current ring settings, to try the sound and lock-screen flow.
  Future<void> scheduleTestAlarm();
}
