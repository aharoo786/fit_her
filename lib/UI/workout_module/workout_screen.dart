import 'package:fitness_zone_2/UI/diet_screen/doctor_details.dart';
import 'package:fitness_zone_2/data/models/get_all_users/get_all_users_based_on_type.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/meal_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/controllers/home_controller/home_controller.dart';

class WorkoutScreen extends StatelessWidget {
  WorkoutScreen({super.key, this.isProduct = false});
  final bool isProduct;
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: isProduct ? "Our Products" : "Workouts"),
      body: Obx(() => homeController.getUsersBasedOnUserTypeLoad.value
          ? ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.all(18.w),
              itemCount: homeController.getUsersBasedOnUserTypeModel!.users
                  .length, // Number of stars (you can make this dynamic)
              itemBuilder: (context, index) {
                var trainer =
                    homeController.getUsersBasedOnUserTypeModel!.users[index];
                return GestureDetector(
                  onTap: () {
                    if (isProduct) {
                      Get.to(() => DietDetails());
                    } else {
                      Get.to(() => DoctorDetails(
                            userTypeData: trainer,
                          ));
                    }
                  },
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        height: 120.h,
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(
                            vertical: 13.h, horizontal: 25.w),
                        decoration: BoxDecoration(
                            color: MyColors.workOut1,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0.5,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.25))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isProduct
                                  ? "Workout Equipment"
                                  : "${trainer.description ?? ""}",
                              style: textTheme.bodySmall!.copyWith(
                                  color: MyColors.workOutTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              isProduct
                                  ? "Dumbbells"
                                  : "${trainer.firstName} ${trainer.lastName}",
                              style: textTheme.headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            isProduct
                                ? Text(
                                    "Rs. 2000",
                                    style: textTheme.bodyMedium!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  )
                                : CustomButton(
                                    text: trainer.experience == null
                                        ? "Beginner level"
                                        : int.parse(trainer.experience!) > 2
                                            ? "Experience Level"
                                            : "Beginner level",
                                    onPressed: () {},
                                    height: 22.h,
                                    fontSize: 12.sp,
                                    width: 150.w,
                                    textColor: Colors.black,
                                    color: const Color(0xffA4D78B),
                                    borderColor: const Color(0xffA4D78B))
                          ],
                        ),
                      ),
                      Image.asset(
                        isProduct ? MyImgs.dumble : MyImgs.yoga3,
                        scale: 4,
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: isProduct ? 25.h : 15.h,
                );
              },
            )
          : CircularProgress()),
    );
  }
}
