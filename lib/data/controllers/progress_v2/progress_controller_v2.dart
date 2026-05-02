import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../helper/analytics_helper.dart';
import '../../Repos/progress_v2/progress_repository.dart';
import '../../models/progress_v2/progress_models.dart';

/// Phase D — Progress hub state container. Owns:
///   * the period selector value (`Rx<String>`),
///   * one [CardState] per card (per-card load/error tracking),
///   * the AI-insights single-open `RxInt` (shared by 3 ExpandableCards).
///
/// Keeps the screen widget dumb — every Obx() in `progress_screen_v2.dart`
/// reads a single Rxn from this controller.
class ProgressControllerV2 extends GetxController {
  final ProgressRepository repo;

  ProgressControllerV2({required this.repo});

  /// Backend allow-list: week | month | 3month | 6month | year.
  /// Default month per brief §10 question 6 — no last-used persistence yet.
  final period = 'month'.obs;

  /// Insights expand-collapse coordinator. -1 = all closed.
  final insightsSelectedIndex = (-1).obs;

  // ───────── per-card state ──────────────────────────────────────────────
  // Each card has its own [CardState] so a single failing endpoint doesn't
  // collapse the whole screen into a generic error. The screen reads these
  // and dispatches to loading / empty / error / ready.

  final summary = Rx<CardState<ProgressSummary>>(CardState.loading());
  final weight = Rx<CardState<WeightTrend>>(CardState.loading());
  final glance = Rx<CardState<GlanceData>>(CardState.loading());
  final hydration = Rx<CardState<HydrationData>>(CardState.loading());
  final symptoms = Rx<CardState<SymptomsData>>(CardState.loading());
  final insights = Rx<CardState<InsightsHubData>>(CardState.loading());

  /// True while the topmost pull-to-refresh is animating. Distinct from
  /// per-card loading so a manual pull doesn't clear good data on screen.
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Period change → close any open insight (state stale) + refetch all.
    String? prevPeriod;
    ever(period, (next) {
      insightsSelectedIndex.value = -1;
      fetchAll();
      // E3 analytics. Skip the very first auto-fire (prevPeriod == null
      // means controller.onInit just ran) so we don't log a "change"
      // that's actually the initial value.
      if (prevPeriod != null && prevPeriod != next) {
        try {
          AnalyticsHelper.trackProgressV2PeriodChanged(
            from: prevPeriod,
            to: next as String,
          );
        } catch (_) {/* analytics optional */}
      }
      prevPeriod = next as String;
    });
    // First load.
    fetchAll();
  }

  /// Fires all 6 endpoints in parallel. Each card transitions to loading
  /// first (so a refetch shows a skeleton) and then to ready/error/empty
  /// independently as its future resolves.
  Future<void> fetchAll() async {
    final p = period.value;

    summary.value = CardState.loading(prev: summary.value.data);
    weight.value = CardState.loading(prev: weight.value.data);
    glance.value = CardState.loading(prev: glance.value.data);
    hydration.value = CardState.loading(prev: hydration.value.data);
    symptoms.value = CardState.loading(prev: symptoms.value.data);
    insights.value = CardState.loading(prev: insights.value.data);

    await Future.wait([
      _runSummary(p),
      _runWeight(p),
      _runGlance(p),
      _runHydration(p),
      _runSymptoms(p),
      _runInsights(p),
    ]);
  }

  /// Pull-to-refresh entry point. Named `refreshAll` to dodge the conflict
  /// with the inherited `Listenable.refresh` shape and keep the intent
  /// explicit at call sites.
  Future<void> refreshAll() async {
    isRefreshing.value = true;
    try {
      await fetchAll();
    } finally {
      isRefreshing.value = false;
    }
  }

  // ───────── per-endpoint runners ────────────────────────────────────────

  Future<void> _runSummary(String p) async {
    try {
      final data = await repo.getSummary(period: p);
      if (data == null) {
        summary.value = CardState.error('Could not load summary');
      } else {
        summary.value = CardState.ready(data);
      }
    } catch (e) {
      debugPrint('[ProgressControllerV2.summary] $e');
      summary.value = CardState.error('Could not load summary');
    }
  }

  Future<void> _runWeight(String p) async {
    try {
      final data = await repo.getWeight(period: p);
      if (data == null) {
        weight.value = CardState.error('Could not load weight trend');
      } else {
        weight.value = CardState.ready(data);
      }
    } catch (e) {
      debugPrint('[ProgressControllerV2.weight] $e');
      weight.value = CardState.error('Could not load weight trend');
    }
  }

  Future<void> _runGlance(String p) async {
    try {
      final data = await repo.getGlance(period: p);
      if (data == null) {
        glance.value = CardState.error('Could not load glance');
      } else {
        glance.value = CardState.ready(data);
      }
    } catch (e) {
      debugPrint('[ProgressControllerV2.glance] $e');
      glance.value = CardState.error('Could not load glance');
    }
  }

  Future<void> _runHydration(String p) async {
    try {
      final data = await repo.getHydration(period: p);
      if (data == null) {
        hydration.value = CardState.error('Could not load hydration');
      } else {
        hydration.value = CardState.ready(data);
      }
    } catch (e) {
      debugPrint('[ProgressControllerV2.hydration] $e');
      hydration.value = CardState.error('Could not load hydration');
    }
  }

  Future<void> _runSymptoms(String p) async {
    try {
      final data = await repo.getSymptoms(period: p);
      if (data == null) {
        symptoms.value = CardState.error('Could not load symptoms');
      } else {
        symptoms.value = CardState.ready(data);
      }
    } catch (e) {
      debugPrint('[ProgressControllerV2.symptoms] $e');
      symptoms.value = CardState.error('Could not load symptoms');
    }
  }

  Future<void> _runInsights(String p) async {
    try {
      final data = await repo.getInsightsHub(period: p);
      if (data == null) {
        insights.value = CardState.error('Could not load insights');
      } else {
        insights.value = CardState.ready(data);
      }
    } catch (e) {
      debugPrint('[ProgressControllerV2.insights] $e');
      insights.value = CardState.error('Could not load insights');
    }
  }
}

/// Discriminated union for per-card state. We want `loading + previous
/// data` so that on a period switch the chart doesn't flash empty —
/// a skeleton overlay is enough.
class CardState<T> {
  final CardStatus status;
  final T? data;
  final String? errorMessage;

  const CardState._(this.status, this.data, this.errorMessage);

  factory CardState.loading({T? prev}) =>
      CardState._(CardStatus.loading, prev, null);
  factory CardState.ready(T data) =>
      CardState._(CardStatus.ready, data, null);
  factory CardState.error(String message, {T? prev}) =>
      CardState._(CardStatus.error, prev, message);

  bool get isLoading => status == CardStatus.loading;
  bool get isReady => status == CardStatus.ready;
  bool get isError => status == CardStatus.error;
}

enum CardStatus { loading, ready, error }
