import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/diet_bottom_bar.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';

class DietPlansOfUser extends StatefulWidget {
  DietPlansOfUser({super.key, this.showBackButton = true});
  bool showBackButton;

  @override
  State<DietPlansOfUser> createState() => _DietPlansOfUserState();
}

class _DietPlansOfUserState extends State<DietPlansOfUser> {
  DietController dietController = Get.find();
  int? _singleUserPlanId;
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
    dietController.getDietAllPlansFunc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Obx(() {
      if (dietController.dietOfUserLoad.value &&
          dietController.getDietAllPlans != null) {
        final userPlans = dietController.getDietAllPlans!.userPlans;
        if (userPlans.length == 1) {
          final singlePlanId = userPlans.first.id;
          if (_singleUserPlanId != singlePlanId) {
            _singleUserPlanId = singlePlanId;
            _requestedSinglePlanDetails = false;
          }
          if (!_requestedSinglePlanDetails) {
            _requestedSinglePlanDetails = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _singleUserPlanId == null) return;
              dietController.getDietPlanDetailsFunc(_singleUserPlanId.toString());
            });
          }
          return _animatedBody(
            DietBottomBarScreen(
              userPlanId: singlePlanId,
              showBackButton: widget.showBackButton,
            ),
            keyValue: 'diet-detail-$singlePlanId',
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
          dietController.dietOfUserLoad.value
              ? dietController.getDietAllPlans!.userPlans.isEmpty
                  ? HelpingWidgets().getOurPlans(context, textTheme)
                  : ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
                      itemCount:
                          dietController.getDietAllPlans!.userPlans.length,
                      itemBuilder: (BuildContext context, int index) {
                        var plan = dietController
                            .getDietAllPlans!.userPlans[index].dietPlanOfUser;
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => DietBottomBarScreen(
                                  userPlanId: dietController
                                      .getDietAllPlans!.userPlans[index].id,
                                ));
                            dietController.getDietPlanDetailsFunc(dietController
                                .getDietAllPlans!.userPlans[index].id
                                .toString());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 2),
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
          keyValue: dietController.dietOfUserLoad.value
              ? (dietController.getDietAllPlans!.userPlans.isEmpty
                  ? 'diet-empty'
                  : 'diet-list')
              : 'diet-loading',
        ),
      );
    });
  }
}
