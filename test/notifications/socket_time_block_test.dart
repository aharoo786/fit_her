// Tests for the time-block matching logic extracted from
// SocketController (see lib/data/controllers/socket_time_block.dart).
// This gates whether a real-time "slotUpdate" socket event triggers a
// local notification, based on the user's morning/afternoon/evening/
// night/all preference.
//
// NOTE (audit finding): the backend's TIME_BLOCK_HOURS in
// crownjobfunction.js uses DIFFERENT hour windows than this client-side
// copy, and handles the midnight wrap for 'night' where this one does
// not. That's a real product discrepancy, not a test bug — see the
// audit report. These tests lock in the client's CURRENT behavior so
// any future fix to reconcile the two is a deliberate, visible change
// here rather than a silent regression.
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/controllers/socket_time_block.dart';

void main() {
  group('isSlotTimeInPreferredBlock — "all" and edge inputs', () {
    test('"all" always matches regardless of slot time', () {
      expect(isSlotTimeInPreferredBlock('all', '3:00 AM'), isTrue);
      expect(isSlotTimeInPreferredBlock('all', null), isTrue);
    });

    test('null or empty slotStart always matches (fail-open)', () {
      expect(isSlotTimeInPreferredBlock('morning', null), isTrue);
      expect(isSlotTimeInPreferredBlock('night', ''), isTrue);
    });

    test('unparsable slotStart fails open (matches) rather than throwing', () {
      expect(() => isSlotTimeInPreferredBlock('morning', 'not a time'), returnsNormally);
      expect(isSlotTimeInPreferredBlock('morning', 'not a time'), isTrue);
    });
  });

  group('isSlotTimeInPreferredBlock — 12h format parsing', () {
    test('morning window (6-11) matches AM times in range', () {
      expect(isSlotTimeInPreferredBlock('morning', '8:00 AM'), isTrue);
      expect(isSlotTimeInPreferredBlock('morning', '6:00 AM'), isTrue);
      expect(isSlotTimeInPreferredBlock('morning', '10:59 AM'), isTrue);
    });

    test('morning window excludes times outside 6-11', () {
      expect(isSlotTimeInPreferredBlock('morning', '5:59 AM'), isFalse);
      expect(isSlotTimeInPreferredBlock('morning', '11:00 AM'), isFalse);
      expect(isSlotTimeInPreferredBlock('morning', '2:00 PM'), isFalse);
    });

    test('12 AM parses as hour 0, 12 PM parses as hour 12', () {
      // 12 AM (midnight) -> hour 0 -> not in any of the defined windows.
      expect(isSlotTimeInPreferredBlock('night', '12:00 AM'), isFalse);
      // 12 PM (noon) -> hour 12 -> afternoon window (11-16).
      expect(isSlotTimeInPreferredBlock('afternoon', '12:00 PM'), isTrue);
    });

    test('afternoon window (11-16)', () {
      expect(isSlotTimeInPreferredBlock('afternoon', '11:00 AM'), isTrue);
      expect(isSlotTimeInPreferredBlock('afternoon', '3:59 PM'), isTrue);
      expect(isSlotTimeInPreferredBlock('afternoon', '4:00 PM'), isFalse);
    });

    test('evening window (16-20)', () {
      expect(isSlotTimeInPreferredBlock('evening', '4:00 PM'), isTrue);
      expect(isSlotTimeInPreferredBlock('evening', '7:59 PM'), isTrue);
      expect(isSlotTimeInPreferredBlock('evening', '8:00 PM'), isFalse);
    });

    test('night window (20-23) — does NOT wrap past midnight', () {
      expect(isSlotTimeInPreferredBlock('night', '8:00 PM'), isTrue);
      expect(isSlotTimeInPreferredBlock('night', '10:59 PM'), isTrue);
      // A class at 11 PM or later, or after midnight, is NOT matched —
      // this is the exact discrepancy flagged vs. the backend, which
      // does wrap 'night' through to 5 AM.
      expect(isSlotTimeInPreferredBlock('night', '11:00 PM'), isFalse);
      expect(isSlotTimeInPreferredBlock('night', '12:30 AM'), isFalse);
    });
  });

  group('isSlotTimeInPreferredBlock — 24h format parsing', () {
    test('24h format is parsed the same as 12h equivalents', () {
      expect(isSlotTimeInPreferredBlock('morning', '08:00'), isTrue);
      expect(isSlotTimeInPreferredBlock('evening', '18:00'), isTrue);
      expect(isSlotTimeInPreferredBlock('night', '21:00'), isTrue);
    });
  });

  group('classReminderTitleForStatus / classReminderBodyForStatus', () {
    test('Cancelled status', () {
      expect(classReminderTitleForStatus('Cancelled'), 'Class Cancelled');
      expect(classReminderBodyForStatus('Cancelled'),
          'Sorry, your upcoming class has been cancelled.');
    });

    test('In Progress status', () {
      expect(classReminderTitleForStatus('In Progress'), 'Sweat Now, Selfies Later 💪');
      expect(classReminderBodyForStatus('In Progress'), 'Join the session now.');
    });

    test('any other/unknown/null status falls back to the default "link added" copy', () {
      expect(classReminderTitleForStatus('Confirmed'), 'Class Link Added');
      expect(classReminderTitleForStatus(null), 'Class Link Added');
      expect(classReminderBodyForStatus('Confirmed'), 'Join the session now.');
    });
  });
}
