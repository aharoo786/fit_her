import 'package:fitness_zone_2/UI/plans_module/all_plans.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../helper/custom_print.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/toasts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../call_screen/call_screen.dart';

class WorkOutBottomScreen extends StatelessWidget {
  WorkOutBottomScreen({super.key});

  final List workoutText = ["Cardo", "Face", "Yoga"];
  AuthController authController = Get.find();
  HomeController homeController = Get.find();
  WorkOutController workOutController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: HelpingWidgets().appBarWidget(null, text: "Workout Schedule"),
        body: Obx(
          () => !workOutController.workOutPlanDetailsLoad.value
              ? CircularProgress()
              : ListView(
                  children: [
                    Center(
                      child: Text(
                        "We provide you with flexible timeslots\nthroughout the day so that you can\njoin according to your feasibility",
                        style: textTheme.bodySmall!
                            .copyWith(fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.green, // Header background color
                          onPrimary: Colors.white, // Header text color
                          onSurface: Colors.black, // Body text color
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green, // Button text color
                          ),
                        ),
                      ),
                      child: CalendarDatePicker(
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2090),
                          selectableDayPredicate: (DateTime value) {
                            return true;
                          },
                          onDateChanged: (DateTime date) {}),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(15),
                    //       color: MyColors.planColor),
                    //   margin: EdgeInsets.symmetric(horizontal: 20.w),
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: 10.w, vertical: 5.h),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         "Monday",
                    //         style: textTheme.bodySmall!
                    //             .copyWith(fontWeight: FontWeight.w600),
                    //       ),
                    //       Row(
                    //         children: [
                    //           Text(
                    //             "View All",
                    //             style: textTheme.bodySmall!
                    //                 .copyWith(fontWeight: FontWeight.w600),
                    //           ),
                    //           const Icon(Icons.arrow_drop_down_sharp)
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                    // Wrap(
                    //   children: workoutText.map((i) {
                    //     return Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Container(
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(15),
                    //               color: MyColors.primaryGradient1),
                    //           margin: EdgeInsets.only(left: 20.w),
                    //           padding: EdgeInsets.symmetric(
                    //               horizontal: 10.w, vertical: 5.h),
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 i,
                    //                 style: textTheme.bodySmall!.copyWith(
                    //                     fontWeight: FontWeight.w600,
                    //                     color: Colors.white),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     );
                    //   }).toList(),
                    // ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemBuilder: (BuildContext context, int timeIndex) {
                        var time = workOutController
                            .getUserWorkoutPlanDetailsPlan!
                            .plan
                            .times[timeIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              time.day,
                              style: textTheme.headlineSmall,
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                              ),
                              itemCount: time.slots
                                  .length, // Number of stars (you can make this dynamic)
                              itemBuilder: (context, index) {
                                var slot = time.slots[index];
                                return GestureDetector(
                                  onTap: () async {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 16),
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(Icons.access_time,
                                                        color: Colors.green,
                                                        size: 32),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      '50 Min',
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text('Time'),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .local_fire_department,
                                                        color: Colors.green,
                                                        size: 32),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      '254',
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text('Calories'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const Divider(),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.access_time_sharp),
                                              title: Text(
                                                '${slot.start}-${slot.end}',
                                                style: textTheme.bodySmall,
                                              ),
                                              visualDensity:
                                                  VisualDensity(vertical: -4),
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(Icons.fitness_center),
                                              title: Text(
                                                  'High Intensity Workout Session',
                                                  style: textTheme.bodySmall),
                                              visualDensity:
                                                  VisualDensity(vertical: -4),
                                            ),
                                            ListTile(
                                              leading: const CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    MyImgs.profilePicture),
                                                maxRadius: 10,
                                              ),
                                              title: Text(
                                                  'with ${workOutController.getUserWorkoutPlanDetailsPlan!.plan.title}',
                                                  style: textTheme.bodySmall),
                                              visualDensity:
                                                  VisualDensity(vertical: -4),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                if (homeController
                                                        .userHomeData!.freeze ==
                                                    1) {
                                                  CustomToast.failToast(
                                                      msg:
                                                          "Your account is freezed please contact admin for further help");
                                                } else {
                                                  if (slot.trainerLink ==
                                                      null) {
                                                    CustomToast.failToast(
                                                        msg:
                                                            "Trainer did not add link yet");
                                                  } else {
                                                    if (isValidUrl(
                                                        slot.trainerLink ??
                                                            "")) {
                                                      await launchUrl(Uri.parse(
                                                          slot.trainerLink ??
                                                              ""));
                                                    } else {
                                                      await handleCameraAndMic(
                                                          Permission.camera);
                                                      await handleCameraAndMic(
                                                          Permission
                                                              .microphone);
                                                      var token =
                                                          await homeController
                                                              .getAgoraToken(
                                                                  slot.trainerLink ??
                                                                      "");

                                                      Get.to(() => CallScreen(
                                                            channelName:
                                                                slot.trainerLink ??
                                                                    "",
                                                            token: token!,
                                                            userId: Get.find<
                                                                    AuthController>()
                                                                .logInUser!
                                                                .id
                                                                .toString(),
                                                            // camera: firstCamera,
                                                          ));
                                                    }
                                                  }
                                                }
                                              },
                                              icon:
                                                  const Icon(Icons.video_call),
                                              label: const Text('Join Session'),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 24),
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 65.h,
                                    width: double.maxFinite,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 13.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${slot.start} - ${slot.end}",
                                              style: textTheme.bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                            const Spacer(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const CircleAvatar(
                                                  radius: 12,

                                                  backgroundImage: AssetImage(MyImgs
                                                      .profilePicture1), // Replace with your image asset
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workOutController
                                                          .getUserWorkoutPlanDetailsPlan!
                                                          .plan
                                                          .title,
                                                      style: textTheme
                                                          .bodySmall!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xff7F7F7F)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SvgPicture.asset(MyImgs.progressbar)
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 15.h,
                                );
                              },
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 10.h,
                        );
                      },
                      itemCount: workOutController
                          .getUserWorkoutPlanDetailsPlan!.plan.times.length,
                    )
                  ],
                ),
        ));
  }
}
