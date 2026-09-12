import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/services/recommendation_service.dart';

void main() {
  group('RecommendationService.getSlotIntensity', () {
    test('exact match is case-insensitive', () {
      expect(RecommendationService.getSlotIntensity('Power HIIT'), 'high');
      expect(RecommendationService.getSlotIntensity('power hiit'), 'high');
    });

    test('partial match: "Yoga" matches a yoga variant', () {
      final intensity = RecommendationService.getSlotIntensity('Yoga');
      expect(intensity, isNotNull);
      expect(['medium', 'low'], contains(intensity));
    });

    test('null or empty type returns null', () {
      expect(RecommendationService.getSlotIntensity(null), isNull);
      expect(RecommendationService.getSlotIntensity('   '), isNull);
    });

    test('unrecognized type returns null', () {
      expect(RecommendationService.getSlotIntensity('Underwater Basket Weaving'), isNull);
    });
  });

  group('RecommendationService.isRecommended', () {
    test('menstrual phase recommends only low intensity', () {
      expect(RecommendationService.isRecommended('Gentle Yoga', 'menstrual'), isTrue);
      expect(RecommendationService.isRecommended('Power HIIT', 'menstrual'), isFalse);
    });

    test('ovulatory phase recommends only high intensity', () {
      expect(RecommendationService.isRecommended('Power HIIT', 'ovulatory'), isTrue);
      expect(RecommendationService.isRecommended('Gentle Yoga', 'ovulatory'), isFalse);
    });

    test('follicular phase recommends medium and high', () {
      expect(RecommendationService.isRecommended('Pilates', 'follicular'), isTrue);
      expect(RecommendationService.isRecommended('Power HIIT', 'follicular'), isTrue);
      expect(RecommendationService.isRecommended('Gentle Yoga', 'follicular'), isFalse);
    });

    test('null slotType or phase is never recommended', () {
      expect(RecommendationService.isRecommended(null, 'menstrual'), isFalse);
      expect(RecommendationService.isRecommended('Power HIIT', null), isFalse);
    });

    test('unknown phase is never recommended', () {
      expect(RecommendationService.isRecommended('Power HIIT', 'nonexistent_phase'), isFalse);
    });

    test('phase matching is case-insensitive', () {
      expect(RecommendationService.isRecommended('Power HIIT', 'OVULATORY'), isTrue);
    });
  });

  group('RecommendationService.filterRecommended', () {
    test('null phase returns empty list', () {
      final result = RecommendationService.filterRecommended<String>(
        ['Power HIIT', 'Gentle Yoga'],
        (s) => s,
        null,
      );
      expect(result, isEmpty);
    });

    test('filters to only recommended items for the phase', () {
      final slots = ['Power HIIT', 'Gentle Yoga', 'Cardio Blast', 'Meditation & Breathwork'];
      final result = RecommendationService.filterRecommended<String>(
        slots,
        (s) => s,
        'ovulatory',
      );
      expect(result, ['Power HIIT', 'Cardio Blast']);
    });

    test('caps results at 5 even if more match', () {
      final slots = List.generate(10, (_) => 'Power HIIT');
      final result = RecommendationService.filterRecommended<String>(
        slots,
        (s) => s,
        'ovulatory',
      );
      expect(result.length, 5);
    });
  });
}
