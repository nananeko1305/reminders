import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The device's IANA time zone, which scheduled notifications are pinned to.
class LocalTimezone {
  LocalTimezone() {
    tzdata.initializeTimeZones();
  }

  /// Re-reads the device zone (it changes when travelling) and makes it
  /// [tz.local].
  Future<tz.Location> refresh() async {
    final location = await _deviceLocation();
    tz.setLocalLocation(location);
    return location;
  }

  Future<tz.Location> _deviceLocation() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return tz.getLocation(info.identifier);
    } catch (e) {
      debugPrint('Unknown device time zone, using its UTC offset: $e');
      return _fromOffset(DateTime.now().timeZoneOffset);
    }
  }

  /// Fixed-offset fallback. Etc/GMT names have inverted signs: Etc/GMT-2 is
  /// UTC+2.
  static tz.Location _fromOffset(Duration offset) {
    final hours = offset.inHours;
    if (hours == 0 || offset.inMinutes % 60 != 0) return tz.UTC;
    try {
      return tz.getLocation('Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}');
    } catch (_) {
      return tz.UTC;
    }
  }
}
