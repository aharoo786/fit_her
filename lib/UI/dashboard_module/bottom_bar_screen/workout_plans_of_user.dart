import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/diet_bottom_bar.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';

class WorkPlansOfUser extends StatelessWidget {
  WorkPlansOfUser({super.key});
  WorkOutController workOutController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(null, text: "Your Plans"),
      body: Obx(() => workOutController.workOutOfUserLoad.value
          ? workOutController.workoutPlans!.plans.isEmpty?HelpingWidgets().getOurPlans(textTheme):ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
        itemCount: workOutController.workoutPlans!.plans.length,
        itemBuilder: (BuildContext context, int index) {
          var plan = workOutController
              .workoutPlans!.plans[index];
          return GestureDetector(
            onTap: () {
              Get.to(() => WorkOutBottomScreen());
              workOutController.getDietPlanDetailsFunc(plan.id.toString() );
            },
            child: Container(
              // height: 200,
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
                      Text(
                        "Duration: ${plan.duration}",
                        style: textTheme.titleLarge!.copyWith(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "PKR ${plan.price}",
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
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
      )),
    );
  }
}
