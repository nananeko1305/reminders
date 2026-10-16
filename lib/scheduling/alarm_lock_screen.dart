import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge to MainActivity.kt, which shows the app over the lock screen only
/// while an alarm launched it. [release] ends that, so the app needs
/// unlocking again.
class AlarmLockScreen {
  static const _channel = MethodChannel('reminders/lock_screen');

  const AlarmLockScreen();

  Future<void> release() async {
    try {
      await _channel.invokeMethod<void>('release');
    } on MissingPluginException {
      // Not on Android (tests): nothing to release.
    } catch (e) {
      debugPrint('Lock-screen release failed: $e');
    }
  }
}
