import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/Repos/cycle_repo/cycle_data_repository.dart';
import '../data/controllers/auth_controller/auth_controller.dart';
import '../data/controllers/cycle_theme_controller/cycle_theme_controller.dart';
import '../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../data/controllers/workout_controller/work_out_controller.dart';
import '../data/services/cycle_engine.dart';
import '../UI/dashboard_module/bottom_bar_screen/workout_plans_of_user.dart';
import '../utils/slot_input_builder.dart';
import '../values/constants.dart';
import '../widgets/new_home/community_footer.dart';
import '../widgets/new_home/feel_selector_card.dart';
import '../widgets/new_home/hero_coming_up_row.dart' show UpcomingSlot;
import '../widgets/new_home/home_hero.dart';
import '../widgets/new_home/locked_insight_card.dart';
import '../widgets/new_home/locked_stats_grid.dart';
import '../widgets/new_home/reengagement_cta_card.dart';
import '../widgets/paid_home_v2/paid_feel_selector.dart';
import '../widgets/paid_home_v2/paid_sleep_card.dart';
import '../widgets/paid_home_v2/paid_water_card.dart';

/// Unpaid (free-trial / pre-purchase) home screen.
/// Mounted by home_screen.dart for every unpaid user (logInUser.status == false).
///
/// Data sources:
///   firstName       — AuthController.logInUser.firstName
///   cycleInfo       — CycleDataRepository.getCycleData(), cached per mount.
///   upcomingSlots   — populated for active trial users via
///                     WorkOutController.getDietPlanDetailsFunc('0').
///   dashboard       — PaidHomeController.loadDashboard(), loaded for trial
///                     users so feel/water/sleep widgets become interactive.
class UnpaidHomeScreenV2 extends StatefulWidget {
  const UnpaidHomeScreenV2({super.key});

  @override
  State<UnpaidHomeScreenV2> createState() => _UnpaidHomeScreenV2State();
}

class _UnpaidHomeScreenV2State extends State<UnpaidHomeScreenV2> {
  final AuthController _auth = Get.find();
  final WorkOutController _workOutController = Get.find();
  final PaidHomeController _paidController = Get.find<PaidHomeController>();

  late Future<CycleInfo?> _cycleFuture;
  Worker? _trialWorker;

  @override
  void initState() {
    super.initState();
    _cycleFuture = _fetchCycleInfo();

    if (_auth.trialActivated.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchTrialSlots();
          _paidController.loadDashboard();
        }
      });
    }

    _trialWorker = ever(_auth.trialActivated, (bool active) {
      if (active && mounted) {
        _fetchTrialSlots();
        _paidController.loadDashboard();
      }
    });
  }

  @override
  void dispose() {
    _trialWorker?.dispose();
    super.dispose();
  }

  void _fetchTrialSlots() {
    _workOutController.getDietPlanDetailsFunc('0');
  }

  Future<void> _onRefresh() async {
    final fresh = _fetchCycleInfo();
    setState(() { _cycleFuture = fresh; });
    if (_auth.trialActivated.value) {
      _fetchTrialSlots();
      _paidController.loadDashboard();
    }
    await fresh;
  }

  List<UpcomingSlot> _buildUpcomingSlots() {
    // ignore: unused_local_variable
    final _ = _workOutController.workOutPlanDetailsLoad.value;
    final plan = _workOutController.getUserWorkoutPlanDetailsPlan;
    if (plan == null) return [];

    final now = DateTime.now();
    final todayName = DateFormat('EEEE').format(now);
    final tomorrowDate = now.add(const Duration(days: 1));
    final tomorrowName = DateFormat('EEEE').format(tomorrowDate);

    final results = <UpcomingSlot>[];
    for (final daySlot in plan.trainerSlots) {
      final int dayOffset;
      final DateTime anchorDate;
      if (daySlot.day == todayName) {
        dayOffset = 0;
        anchorDate = now;
      } else if (daySlot.day == tomorrowName) {
        dayOffset = 1;
        anchorDate = tomorrowDate;
      } else {
        continue;
      }

      for (final slot in daySlot.slots) {
        final start = parseSlotWallClock(slot.start, anchorDate);
        final end = parseSlotWallClock(slot.end, anchorDate);
        if (start == null || end == null) continue;
        if (end.isBefore(now)) continue;
        results.add(UpcomingSlot(slot, start, end, dayOffset: dayOffset));
      }
    }

    results.sort((a, b) {
      final dayDiff = a.dayOffset.compareTo(b.dayOffset);
      return dayDiff != 0 ? dayDiff : a.startLocal.compareTo(b.startLocal);
    });
    return results.take(3).toList();
  }

  Future<CycleInfo?> _fetchCycleInfo() async {
    try {
      final repo = Get.find<CycleDataRepository>();
      final token = _auth.sharedPreferences.getString(Constants.accessToken) ?? '';
      final response = await repo.getCycleData(accessToken: token);
      final body = response.body;
      if (body == null || body['status'] != '1' || body['data'] == null) return null;
      final data = body['data'];
      final provided = data['dataProvided'];
      final hasProvided = provided == 1 || provided == true || provided == '1';
      final last = data['lastPeriodDate'];
      if (!hasProvided || last == null) return null;
      final info = CycleEngine.calculate(
        lastPeriodDate: DateTime.parse(last.toString()),
        cycleLength: data['averageCycleLength'] ?? 28,
      );
      try { Get.find<CycleThemeController>().setPhase(info?.phase); } catch (_) {}
      return info;
    } catch (_) {
      return null;
    }
  }

  String _firstName() {
    final n = _auth.logInUser?.firstName.trim();
    return (n == null || n.isEmpty) ? '' : n;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FCF7),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF6DC55A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero: upcoming slots + workout tap navigation ──
                Obx(() {
                  final trialActive = _auth.trialActivated.value;
                  final slots = trialActive
                      ? _buildUpcomingSlots()
                      : const <UpcomingSlot>[];
                  return FutureBuilder<CycleInfo?>(
                    future: _cycleFuture,
                    builder: (_, snap) => HomeHero(
                      firstName: _firstName(),
                      cycleInfo: snap.data,
                      isLoading: snap.connectionState == ConnectionState.waiting,
                      upcomingSlots: slots,
                      // Tapping a slot tile navigates to the workout schedule.
                      onWorkoutTap: trialActive
                          ? () => Get.to(() => WorkPlansOfUser(showBackButton: true))
                          : null,
                    ),
                  );
                }),

                // ── Feel / insight / water+sleep / CTA ──
                // When trial is active AND the paid dashboard has loaded,
                // replace the locked-UI widgets with fully interactive paid ones
                // so the user can log mood, water, and sleep exactly as on the
                // paid home screen.
                Obx(() {
                  final trialActive = _auth.trialActivated.value;
                  final dash = _paidController.dashboard.value;
                  final showPaid = trialActive && dash != null;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mood selector
                        if (showPaid) ...[
                          PaidFeelSelector(dashboard: dash),
                          const SizedBox(height: 8),
                        ] else ...[
                          const FeelSelectorCard(),
                        ],

                        // AI insight teaser (always locked — not a paid feature)
                        const LockedInsightCard(),

                        // Water + Sleep — IntrinsicHeight forces both cards
                        // to the same height regardless of content differences.
                        if (showPaid) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: PaidWaterCard(dashboard: dash)),
                                  const SizedBox(width: 8),
                                  Expanded(child: PaidSleepCard(dashboard: dash)),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const LockedStatsGrid(),
                        ],

                        const ReengagementCtaCard(),
                        const CommunityFooter(),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
