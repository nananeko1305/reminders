import 'package:flutter_test/flutter_test.dart';

import 'package:reminders/l10n/strings.dart';
import 'package:reminders/models/reminder_offset.dart';

void main() {
  final sr = AppStrings.of('sr');
  final en = AppStrings.of('en');
  final now = DateTime(2026, 10, 16, 12);

  test('countdown rounds up to the minute', () {
    expect(sr.countdown(now.add(const Duration(seconds: 20)), now), 'za 1 min');
    expect(sr.countdown(now, now), 'sada');
    expect(sr.countdown(now.subtract(const Duration(minutes: 5)), now), 'sada');
    expect(sr.countdown(DateTime(2026, 10, 16, 12, 45), now), 'za 45 min');
    expect(sr.countdown(DateTime(2026, 10, 16, 14, 10), now), 'za 2 h 10 min');
    expect(sr.countdown(DateTime(2026, 10, 16, 15), now), 'za 3 h');
    expect(en.countdown(DateTime(2026, 10, 16, 14, 10), now), 'in 2 h 10 min');
  });

  test('days use calendar days and Serbian plural forms', () {
    expect(sr.countdown(DateTime(2026, 10, 17, 13), now), 'za 1 dan');
    expect(sr.countdown(DateTime(2026, 10, 18, 9), now), 'za 2 dana');
    expect(sr.countdown(DateTime(2026, 10, 27, 9), now), 'za 11 dana');
    expect(sr.countdown(DateTime(2026, 11, 6, 9), now), 'za 21 dan');
    expect(en.countdown(DateTime(2026, 10, 17, 13), now), 'in 1 day');
    expect(en.countdown(DateTime(2026, 10, 18, 9), now), 'in 2 days');
  });

  test('day across the DST change still counts as one day', () {
    final saturday = DateTime(2026, 10, 24, 12);
    expect(AppStrings.daysBetween(saturday, DateTime(2026, 10, 25, 9)), 1);
    expect(AppStrings.daysBetween(saturday, DateTime(2026, 10, 26, 9)), 2);
  });

  test('day headers', () {
    expect(sr.dayHeader(DateTime(2026, 10, 16), now), 'Danas');
    expect(sr.dayHeader(DateTime(2026, 10, 17), now), 'Sutra');
    expect(sr.dayHeader(DateTime(2026, 10, 18), now), 'Nedelja, 18. okt');
    expect(en.dayHeader(DateTime(2026, 10, 18), now), 'Sunday, Oct 18');
  });

  test('dates', () {
    expect(sr.longDate(DateTime(2026, 10, 16)), 'Petak, 16. okt 2026.');
    expect(en.longDate(DateTime(2026, 10, 16)), 'Friday, Oct 16, 2026');
    expect(sr.time(DateTime(2026, 1, 1, 7, 5)), '07:05');
  });

  test('notification bodies', () {
    final at = DateTime(2026, 10, 20, 14, 30);
    expect(sr.reminderBody(null, at), 'Počinje sada · 14:30');
    expect(sr.reminderBody(ReminderOffset.day, at), 'Sutra · 14:30');
    expect(en.reminderBody(ReminderOffset.hour, at), 'In 1 hour · 14:30');
  });
}
