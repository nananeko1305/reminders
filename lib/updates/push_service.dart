import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Release notifications over Firebase Cloud Messaging.
///
/// Every install subscribes to the [releasesTopic]; CI sends one message to
/// it after publishing a new APK. While the app is closed or in the
/// background, Android shows the notification itself. When a release message
/// arrives in the foreground, or the user taps the notification, [onRelease]
/// fires so the UI can show the update dialog.
///
/// Unlike car_expenses this does not ask for the notification permission:
/// NotificationPermissions already does, and two prompts at once collide.
class PushService {
  static const releasesTopic = 'releases';

  final StreamController<void> _releases = StreamController.broadcast();
  bool _started = false;

  /// Emits whenever a release notification was received or opened.
  Stream<void> get onRelease => _releases.stream;

  /// Idempotent; safe to call on every app start. Failures (no Play
  /// services, offline, Firebase not initialized) are swallowed — the
  /// start-up update check still works.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      FirebaseMessaging.onMessage.listen(_handle);
      FirebaseMessaging.onMessageOpenedApp.listen(_handle);
      await FirebaseMessaging.instance.subscribeToTopic(releasesTopic);
    } catch (e) {
      // Retried on the next app start.
      debugPrint('Release push setup failed: $e');
      _started = false;
    }
  }

  void _handle(RemoteMessage message) {
    if (message.data['type'] == 'release') _releases.add(null);
  }
}
