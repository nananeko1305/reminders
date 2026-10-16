import '../models/event.dart';
import 'reminder_texts.dart';

/// Keeps the OS notification schedule in line with the events. The real one
/// talks to Android; tests use a fake.
abstract interface class ReminderScheduler {
  /// Language for notification texts and channel names. Takes effect on the
  /// next [sync].
  Future<void> useTexts(ReminderTexts texts);

  /// Schedules what [events] need and cancels what they no longer need.
  Future<void> sync(List<Event> events);

  /// Silences the alarm notification [notificationId]. Removing it can also
  /// drop the next occurrence of a repeating series, so call [sync] after.
  Future<void> dismiss(int notificationId);

  /// Whether [notificationId] is still on screen (so a stale tap from Recents
  /// does not reopen an alarm that was already silenced).
  Future<bool> isShowing(int notificationId);

  /// Rings the alarm in a few seconds, to try the sound and lock-screen flow.
  Future<void> scheduleTestAlarm();
}
