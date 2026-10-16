import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:reminders/models/reminder_offset.dart';
import 'package:reminders/models/ring_mode.dart';
import 'package:reminders/models/ring_settings.dart';
import 'package:reminders/scheduling/notification_request.dart';
import 'package:reminders/scheduling/planned_reminder.dart';
import 'package:reminders/scheduling/schedule_diff.dart';

void main() {
  group('ScheduleDiff', () {
    test('keeps what matches, cancels the rest, schedules what is missing', () {
      final diff = ScheduleDiff.compute(
        wantedKeys: ['a', 'b', 'c'],
        pending: const [
          PendingNotification(1, 'a'),
          PendingNotification(2, 'old'),
          PendingNotification(3, null),
          PendingNotification(4, 'a'),
        ],
        busyIds: {0, 2, 5},
      );
      expect(diff.cancel, [2, 3, 4]);
      // 1 is kept for 'a'; 2 and 5 are on screen; 3 and 4 are free again.
      expect(diff.schedule.values.toSet(), {3, 4});
      expect(diff.schedule.keys.toSet(), {'b', 'c'});
    });

    test('nothing to do when the OS already matches', () {
      final diff = ScheduleDiff.compute(
        wantedKeys: ['a'],
        pending: const [PendingNotification(7, 'a')],
        busyIds: {0},
      );
      expect(diff.isEmpty, isTrue);
    });

    test('never hands out a busy id', () {
      final diff = ScheduleDiff.compute(
        wantedKeys: ['x', 'y'],
        pending: const [],
        busyIds: {0, 1, 2},
      );
      expect(diff.schedule.values.toSet(), {3, 4});
    });
  });

  group('NotificationRequest', () {
    late tz.Location belgrade;
    setUpAll(() {
      tzdata.initializeTimeZones();
      belgrade = tz.getLocation('Europe/Belgrade');
    });

    PlannedReminder reminder(ReminderOffset? offset,
            {RepeatKind repeat = RepeatKind.none}) =>
        PlannedReminder(
          eventId: 'e1',
          offset: offset,
          fireAt: tz.TZDateTime(belgrade, 2026, 10, 20, 9),
          title: 't',
          body: 'b',
          repeat: repeat,
        );

    test('payload round-trips', () {
      final request = NotificationRequest(reminder(null), exactAllowed: true);
      final decoded = NotificationPayload.decode(request.payload)!;
      expect(decoded.key, request.key);
      expect(decoded.eventId, 'e1');
      expect(decoded.alarm, isTrue);
      expect(NotificationPayload.decode('nope'), isNull);
      expect(NotificationPayload.decode(''), isNull);
    });

    test('alarm uses alarm-clock mode, reminders exact, inexact as fallback', () {
      expect(NotificationRequest(reminder(null), exactAllowed: true).scheduleMode,
          AndroidScheduleMode.alarmClock);
      expect(
          NotificationRequest(reminder(ReminderOffset.hour), exactAllowed: true)
              .scheduleMode,
          AndroidScheduleMode.exactAllowWhileIdle);
      expect(NotificationRequest(reminder(null), exactAllowed: false).scheduleMode,
          AndroidScheduleMode.inexactAllowWhileIdle);
    });

    test('mode is part of the key', () {
      expect(NotificationRequest(reminder(null), exactAllowed: true).key,
          isNot(NotificationRequest(reminder(null), exactAllowed: false).key));
    });

    test('ring mode picks the channel style', () {
      NotificationStyle style(ReminderOffset? offset, RingMode mode) =>
          NotificationRequest(reminder(offset),
                  exactAllowed: true, ring: RingSettings(mode: mode))
              .style;
      expect(style(null, RingMode.alarm), NotificationStyle.alarm);
      expect(style(ReminderOffset.hour, RingMode.alarm), NotificationStyle.sound);
      expect(style(null, RingMode.notification), NotificationStyle.sound);
      expect(style(ReminderOffset.hour, RingMode.vibrate),
          NotificationStyle.vibrate);
      expect(style(null, RingMode.vibrate), NotificationStyle.vibrate);
    });

    test('only a real alarm takes over the screen and uses alarm-clock mode',
        () {
      for (final mode in RingMode.values) {
        final request = NotificationRequest(reminder(null),
            exactAllowed: true, ring: RingSettings(mode: mode));
        final isAlarm = mode == RingMode.alarm;
        expect(NotificationPayload.decode(request.payload)!.alarm, isAlarm);
        expect(
            request.scheduleMode,
            isAlarm
                ? AndroidScheduleMode.alarmClock
                : AndroidScheduleMode.exactAllowWhileIdle);
      }
    });

    test('changing the ring mode changes the key, so sync reschedules', () {
      final keys = {
        for (final mode in RingMode.values)
          NotificationRequest(reminder(ReminderOffset.day),
                  exactAllowed: true, ring: RingSettings(mode: mode))
              .key,
      };
      expect(keys, hasLength(RingMode.values.length));
    });

    test('repeat maps to the matching date components', () {
      expect(
          NotificationRequest(reminder(null, repeat: RepeatKind.weekly),
                  exactAllowed: true)
              .matchDateTimeComponents,
          DateTimeComponents.dayOfWeekAndTime);
      expect(NotificationRequest(reminder(null), exactAllowed: true)
          .matchDateTimeComponents, isNull);
    });
  });
}
