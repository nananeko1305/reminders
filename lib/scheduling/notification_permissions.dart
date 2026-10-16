import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// What the alarm needs from Android, and the system screens to grant it.
/// Off Android every check reports "allowed".
class NotificationPermissions {
  NotificationPermissions(FlutterLocalNotificationsPlugin plugin)
      : _android = plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

  final AndroidFlutterLocalNotificationsPlugin? _android;

  Future<bool> notificationsEnabled() async =>
      await _guard(() => _android?.areNotificationsEnabled()) ?? true;

  Future<bool> exactAlarmsAllowed() async =>
      await _guard(() => _android?.canScheduleExactNotifications()) ?? true;

  Future<void> requestNotifications() =>
      _guard(() => _android?.requestNotificationsPermission());

  Future<void> requestExactAlarms() =>
      _guard(() => _android?.requestExactAlarmsPermission());

  /// Android 14+: opens the system screen unless already granted. Its status
  /// cannot be read back, so this is offered as a button only.
  Future<void> requestFullScreen() =>
      _guard(() => _android?.requestFullScreenIntentPermission());

  Future<void> openNotificationSettings() =>
      _guard(() => _android?.openAppNotificationSettings());

  /// First run: ask for everything the alarm needs, one system prompt at a time.
  Future<void> requestAll() async {
    await requestNotifications();
    if (!await exactAlarmsAllowed()) await requestExactAlarms();
    await requestFullScreen();
  }

  /// A failed check or prompt (e.g. one already in progress) must never break
  /// the caller.
  static Future<T?> _guard<T>(Future<T?>? Function() call) async {
    try {
      return await call();
    } catch (e) {
      debugPrint('Notification permission call failed: $e');
      return null;
    }
  }
}
