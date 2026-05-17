import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/meal_log_controller/meal_log_controller.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../../data/models/meal_log/meal_log.dart';
import 'log_weight_modal.dart';
import 'paid_cycle_card.dart';
import 'set_target_weight_modal.dart';

// TODO: Replace static values with real data
// - Workouts: connect to dashboard.stats.workoutsThisWeek (was wired
//   pre-demo, reverted to static "4" for HBL visual completeness)
// - Weight: connect to weight tracking — modal still wired but value
//   display is static
// - Calories: connect to calorie counter when re-enabled
// - Nutrition: connect to diet plan adherence when available
//
// NOTE: Row 2 hosts the existing PaidCycleCard alongside Nutrition.
// paid_home_screen_v2.dart MUST NOT also emit PaidCycleCard at the
// screen level — that would double-render the same widget.

/// Two-row stats grid below the hero.
///
///   Row 1: Workouts | Weight | Calories   (3 equal cards)
///   Row 2: Cycle | Nutrition               (2 equal cards, side-by-side)
///
/// Row 1 values are static placeholders for the HBL demo (see tech-debt
/// block above). Row 2's Cycle card is the existing `PaidCycleCard`
/// widget — placed alongside Nutrition rather than full-width below the
/// stats row. The screen-level `paid_home_screen_v2.dart` no longer
/// emits `PaidCycleCard` separately to avoid double-rendering.
///
/// If cycle data is missing (cycleDay null), `PaidCycleCard` collapses
/// to `SizedBox.shrink()`. Row 2 detects that and falls back to
/// rendering Nutrition full-width so the layout doesn't show an empty
/// half-row.
///
/// Card shell mirrors the existing water/sleep visual: white bg, mint
/// border, 20-radius, soft shadow.
class PaidStatsRow extends StatelessWidget {
  final HomeDashboardModel dashboard;

  const PaidStatsRow({Key? key, required this.dashboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1 — 3 cards.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _WorkoutsCard(dashboard: dashboard)),
              const SizedBox(width: 7),
              Expanded(child: _WeightCard(dashboard: dashboard)),
              const SizedBox(width: 7),
              Expanded(child: _CaloriesCard(dashboard: dashboard)),
            ],
          ),
        ),
        const SizedBox(height: 7),
        // Row 2 — Cycle + Nutrition side-by-side. Falls back to
        // Nutrition full-width if cycle data is missing (PaidCycleCard
        // would otherwise collapse to a 0-width void inside its
        // Expanded slot, leaving an unbalanced half-row).
        if ((dashboard.cycle?.cycleDay) != null)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: PaidCycleCard(dashboard: dashboard)),
                const SizedBox(width: 7),
                Expanded(child: _NutritionCard(dashboard: dashboard)),
              ],
            ),
          )
        else
          _NutritionCard(dashboard: dashboard),
      ],
    );
  }
}

// ─── Row 1, Card 1 ───────────────────────────────────────────────────────

class _WorkoutsCard extends StatelessWidget {
  final HomeDashboardModel dashboard;
  const _WorkoutsCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    // STATIC for HBL demo — was previously dashboard.stats?.workoutsThisWeek.
    // See tech-debt note at top of file.
    return const _CardShell(
      child: _StatColumn(
        label: '🏋️ Workouts',
        value: '4',
        sub: 'this week',
      ),
    );
  }
}

// ─── Row 1, Card 2 ───────────────────────────────────────────────────────

/// Replaces the previous `_ProgressCard`. Visual value is static for the
/// HBL demo, BUT the tap-to-log-weight flow is preserved exactly: hands
/// off to `SetTargetWeightModal` when no goal exists, otherwise to
/// `LogWeightModal` seeded with the current weight. Real user weight-
/// logging behaviour is unchanged.
class _WeightCard extends StatelessWidget {
  final HomeDashboardModel dashboard;
  const _WeightCard({required this.dashboard});

  void _onTap(BuildContext context) {
    final goal = dashboard.goal;
    final hasGoal = goal?.targetWeightKg != null;
    if (!hasGoal) {
      SetTargetWeightModal.show(context: context, dashboard: dashboard);
    } else {
      LogWeightModal.show(
        context: context,
        dashboard: dashboard,
        initialKg: goal?.currentWeightKg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: () => _onTap(context),
      child: const _StatColumn(
        label: '⚖️ Weight',
        // STATIC display — modal flow on tap is live.
        value: '-0.4',
        sub: 'kg/week',
      ),
    );
  }
}

// ─── Row 1, Card 3 ───────────────────────────────────────────────────────

class _CaloriesCard extends StatelessWidget {
  final HomeDashboardModel dashboard;
  const _CaloriesCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    // STATIC for HBL demo — backend doesn't track daily kcal yet
    // (DashboardController emits caloriesRemaining/dailyKcalBudget=null).
    return const _CardShell(
      child: _StatColumn(
        label: '🍎 Calories',
        value: '322',
        sub: 'kcal left',
      ),
    );
  }
}

// ─── Row 2 ───────────────────────────────────────────────────────────────

class _NutritionCard extends StatelessWidget {
  final HomeDashboardModel dashboard;
  const _NutritionCard({required this.dashboard});

  static String _slotName(MealType t) {
    switch (t) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.dinner:
        return 'dinner';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve once per build — slot only changes hour-to-hour, and the
    // accordion state is reactive via Obx below.
    final slot = currentMealForNow();
    // Defensive lookup — GetX's lazyPut bindings can fall out of the
    // registry on hot-reload when get_di.dart is edited without a full
    // hot-restart. Re-register on demand so the Nutrition card doesn't
    // bring the whole home screen down with "MealLogController not
    // found". Idempotent: if it's already there, isRegistered short-
    // circuits to the existing instance.
    if (!Get.isRegistered<MealLogController>()) {
      Get.put(MealLogController(
        homeRepo: Get.find(),
        sharedPreferences: Get.find(),
      ));
    }
    final ctrl = Get.find<MealLogController>();
    return _CardShell(
      onTap: ctrl.toggleTodayMeals,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _StatColumn(
            label: '🥗 Nutrition',
            value: '82%',
            sub: 'diet plan',
            valueFontSize: 26,
            subFontSize: 10,
          ),
          const SizedBox(height: 6),
          Obx(() {
            final expanded = ctrl.todayMealsExpanded.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Log ${_slotName(slot)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163220),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  // 0.25 turns = 90° clockwise → arrow points down.
                  turns: expanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: Color(0xFF163220),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Shared bits ─────────────────────────────────────────────────────────

/// Standard label / value / sub stack used by every card. Centralises
/// font sizing + colours so the 5 cards stay visually identical.
/// Mirrors the original `_WorkoutsCard` block in the previous version
/// of this file.
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final double valueFontSize;
  final double subFontSize;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.sub,
    this.valueFontSize = 21,
    this.subFontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF9AB09A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF6DC55A),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subFontSize,
            color: const Color(0xFF9AB09A),
          ),
        ),
      ],
    );
  }
}

/// Shared card shell — white bg, mint border, 20 radius, soft shadow.
/// Mirrors water/sleep cards visually. Optional `onTap` for the
/// interactive Weight variant (preserves the previous _ProgressCard's
/// tap-to-log-weight behaviour).
class _CardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const _CardShell({
    required this.child,
    this.onTap,
    // Default mirrors HTML stats-card padding (11px vert, 6px horiz).
    // Override for the wider Nutrition cell which uses .card padding.
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
