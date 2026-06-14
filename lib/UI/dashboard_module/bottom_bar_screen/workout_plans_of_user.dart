import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/diet_bottom_bar.dart';
import 'package:fitness_zone_2/UI/dashboard_module/recommended_slots_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart';
import 'package:fitness_zone_2/UI/plans_module/all_plans.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';

class WorkPlansOfUser extends StatefulWidget {
  WorkPlansOfUser({super.key, this.showBackButton = true});
  bool showBackButton;

  @override
  State<WorkPlansOfUser> createState() => _WorkPlansOfUserState();
}

class _WorkPlansOfUserState extends State<WorkPlansOfUser> {
  WorkOutController workOutController = Get.find();
  // Guards single-plan auto-skip so we don't kick off getDietPlanDetailsFunc
  // on every Obx tick. Holds the id of the plan we already loaded.
  String? _autoLoadedPlanId;

  @override
  void initState() {
    workOutController.getWorkoutAllPlansFunc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Obx(() {
      // Trial-activated unpaid users have no real plan but should see a
      // sample schedule in place of the empty state. Owns its own Scaffold
      // so the "Your Plans" AppBar (Poppins w500/20sp — mismatches home's
      // w800/28-32 hero titles) doesn't leak in above it.
      if (Get.find<AuthController>().trialActivated.value &&
          workOutController.workOutOfUserLoad.value &&
          (workOutController.workoutPlans?.plans.isEmpty ?? true)) {
        return const _SampleScheduleView();
      }
      // Single-plan users skip the intermediate "Your Plans" list and land
      // straight on today's schedule. Multiple plans still see the list.
      if (workOutController.workOutOfUserLoad.value) {
        final plans = workOutController.workoutPlans?.plans ?? const [];
        if (plans.length == 1) {
          final plan = plans.first;
          final planId = plan.id.toString();
          if (_autoLoadedPlanId != planId) {
            _autoLoadedPlanId = planId;
            // Mirror the tap-handler's side effects (selectedPlan global +
            // diet details fetch). Schedule for next frame to avoid the
            // setState-during-build trap.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              selectedPlan = planId;
              workOutController.getDietPlanDetailsFunc(planId);
            });
          }
          // WorkOutBottomScreen is itself a Scaffold; no outer chrome.
          return WorkOutBottomScreen(planId: planId);
        }
      }
      return Scaffold(
        appBar: HelpingWidgets().appBarWidget(
            widget.showBackButton
                ? () {
                    Get.back();
                  }
                : null,
            text: "Your Plans"),
        body: workOutController.workOutOfUserLoad.value
          ? workOutController.workoutPlans!.plans.isEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: HelpingWidgets().getOurPlans(context, textTheme),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => const RecommendedSlotsScreen());
                        },
                        child: Text(
                          'View recommended sessions →',
                          style: textTheme.bodyMedium!.copyWith(
                            color: MyColors.buttonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
                  itemCount: workOutController.workoutPlans!.plans.length,
                  itemBuilder: (BuildContext context, int index) {
                    var plan = workOutController.workoutPlans!.plans[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => WorkOutBottomScreen(
                              planId: plan.id.toString(),
                            ));
                        selectedPlan = plan.id.toString();
                        workOutController.getDietPlanDetailsFunc(plan.id.toString());
                      },
                      child: Container(
                        // height: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.1))]),
                        child: Row(children: [
                          SizedBox(
                            width: 70.w,
                            child: Image.asset(MyImgs.logo),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  plan.shortDescription,
                                  style: textTheme.bodySmall!.copyWith(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Text(
                                //   "Duration: ${plan.countries![0].duration![0].days}",
                                //   style: textTheme.titleLarge!.copyWith(),
                                //   maxLines: 2,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                // Text(
                                //   "PKR ${plan.countries![0].duration![0].priceAmount}",
                                //   style: textTheme.titleLarge!.copyWith(
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                //),
                              ],
                            ),
                          )
                        ]),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 20.w,
                    );
                  },
                )
            : const Center(
                child: CircularProgress(),
              ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════
// Sample schedule shown after a user activates the local trial flag.
// Three days of phase-matched classes, all read-only — taps land on the
// plans screen so the user can pick a real plan to make it stick.
// ════════════════════════════════════════════════════════════════════════
class _SampleScheduleView extends StatelessWidget {
  const _SampleScheduleView();

  static const _accent = Color(0xFF6DC55A);
  static const _heroDark = Color(0xFF163220);
  static const _muted = Color(0xFF6F8B7A);
  static const _cardBorder = Color(0xFFD8EDD4);
  static const _canvas = Color(0xFFF9FCF7);

  static const _days = <_SampleDay>[
    _SampleDay(label: 'Today, Tue', items: [
      _SampleSlot(
        time: '09:00 AM',
        name: 'Strength Training',
        duration: '45 min',
        phase: 'Follicular ⚡',
      ),
      _SampleSlot(
        time: '06:30 PM',
        name: 'Hormonal Yoga',
        duration: '30 min',
        phase: 'Follicular ⚡',
      ),
    ]),
    _SampleDay(label: 'Tomorrow, Wed', items: [
      _SampleSlot(
        time: '09:00 AM',
        name: 'Zumba Fat Burn',
        duration: '40 min',
        phase: 'Follicular ⚡',
      ),
    ]),
    _SampleDay(label: 'Thu', items: [
      _SampleSlot(
        time: '09:00 AM',
        name: 'Core & Pilates',
        duration: '35 min',
        phase: 'Ovulation ✨',
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _canvas,
        body: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Hero — same edge-to-edge dark band + Poppins w800 28-px title
          // pattern as the home + progress preview screens, so the typography
          // and chrome line up across the unpaid surfaces.
          Container(
            decoration: const BoxDecoration(
              color: _heroDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            padding: EdgeInsets.fromLTRB(22, topInset + 16, 22, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.18),
                    border: Border.all(color: _accent.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    '✨ TRIAL · SAMPLE SCHEDULE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFA8F0C0),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your workout schedule',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Three days of what your week looks like on FitHer. '
                  'Pick a plan to make this real.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final day in _days) ...[
                  _DayHeader(label: day.label),
                  const SizedBox(height: 8),
                  for (final slot in day.items) ...[
                    _SlotCard(slot: slot),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 6),
                ],
                // Footer CTA → OurPlansScreen.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.to<dynamic>(() => OurPlansScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Pick a plan to make this yours →',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SampleDay {
  final String label;
  final List<_SampleSlot> items;
  const _SampleDay({required this.label, required this.items});
}

class _SampleSlot {
  final String time;
  final String name;
  final String duration;
  final String phase;
  const _SampleSlot({
    required this.time,
    required this.name,
    required this.duration,
    required this.phase,
  });
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _SampleScheduleView._muted,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final _SampleSlot slot;
  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _SampleScheduleView._cardBorder),
        boxShadow: [
          BoxShadow(
            color: _SampleScheduleView._heroDark.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left rail: time
          SizedBox(
            width: 64,
            child: Text(
              slot.time,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _SampleScheduleView._heroDark,
                height: 1.2,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: _SampleScheduleView._cardBorder,
          ),
          const SizedBox(width: 12),
          // Middle: name + duration · phase
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _SampleScheduleView._heroDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${slot.duration} · ${slot.phase}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: _SampleScheduleView._muted,
                  ),
                ),
              ],
            ),
          ),
          // Right: muted "Start" chip — tap routes to plans (this is a
          // preview, no real class to start yet).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.to<dynamic>(() => OurPlansScreen()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _SampleScheduleView._accent.withOpacity(0.14),
                border: Border.all(
                    color:
                        _SampleScheduleView._accent.withOpacity(0.32)),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Start →',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _SampleScheduleView._accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
