import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/services/progress_service.dart';

void main() {
  group('ProgressService.countCheckinsThisWeek', () {
    test('counts list length regardless of content', () {
      expect(ProgressService.countCheckinsThisWeek([]), 0);
      expect(
        ProgressService.countCheckinsThisWeek([
          {'date': '2026-07-20'},
          {'date': '2026-07-21'},
        ]),
        2,
      );
    });
  });

  group('ProgressService.countCheckinsThisCycle', () {
    test('only counts checkins on/after lastPeriodDate', () {
      final result = ProgressService.countCheckinsThisCycle(
        [
          {'date': '2026-06-30'}, // before period, excluded
          {'date': '2026-07-01'}, // == period start, included
          {'date': '2026-07-15'}, // after, included
        ],
        DateTime(2026, 7, 1),
      );
      expect(result, 2);
    });

    test('checkins missing a date field are skipped', () {
      final result = ProgressService.countCheckinsThisCycle(
        [
          {'date': '2026-07-05'},
          {'other': 'field'},
        ],
        DateTime(2026, 7, 1),
      );
      expect(result, 1);
    });
  });

  group('ProgressService.getProgressReport', () {
    test('weeklyReportReady is true at exactly 4 checkins, false at 3', () {
      final ready = ProgressService.getProgressReport(
        weekCheckins: List.generate(4, (_) => <String, dynamic>{}),
        recentCheckins: const [],
      );
      expect(ready.weeklyReportReady, isTrue);

      final notReady = ProgressService.getProgressReport(
        weekCheckins: List.generate(3, (_) => <String, dynamic>{}),
        recentCheckins: const [],
      );
      expect(notReady.weeklyReportReady, isFalse);
    });

    test('monthlyReportReady is true at exactly 15 cycle checkins, false at 14', () {
      final lastPeriod = DateTime(2026, 7, 1);
      final checkins = List.generate(
        15,
        (i) => {'date': '2026-07-${(i + 1).toString().padLeft(2, '0')}'},
      );
      final ready = ProgressService.getProgressReport(
        weekCheckins: const [],
        recentCheckins: checkins,
        lastPeriodDate: lastPeriod,
      );
      expect(ready.checkinsThisCycle, 15);
      expect(ready.monthlyReportReady, isTrue);

      final notReady = ProgressService.getProgressReport(
        weekCheckins: const [],
        recentCheckins: checkins.sublist(0, 14),
        lastPeriodDate: lastPeriod,
      );
      expect(notReady.monthlyReportReady, isFalse);
    });

    test('null lastPeriodDate means checkinsThisCycle is 0, not an error', () {
      final result = ProgressService.getProgressReport(
        weekCheckins: const [],
        recentCheckins: [
          {'date': '2026-07-01'},
        ],
        lastPeriodDate: null,
      );
      expect(result.checkinsThisCycle, 0);
      expect(result.monthlyReportReady, isFalse);
    });
  });
}
