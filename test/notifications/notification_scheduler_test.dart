// Tests for the pure date-math in NotificationScheduler. The scheduling
// methods themselves (scheduleMorningNudge/scheduleWeeklyCheckin) call
// FlutterLocalNotificationsPlugin, which needs a real platform channel
// and isn't covered here — see the audit report for that gap. What IS
// fully covered: isQuietHours, nextOccurrence, and nextDayOfWeek, which
// were refactored to accept an injectable "now" specifically so they
// could be tested deterministically (previously private + wall-clock
// only).
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:fitness_zone_2/data/services/notification_scheduler.dart';

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('NotificationScheduler.isQuietHours', () {
    test('simple same-day window (e.g. 13:00-15:00)', () {
      expect(
        NotificationScheduler.isQuietHours('13:00', '15:00', DateTime(2026, 1, 1, 14, 0)),
        isTrue,
      );
      expect(
        NotificationScheduler.isQuietHours('13:00', '15:00', DateTime(2026, 1, 1, 12, 59)),
        isFalse,
      );
      expect(
        NotificationScheduler.isQuietHours('13:00', '15:00', DateTime(2026, 1, 1, 15, 0)),
        isFalse, // end is exclusive
      );
    });

    test('midnight-crossing window (22:00-07:00)', () {
      // Late night, after start, before midnight.
      expect(
        NotificationScheduler.isQuietHours('22:00', '07:00', DateTime(2026, 1, 1, 23, 30)),
        isTrue,
      );
      // Early morning, before end.
      expect(
        NotificationScheduler.isQuietHours('22:00', '07:00', DateTime(2026, 1, 1, 6, 59)),
        isTrue,
      );
      // Daytime, clearly outside.
      expect(
        NotificationScheduler.isQuietHours('22:00', '07:00', DateTime(2026, 1, 1, 12, 0)),
        isFalse,
      );
      // Exactly at start boundary.
      expect(
        NotificationScheduler.isQuietHours('22:00', '07:00', DateTime(2026, 1, 1, 22, 0)),
        isTrue,
      );
      // Exactly at end boundary (exclusive).
      expect(
        NotificationScheduler.isQuietHours('22:00', '07:00', DateTime(2026, 1, 1, 7, 0)),
        isFalse,
      );
    });
  });

  group('NotificationScheduler.nextOccurrence', () {
    test('time later today returns today at that time', () {
      final now = tz.TZDateTime(tz.local, 2026, 7, 21, 6, 0);
      final result = NotificationScheduler.nextOccurrence(8, 0, now);
      expect(result.year, 2026);
      expect(result.month, 7);
      expect(result.day, 21);
      expect(result.hour, 8);
      expect(result.minute, 0);
    });

    test('time already passed today rolls to tomorrow', () {
      final now = tz.TZDateTime(tz.local, 2026, 7, 21, 9, 0);
      final result = NotificationScheduler.nextOccurrence(8, 0, now);
      expect(result.day, 22);
      expect(result.hour, 8);
    });

    test('exactly at the target time counts as "already passed" (isBefore is strict, so equal is NOT before -> stays today)', () {
      final now = tz.TZDateTime(tz.local, 2026, 7, 21, 8, 0);
      final result = NotificationScheduler.nextOccurrence(8, 0, now);
      // scheduled == now -> scheduled.isBefore(now) is false -> stays today.
      expect(result.day, 21);
    });
  });

  group('NotificationScheduler.nextDayOfWeek', () {
    test('target weekday later this week returns this week', () {
      // 2026-07-21 is a Tuesday (DateTime.tuesday == 2).
      final tuesday = tz.TZDateTime(tz.local, 2026, 7, 21, 6, 0);
      expect(tuesday.weekday, DateTime.tuesday);

      final result = NotificationScheduler.nextDayOfWeek(DateTime.sunday, 19, 0, tuesday);
      // Next Sunday from Tuesday 2026-07-21 is 2026-07-26.
      expect(result.year, 2026);
      expect(result.month, 7);
      expect(result.day, 26);
      expect(result.hour, 19);
    });

    test('target weekday is today but time already passed rolls to next week', () {
      // Sunday 2026-07-26 at 20:00 -> target is Sunday 19:00, already passed.
      final sundayNight = tz.TZDateTime(tz.local, 2026, 7, 26, 20, 0);
      expect(sundayNight.weekday, DateTime.sunday);

      final result = NotificationScheduler.nextDayOfWeek(DateTime.sunday, 19, 0, sundayNight);
      expect(result.day, 2); // next Sunday: Aug 2, 2026
      expect(result.month, 8);
    });

    test('target weekday is today and time has not passed yet stays today', () {
      final sundayMorning = tz.TZDateTime(tz.local, 2026, 7, 26, 10, 0);
      final result = NotificationScheduler.nextDayOfWeek(DateTime.sunday, 19, 0, sundayMorning);
      expect(result.day, 26);
      expect(result.month, 7);
    });
  });
}
