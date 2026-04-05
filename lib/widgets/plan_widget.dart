import 'package:fitness_zone_2/UI/diet_screen/diet_module.dart';
import 'package:fitness_zone_2/UI/plans_module/select_payment_mode.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/data/services/youtube_tutorial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../data/models/get_user_plan/get_user_plan.dart';
import '../values/my_colors.dart';
import '../helper/analytics_helper.dart';
import 'meal_details.dart';

class PlanWidget extends StatelessWidget {
  const PlanWidget({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 5,
      child: Container(
        // width: 300,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MyColors.primaryGradient1),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(plan.title, textAlign: TextAlign.center, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
            // const SizedBox(
            //   height: 5,
            // ),
            DropdownButtonFormField<DurationPlan>(
              itemHeight: null,
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              iconSize: 30,
              icon: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(color: MyColors.buttonColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  Icons.arrow_drop_down_outlined,
                  color: Colors.white,
                ),
              ),
              iconEnabledColor: MyColors.buttonColor,
              style: TextStyle(
                color: MyColors.textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(12),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                border: InputBorder.none,
              ),
              value: plan.selectedDurationId.value == 0
                  ? plan.countries!.first.duration![0]
                  : plan.countries!.first.duration!.firstWhere(
                      (value) => value.id == plan.selectedDurationId.value,
                      orElse: () => plan.countries!.first.duration![0], // Safety check
                    ),
              onChanged: (DurationPlan? newValue) {
                if (newValue != null) {
                  plan.selectedDurationId.value = newValue.id!;
                }
              },
              items: plan.countries![0].duration!.map((DurationPlan cat) {
                return DropdownMenuItem<DurationPlan>(
                  value: cat,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${plan.countries?.first.currency} ${cat.priceAmount}',
                        style: textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                      // const SizedBox(width: 5), // Spacing between texts
                      Text(
                        '/${cat.days}',
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            //SizedBox(height: 10.h),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  arrowContainer(textTheme, text: plan.shortDescription),
                  arrowContainer(textTheme, text: plan.longDescription),
                  arrowContainer(textTheme),
                  // arrowContainer(textTheme),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            CustomButton(
              height: 34,
              width: 190.w,
              roundCorner: 4,
              text: "Subscribe",
              fontSize: 14.sp,
              textColor: Colors.white,
              onPressed: () async {
                // Track plan selection
                DurationPlan? durationPlan;
                if (plan!.countries!.isNotEmpty) {
                  if (plan.countries!.first.duration!.isNotEmpty) {
                    durationPlan = plan.countries?.first!.duration!.firstWhere((test) => test.id == plan.selectedDurationId.value);
                  }
                }

                await AnalyticsHelper.trackPlanSelected(
                  plan.title,
                  planPrice: durationPlan?.priceAmount,
                  planDuration: durationPlan?.days,
                );

                // Show subscribe tutorial first and wait for user response
                final tutorialService = Get.find<YouTubeTutorialService>();
                await tutorialService.showSubscribeTutorial(context);

                Get.to(() => DietDetails(
                      currency: plan.countries?.first.currency ?? "Rs.",
                      isPlan: true,
                      title: plan.title,
                      description: plan.shortDescription,
                      longDescription: plan.longDescription,
                      planId: plan.id.toString(),
                      price: durationPlan == null ? "" : durationPlan.priceAmount ?? "",
                      duration: durationPlan == null ? "" : durationPlan.days ?? "",
                      durationId: plan.selectedDurationId.value,
                    ));
                // Get.to(()=>DietDetails());
                // Get.to(() => SelectPaymentMode(
                //       planId: plan.id.toString(),
                //       durationId: plan.selectedDurationId.value,
                //       price: plan.countries![0].duration
                //               ?.firstWhere(
                //                   (v) => v.id == plan.selectedDurationId.value)
                //               .priceAmount ??
                //           "N/A",
                //     ));
              },
              // color: Myc.white,
            ),
            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }

  arrowContainer(TextTheme textTheme, {String? text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            MyImgs.arrowCircleRight,
            colorFilter: const ColorFilter.mode(MyColors.buttonColor, BlendMode.srcIn),
          ),
          SizedBox(
            width: 10.w,
          ),
          SizedBox(
            width: 150,
            child: Text(
              text ?? 'Live Workout Session',
              style: textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
