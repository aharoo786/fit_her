import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/services/accuracy_service.dart';

void main() {
  group('AccuracyService.calculateDayAccuracy', () {
    test('perfect match (diff 0) scores 1.0', () {
      final score = AccuracyService.calculateDayAccuracy(
        predictedEnergy: 5,
        actualEnergy: 5,
        predictedMood: 3,
        actualMood: 3,
      );
      expect(score, 1.0);
    });

    test('off-by-one still scores 1.0 (within tolerance)', () {
      final score = AccuracyService.calculateDayAccuracy(
        predictedEnergy: 5,
        actualEnergy: 4,
        predictedMood: 3,
        actualMood: 3,
      );
      expect(score, 1.0);
    });

    test('off-by-two scores 0.5 for that dimension', () {
      final score = AccuracyService.calculateDayAccuracy(
        predictedEnergy: 5,
        actualEnergy: 3, // diff 2 -> 0.5
        predictedMood: 3,
        actualMood: 3, // diff 0 -> 1.0
      );
      expect(score, (0.5 + 1.0) / 2.0);
    });

    test('off-by-three-or-more scores 0.0 for that dimension', () {
      final score = AccuracyService.calculateDayAccuracy(
        predictedEnergy: 5,
        actualEnergy: 1, // diff 4 -> 0.0
        predictedMood: 3,
        actualMood: 3, // diff 0 -> 1.0
      );
      expect(score, 0.5);
    });
  });

  group('AccuracyService.getRolling7DayAccuracy', () {
    test('fewer than 3 valid checkins returns null', () {
      final result = AccuracyService.getRolling7DayAccuracy([
        {'predictedEnergy': 5, 'predictedMood': 3, 'energyLevel': 5, 'moodLevel': 3},
        {'predictedEnergy': 5, 'predictedMood': 3, 'energyLevel': 5, 'moodLevel': 3},
      ]);
      expect(result, isNull);
    });

    test('checkins missing fields are skipped from the count', () {
      final result = AccuracyService.getRolling7DayAccuracy([
        {'predictedEnergy': 5, 'predictedMood': 3, 'energyLevel': 5, 'moodLevel': 3},
        {'predictedEnergy': 5, 'predictedMood': 3, 'energyLevel': 5, 'moodLevel': 3},
        {'predictedEnergy': null, 'predictedMood': 3, 'energyLevel': 5, 'moodLevel': 3},
        {'predictedEnergy': 5, 'predictedMood': 3, 'energyLevel': 5, 'moodLevel': 3},
      ]);
      // Only 3 of the 4 entries are valid -> should compute, not null.
      expect(result, isNotNull);
    });

    test('accuracy below 60% is suppressed (returns null, positive framing)', () {
      final result = AccuracyService.getRolling7DayAccuracy(List.generate(
        3,
        (_) => {
          'predictedEnergy': 5,
          'predictedMood': 5,
          'energyLevel': 1, // diff 4 -> 0.0 both dimensions
          'moodLevel': 1,
        },
      ));
      expect(result, isNull);
    });

    test('accuracy >= 60% is returned, clamped to [0,1]', () {
      final result = AccuracyService.getRolling7DayAccuracy(List.generate(
        3,
        (_) => {
          'predictedEnergy': 5,
          'predictedMood': 5,
          'energyLevel': 5,
          'moodLevel': 5,
        },
      ));
      expect(result, 1.0);
    });
  });

  group('AccuracyService.formatAccuracy', () {
    test('formats 0.78 as "78"', () {
      expect(AccuracyService.formatAccuracy(0.78), '78');
    });

    test('rounds correctly at the boundary', () {
      expect(AccuracyService.formatAccuracy(0.995), '100');
      expect(AccuracyService.formatAccuracy(0.0), '0');
    });
  });
}
