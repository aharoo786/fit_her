import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/diet_bottom_bar.dart';
import 'package:fitness_zone_2/UI/dashboard_module/recommended_slots_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/main.dart';
import 'package:flutter/material.dart';
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
  String? _singlePlanId;
  bool _requestedSinglePlanDetails = false;

  Widget _animatedBody(Widget child, {required String keyValue}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(keyValue),
        child: child,
      ),
    );
  }

  @override
  void initState() {
    workOutController.getWorkoutAllPlansFunc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Obx(() {
      if (workOutController.workOutOfUserLoad.value &&
          workOutController.workoutPlans != null) {
        final plans = workOutController.workoutPlans!.plans;
        if (plans.length == 1) {
          final singlePlanId = plans.first.id.toString();
          if (_singlePlanId != singlePlanId) {
            _singlePlanId = singlePlanId;
            _requestedSinglePlanDetails = false;
          }
          if (!_requestedSinglePlanDetails) {
            _requestedSinglePlanDetails = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _singlePlanId == null) return;
              selectedPlan = _singlePlanId!;
              workOutController.getDietPlanDetailsFunc(_singlePlanId!);
            });
          }
          return _animatedBody(
            WorkOutBottomScreen(
              planId: singlePlanId,
              showBackButton: widget.showBackButton,
            ),
            keyValue: 'workout-detail-$singlePlanId',
          );
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
        body: _animatedBody(
          workOutController.workOutOfUserLoad.value
              ? workOutController.workoutPlans!.plans.isEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child:
                              HelpingWidgets().getOurPlans(context, textTheme),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
                      itemCount: workOutController.workoutPlans!.plans.length,
                      itemBuilder: (BuildContext context, int index) {
                        var plan = workOutController.workoutPlans!.plans[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => WorkOutBottomScreen(
                                  planId: plan.id.toString(),
                                ));
                            selectedPlan = plan.id.toString();
                            workOutController
                                .getDietPlanDetailsFunc(plan.id.toString());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.1))
                                ]),
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
          keyValue: workOutController.workOutOfUserLoad.value
              ? (workOutController.workoutPlans!.plans.isEmpty
                  ? 'workout-empty'
                  : 'workout-list')
              : 'workout-loading',
        ),
      );
    });
  }
}
