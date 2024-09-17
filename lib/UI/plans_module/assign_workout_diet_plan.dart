import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/get_all_dietitian_trainers/get_all_dietitian_trainers.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../../widgets/circular_progress.dart';

class AssignWorkoutDietPlan extends StatelessWidget {
  AssignWorkoutDietPlan({super.key});
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Assign Plan"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Select Dietitians",
              style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Obx(() => homeController.getDietitianLoad.value
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: list(
                      homeController.getAllDietitianAndTrainers!.dietitions,
                      homeController.selectedDietId,
                      textTheme),
                )
              : const CircularProgress()),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Select Trainers",
              style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Obx(() => homeController.getDietitianLoad.value
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: list(
                      homeController.getAllDietitianAndTrainers!.trainers,
                      homeController.selectedTrainerId,
                      textTheme),
                )
              : const CircularProgress()),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Select Plan",
              style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Obx(() => homeController.getPlanLoaded.value
              ? SizedBox(
                  height: 170.h,
                  child: ListView.separated(
                    padding: EdgeInsets.only(top: 20.h, left: 20.w, bottom: 10),
                    itemCount: homeController.allPlanModel!.plans.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      var plan = homeController.allPlanModel!.plans[index];
                      return GestureDetector(
                        onTap: () {
                          homeController.selectedPlanIndex.value = index;
                        },
                        child: Obx(
                          () => Container(
                            width: 300.w,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: homeController
                                                .selectedPlanIndex.value ==
                                            index
                                        ? MyColors.buttonColor
                                        : Colors.white),
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
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: 10.w,
                      );
                    },
                  ))
              : const Center(
                  child: CircularProgress(),
                )),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
              child: Center(
                  child: CustomButton(text: "Assign", onPressed: () {homeController.addWorkoutAndTrainerApp();}))),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

  Widget list(List<Dietition> list, RxInt variable, TextTheme textTheme) {
    return ListView.separated(
      // shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        var diet = list[index];

        return GestureDetector(
          onTap: () {
            variable.value = diet.id;
          },
          child: Obx(
            () => Container(
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: variable.value == diet.id
                          ? MyColors.buttonColor
                          : Colors.white),
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.1))
                  ]),
              child: Row(children: [
                Container(
                  width: 70.w,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: MyColors.primaryGradient1,
                      image: const DecorationImage(
                          image: AssetImage(MyImgs.logo))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${diet.firstName} ${diet.lastName}",
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          diet.email,
                          style: textTheme.bodySmall!.copyWith(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10.h,
        );
      },
    );
  }
}
