import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_channels.dart';
import 'notification_request.dart';

/// Called by the plugin in a background isolate for action buttons. The only
/// action is "dismiss", which the plugin already handles by removing the
/// notification; it must still be registered or the plugin logs errors.
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {}

/// A notification the user opened: by tapping it, or by the full-screen
/// alarm launching the app ([coldStart]).
class NotificationTap {
  final int id;
  final NotificationPayload? payload;
  final bool coldStart;

  const NotificationTap(this.id, this.payload, {this.coldStart = false});

  bool get isAlarm => payload?.alarm ?? false;
}

/// Initializes the plugin and turns its callbacks into [taps].
class NotificationBootstrap {
  NotificationBootstrap(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<NotificationTap>.broadcast();

  /// Taps while the app is running.
  Stream<NotificationTap> get taps => _taps.stream;

  /// Returns the notification that launched the app, if any. A plugin failure
  /// is logged, never thrown: the app must still open.
  Future<NotificationTap?> initialize() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(NotificationChannels.smallIcon),
        ),
        onDidReceiveNotificationResponse: _onResponse,
        onDidReceiveBackgroundNotificationResponse:
            notificationBackgroundHandler,
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      final id = response?.id;
      if (launch?.didNotificationLaunchApp != true || id == null) return null;
      return NotificationTap(id, NotificationPayload.decode(response?.payload),
          coldStart: true);
    } catch (e) {
      debugPrint('Notification setup failed: $e');
      return null;
    }
  }

  void _onResponse(NotificationResponse response) {
    final id = response.id;
    if (id == null || response.actionId == NotificationChannels.dismissActionId) {
      return;
    }
    _taps.add(NotificationTap(id, NotificationPayload.decode(response.payload)));
  }
}
