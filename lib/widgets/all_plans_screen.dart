import 'package:fitness_zone_2/UI/dashboard_module/add_package/add_package.dart';
import 'package:fitness_zone_2/UI/dashboard_module/add_package/package_details.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/models/get_user_plan/get_user_plan.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';

class AllPlansScreen extends StatelessWidget {
  AllPlansScreen({super.key, this.isHaveAppBar = false});
  final bool isHaveAppBar;
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: isHaveAppBar
          ? HelpingWidgets().appBarWidget(() {
              Get.back();
            }, text: "All Plans")
          : null,
      bottomNavigationBar: isHaveAppBar
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                  text: "Update",
                  onPressed: () {
                    var index = homeController.selectedPlanIndex.value;
                    Plan selectedPlan =
                        homeController.allPlanModel!.plans[index];
                    homeController.packageName.text = selectedPlan.title;
                    homeController.shortDis.text =
                        selectedPlan.shortDescription;
                    homeController.longDis.text = selectedPlan.longDescription;
                    homeController.price.text = selectedPlan.price.toString();
                    homeController.packageDuration.text = selectedPlan.duration;
                    homeController.selectedId.value = selectedPlan.categoryId;
                    homeController.selectedId.value = selectedPlan.categoryId;
                    // homeController.addPackageTimeTable=selectedPlan
                    homeController.getCategories();

                    Get.to(() => AddPackage(
                          isFromUpdate: true,
                        ));
                  }),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
                itemCount: homeController.getPlanLoaded.value
                    ? homeController.allPlanModel!.plans.length
                    : 1,
                itemBuilder: (BuildContext context, int index) {
                  if (homeController.getPlanLoaded.value) {
                    var plan = homeController.allPlanModel!.plans[index];
                    return GestureDetector(
                      onTap: () {
                        homeController.selectedPlanId.value = plan.id;
                        homeController.selectedPlanIndex.value = index;
                        if (!isHaveAppBar) {
                          Get.to(() => PackageDetails(
                                plan: plan,
                              ));
                          homeController.getAllDietitian();
                        }
                      },
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(maxHeight: 150.h),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: homeController.selectedPlanId.value ==
                                          plan.id
                                      ? MyColors.buttonColor
                                      : Colors.white),
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
                                    style: textTheme.headlineSmall!.copyWith(
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
                                    style: textTheme.bodySmall!.copyWith(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "PKR ${plan.price}",
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: MyColors.buttonColor,
                    ));
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 10.h,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
