import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../UI/consultation_module/popup_orchestrator.dart';
import '../UI/consultation_module/popups/medical_concern_sheet.dart';
import '../UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import '../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../utils/app_clock.dart';
import '../widgets/paid_home_v2/paid_cycle_card.dart';
import '../widgets/paid_home_v2/paid_feel_selector.dart';
import '../widgets/paid_home_v2/paid_footer.dart';
import '../widgets/paid_home_v2/paid_hero.dart';
import '../widgets/paid_home_v2/paid_insight_card.dart';
import '../widgets/paid_home_v2/paid_sleep_card.dart';
import '../widgets/paid_home_v2/paid_stats_row.dart'
    show PaidStatsRow, PaidNutritionCard, PaidMealSummaryCard;
import '../widgets/paid_home_v2/paid_water_card.dart';
import '../widgets/v2/medical_concern_fab.dart';
import '../widgets/v2/plan_expiry_banner.dart';
import '../widgets/v2/plan_frozen_banner.dart';
import '../main.dart' show routeObserver;
import '../widgets/v2/v2_today_meals_section.dart' show V2Day7TriggerBanner;

/// PaidHomeScreenV2 — phase-themed dashboard for paid users behind the
/// `useNewPaidHome` feature flag. Phase B2.3 ships only the hero section
/// (top bar + greeting + LIVE + coming up). The cream body below is a
/// placeholder that will be filled in subsequent phases (insight, mood,
/// water, sleep, stats, cycle/nutrition, footer).
class PaidHomeScreenV2 extends StatefulWidget {
  const PaidHomeScreenV2({super.key});

  @override
  State<PaidHomeScreenV2> createState() => _PaidHomeScreenV2State();
}

class _PaidHomeScreenV2State extends State<PaidHomeScreenV2>
    with WidgetsBindingObserver, RouteAware {
  final PaidHomeController _controller = Get.find<PaidHomeController>();

  // Bumped whenever this screen becomes visible again after a pushed
  // screen (Profile, most relevantly) is popped -- see didPopNext()
  // below. Threaded into PaidHero/PlanFrozenBanner/PlanExpiryBanner as
  // part of their Key so a bump forces Flutter to dispose and recreate
  // them, re-running their initState() freeze/expiry-status fetch.
  // Those widgets intentionally manage their own state independently
  // (self-contained fetch-on-mount pattern used throughout this screen)
  // rather than reading from _controller's dashboard, so simply calling
  // _controller.refreshDashboard() on return would NOT have picked up a
  // freeze/unfreeze done on Profile -- only remounting them does.
  int _refreshGen = 0;

  // Step 4-style sync layers — same pattern as the workout schedule.
  // Heartbeat keeps live/comingUp data fresh when the realtime socket
  // is offline; foreground + reconnect triggers cover the long-tail
  // cases (resume from background, network drop). _lastContactAt
  // drives the "Reconnecting…" banner.
  Timer? _heartbeatTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  DateTime? _lastContactAt;
  // Guard against overlapping heartbeats. The 30s timer + foreground
  // resume + connectivity-reconnect triggers can all fire in tight
  // succession on flaky networks; without this, multiple concurrent
  // dashboard fetches stack up and a later one's success can mask an
  // earlier failure.
  bool _heartbeatInFlight = false;

  static const Duration _kHeartbeatInterval = Duration(seconds: 30);
  static const Duration _kStaleAfter = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.dashboard.value == null) {
        _controller.loadDashboard().then((_) {
          if (mounted) setState(() => _lastContactAt = AppClock.now());
        });
      } else {
        _lastContactAt = AppClock.now();
      }
    });

    _heartbeatTimer = Timer.periodic(_kHeartbeatInterval, (_) => _heartbeat());

    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  // RouteAware -- fires when a screen pushed on top of this one (e.g.
  // Get.to(() => ProfileScreenUser()) from the hero top bar, or from
  // PlanFrozenBanner's own "Manage" button) is popped and this Home
  // screen is visible again. This is specifically what Shaista asked
  // for: freezing/unfreezing on Profile and coming back to Home should
  // show the correct paused/active state right away, not only after a
  // full app restart or the next 30s heartbeat tick.
  @override
  void didPopNext() {
    _heartbeat(reason: 'route-return');
    if (mounted) setState(() => _refreshGen++);
  }

  Future<void> _heartbeat({String reason = 'tick'}) async {
    if (!mounted || _heartbeatInFlight) return;
    _heartbeatInFlight = true;
    try {
      debugPrint('[PaidHomeV2] heartbeat ($reason)');
      final ok = await _controller.silentRefresh();
      if (!mounted || !ok) return;
      setState(() => _lastContactAt = AppClock.now());
    } finally {
      _heartbeatInFlight = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _heartbeat(reason: 'resumed');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final reachable = results.any((r) => r != ConnectivityResult.none);
    if (reachable) _heartbeat(reason: 'reconnect');
  }

  bool get _isStale {
    if (_lastContactAt == null) return false;
    return AppClock.now().difference(_lastContactAt!) > _kStaleAfter;
  }

  @override
  Widget build(BuildContext context) {
    // Status-bar styling — single mechanism: AnnotatedRegion. The hero
    // (PaidHero) has a flat top and paints from y=0 (Scaffold body has no
    // implicit SafeArea); PaidHeroTopBar already pads its content by
    // `MediaQuery.padding.top + 14` so bell + avatar clear the system
    // chrome. With edgeToEdge enabled in main.dart, a transparent
    // statusBarColor lets the hero's actual phase colour show through
    // the OS bar — no fake-tint scrim, no imperative SystemChrome push,
    // no possibility of a stale "mint band" from splash sticking around.
    return Obx(() {
      // Even though the per-phase colour is no longer wired into the
      // status bar, we still rebuild on dashboard changes so AnnotatedRegion
      // refreshes if anything else (icon brightness, etc.) ever needs to.
      _controller.dashboard.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          // Transparent so the hero's dark phase colour paints the strip.
          statusBarColor: Colors.transparent,
          // Android: light icons render white on dark hero.
          statusBarIconBrightness: Brightness.light,
          // iOS: `Brightness.dark` reads as "the surface is dark" — system
          // renders status-bar content in white. Platform-inverted naming.
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          // Cream body bg matches the H-01 reference scroll area below the
          // hero. Unchanged.
          backgroundColor: const Color(0xFFEAF7E4),
          // Phase 2D wiring (consultation flow):
          //   • PendingPopupOrchestrator watches dashboard.pendingPopups
          //     and dispatches the right sheet by variable name.
          //   • MedicalConcernFAB renders the floating "urgent help"
          //     button per Decision 8 — paid surfaces only, hidden
          //     during fullscreen modals via the static `suppress` flag.
          body: PendingPopupOrchestrator(
            // Inactivity popup's "View today's classes" CTA — switch the
            // bottom-bar to the Workout tab so the user lands on their
            // schedule. WorkPlansOfUser → tap into the plan → today's class.
            onOpenWorkoutSchedule: () =>
                Get.offAll<dynamic>(() => BottomBarScreen(index: 1)),
            child: MedicalConcernFAB(
              onTap: () => MedicalConcernSheet.show(),
              child: Stack(
                children: [
                  _buildBody(),
                  // Reconnecting banner — overlay so it stays pinned at
                  // the top of the screen instead of scrolling away with
                  // the hero. SafeArea so it clears the status bar.
                  if (_isStale)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: false,
                        child: _buildReconnectingBanner(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Slim amber pill shown when no successful heartbeat in [_kStaleAfter].
  // Same styling intent as the workout schedule banner so users see
  // consistent reconnecting feedback wherever they are in the app.
  Widget _buildReconnectingBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: const Color(0xFFFAC775),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 12.w,
            height: 12.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Reconnecting…',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_controller.isLoading.value &&
          _controller.dashboard.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final dashboard = _controller.dashboard.value;
      if (dashboard == null) {
        return Center(
          child: Text(
            _controller.errorMessage.value.isEmpty
                ? 'No data'
                : _controller.errorMessage.value,
            style: const TextStyle(color: Colors.black54),
          ),
        );
      }
      return RefreshIndicator(
          onRefresh: _controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                PaidHero(
                  key: ValueKey('hero_$_refreshGen'),
                  dashboard: dashboard,
                ),
                // Renewal heads-up — same "self-hides, own margin" sibling
                // pattern as V2Day7TriggerBanner right below. Sits above it
                // so a lapsing/expired plan is the first thing a user sees
                // under the hero, ahead of the day-7 check-in nudge.
                PlanExpiryBanner(key: ValueKey('expiry_$_refreshGen')),
                // Frozen-plan heads-up -- item #1 of the frozen-plan
                // architecture pass. Sits right below the renewal banner;
                // in practice the two never show at once (a frozen plan's
                // expireDate was already pushed out at freeze time), but
                // each self-hides independently so there's no ordering
                // dependency between them.
                PlanFrozenBanner(
                  key: ValueKey('frozen_$_refreshGen'),
                  // Unfreezing right here (no navigation involved) needs
                  // the same PaidHero remount that didPopNext() triggers
                  // for the "unfroze on Profile, came back" path -- see
                  // PlanFrozenBanner.onUnfrozen's doc comment.
                  onUnfrozen: () {
                    if (mounted) setState(() => _refreshGen++);
                  },
                ),
                // Cream scroll body. Insight card is the first section;
                // everything below the `SizedBox` is a placeholder that
                // future phases fill in (mood, water/sleep, stats, etc.).
                // Phase H — Day 7 check-in trigger. Mounted as a
                // sibling of the cream-body Padding (not inside it)
                // because V2Day7TriggerBanner already has its own
                // 16w margin — putting it inside the 16-padded inner
                // Column would double-pad. Self-hides when ineligible,
                // so this slot only contributes layout on Day 7+.
                const V2Day7TriggerBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PaidInsightCard(dashboard: dashboard),
                      const SizedBox(height: 8),
                      PaidFeelSelector(dashboard: dashboard),
                      const SizedBox(height: 8),
                      // Water + Sleep row. IntrinsicHeight keeps the two
                      // cards the same height even though the water card
                      // has extra button rows underneath the bar.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: PaidWaterCard(dashboard: dashboard)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: PaidSleepCard(dashboard: dashboard)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      PaidStatsRow(dashboard: dashboard),
                      const SizedBox(height: 8),
                      // Cycle + Nutrition + Meals, laid out as rows of
                      // two so no card is ever left alone full-width
                      // (which looked broken — a lonely card stacked
                      // above another lonely card).
                      //
                      // Nutrition's "% diet plan" figure only means
                      // anything once a dietitian has assigned a
                      // structured plan, so it's held back until then.
                      // While it's hidden, Cycle pairs with Meals
                      // instead of sitting alone; once a plan exists,
                      // Cycle gets its own row above and Nutrition
                      // pairs with Meals (matching the two-card rhythm
                      // used everywhere else on this screen).
                      Obx(() {
                        final dietCtrl = Get.find<DietPlanUserController>();
                        final hasPlan = dietCtrl.activePlan.value != null;
                        final stillChecking = dietCtrl.isLoading.value &&
                            dietCtrl.activePlan.value == null;
                        final showNutrition = hasPlan && !stillChecking;
                        final hasCycle =
                            dashboard.cycle?.cycleDay != null;

                        Widget pairRow(Widget left, Widget right) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: left),
                                const SizedBox(width: 8),
                                Expanded(child: right),
                              ],
                            ),
                          );
                        }

                        if (showNutrition) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (hasCycle) ...[
                                PaidCycleCard(dashboard: dashboard),
                                const SizedBox(height: 8),
                              ],
                              pairRow(
                                PaidNutritionCard(dashboard: dashboard),
                                const PaidMealSummaryCard(),
                              ),
                            ],
                          );
                        }
                        // No plan yet (or we haven't confirmed either
                        // way) — pair Cycle with the generic Meals card
                        // instead of stacking two lonely full-width
                        // cards. If there's no cycle data either,
                        // Meals is the only thing left to show.
                        if (hasCycle) {
                          return pairRow(
                            PaidCycleCard(dashboard: dashboard),
                            const PaidMealSummaryCard(),
                          );
                        }
                        return const PaidMealSummaryCard();
                      }),
                      const SizedBox(height: 8),
                      // PaidCycleCard removed from this position —
                      // PaidStatsRow now embeds it in Row 2 alongside
                      // Nutrition. Re-adding it here would render
                      // cycle data twice.
                      PaidFooter(dashboard: dashboard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }
}
