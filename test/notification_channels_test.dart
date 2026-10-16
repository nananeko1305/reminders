import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:reminders/l10n/strings.dart';
import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/models/ring_mode.dart';
import 'package:reminders/models/ring_settings.dart';
import 'package:reminders/scheduling/notification_channels.dart';
import 'package:reminders/scheduling/notification_request.dart';
import 'package:reminders/scheduling/planned_reminder.dart';

const oxygen = AlarmSound(uri: 'content://media/internal/audio/media/7');
const beep = AlarmSound(uri: 'content://media/internal/audio/media/9');

void main() {
  tzdata.initializeTimeZones();
  final belgrade = tz.getLocation('Europe/Belgrade');
  final texts = AppStrings.of('sr');

  NotificationRequest request(ReminderOffset? offset, RingSettings ring) =>
      NotificationRequest(
        PlannedReminder(
          eventId: 'e',
          offset: offset,
          fireAt: tz.TZDateTime(belgrade, 2026, 10, 20, 9),
          title: 't',
          body: 'b',
        ),
        exactAllowed: true,
        ring: ring,
      );

  AndroidNotificationDetails details(NotificationRequest r) =>
      NotificationChannels.forRequest(r, texts).android!;

  group('channel ids', () {
    test('the default sound keeps the original alarm channel', () {
      expect(NotificationChannels.alarmIdFor(AlarmSound.phoneDefault), 'alarm_v1');
      expect(NotificationChannels.startIdFor(AlarmSound.phoneDefault), isNull);
    });

    test('each sound gets its own stable channel', () {
      final a = NotificationChannels.alarmIdFor(oxygen);
      expect(a, NotificationChannels.alarmIdFor(oxygen));
      expect(a, isNot(NotificationChannels.alarmIdFor(beep)));
      expect(a, startsWith('alarm_'));
      expect(NotificationChannels.startIdFor(oxygen), startsWith('start_'));
    });

    test('channels of other sounds are stale, shared ones never', () {
      final oxygenAlarm = NotificationChannels.alarmIdFor(oxygen);
      expect(NotificationChannels.isStale(oxygenAlarm, beep), isTrue);
      expect(NotificationChannels.isStale('alarm_v1', oxygen), isTrue);
      expect(NotificationChannels.isStale(oxygenAlarm, oxygen), isFalse);
      expect(NotificationChannels.isStale('reminders_v1', oxygen), isFalse);
      expect(NotificationChannels.isStale('silent_v1', oxygen), isFalse);
      expect(NotificationChannels.isStale('updates', oxygen), isFalse);
    });
  });

  group('details', () {
    test('alarm mode: the chosen sound on the alarm, full screen as set', () {
      final on = details(request(null, const RingSettings(sound: oxygen)));
      expect(on.channelId, NotificationChannels.alarmIdFor(oxygen));
      expect(on.fullScreenIntent, isTrue);

      final off = details(request(
          null, const RingSettings(sound: oxygen, fullScreen: false)));
      expect(off.fullScreenIntent, isFalse);
      expect(off.audioAttributesUsage, AudioAttributesUsage.alarm);
    });

    test('earlier reminders keep the short notification sound', () {
      expect(
          details(request(
                  ReminderOffset.hour, const RingSettings(sound: oxygen)))
              .channelId,
          'reminders_v1');
    });

    test('notification mode plays the chosen sound once at the event time', () {
      const ring = RingSettings(mode: RingMode.notification, sound: oxygen);
      expect(details(request(null, ring)).channelId,
          NotificationChannels.startIdFor(oxygen));
      expect(
          details(request(null,
                  const RingSettings(mode: RingMode.notification)))
              .channelId,
          'reminders_v1');
    });

    test('vibrate mode is silent', () {
      const ring = RingSettings(mode: RingMode.vibrate, sound: oxygen);
      final d = details(request(null, ring));
      expect(d.channelId, 'silent_v1');
      expect(d.playSound, isFalse);
    });
  });

  group('keys', () {
    test('a new sound reschedules only what plays it', () {
      String key(ReminderOffset? o, AlarmSound s) =>
          request(o, RingSettings(sound: s)).key;
      expect(key(null, oxygen), isNot(key(null, beep)));
      expect(key(ReminderOffset.hour, oxygen), key(ReminderOffset.hour, beep));
    });

    test('turning full screen off reschedules the alarm, and it no longer '
        'takes over the screen', () {
      final on = request(null, const RingSettings());
      final off = request(null, const RingSettings(fullScreen: false));
      expect(on.key, isNot(off.key));
      expect(on.takesOverScreen, isTrue);
      expect(off.takesOverScreen, isFalse);
      expect(off.scheduleMode, AndroidScheduleMode.alarmClock);
    });
  });
}
