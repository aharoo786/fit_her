import 'package:fitness_zone_2/UI/diet_screen/diet_plan_food_details.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_trainers/get_diet_plan_details.dart';
import 'package:fitness_zone_2/widgets/border_titlle_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/custom_print.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/toasts.dart';
import '../../chat/widgets/chat_room.dart';
import '../call_screen/call_screen.dart';

class DietBottomBarScreen extends StatelessWidget {
  DietBottomBarScreen({super.key});
  final List workoutText = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  DietController dietController = Get.find();
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: HelpingWidgets().appBarWidget(null, text: "Diet Plan"),
        body: Obx(() => dietController.dietPlanDetailsLoad.value
            ? ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Get personalized meal plans with\ndetailed daily guidance to achieve\nyour nutrition goals.",
                      style: textTheme.bodySmall!
                          .copyWith(fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
                    width: double.maxFinite,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                        color: MyColors.planColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 4),
                              blurRadius: 20,
                              spreadRadius: 0.5,
                              color: Colors.black.withOpacity(0.25))
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,

                                  backgroundImage: AssetImage(MyImgs
                                      .logo), // Replace with your image asset
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${dietController.getDietPlanDetails!.dietitionDetails.user.firstName} ${dietController.getDietPlanDetails!.dietitionDetails.user.lastName}",
                                      style: textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    // Text(
                                    //   "Nutrition Expert & Coach",
                                    //   style: textTheme.titleSmall!.copyWith(
                                    //       fontWeight: FontWeight.w400,
                                    //       color: const Color(0xff7F7F7F)),
                                    // ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                          text:   "N/A",
                                          style:
                                              textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: " yr experience",
                                              style: textTheme.titleSmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xff7F7F7F)),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomButton(
                              height: 25.h,
                              roundCorner: 4,
                              borderColor: MyColors.primaryGradient1,
                              textColor: MyColors.primaryGradient1,
                              color: MyColors.planColor,
                              width: 150.w,
                              fontSize: 12.sp,
                              text: "Appointment",
                              onPressed: () async {
                                var trainerLink =  dietController
                                    .getDietPlanDetails!.details.dietitionLink;

                                if (homeController.userHomeData!.freeze == 1) {
                                  CustomToast.failToast(
                                      msg:
                                      "Your account is freezed please contact admin for further help");
                                } else {
                                  if (trainerLink == null) {
                                    CustomToast.failToast(
                                        msg: "Dietitian did not add link yet");
                                  } else {
                                    if (isValidUrl(trainerLink ?? "")) {
                                      await launchUrl(
                                          Uri.parse(trainerLink ?? ""));
                                    } else {
                                      await handleCameraAndMic(
                                          Permission.camera);
                                      await handleCameraAndMic(
                                          Permission.microphone);
                                      var token = await homeController
                                          .getAgoraToken(trainerLink ?? "");

                                      Get.to(() => CallScreen(
                                        channelName: trainerLink ?? "",
                                        token: token!,
                                        userId: Get.find<AuthController>()
                                            .logInUser!
                                            .id
                                            .toString(),
                                        // camera: firstCamera,
                                      ));
                                    }
                                  }
                                }
                              },
                            ),

                            SizedBox(
                              height: 5.h,
                            ),
                            CustomButton(
                              height: 25.h,
                              roundCorner: 4,
                              color: MyColors.primaryGradient1,
                              width: 80.w,
                              fontSize: 12.sp,
                              text: "Chat",
                              onPressed: () async {
                                var userDetail = dietController
                                    .getDietPlanDetails
                                    ?.dietitionDetails
                                    .user
                                    .id
                                    .toString();

                                var userMap =await homeController
                                    .getspecificUserFromFireStore(userDetail!);
                                var roomId =await  homeController
                                    .makeRoomId(userDetail);

                                Get.to(() => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap,
                                ));
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  const BorderTitleWidget(text: "Daily Diet Plan"),
                  SizedBox(
                    height: 10.h,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    itemCount: dietController
                        .getDietPlanDetails!
                        .details
                        .dietTimes
                        .length, // Number of stars (you can make this dynamic)
                    itemBuilder: (context, index) {
                      var dietTime = dietController
                          .getDietPlanDetails!.details.dietTimes[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => DietPlanFoodDetails(
                                dietPlan: dietTime.diets,
                              ));
                        },
                        child: Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 14.h),
                          decoration: BoxDecoration(
                              color: MyColors.planColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0.5,
                                    color: Colors.black.withOpacity(0.25))
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dietTime.day,
                                style: textTheme.bodySmall!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.arrow_right),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 15.h,
                      );
                    },
                  ),
                ],
              )
            : CircularProgress()));
  }
}
