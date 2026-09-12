import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/services/cycle_engine.dart';

void main() {
  group('CycleEngine.calculate', () {
    test('returns null when lastPeriodDate is null', () {
      final result = CycleEngine.calculate(lastPeriodDate: null, cycleLength: 28);
      expect(result, isNull);
    });

    test('day 1 (today == lastPeriodDate) is menstrual', () {
      final today = DateTime(2026, 7, 21);
      final result = CycleEngine.calculate(
        lastPeriodDate: today,
        cycleLength: 28,
        today: today,
      );
      expect(result!.cycleDay, 1);
      expect(result.phase, 'menstrual');
    });

    test('mid-cycle day lands in follicular/ovulatory as expected (28-day cycle)', () {
      final lastPeriod = DateTime(2026, 7, 1);
      // Day 14 of a 28-day cycle.
      final result = CycleEngine.calculate(
        lastPeriodDate: lastPeriod,
        cycleLength: 28,
        today: DateTime(2026, 7, 14),
      );
      expect(result!.cycleDay, 14);
      // menstrualEnd=5, follicularEnd=13, ovulatoryEnd=16 for a 28-day cycle
      expect(result.phase, 'ovulatory');
    });

    test('late period (past cycleLength) keeps counting, does not modulo, stays luteal', () {
      final lastPeriod = DateTime(2026, 7, 1);
      final result = CycleEngine.calculate(
        lastPeriodDate: lastPeriod,
        cycleLength: 28,
        today: DateTime(2026, 8, 5), // 35 days later
      );
      expect(result!.cycleDay, 36); // daysSince(35) + 1, not modulo
      expect(result.phase, 'luteal');
    });

    test('exactly at cycleLength boundary continues counting (daysSince >= cycleLength)', () {
      final lastPeriod = DateTime(2026, 1, 1);
      final result = CycleEngine.calculate(
        lastPeriodDate: lastPeriod,
        cycleLength: 28,
        today: DateTime(2026, 1, 29), // daysSince == 28 == cycleLength
      );
      expect(result!.cycleDay, 29);
    });
  });

  group('CycleEngine.getPhaseBoundaries', () {
    test('boundaries are contiguous and cover 1..cycleLength for a 28-day cycle', () {
      final boundaries = CycleEngine.getPhaseBoundaries(28);
      expect(boundaries['menstrual'], [1, 5]);
      expect(boundaries['follicular'], [6, 13]);
      expect(boundaries['ovulatory'], [14, 16]);
      expect(boundaries['luteal'], [17, 28]);
    });

    test('boundaries scale for a shorter 21-day cycle', () {
      final boundaries = CycleEngine.getPhaseBoundaries(21);
      // menstrualEnd = round(21*0.18)=4, follicularEnd=round(21*0.46)=10,
      // ovulatoryEnd=round(21*0.57)=12
      expect(boundaries['menstrual'], [1, 4]);
      expect(boundaries['follicular'], [5, 10]);
      expect(boundaries['ovulatory'], [11, 12]);
      expect(boundaries['luteal'], [13, 21]);
    });
  });
}
