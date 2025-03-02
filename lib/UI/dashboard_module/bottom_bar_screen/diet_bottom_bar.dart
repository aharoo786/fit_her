import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/border_titlle_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:get/get.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/custom_print.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/review_bottom_sheet.dart';
import '../../../widgets/toasts.dart';
import '../../chat/widgets/chat_room.dart';
import '../call_screen/call_screen.dart';

class DietBottomBarScreen extends StatelessWidget {
  DietController dietController = Get.find();
  HomeController homeController = Get.find();
  AuthController authController = Get.find();
  int userPlanId;
  DietBottomBarScreen({required this.userPlanId});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: HelpingWidgets().appBarWidget(null, text: "Diet Plan"),
        body: Obx(() => dietController.dietPlanDetailsLoad.value
            ? Column(
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
                                      "${dietController.getDietPlanDetails!.dietDetails.firstName} ${dietController.getDietPlanDetails!.dietDetails.lastName}",
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
                                          text: dietController
                                              .getDietPlanDetails!
                                              .dietDetails
                                              .experience,
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
                            if (dietController.getDietPlanDetails!.bookedSlot !=
                                null)
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
                                  var trainerLink = dietController
                                      .getDietPlanDetails!
                                      .bookedSlot
                                      ?.dietitionLink;

                                  if (homeController
                                      .userHomeData!.userData.freeze.value) {
                                    CustomToast.failToast(
                                        msg:
                                            "Your account is freezed please unfreeze first");
                                  } else {
                                    if (homeController.userHomeData!
                                            .userAllPlans.first.remainingDays ==
                                        0) {
                                      CustomToast.failToast(
                                          msg: "Please renew your plan");
                                      return;
                                    }
                                    if (trainerLink == null) {
                                      CustomToast.failToast(
                                          msg:
                                              "Dietitian does not add link yet");
                                    } else {
                                      if (isValidUrl(trainerLink ?? "")) {
                                        await launchUrl(
                                            Uri.parse(trainerLink ?? ""));
                                        // Get.to(() => AppWebView(
                                        //       url: trainerLink,
                                        //     ));
                                        // Get.to(()=>WebViewScreen(url: "https://meet.google.com/aig-xvta-fpd",));
                                      } else {
                                        await handleCameraAndMic(
                                            Permission.camera);
                                        await handleCameraAndMic(
                                            Permission.microphone);
                                        var token = await homeController
                                            .getAgoraToken(trainerLink ?? "");

                                        var isReview = Get.to(() => CallScreen(
                                              isDiet: true,
                                              channelName: trainerLink ?? "",
                                              token: token!,
                                              userId: Get.find<AuthController>()
                                                  .logInUser!
                                                  .id
                                                  .toString(),
                                              title: "Dietary Consultation",
                                              // camera: firstCamera,
                                            ));
                                        if (isReview != null) {
                                          // showModalBottomSheet(
                                          //   context: context,
                                          //   isScrollControlled: true,
                                          //   builder: (context) =>
                                          //       FeedbackBottomSheet(
                                          //           dietController
                                          //               .getDietPlanDetails!
                                          //               .dietDetails
                                          //               .id
                                          //               .toString(),
                                          //           dietController
                                          //               .getDietPlanDetails!
                                          //               .dietDetails
                                          //               .id
                                          //               .toString()
                                          //               ),
                                          // );
                                          Get.bottomSheet(
                                              isScrollControlled: true,
                                              FeedbackBottomSheet(
                                                  dietController
                                                      .getDietPlanDetails!
                                                      .dietDetails
                                                      .id
                                                      .toString(),
                                                  dietController
                                                      .getDietPlanDetails!
                                                      .dietDetails
                                                      .id
                                                      .toString()));
                                        }
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
                              width: 100.w,
                              fontSize: 12.sp,
                              text: "Message",
                              onPressed: () async {
                                var userDetail = dietController
                                    .getDietPlanDetails?.dietDetails.id
                                    .toString();

                                var userMap = await homeController
                                    .getspecificUserFromFireStore(userDetail!);
                                var roomId =
                                    await homeController.makeRoomId(userDetail);

                                Get.to(() => ChatRoom(
                                      title:
                                          "Message to Dr.${dietController.getDietPlanDetails?.dietDetails.firstName} ${dietController.getDietPlanDetails?.dietDetails.lastName}",
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
                  if (dietController
                      .getDietPlanDetails!.timeDietition.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemBuilder: (context, int index) {
                            var dayTime = dietController
                                .getDietPlanDetails!.timeDietition[index];
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
                              trailing:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                              tilePadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              minTileHeight: 40,
                              title: Text(
                                dayTime.day,
                                style: textTheme.bodyLarge,
                              ),
                              children: [
                                ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, int timeIndex) {
                                      var slot = dayTime.slots[timeIndex];
                                      return Obx(
                                        () => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    dietController
                                                        .bookAppointmentSlotId
                                                        .value = slot.id ?? 0;
                                                  },
                                                  child: Container(
                                                    height: 56.h,
                                                    //width: 120.w,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.w),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    decoration: BoxDecoration(
                                                        color: dietController
                                                                    .bookAppointmentSlotId
                                                                    .value ==
                                                                slot.id
                                                            ? MyColors
                                                                .buttonColor
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: Text(
                                                      "Book Consultation (${slot.start} to ${slot.end})",
                                                      style: TextStyle(
                                                          color: dietController
                                                                      .bookAppointmentSlotId
                                                                      .value ==
                                                                  slot.id
                                                              ? MyColors
                                                                  .textColor2
                                                              : MyColors
                                                                  .textColor,
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (dietController
                                                      .bookAppointmentSlotId
                                                      .value ==
                                                  slot.id)
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
                                                        dietController
                                                            .bookAppointment(
                                                                userPlanId,
                                                                dietController
                                                                    .getDietPlanDetails!
                                                                    .dietDetails
                                                                    .id);
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
                          itemCount: dietController
                              .getDietPlanDetails!.timeDietition.length),
                    ),

                  Obx(() => dietController
                          .getDietPlanDetails!.pdfFile.value.isNotEmpty
                      ? Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        const BorderRadius.all(Radius.zero),
                                    boxShadow: [
                                      BoxShadow(
                                          color: MyColors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5)
                                    ],
                                  ),
                                  child: SfPdfViewer.network(
                                    dietController
                                        .getDietPlanDetails!.pdfFile.value,
                                    onDocumentLoadFailed: (details) {},
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomButton(
                                  text: "Download Diet",
                                  onPressed: () async {
                                    var documentUrl = dietController
                                        .getDietPlanDetails!.pdfFile;
                                    String filePath =
                                        documentUrl.split("/").last;

                                    var file =
                                        await dietController.downloadFile(
                                            filePath, documentUrl.value);
                                    print("path  $file");
                                    CustomToast.showDownLoadToast(context,
                                        filePath: file,
                                        message: 'Download Complete');
                                  }),
                            ],
                          ),
                        )
                      : SizedBox()),

                  SizedBox(
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
              )
            : CircularProgress()));
  }
}
