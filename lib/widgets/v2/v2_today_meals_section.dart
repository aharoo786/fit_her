import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../UI/consultation_module/booking/book_consultation_sheet.dart';
import '../../UI/diet_screen/user_v2/day7_review_screen.dart';
import '../../UI/plans_module/all_plans.dart';
import '../../data/controllers/day7_review_controller/day7_review_controller.dart';
import '../../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../../data/models/diet_plan_v2/diet_plan_v2_models.dart';
import '../../data/models/diet_plan_v2/meal_log_v2.dart';
import 'v2_bottom_sheet.dart';
import 'v2_buttons.dart';
import 'v2_day_strip.dart';
import 'v2_plan_timeline_banner.dart';

const Color _kCream = Color(0xFFEAF7E4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kDanger = Color(0xFFE07B7B);
// Phase F.2 — "alternative" status indicator. Phase tint reused from
// luteal so the colour vocabulary is consistent with paid_home_v2.
const Color _kAlternative = Color(0xFFFAC775);

/// Shared follow-up booking flow used by Phase G.2's timeline banner
/// and Phase F.3's "Plan Completed" empty state. Lazy-loads the
/// booking context first (the banner can fire from the active-plan
/// path where context isn't auto-fetched), then routes:
///   • bookingContext.canBook → BookConsultationSheet (kind: followup)
///   • else → OurPlansScreen (silent fallback — no error snackbar)
Future<void> _bookFollowUpFromContext(String popupVariable) async {
  final ctrl = Get.find<DietPlanUserController>();
  // Idempotent — returns immediately if already loaded or in flight.
  await ctrl.loadBookingContext();
  final ctx = ctrl.bookingContext.value;
  if (ctx != null && ctx.canBook) {
    await BookConsultationSheet.show(
      popupVariable: popupVariable,
      dietitianId: ctx.dietitianId!,
      userId: ctx.userId!,
      userPlanId: ctx.userPlanId!,
      kind: 'followup',
    );
    return;
  }
  Get.to<dynamic>(() => OurPlansScreen());
}

Future<void> _onTimelineBookFollowUp(DietPlanUserController _) async {
  // Distinct popup variable so analytics can tell where the booking
  // came from (banner vs end-of-plan empty state).
  await _bookFollowUpFromContext('POPUP_PLAN_ENDING_SOON');
}

/// Public entry point for the V2 meal log sheet. Used by both this
/// file (Diet tab meal cards on today) and `PaidMealLogCard` on the
/// paid home so both surfaces share the exact same Phase F.2 logging
/// flow (3 buttons + alternative-text reveal + optimistic update +
/// revert on failure).
///
/// The actual body lives in this file as `_MealLogSheetBody`; this
/// helper just wraps the bottom-sheet show-call so callers don't need
/// to know the private widget exists.
Future<void> showV2MealLogSheet({required DietPlanMealV2 meal}) {
  return V2BottomSheet.show<void>(
    title: meal.mealType.label,
    child: _MealLogSheetBody(meal: meal),
  );
}

/// Phase G.3 — Day 7 check-in trigger banner. Self-contained: hides
/// itself when the controller says ineligible (no active plan, today
/// < 7, or already submitted/dismissed for this cycle).
///
/// Visual: white card, 4px accent-green left rail, mint border on the
/// other three sides, small caps "QUICK CHECK-IN" header, 1-line
/// prompt, full-width V2PrimaryButton + dismiss X.
///
/// Public (Phase H follow-up) so paid_home_screen_v2.dart can mount
/// the same banner at the top of the cream body — both surfaces share
/// the same Day7ReviewController, so submitting/dismissing from either
/// flips eligibility on both instantly.
class V2Day7TriggerBanner extends StatelessWidget {
  const V2Day7TriggerBanner({super.key});

  void _openCheckIn(DietPlanUserController dietCtrl) {
    final plan = dietCtrl.activePlan.value;
    final userPlanId = plan?.userPlanId;
    if (userPlanId == null) return;
    Get.to<dynamic>(() => Day7ReviewScreen(
          userPlanId: userPlanId,
          cycle: Get.find<Day7ReviewController>().currentCycle,
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<Day7ReviewController>()) {
      return const SizedBox.shrink();
    }
    final ctrl = Get.find<Day7ReviewController>();
    final dietCtrl = Get.find<DietPlanUserController>();
    return Obx(() {
      if (!ctrl.isEligible.value) return const SizedBox.shrink();
      if (dietCtrl.activePlan.value == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: _kAccent, width: 4),
              top: BorderSide(color: _kCardBorder),
              right: BorderSide(color: _kCardBorder),
              bottom: BorderSide(color: _kCardBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: _kHeroDark.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 6.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'QUICK CHECK-IN',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: _kAccent,
                        letterSpacing: 0.84,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: ctrl.dismiss,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: _kSage),
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 2.h, 8.w, 12.h),
                child: Text(
                  'How is your plan going? Share a quick update with '
                  'your dietitian.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _kHeroDark,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: V2PrimaryButton(
                  label: 'Take 2 minutes',
                  leadingIcon: Icons.rate_review_outlined,
                  onPressed: () => _openCheckIn(dietCtrl),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Phase F.1 — "today's meals" surface for the user. Renders 4 states
/// off `DietPlanUserController`: loading, error, no-active-plan
/// (Option B empty state), plan-ended, and the loaded list of meal
/// cards sorted by time.
///
/// Lives as a `Section` widget so callers (the diet bottom-nav tab,
/// future home embeds) wrap it in their own scaffold + scroll. The
/// section provides padding internally so it can be dropped into a
/// SingleChildScrollView or directly into a Scaffold body.
class V2TodayMealsSection extends StatelessWidget {
  const V2TodayMealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DietPlanUserController>();
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.activePlan.value == null) {
        return const _LoadingState();
      }
      if (ctrl.errorMessage.value != null && ctrl.activePlan.value == null) {
        return _ErrorState(
          message: ctrl.errorMessage.value!,
          onRetry: () => ctrl.loadActivePlan(refresh: true),
        );
      }
      final plan = ctrl.activePlan.value;
      if (plan == null) {
        // Phase F.3 — lazily fetch booking context so the CTA can open
        // BookConsultationSheet with real IDs. Idempotent on the
        // controller side; safe to schedule on every empty-state paint.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ctrl.loadBookingContext();
        });
        return const _NoPlanState();
      }
      if (ctrl.planHasEnded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ctrl.loadBookingContext();
        });
        return _PlanEndedState(plan: plan);
      }
      final today = ctrl.todaysDay;
      if (today == null) {
        // Plan exists but today doesn't map to a day — usually means the
        // plan was just activated and we're still ahead of `activatedAt`.
        // Render the same "completed" copy fallback so the screen is
        // never blank; the dietitian's view of dayNumber is the source
        // of truth.
        return _PlanEndedState(plan: plan);
      }
      // Phase G.1 — _LoadedState now drives day selection itself.
      return _LoadedState(plan: plan);
    });
  }
}

// ─── States ───────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: _Card(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kDanger.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.error_outline, color: _kDanger, size: 24.w),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _kHeroDark,
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: 160.w,
              child: V2SecondaryButton(label: 'Retry', onPressed: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPlanState extends StatelessWidget {
  const _NoPlanState();

  /// Phase F.3 — open BookConsultationSheet when we have real IDs from
  /// the booking-context endpoint; otherwise fall back to the paywall.
  /// `kind: 'initial'` because the user has no active plan and likely
  /// has never had one (no userPlanId means brand-new user → paywall).
  Future<void> _onBookConsultation() async {
    final ctrl = Get.find<DietPlanUserController>();
    final ctx = ctrl.bookingContext.value;
    if (ctx != null && ctx.canBook) {
      await BookConsultationSheet.show(
        popupVariable: 'POPUP_NO_PLAN_YET',
        dietitianId: ctx.dietitianId!,
        userId: ctx.userId!,
        userPlanId: ctx.userPlanId!,
        kind: 'initial',
      );
      return;
    }
    // Brand-new user (no UserPlan yet) — they need to buy a plan
    // before a dietitian gets assigned, so route to the paywall.
    Get.to<dynamic>(() => OurPlansScreen());
  }

  void _onTalkToSupport() {
    Get.snackbar(
      'Support',
      'Open the chat tab to message your dietitian.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: _Card(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text('🥗', style: TextStyle(fontSize: 48.sp))),
            SizedBox(height: 14.h),
            Center(
              child: Text(
                'NO PLAN YET',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: _kSage,
                  letterSpacing: 0.84,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Your dietitian hasn't shared a plan yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _kHeroDark,
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Book a consultation with your dietitian to get a '
              'personalized AI-powered meal plan tailored to your '
              'goals, cycle, and preferences.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: _kBodyMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 18.h),
            V2PrimaryButton(
              label: 'Book a Consultation',
              leadingIcon: Icons.event_note_rounded,
              onPressed: _onBookConsultation,
            ),
            SizedBox(height: 6.h),
            Center(
              child: V2GhostButton(
                label: 'Talk to support',
                onPressed: _onTalkToSupport,
                fullWidth: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanEndedState extends StatelessWidget {
  final DietPlanV2 plan;
  const _PlanEndedState({required this.plan});

  /// Phase F.3 — completed-plan path. Defers to the shared follow-up
  /// helper so the Phase G.2 banner CTA and this empty-state button
  /// route through the same lazy-load + fallback flow.
  Future<void> _onBookFollowUp() async {
    await _bookFollowUpFromContext('POPUP_PLAN_ENDED');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: _Card(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text('🎉', style: TextStyle(fontSize: 48.sp))),
            SizedBox(height: 14.h),
            Center(
              child: Text(
                'PLAN COMPLETED',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: _kAccent,
                  letterSpacing: 0.84,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your ${plan.planDays}-day plan is complete!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _kHeroDark,
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Time to check in with your dietitian for your next plan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: _kBodyMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 18.h),
            V2PrimaryButton(
              label: 'Book Follow-up Consultation',
              leadingIcon: Icons.event_repeat_rounded,
              onPressed: _onBookFollowUp,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedState extends StatelessWidget {
  final DietPlanV2 plan;
  const _LoadedState({required this.plan});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DietPlanUserController>();
    return Obx(() {
      final day = ctrl.selectedDay;
      // Defensive — selectedDayNumber points outside plan.days. Falls
      // back to today; if today is also missing, the empty-state path
      // already short-circuited above so we never get here.
      final renderDay = day ?? ctrl.todaysDay;
      if (renderDay == null) return const SizedBox.shrink();

      final showStrip = plan.planDays > 1;
      final viewState = ctrl.isViewingFuture
          ? _ViewState.future
          : ctrl.isViewingPast
              ? _ViewState.past
              : _ViewState.today;

      // Sort meals by time so the column reads breakfast → dinner. Server
      // already orders them, but the client guards against future edits
      // landing out of order.
      final meals = [...renderDay.meals]
        ..sort((a, b) => a.time.compareTo(b.time));

      return Padding(
        padding: EdgeInsets.fromLTRB(0, 12.h, 0, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phase G.3 — Day 7 check-in trigger. Sits above the timeline
            // banner so it's the first thing the user sees after the
            // app bar. Hidden once submitted or dismissed for the cycle.
            const V2Day7TriggerBanner(),
            // Phase G.2 — plan progress + ending-soon CTA. Renders
            // nothing when the plan is already ended (F.1's Plan
            // Completed empty state takes over up the tree) — extra
            // guard kept here so future refactors can drop the
            // banner anywhere without re-adding the check.
            if (!ctrl.isPlanEnded)
              V2PlanTimelineBanner(
                plan: plan,
                todaysDayNumber: ctrl.todaysDayNumber,
                daysRemaining: ctrl.daysRemainingInPlan ?? 0,
                progressPercent: ctrl.planProgressPercent,
                endingSoon: ctrl.isPlanEndingSoon,
                onBookFollowUp: ctrl.isPlanEndingSoon
                    ? () => _onTimelineBookFollowUp(ctrl)
                    : null,
              ),
            if (showStrip)
              Stack(
                children: [
                  V2DayStrip(
                    plan: plan,
                    selectedDayNumber: ctrl.effectiveDayNumber,
                    todayDayNumber: ctrl.todaysDayNumber,
                    onDaySelected: ctrl.selectDay,
                    controller: ctrl,
                  ),
                  if (!ctrl.isViewingToday)
                    Positioned(
                      right: 16.w,
                      top: 12.h,
                      child: _TodayJumpChip(onTap: ctrl.selectToday),
                    ),
                ],
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DayHeader(
                    plan: plan,
                    day: renderDay,
                    viewState: viewState,
                    date: ctrl.dateForDay(renderDay.dayNumber),
                  ),
                  SizedBox(height: 12.h),
                  for (final m in meals) ...[
                    _MealCard(
                      meal: m,
                      dayNumber: renderDay.dayNumber,
                      viewState: viewState,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Phase G.1 — discrimates rendering for the day being viewed.
enum _ViewState { today, past, future }

/// Floating "Today" jump chip that overlays the day strip when the
/// user has navigated away from today.
class _TodayJumpChip extends StatelessWidget {
  final VoidCallback onTap;
  const _TodayJumpChip({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.today_rounded, size: 14.w, color: Colors.white),
              SizedBox(width: 5.w),
              Text(
                'Today',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DietPlanV2 plan;
  final DietPlanDayV2 day;
  final _ViewState viewState;
  final DateTime? date;

  const _DayHeader({
    required this.plan,
    required this.day,
    required this.viewState,
    required this.date,
  });

  static const _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate() {
    if (date == null) return '';
    final wd = _weekdayShort[(date!.weekday - 1).clamp(0, 6)];
    final mo = _monthShort[(date!.month - 1).clamp(0, 11)];
    return '$wd, $mo ${date!.day}';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate();
    final String label;
    final Color labelColor;
    switch (viewState) {
      case _ViewState.today:
        label = "TODAY'S MEALS · DAY ${day.dayNumber} OF ${plan.planDays}";
        labelColor = _kAccent;
        break;
      case _ViewState.past:
        label = dateStr.isEmpty
            ? 'DAY ${day.dayNumber} · OF ${plan.planDays}'
            : 'DAY ${day.dayNumber} · ${dateStr.toUpperCase()}';
        labelColor = _kBodyMuted;
        break;
      case _ViewState.future:
        label = dateStr.isEmpty
            ? 'UPCOMING · DAY ${day.dayNumber}'
            : 'UPCOMING · DAY ${day.dayNumber} · ${dateStr.toUpperCase()}';
        labelColor = _kSage;
        break;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 0.84,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: _kAccent.withOpacity(0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: _kAccent.withOpacity(0.32), width: 1),
          ),
          child: Text(
            '${day.totalCalories} kcal',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: _kHeroDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final DietPlanMealV2 meal;
  final int dayNumber;
  final _ViewState viewState;

  const _MealCard({
    required this.meal,
    required this.dayNumber,
    required this.viewState,
  });

  void _openSheet(DietPlanUserController ctrl) {
    switch (viewState) {
      case _ViewState.today:
        showV2MealLogSheet(meal: meal);
        break;
      case _ViewState.past:
        final log = ctrl.getLogForMeal(dayNumber, meal.mealType.wire);
        V2BottomSheet.show<void>(
          title: meal.mealType.label,
          child: _PastMealSheetBody(
            meal: meal,
            log: log,
            date: ctrl.dateForDay(dayNumber),
          ),
        );
        break;
      case _ViewState.future:
        V2BottomSheet.show<void>(
          title: meal.mealType.label,
          child: _FutureMealSheetBody(
            meal: meal,
            date: ctrl.dateForDay(dayNumber),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DietPlanUserController>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openSheet(ctrl),
        borderRadius: BorderRadius.circular(20),
        child: _Card(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _kSage,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      meal.time,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      meal.mealType.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: _kSage,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                meal.foodName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _kHeroDark,
                  height: 1.35,
                ),
              ),
              if ((meal.notes ?? '').trim().isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  '↳ ${meal.notes!.trim()}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                    color: _kSage,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    '${meal.calories} kcal',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _kBodyMuted,
                    ),
                  ),
                  const Spacer(),
                  // Phase G.1 — indicator depends on whether the day
                  // is today (live status), past (logged status), or
                  // future (locked).
                  if (viewState == _ViewState.future)
                    const _LockIndicator()
                  else
                    Obx(() {
                      final log = ctrl.getLogForMeal(
                          dayNumber, meal.mealType.wire);
                      return _StatusIndicator(
                        status: log?.status ?? MealLogStatusV2.pending,
                      );
                    }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final MealLogStatusV2 status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final size = 28.w;
    switch (status) {
      case MealLogStatusV2.pending:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kSage, width: 1.4),
          ),
        );
      case MealLogStatusV2.followed:
        return _filled(_kAccent, Icons.check_rounded, label: 'Logged');
      case MealLogStatusV2.alternative:
        return _filled(_kAlternative, Icons.swap_horiz_rounded,
            label: 'Swapped');
      case MealLogStatusV2.skipped:
        return _filled(_kDanger, Icons.close_rounded, label: 'Skipped');
    }
  }

  Widget _filled(Color bg, IconData icon, {required String label}) {
    final size = 28.w;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16.w),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: bg,
          ),
        ),
      ],
    );
  }
}

/// Phase F.2 — meal logging sheet body. Renders the meal info on top,
/// a status banner + "Change" link if the meal's already been logged,
/// and three big buttons (Ate as planned / Had something else /
/// Skipped) otherwise. The "had something else" path reveals a
/// TextField for the alternative meal name.
class _MealLogSheetBody extends StatefulWidget {
  final DietPlanMealV2 meal;
  const _MealLogSheetBody({required this.meal});

  @override
  State<_MealLogSheetBody> createState() => _MealLogSheetBodyState();
}

class _MealLogSheetBodyState extends State<_MealLogSheetBody> {
  late final DietPlanUserController _ctrl;
  late final TextEditingController _altCtrl;

  /// Local view state — when the user taps "I had something else" we
  /// reveal the text field instead of immediately firing. When the
  /// user taps "Change" on a logged meal we drop back to the picker.
  bool _showAlternativeForm = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DietPlanUserController>();
    final existing =
        _ctrl.todayLogsByType[widget.meal.mealType.wire];
    _altCtrl = TextEditingController(
      text: existing?.alternativeText ?? '',
    );
  }

  @override
  void dispose() {
    _altCtrl.dispose();
    super.dispose();
  }

  Future<void> _log(MealLogStatusV2 status, {String? alternativeText}) async {
    // Close the sheet immediately — controller does the optimistic
    // update + error revert. The user sees the status flip on the card
    // before the network even returns.
    Get.back<dynamic>();
    await _ctrl.logMeal(
      mealTypeWire: widget.meal.mealType.wire,
      status: status,
      alternativeText: alternativeText,
      dietPlanMealId: widget.meal.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final log = _ctrl.todayLogsByType[widget.meal.mealType.wire];
      final isLogged =
          log != null && log.status != MealLogStatusV2.pending;
      final showPicker = !isLogged || _editing;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _mealHeader(),
          SizedBox(height: 18.h),
          if (isLogged && !_editing) _loggedBanner(log),
          if (showPicker) ...[
            if (_showAlternativeForm)
              _alternativeForm()
            else
              _picker(),
          ],
          SizedBox(height: 8.h),
          Center(
            child: V2GhostButton(
              label: 'Cancel',
              onPressed: () => Get.back<dynamic>(),
              fullWidth: false,
            ),
          ),
          SizedBox(height: 4.h),
        ],
      );
    });
  }

  Widget _mealHeader() {
    final meal = widget.meal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _kSage,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                meal.time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              '${meal.calories} kcal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _kBodyMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          meal.foodName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: _kHeroDark,
            height: 1.3,
          ),
        ),
        if ((meal.notes ?? '').trim().isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            meal.notes!.trim(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: _kBodyMuted,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _loggedBanner(MealLogV2 log) {
    final (Color bg, IconData icon, String label) = switch (log.status) {
      MealLogStatusV2.followed => (
          _kAccent,
          Icons.check_rounded,
          'You ate this as planned'
        ),
      MealLogStatusV2.alternative => (
          _kAlternative,
          Icons.swap_horiz_rounded,
          'You had something else'
        ),
      MealLogStatusV2.skipped => (
          _kDanger,
          Icons.close_rounded,
          'You skipped this meal'
        ),
      MealLogStatusV2.pending => (
          _kSage,
          Icons.radio_button_unchecked,
          'Pending'
        ),
    };
    final altText = (log.alternativeText ?? '').trim();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bg.withOpacity(0.32), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: bg, size: 18.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _kHeroDark,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() {
                  _editing = true;
                  _showAlternativeForm = false;
                }),
                child: Text(
                  'Change',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _kAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          if (log.status == MealLogStatusV2.alternative &&
              altText.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 28.w),
              child: Text(
                '↳ $altText',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: _kBodyMuted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _picker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        V2PrimaryButton(
          label: 'Ate as planned',
          leadingIcon: Icons.check_rounded,
          onPressed: () => _log(MealLogStatusV2.followed),
        ),
        SizedBox(height: 10.h),
        _LogChoiceButton(
          label: 'I had something else',
          icon: Icons.swap_horiz_rounded,
          accent: _kAlternative,
          onPressed: () => setState(() => _showAlternativeForm = true),
        ),
        SizedBox(height: 10.h),
        _LogChoiceButton(
          label: 'Skipped this meal',
          icon: Icons.close_rounded,
          accent: _kDanger,
          onPressed: () => _log(MealLogStatusV2.skipped),
        ),
      ],
    );
  }

  Widget _alternativeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'WHAT DID YOU EAT?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: _kSage,
            letterSpacing: 0.84,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _altCtrl,
          maxLength: 255,
          autofocus: true,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: _kHeroDark,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Paratha and yogurt',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: _kBodyMuted,
            ),
            filled: true,
            fillColor: _kCream,
            counterText: '',
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kCardBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kCardBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kAccent, width: 1.4),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: V2SecondaryButton(
                label: 'Back',
                onPressed: () =>
                    setState(() => _showAlternativeForm = false),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: V2PrimaryButton(
                label: 'Save',
                onPressed: () {
                  final text = _altCtrl.text.trim();
                  _log(
                    MealLogStatusV2.alternative,
                    alternativeText: text.isEmpty ? null : text,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Outline-style choice button with a coloured icon — used for the two
/// non-primary log options ("I had something else", "Skipped this
/// meal"). Differentiates them from the dominant green "Ate as planned"
/// CTA without giving them equal visual weight.
class _LogChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onPressed;
  const _LogChoiceButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: accent.withOpacity(0.32), width: 1.2),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 20.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _kHeroDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: accent, size: 22.w),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phase G.1 — sage outlined circle with a small lock icon. Used on
/// future-day meal cards to make "you can't log this yet" obvious at a
/// glance, paralleling the pending/followed/etc. status indicators
/// without sneaking into MealLogStatusV2 (which is a backend-mirrored
/// enum we don't want to grow).
class _LockIndicator extends StatelessWidget {
  const _LockIndicator();
  @override
  Widget build(BuildContext context) {
    final size = 28.w;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kSage, width: 1.4),
      ),
      child: Icon(Icons.lock_outline_rounded,
          size: 14.w, color: _kSage),
    );
  }
}

/// Read-only meal sheet for past days. Shows the logged status (or a
/// pending pill if the user never logged it) plus a clear hint that
/// the row can't be edited.
class _PastMealSheetBody extends StatelessWidget {
  final DietPlanMealV2 meal;
  final MealLogV2? log;
  final DateTime? date;
  const _PastMealSheetBody({
    required this.meal,
    required this.log,
    required this.date,
  });

  String _formatDate() {
    if (date == null) return 'a previous day';
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final w = wd[(date!.weekday - 1).clamp(0, 6)];
    final m = mo[(date!.month - 1).clamp(0, 11)];
    return '$w, $m ${date!.day}';
  }

  @override
  Widget build(BuildContext context) {
    final status = log?.status ?? MealLogStatusV2.pending;
    final altText = (log?.alternativeText ?? '').trim();
    final (Color bg, IconData icon, String label) = switch (status) {
      MealLogStatusV2.followed => (
          _kAccent,
          Icons.check_rounded,
          'Logged as eaten'
        ),
      MealLogStatusV2.alternative => (
          _kAlternative,
          Icons.swap_horiz_rounded,
          'Logged as alternative'
        ),
      MealLogStatusV2.skipped => (
          _kDanger,
          Icons.close_rounded,
          'Logged as skipped'
        ),
      MealLogStatusV2.pending => (
          _kSage,
          Icons.radio_button_unchecked,
          'Not logged'
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MealMeta(meal: meal),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: bg.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: bg.withOpacity(0.32), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: bg, size: 18.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  '$label · ${_formatDate()}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _kHeroDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (status == MealLogStatusV2.alternative && altText.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              '↳ $altText',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                color: _kBodyMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _kCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kCardBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 16.w, color: _kSage),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Past meals can't be edited.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: _kBodyMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

/// Future-day meal sheet — meal info + a "logging unlocks on {date}"
/// hint. No log buttons.
class _FutureMealSheetBody extends StatelessWidget {
  final DietPlanMealV2 meal;
  final DateTime? date;
  const _FutureMealSheetBody({required this.meal, required this.date});

  String _formatDate() {
    if (date == null) return 'this day';
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final w = wd[(date!.weekday - 1).clamp(0, 6)];
    final m = mo[(date!.month - 1).clamp(0, 11)];
    return '$w, $m ${date!.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MealMeta(meal: meal),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: _kCream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCardBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 18.w, color: _kSage),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Logging available on ${_formatDate()}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _kBodyMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "You can preview upcoming meals and prep ahead. Come back on "
          'the day to log what you ate.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            color: _kBodyMuted,
            height: 1.5,
          ),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

/// Meal meta shared by both read-only sheets — time pill + food name +
/// kcal + notes. Mirrors the top of `_MealLogSheetBody._mealHeader`.
class _MealMeta extends StatelessWidget {
  final DietPlanMealV2 meal;
  const _MealMeta({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _kSage,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                meal.time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              '${meal.calories} kcal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _kBodyMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          meal.foodName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: _kHeroDark,
            height: 1.3,
          ),
        ),
        if ((meal.notes ?? '').trim().isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            meal.notes!.trim(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: _kBodyMuted,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Local card shell (mirrors v2 pattern) ────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kHeroDark.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
