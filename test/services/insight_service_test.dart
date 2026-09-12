// These tests check structure/behavior, not exact copy text, so they
// stay valid if the static insight content (StaticInsights/PhaseConfig)
// is edited later — only the logic that picks/falls back is asserted.
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_zone_2/data/services/cycle_engine.dart';
import 'package:fitness_zone_2/data/services/insight_service.dart';

void main() {
  group('InsightService.getTodayInsight', () {
    test('null cycleInfo returns a generic insight with non-empty title/body', () {
      final insight = InsightService.getTodayInsight(null);
      expect(insight.title, isNotEmpty);
      expect(insight.body, isNotEmpty);
      expect(insight.energy, isNull);
      expect(insight.mood, isNull);
    });

    test('menstrual phase day 1 returns a non-empty insight', () {
      const cycleInfo = CycleInfo(cycleDay: 1, phase: 'menstrual');
      final insight = InsightService.getTodayInsight(cycleInfo);
      expect(insight.title, isNotEmpty);
      expect(insight.body, isNotEmpty);
    });

    test('luteal phase falls back gracefully for a day far past normal range', () {
      // day 100 is absurd but should not throw — should fall back to the
      // last matching template rather than returning null/crashing.
      const cycleInfo = CycleInfo(cycleDay: 100, phase: 'luteal');
      expect(() => InsightService.getTodayInsight(cycleInfo), returnsNormally);
      final insight = InsightService.getTodayInsight(cycleInfo);
      expect(insight.title, isNotEmpty);
      expect(insight.body, isNotEmpty);
    });

    test('unknown phase string does not throw, falls back to defaults', () {
      const cycleInfo = CycleInfo(cycleDay: 5, phase: 'not_a_real_phase');
      expect(() => InsightService.getTodayInsight(cycleInfo), returnsNormally);
      final insight = InsightService.getTodayInsight(cycleInfo);
      // No nudge template matches -> falls back to the generic defaults
      // baked into getTodayInsight's `??` fallbacks.
      expect(insight.title, 'Your daily insight');
      expect(insight.body, 'Listen to your body and move at your own pace.');
      expect(insight.energy, isNull);
      expect(insight.mood, isNull);
    });
  });
}
