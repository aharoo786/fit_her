import 'package:fitness_zone_2/UI/auth_module/result_screen.dart';
import 'package:fitness_zone_2/UI/diet_screen/dietry_module/widgets/calory_widget.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/helper/analytics_helper.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/services/youtube_tutorial_service.dart';
import 'package:fitness_zone_2/widgets/border_titlle_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/custom_print.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/toasts.dart';

class DietBottomBarScreen extends StatelessWidget {
  final DietController dietController = Get.find();
  final HomeController homeController = Get.find();
  final AuthController authController = Get.find();
  final int userPlanId;

  DietBottomBarScreen({super.key, required this.userPlanId});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          Get.back();
        }, text: "Diet Plan"),
        body: Obx(() => dietController.dietPlanDetailsLoad.value
            ? GetBuilder<DietController>(
                id: "dietBottomScreen",
                builder: (cont) {
                  return Obx(
                    () => dietController.dietPlanDetailsLoad.value
                        ? RefreshIndicator(
                            onRefresh: () async {
                              // Refresh diet plan details
                              await dietController.getDietPlanDetailsFunc(userPlanId.toString());
                            },
                            color: MyColors.buttonColor,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(
                                      "Get personalized meal plans with\ndetailed daily guidance to achieve\nyour nutrition goals.",
                                      style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(color: MyColors.planColor, borderRadius: BorderRadius.circular(10), boxShadow: [
                                      BoxShadow(offset: const Offset(0, 2), blurRadius: 10, spreadRadius: 0.5, color: Colors.black.withOpacity(0.25))
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

                                                  backgroundImage: AssetImage(MyImgs.logo),
                                                  // Replace with your image asset
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${dietController.getDietPlanDetails!.dietDetails.firstName} ${dietController.getDietPlanDetails!.dietDetails.lastName}",
                                                      style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
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
                                                          text: dietController.getDietPlanDetails!.dietDetails.experience,
                                                          style: textTheme.titleMedium!.copyWith(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: " yr experience",
                                                              style: textTheme.titleSmall!
                                                                  .copyWith(fontWeight: FontWeight.w400, color: const Color(0xff7F7F7F)),
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
                                              color: MyColors.primaryGradient1,
                                              width: 100.w,
                                              fontSize: 12.sp,
                                              text: "Whatsapp",
                                              onPressed: () async {
                                                // var userDetail = dietController.getDietPlanDetails?.dietDetails.id.toString();
                                                // var userMap = await homeController.getspecificUserFromFireStore(userDetail!);
                                                // var roomId = await homeController.makeRoomId(userDetail);
                                                // Get.to(() => ChatRoom(
                                                //       title:
                                                //           "Message to Dr.${dietController.getDietPlanDetails?.dietDetails.firstName} ${dietController.getDietPlanDetails?.dietDetails.lastName}",
                                                //       chatRoomId: roomId,
                                                //       userMap: userMap,
                                                //     ));
                                                openWhatsAppChat("${dietController.getDietPlanDetails?.dietDetails.phone}");
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Obx(() {
                                    if (dietController.getDietPlanDetails!.pdfFile.value.isNotEmpty) {
                                      return Column(
                                        children: [
                                          // const CaloryWidget(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            width: double.infinity,
                                            height: 400.h, // Fixed height for PDF viewer
                                            margin: const EdgeInsets.only(bottom: 12.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: const BorderRadius.all(Radius.zero),
                                              boxShadow: [BoxShadow(color: MyColors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
                                            ),
                                            child: SfPdfViewer.network(
                                              dietController.getDietPlanDetails!.pdfFile.value,
                                              onDocumentLoaded: (details) {
                                                // Track diet plan delivered when user views PDF
                                                AnalyticsHelper.trackDietPlanDelivered('day',
                                                    userPlanId: userPlanId,
                                                    dietitianId: dietController.getDietPlanDetails?.dietDetails.id);
                                              },
                                              onDocumentLoadFailed: (details) {},
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomButton(
                                              text: "Download Diet",
                                              onPressed: () async {
                                                var documentUrl = dietController.getDietPlanDetails!.pdfFile;
                                                String filePath = documentUrl.split("/").last;

                                                var file = await dietController.downloadFile(filePath, documentUrl.value);
                                                CustomToast.showDownLoadToast(context, filePath: file, message: 'Download Complete');
                                              }),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          if (dietController.getDietPlanDetails?.isBooked ?? false)
                                            Container(
                                              //width: 120.w,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                              margin: const EdgeInsets.symmetric(horizontal: 20),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.black)),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Booked Consultation\n${HelpingWidgets.formatDateWithMonthName(dietController.getDietPlanDetails?.date ?? DateTime.now())} (${dietController.getDietPlanDetails?.bookedSlot?.start} to ${dietController.getDietPlanDetails?.bookedSlot?.end})",
                                                      style: TextStyle(color: MyColors.textColor, fontSize: 12.sp, fontWeight: FontWeight.w400),
                                                    ),
                                                  ),
                                                  CustomButton(
                                                    width: 60,
                                                    height: 46.h,
                                                    text: "Join",
                                                    onPressed: () async {
                                                      // Then proceed with join logic
                                                      var trainerLink = dietController.getDietPlanDetails!.bookedSlot?.dietitionLink;
                                                      if (homeController.userHomeData!.userData.freeze.value) {
                                                        CustomToast.failToast(msg: "Your account is frozen please unfreeze first");
                                                      } else {
                                                        if (homeController.userHomeData!.userAllPlans.first.remainingDays == 0) {
                                                          CustomToast.failToast(msg: "Please renew your plan");
                                                          return;
                                                        }
                                                        if (trainerLink == null) {
                                                          CustomToast.failToast(msg: "Dietitian does not add link yet");
                                                        } else {
                                                          if (isValidUrl(trainerLink ?? "")) {
                                                            await launchUrl(Uri.parse(trainerLink ?? ""));
                                                          } else {
                                                            CustomToast.failToast(msg: "Dietitian does not add link yet");
                                                          }

                                                          // else {
                                                          //   Get.bottomSheet(
                                                          //       isScrollControlled: true,
                                                          //       FeedbackBottomSheet(dietController.getDietPlanDetails!.dietDetails.id.toString(),
                                                          //           dietController.getDietPlanDetails!.dietDetails.id.toString()));
                                                          // }
                                                        }
                                                      }
                                                    },
                                                    fontSize: 10,
                                                  )
                                                ],
                                              ),
                                            ),
                                         //  if (!(dietController.getDietPlanDetails?.isBooked ?? false))
                                         //    const BorderTitleWidget(text: "Daily Diet Plan"),
                                         // // const CaloryWidget(),
                                          if (!(dietController.getDietPlanDetails?.isBooked ?? false))
                                            ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                itemBuilder: (context, int index) {
                                                  var dayTime = dietController.getDietPlanDetails!.timeDietition[index];
                                                  print('DietBottomBarScreen.build ${dayTime.day}');
                                                  return ExpansionTile(
                                                    collapsedBackgroundColor: MyColors.planColor,

                                                    collapsedShape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    onExpansionChanged: (bool value) {
                                                      if (value) {}
                                                    },
                                                    // backgroundColor: MyColors.planColor,
                                                    iconColor: Colors.black,
                                                    trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                                                    tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                                                    minTileHeight: 40,
                                                    title: Row(
                                                      children: [
                                                        Text(
                                                          dayTime.day,
                                                          style: textTheme.bodyLarge,
                                                        ),
                                                        Text(
                                                          " ${HelpingWidgets.formatDateWithMonthName(HelpingWidgets.getNextWeekdayDate(dayTime.day))}",
                                                          style: textTheme.bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                    children: [
                                                      ListView.separated(
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemBuilder: (context, int timeIndex) {
                                                            var slot = dayTime.slots[timeIndex];
                                                            return Obx(
                                                              () => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                Flexible(
                                                                  child: GestureDetector(
                                                                    onTap: () async {
                                                                      // Show diet tutorial first and wait for user response
                                                                      final tutorialService = Get.find<YouTubeTutorialService>();
                                                                      await tutorialService.showDietTutorial(context);

                                                                      // Then proceed with booking
                                                                      dietController.bookAppointmentSlotId.value = slot.id ?? 0;
                                                                    },
                                                                    child: Container(
                                                                      height: 56.h,
                                                                      //width: 120.w,
                                                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                                                      alignment: Alignment.centerLeft,
                                                                      decoration: BoxDecoration(
                                                                          color: dietController.bookAppointmentSlotId.value == slot.id
                                                                              ? MyColors.buttonColor
                                                                              : Colors.white,
                                                                          borderRadius: BorderRadius.circular(8),
                                                                          border: Border.all(color: Colors.black)),
                                                                      child: Text(
                                                                        "Book Consultation (${slot.start} to ${slot.end})",
                                                                        style: TextStyle(
                                                                            color: dietController.bookAppointmentSlotId.value == slot.id
                                                                                ? MyColors.textColor2
                                                                                : MyColors.textColor,
                                                                            fontSize: 14.sp,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (dietController.bookAppointmentSlotId.value == slot.id)
                                                                  Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 10,
                                                                      ),
                                                                      CustomButton(
                                                                        width: 60,
                                                                        height: 56.h,
                                                                        text: "Book",
                                                                        onPressed: () {
                                                                          var date = HelpingWidgets.getNextWeekdayDate(dayTime.day);
                                                                          dietController.bookAppointment(
                                                                              userPlanId, dietController.getDietPlanDetails!.dietDetails.id, date);
                                                                        },
                                                                        fontSize: 10,
                                                                      )
                                                                    ],
                                                                  ),
                                                              ]),
                                                            );
                                                          },
                                                          separatorBuilder: (context, int index) {
                                                            return SizedBox(
                                                              height: 10.h,
                                                            );
                                                          },
                                                          itemCount: dayTime.slots.length)
                                                    ],
                                                  );
                                                },
                                                separatorBuilder: (context, int index) {
                                                  return SizedBox(
                                                    height: 10.h,
                                                  );
                                                },
                                                itemCount: dietController.getDietPlanDetails!.timeDietition.length),
                                          if (dietController.getDietPlanDetails?.isBooked ?? false)
                                            Column(
                                              children: [
                                                const SizedBox(
                                                  height: 50,
                                                ),
                                                SvgPicture.asset(MyImgs.doneTick),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                                  child: Text(
                                                    "Your appointment has been booked! You'll receive a notification when it's time for your session.",
                                                    textAlign: TextAlign.center,
                                                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                                CustomButton(
                                                  text: "Reschedule",
                                                  onPressed: () {
                                                    if (dietController.getDietPlanDetails?.status == "canceled") {
                                                      dietController.updateReschedule();
                                                      return;
                                                    }

                                                    HelpingWidgets.showCustomDialog(
                                                      context,
                                                      () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      "You can cancel your appointment with Dietitian if an emergency arises.",
                                                      "Note: This option is valid for once.",
                                                      MyImgs.warning,
                                                      buttonText: "Back",
                                                      secondButtonText: "Cancel",
                                                      secondButtonTap: () {
                                                        Navigator.of(context).pop();
                                                        dietController.updateAppointmentStatus(
                                                            dietController.getDietPlanDetails?.id ?? 0, "canceledByUser",
                                                            planId: userPlanId.toString(), isFromDietDetails: true);
                                                      },
                                                    );
                                                  },
                                                  height: 32,
                                                  width: 120,
                                                  roundCorner: 25,
                                                  fontSize: 12,
                                                )
                                              ],
                                            )
                                        ],
                                      );
                                    }
                                  }),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // ListView.separated(
                                  //   shrinkWrap: true,
                                  //   physics: const NeverScrollableScrollPhysics(),
                                  //   padding:
                                  //       EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  //   itemCount: dietController
                                  //       .getDietPlanDetails!
                                  //       .details
                                  //       .dietTimes
                                  //       .length, // Number of stars (you can make this dynamic)
                                  //   itemBuilder: (context, index) {
                                  //     var dietTime = dietController
                                  //         .getDietPlanDetails!.details.dietTimes[index];
                                  //     return GestureDetector(
                                  //       onTap: () {
                                  //         Get.to(() => DietPlanFoodDetails(
                                  //               dietPlan: dietTime.diets,
                                  //             ));
                                  //       },
                                  //       child: Container(
                                  //         width: double.maxFinite,
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 20.w, vertical: 14.h),
                                  //         decoration: BoxDecoration(
                                  //             color: MyColors.planColor,
                                  //             borderRadius: BorderRadius.circular(8),
                                  //             boxShadow: [
                                  //               BoxShadow(
                                  //                   offset: const Offset(0, 2),
                                  //                   blurRadius: 4,
                                  //                   spreadRadius: 0.5,
                                  //                   color: Colors.black.withOpacity(0.25))
                                  //             ]),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Text(
                                  //               dietTime.day,
                                  //               style: textTheme.bodySmall!
                                  //                   .copyWith(fontWeight: FontWeight.w600),
                                  //             ),
                                  //             const Icon(Icons.arrow_right),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   separatorBuilder: (BuildContext context, int index) {
                                  //     return SizedBox(
                                  //       height: 15.h,
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                          )
                        : CircularProgress(),
                  );
                })
            : CircularProgress()));
  }
}
