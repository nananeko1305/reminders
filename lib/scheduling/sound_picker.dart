import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/ring_settings.dart';

/// The system sound picker and sound names, via MainActivity.kt.
class SoundPicker {
  static const _channel = MethodChannel('reminders/device');

  const SoundPicker();

  /// Lets the user pick a phone sound (with preview). Null when cancelled.
  Future<AlarmSound?> pick({required AlarmSound current, required String title}) async {
    try {
      final picked = await _channel.invokeMapMethod<String, String?>(
          'pickSound', {'current': current.uri, 'title': title});
      if (picked == null) return null;
      return AlarmSound(uri: picked['uri'], title: picked['title']);
    } on MissingPluginException {
      return null;
    } catch (e) {
      debugPrint('Sound picker failed: $e');
      return null;
    }
  }

  /// The sound's display name in the phone's language, if it still exists.
  Future<String?> titleOf(String uri) async {
    try {
      return await _channel.invokeMethod<String>('soundTitle', {'uri': uri});
    } catch (_) {
      return null;
    }
  }
}
