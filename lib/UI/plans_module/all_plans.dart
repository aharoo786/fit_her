import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/meal_details.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import '../../data/models/get_user_plan/get_user_plan.dart';

class OurPlansScreen extends StatelessWidget {
  OurPlansScreen({super.key});
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Our Plans"),
      body: Obx(
        () => homeController.getPlanLoaded.value
            ? GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  mainAxisSpacing: 48.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio:
                      0.7, // Adjust the aspect ratio to your needs
                ),
                itemCount: homeController
                    .allPlanModel?.plans.length, // Number of items in the grid
                itemBuilder: (context, index) {
                  var plan = homeController.allPlanModel?.plans[index];
                  if (plan!.countries!.isNotEmpty) {
                    if (plan.countries!.first.duration!.isNotEmpty) {
                      plan!.selectedDurationId.value =
                          plan.countries!.first.duration!.first.id!;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      DurationPlan? durationPlan;
                      if (plan!.countries!.isNotEmpty) {
                        if (plan.countries!.first.duration!.isNotEmpty) {
                          durationPlan = plan.countries?.first!.duration!
                              .firstWhere((test) =>
                                  test.id == plan.selectedDurationId.value);
                        }
                      }

                      Get.to(() => DietDetails(
                            isPlan: true,
                            title: plan.title,
                            description: plan.shortDescription,
                            longDescription: plan.longDescription,
                            planId: plan.id.toString(),
                            currency: plan.countries?.first.currency ?? "Rs.",
                            price: durationPlan == null
                                ? ""
                                : durationPlan.priceAmount ?? "",
                            duration: durationPlan == null
                                ? ""
                                : durationPlan.days ?? "",
                            durationId: plan.selectedDurationId.value,
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              spreadRadius: 0,
                              color: Colors.black.withOpacity(0.25))
                        ],
                      ),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: constraints.maxHeight / 2,
                                decoration: const BoxDecoration(
                                    color: MyColors.primaryGradient1,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25)),
                                    image: DecorationImage(
                                        image: AssetImage(MyImgs.logo))),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 10.w, right: 10.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan!.title,
                                      style: textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    Text(
                                      plan.shortDescription,
                                      style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withOpacity(0.35),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 30,
                                      alignment: Alignment.center,
                                      child:
                                          DropdownButtonFormField<DurationPlan>(
                                        itemHeight: null,
                                        // padding: const EdgeInsets.only(left: 20, bottom: 10),
                                        iconSize: 20,
                                        icon: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              color: MyColors.buttonColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: MyColors.textColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          border: InputBorder.none,
                                        ),
                                        value: plan.selectedDurationId.value ==
                                                0
                                            ? plan.countries![0].duration![0]
                                            : plan.countries![0].duration!
                                                .firstWhere(
                                                (value) =>
                                                    value.id ==
                                                    plan.selectedDurationId
                                                        .value,
                                                orElse: () => plan.countries![0]
                                                        .duration![
                                                    0], // Safety check
                                              ),
                                        onChanged: (DurationPlan? newValue) {
                                          if (newValue != null) {
                                            plan.selectedDurationId.value =
                                                newValue.id!;
                                          }
                                        },
                                        items: plan.countries![0].duration!
                                            .map((DurationPlan cat) {
                                          return DropdownMenuItem<DurationPlan>(
                                            value: cat,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${plan.countries![0].currency} ${cat.priceAmount}',
                                                  style: textTheme.titleLarge!
                                                      .copyWith(
                                                    fontSize: 8.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                // Spacing between texts
                                                Text(
                                                  ' per ${cat.days}',
                                                  style: textTheme.titleLarge!
                                                      .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                    // Row(
                                    //   children: List.generate(5, (index) {
                                    //     return Icon(
                                    //       index < 4
                                    //           ? Icons.star
                                    //           : Icons
                                    //               .star_border, // 4 filled stars and 1 empty star
                                    //       color: Colors.amber,
                                    //       size: 14,
                                    //     );
                                    //   }),
                                    // ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.arrow_forward_ios_sharp,
                                          size: 15,
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgress(),
              ),
      ),
    );
  }
}
