// Basic unit tests for the meal-log helpers used by the paid home
// screen's Nutrition/Meals cards (lib/data/models/meal_log/meal_log.dart).
// Pure functions only — no GetX controllers, no network, no widgets —
// so these run instantly and don't need any mocking.
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/models/meal_log/meal_log.dart';

void main() {
  group('currentMealForNow — time-of-day → meal slot', () {
    test('4:00–10:59 is breakfast', () {
      expect(currentMealForNow(DateTime(2026, 1, 1, 4, 0)), MealType.breakfast);
      expect(currentMealForNow(DateTime(2026, 1, 1, 10, 59)), MealType.breakfast);
    });

    test('11:00–16:59 is lunch', () {
      expect(currentMealForNow(DateTime(2026, 1, 1, 11, 0)), MealType.lunch);
      expect(currentMealForNow(DateTime(2026, 1, 1, 16, 59)), MealType.lunch);
    });

    test('17:00–3:59 (including past midnight) is dinner', () {
      expect(currentMealForNow(DateTime(2026, 1, 1, 17, 0)), MealType.dinner);
      expect(currentMealForNow(DateTime(2026, 1, 1, 23, 59)), MealType.dinner);
      expect(currentMealForNow(DateTime(2026, 1, 1, 1, 0)), MealType.dinner);
      expect(currentMealForNow(DateTime(2026, 1, 1, 3, 59)), MealType.dinner);
    });
  });

  group('MealType <-> String round-trip', () {
    test('every MealType survives toString -> fromString', () {
      for (final t in MealType.values) {
        expect(mealTypeFromString(mealTypeToString(t)), t);
      }
    });

    test('unknown/null string falls back to breakfast', () {
      expect(mealTypeFromString(null), MealType.breakfast);
      expect(mealTypeFromString('brunch'), MealType.breakfast);
    });
  });

  group('MealStatus <-> String round-trip', () {
    test('every MealStatus survives toString -> fromString', () {
      for (final s in MealStatus.values) {
        expect(mealStatusFromString(mealStatusToString(s)), s);
      }
    });

    test('unknown/null string falls back to pending', () {
      expect(mealStatusFromString(null), MealStatus.pending);
      expect(mealStatusFromString('bogus'), MealStatus.pending);
    });
  });

  group('MealLog.fromJson / toJson', () {
    test('round-trips the fields the backend actually reads back', () {
      final log = MealLog(
        date: '2026-07-21',
        mealType: MealType.lunch,
        status: MealStatus.followed,
        reasonCode: 'busy',
        alternativeText: 'had a salad instead',
      );
      final json = log.toJson();
      expect(json['date'], '2026-07-21');
      expect(json['mealType'], 'lunch');
      expect(json['status'], 'followed');
      expect(json['reasonCode'], 'busy');
      expect(json['alternativeText'], 'had a salad instead');
    });

    test('fromJson defaults missing editable to true', () {
      final log = MealLog.fromJson({
        'date': '2026-07-21',
        'mealType': 'dinner',
        'status': 'pending',
      });
      expect(log.editable, isTrue);
      expect(log.mealType, MealType.dinner);
      expect(log.status, MealStatus.pending);
    });

    test('fromJson respects editable: false (7-day edit window closed)', () {
      final log = MealLog.fromJson({
        'date': '2026-07-01',
        'mealType': 'breakfast',
        'status': 'followed',
        'editable': false,
      });
      expect(log.editable, isFalse);
    });
  });
}
