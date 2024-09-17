import 'package:fitness_zone_2/UI/diet_screen/doctor_details.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/meal_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietScreen extends StatelessWidget {
  DietScreen({super.key, this.fromBottomBar = true});
  final bool fromBottomBar;
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(
          fromBottomBar
              ? null
              : () {
                  Get.back();
                },
          text: "Consultation"),
      body: Column(
        children: [
          SizedBox(
            height: 255.h,
            child: Obx(() => homeController.getUsersBasedOnUserTypeLoad.value
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: homeController
                        .getUsersBasedOnUserTypeModel!
                        .users
                        .length, // Number of stars (you can make this dynamic)
                    itemBuilder: (context, index) {
                      var user = homeController
                          .getUsersBasedOnUserTypeModel!.users[index];
                      return Stack(
                        children: [
                          Container(
                            width: 250.w,
                            margin: EdgeInsets.only(
                                left: 25.w, right: index == 4 ? 20.w : 0),
                            padding: EdgeInsets.symmetric(
                                vertical: 26.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                                color: MyColors.workOut1,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 1),
                                      spreadRadius: 0.5,
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.25))
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user.firstName} ${user.lastName}",
                                  style: textTheme.bodySmall!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "Expert on diet and\nnutrition",
                                  style: textTheme.titleLarge!.copyWith(
                                      color: MyColors.workOutTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                CustomButton(
                                  text: "See More",
                                  onPressed: () {
                                    Get.to(() => DoctorDetails(
                                          userTypeData: user,
                                        ));
                                  },
                                  height: 24.h,
                                  fontSize: 10.sp,
                                  width: 90.w,
                                  // textColor: Colors.black,
                                  // color: const Color(0xffA4D78B),
                                  // borderColor: const Color(0xffA4D78B)
                                )
                              ],
                            ),
                          ),
                          // Positioned(
                          //     // left: 80.w,
                          //     bottom: 0,
                          //     right:20,
                          //
                          //     child: ClipRRect(
                          //       borderRadius: BorderRadius.circular(10),
                          //       child: Image.asset(
                          //         MyImgs.doctor,
                          //         scale: 3.5,
                          //       ),
                          //     ))
                        ],
                      );
                    },
                  )
                : CircularProgress()),
          ),
          // Expanded(
          //   child: ListView.separated(
          //     shrinkWrap: true,
          //     padding: EdgeInsets.all(18.w),
          //     itemCount: 5, // Number of stars (you can make this dynamic)
          //     itemBuilder: (context, index) {
          //       return GestureDetector(
          //         onTap: () {
          //           Get.to(() => DietDetails());
          //         },
          //         child: Container(
          //           height: 140.h,
          //           width: double.maxFinite,
          //           decoration: BoxDecoration(
          //               color: MyColors.planColor,
          //               borderRadius: BorderRadius.circular(25),
          //               border: Border.all(color: Colors.black, width: 1.w),
          //               boxShadow: [
          //                 BoxShadow(
          //                     offset: const Offset(0, 4),
          //                     spreadRadius: 0.5,
          //                     blurRadius: 10,
          //                     color: Colors.black.withOpacity(0.25))
          //               ]),
          //           child: Row(
          //             children: [
          //               Image.asset(MyImgs.dietImage),
          //               Expanded(
          //                 child: Padding(
          //                   padding: EdgeInsets.symmetric(
          //                       vertical: 10.h, horizontal: 20.w),
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text(
          //                         "Keto Diet Plan",
          //                         style: textTheme.titleLarge!
          //                             .copyWith(fontWeight: FontWeight.w600),
          //                       ),
          //                       SizedBox(
          //                         height: 3.h,
          //                       ),
          //                       Expanded(
          //                         child: Text(
          //                           "A low-carb, high-fat diet that helps you burn fat more effectively. Includes meals rich in healthy fats and proteins.",
          //                           style: textTheme.titleMedium!.copyWith(
          //                               fontWeight: FontWeight.w600,
          //                               height: 1.5,
          //                               overflow: TextOverflow.ellipsis),
          //                           maxLines: 3,
          //                         ),
          //                       ),
          //                       SizedBox(
          //                         height: 25.h,
          //                       ),
          //                       Align(
          //                         alignment: Alignment.centerRight,
          //                         child: Text(
          //                           "Read More",
          //                           style: textTheme.titleMedium!.copyWith(
          //                               fontWeight: FontWeight.w600,
          //                               decoration: TextDecoration.underline),
          //                         ),
          //                       )
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //     separatorBuilder: (BuildContext context, int index) {
          //       return SizedBox(
          //         height: 25.h,
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
