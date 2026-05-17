import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/utils/app_clock.dart';

void main() {
  setUp(() {
    AppClock.resetForTest();
  });

  group('AppClock — fallback behavior', () {
    test('returns ~device time before init', () {
      final beforeAny = DateTime.now();
      final clock = AppClock.now();
      final afterAny = DateTime.now();
      // With zero offset, AppClock.now() should fall between two
      // DateTime.now() snapshots taken around the call.
      expect(clock.isAfter(beforeAny.subtract(const Duration(seconds: 1))), isTrue);
      expect(clock.isBefore(afterAny.add(const Duration(seconds: 1))), isTrue);
    });

    test('isInitialized is false before init', () {
      expect(AppClock.isInitialized, isFalse);
    });

    test('lastSyncAt is null before init', () {
      expect(AppClock.lastSyncAt, isNull);
    });

    test('offset is zero before init', () {
      expect(AppClock.offset, Duration.zero);
    });
  });

  group('AppClock — setOffsetForTest', () {
    test('positive offset shifts now() forward', () {
      AppClock.setOffsetForTest(const Duration(minutes: 10));
      final shifted = AppClock.now();
      final device = DateTime.now();
      // shifted should be ~10 min ahead of device, allow 1s slack.
      final delta = shifted.difference(device);
      expect(delta.inSeconds, greaterThanOrEqualTo(599));
      expect(delta.inSeconds, lessThanOrEqualTo(601));
    });

    test('negative offset shifts now() backward', () {
      AppClock.setOffsetForTest(const Duration(minutes: -5));
      final shifted = AppClock.now();
      final device = DateTime.now();
      final delta = device.difference(shifted);
      expect(delta.inSeconds, greaterThanOrEqualTo(299));
      expect(delta.inSeconds, lessThanOrEqualTo(301));
    });

    test('setOffsetForTest marks initialized', () {
      AppClock.setOffsetForTest(const Duration(seconds: 30));
      expect(AppClock.isInitialized, isTrue);
      expect(AppClock.lastSyncAt, isNotNull);
    });
  });

  group('AppClock — resetForTest', () {
    test('clears offset back to zero', () {
      AppClock.setOffsetForTest(const Duration(hours: 1));
      AppClock.resetForTest();
      expect(AppClock.offset, Duration.zero);
      expect(AppClock.isInitialized, isFalse);
      expect(AppClock.lastSyncAt, isNull);
    });
  });

  group('AppClock — drop-in for DateTime.now()', () {
    test('successive now() calls are monotonically non-decreasing', () {
      AppClock.setOffsetForTest(const Duration(minutes: 3));
      final a = AppClock.now();
      final b = AppClock.now();
      final c = AppClock.now();
      // Allow equality within the same millisecond.
      expect(a.isBefore(b) || a.isAtSameMomentAs(b), isTrue);
      expect(b.isBefore(c) || b.isAtSameMomentAs(c), isTrue);
    });

    test('survives offset changes mid-test (recompute on next call)', () {
      AppClock.setOffsetForTest(const Duration(minutes: 5));
      final t1 = AppClock.now();
      AppClock.setOffsetForTest(const Duration(minutes: 10));
      final t2 = AppClock.now();
      // t2 is at least 4 minutes ahead of t1 (the 5-min offset bump,
      // minus the few ms of test wall time between calls).
      expect(t2.difference(t1).inMinutes, greaterThanOrEqualTo(4));
    });
  });
}
