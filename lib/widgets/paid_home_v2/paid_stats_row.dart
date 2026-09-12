import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../../data/controllers/meal_log_controller/meal_log_controller.dart';
import '../../data/models/diet_plan_v2/diet_plan_v2_models.dart';
import '../../data/models/diet_plan_v2/meal_log_v2.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../../data/models/meal_log/meal_log.dart';
import 'log_weight_modal.dart';
import 'paid_meal_log_card.dart';
import 'set_target_weight_modal.dart';

// TODO: Replace static values with real data
// - Workouts: connect to dashboard.stats.workoutsThisWeek (was wired
//   pre-demo, reverted to static "4" for HBL visual completeness)
// - Weight: connect to weight tracking — modal still wired but value
//   display is static
// - Calories: connect to calorie counter when re-enabled
//
// NOTE: PaidCycleCard now lives in paid_home_screen_v2.dart (paired
// with Meals/Nutrition there). Do not re-add it here — that would
// double-render the same widget.

/// Stats grid below the hero — just the top row of 3 equal cards
/// (Workouts | Weight | Calories).
///
/// Cycle used to render here as a full-width "Row 2", but that left the
/// no-plan case with two lonely full-width cards stacked on top of each
/// other (Cycle, then Meals). Cycle now lives in paid_home_screen_v2.dart
/// so it can be paired into a Row with whichever card belongs next to it
/// (Meals when there's no plan yet, or sit above the Nutrition+Meals
/// pair once there is) — single place decides the whole layout instead
/// of splitting the decision across two files.
///
/// Row 1 values are static placeholders for the HBL demo (see tech-debt
/// block above). Card shell mirrors the existing water/sleep visual:
/// white bg, mint border, 20-radius, soft shadow.
class PaidStatsRow extends StatelessWidget {
  final HomeDashboardModel dashboard;

  const PaidStatsRow({Key? key, required this.dashboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
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

/// Promoted from `_NutritionCard` so paid_home_screen_v2.dart can render
/// it directly next to PaidMealLogCard in a shared row. PaidStatsRow no
/// longer emits it in Row 2; the home screen owns its placement now.
///
/// Only ever mounted when the user has an active structured diet plan
/// (paid_home_screen_v2.dart gates this — see the Obx wrapper around
/// this row) — a "% diet plan" figure is meaningless without a real
/// plan to measure against, so this card no longer renders a fake
/// static number for plan-less users.
class PaidNutritionCard extends StatelessWidget {
  final HomeDashboardModel dashboard;
  const PaidNutritionCard({Key? key, required this.dashboard})
      : super(key: key);

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
    return _CardShell(
      // Tap-anywhere opens the shared meal-log sheet — same target as the
      // adjacent PaidMealSummaryCard. PaidMealLogCard is no longer
      // embedded on the home screen, so toggling the in-place accordion
      // would have no visible effect.
      onTap: () => _openMealLogSheet(context),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            // Real adherence, computed from today's structured-plan
            // logs: % of today's meals marked "followed" (alternative
            // and skipped both count against adherence, pending simply
            // hasn't happened yet and is excluded from the denominator
            // used for display parity with the "X of N logged" pill
            // elsewhere — but IS counted here so a day full of unlogged
            // meals doesn't misleadingly read as 100%).
            final dietCtrl = Get.find<DietPlanUserController>();
            final day = dietCtrl.todaysDay;
            String value = '--';
            if (day != null && day.meals.isNotEmpty) {
              final logs = dietCtrl.todayLogsByType;
              final total = day.meals.length;
              final followed = day.meals.where((m) {
                final log = logs[m.mealType.wire];
                return log?.status == MealLogStatusV2.followed;
              }).length;
              value = '${((followed / total) * 100).round()}%';
            }
            return _StatColumn(
              label: '🥗 Nutrition',
              value: value,
              sub: 'diet plan',
              valueFontSize: 26,
              subFontSize: 10,
            );
          }),
          const SizedBox(height: 6),
          Row(
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
              const Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: Color(0xFF163220),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact "today's meals" summary that pairs visually with
/// PaidNutritionCard in a half-width row. Tapping opens the same shared
/// meal-log sheet (`_openMealLogSheet`) — single entry point so both
/// cards behave identically.
class PaidMealSummaryCard extends StatelessWidget {
  const PaidMealSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Same defensive lookup as PaidNutritionCard — controller can fall
    // out of GetX's registry on hot-reload.
    if (!Get.isRegistered<MealLogController>()) {
      Get.put(MealLogController(
        homeRepo: Get.find(),
        sharedPreferences: Get.find(),
      ));
    }
    final ctrl = Get.find<MealLogController>();
    return _CardShell(
      onTap: () => _openMealLogSheet(context),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            // Structured plan (if active) is the source of truth for the
            // real meal count — a plan can have more or fewer than the
            // legacy 3 (breakfast/lunch/dinner), so showing "1/3" for a
            // 5-meal plan would be wrong. Fall back to the legacy count
            // only when there's no active plan to read from.
            int logged;
            int total;
            final dietCtrl = Get.isRegistered<DietPlanUserController>()
                ? Get.find<DietPlanUserController>()
                : null;
            final day = dietCtrl?.todaysDay;
            if (dietCtrl?.activePlan.value != null &&
                day != null &&
                day.meals.isNotEmpty) {
              final logs = dietCtrl!.todayLogsByType;
              total = day.meals.length;
              logged = day.meals.where((m) {
                final log = logs[m.mealType.wire];
                return log != null && log.status != MealLogStatusV2.pending;
              }).length;
            } else {
              total = MealType.values.length;
              logged = ctrl.todayMeals.values
                  .where((m) => m.status != MealStatus.pending)
                  .length;
            }
            return _StatColumn(
              label: '🍽 Meals',
              value: '$logged/$total',
              sub: 'logged today',
              valueFontSize: 26,
              subFontSize: 10,
            );
          }),
          const SizedBox(height: 6),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Log meals',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163220),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: Color(0xFF163220),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared "open meal log" sheet used by PaidNutritionCard +
/// PaidMealSummaryCard. Forces the embedded PaidMealLogCard into its
/// expanded state on open so the user lands directly on the meals
/// to log — they shouldn't need to tap a header to expand inside a
/// sheet that's already dedicated to logging.
void _openMealLogSheet(BuildContext context) {
  if (Get.isRegistered<MealLogController>()) {
    final ctrl = Get.find<MealLogController>();
    if (!ctrl.todayMealsExpanded.value) {
      ctrl.toggleTodayMeals();
    }
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9FCF7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4EC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const PaidMealLogCard(),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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
