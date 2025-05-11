import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../data/controllers/call_controller/chat_controller.dart';
import '../../../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../../../helper/custom_print.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/review_bottom_sheet.dart';
import '../../../widgets/toasts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../call_screen/call_screen.dart';
import 'package:intl/intl.dart';

class WorkOutBottomScreen extends StatelessWidget {
  WorkOutBottomScreen({super.key, required this.planId});
  final String planId;

  HomeController homeController = Get.find();

  WorkOutController workOutController = Get.find();
  bool showBottomSheet = false;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: HelpingWidgets().appBarWidget(null, text: "Workout Schedule"),
        body: Obx(
          () => !workOutController.workOutPlanDetailsLoad.value
              ? CircularProgress()
              : RefreshIndicator(
                  onRefresh: () {
                    workOutController.getDietPlanDetailsFunc(planId);
                    return Future.value();
                  },
                  child: ListView(
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
                              foregroundColor:
                                  Colors.green, // Button text color
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
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        itemBuilder: (BuildContext context, int timeIndex) {
                          var time = workOutController
                              .getUserWorkoutPlanDetailsPlan!
                              .trainerSlots[timeIndex];
                          return ExpansionTile(
                            iconColor: Colors.black,
                            initiallyExpanded:
                                DateFormat('EEEE').format(DateTime.now()) ==
                                    time.day,
                            collapsedIconColor: Colors.black,
                            title: Text(
                              time.day,
                              style: textTheme.headlineSmall,
                            ),
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 10),
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Text(
                                                  slot.description ?? "",
                                                  style: textTheme.bodySmall,
                                                  maxLines: 4,
                                                ),
                                              ),
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
                                                    slot.level ??
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
                                                    'with ${slot.trainer?.firstName} ${slot.trainer?.lastName}',
                                                    style: textTheme.bodySmall),
                                                visualDensity:
                                                    VisualDensity(vertical: -4),
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  print(
                                                      'WorkOutBottomScreen.build ${slot.toJson()}');
                                                  try {
                                                    if (homeController
                                                            .userHomeData
                                                            ?.userData
                                                            .freeze
                                                            .value ==
                                                        true) {
                                                      return showError(
                                                          "Your account is frozen, please unfreeze first.");
                                                    }

                                                    if (homeController
                                                            .userHomeData!
                                                            .userAllPlans
                                                            .first
                                                            .remainingDays <=
                                                        0) {
                                                      return showError(
                                                          "Please renew your plan.");
                                                    }
                                                    print(
                                                        'WorkOutBottomScreen.build ${slot.trainerLink!}');

                                                    // if (isValidUrl(
                                                    //     slot.trainerLink!)) {
                                                    //   await launchUrl(Uri.parse(
                                                    //       slot.trainerLink!));
                                                    // } else {
                                                    if (!isSessionValid(slot)) {
                                                      return; // Check session validity
                                                    }
                                                    if (slot.trainerLink ==
                                                            null ||
                                                        slot.trainerLink!
                                                            .isEmpty) {
                                                      return showError(
                                                          "Trainer has not added a link yet.");
                                                    }

                                                    await launchUrl(Uri.parse(
                                                        slot.trainerLink!));
                                                    // await requestPermissions();
                                                    //
                                                    // Get.back(); // Close modal
                                                    // var isReview =
                                                    //     await navigateToCallScreen(
                                                    //         slot);
                                                    // if (isReview != null) {
                                                    //   showFeedbackBottomSheet(
                                                    //       context, slot);
                                                    // }
                                                    //    }
                                                  } catch (e) {
                                                    print("Error: $e");
                                                    showError(
                                                        "Trainer has not added a link yet.");
                                                  }
                                                },
                                                icon: const Icon(
                                                    Icons.video_call),
                                                label:
                                                    const Text('Join Session'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                      height: 90.h,
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
                                                slot.type ?? "N/A",
                                                style: textTheme.bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
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
                                                    backgroundColor:
                                                        MyColors.buttonColor,

                                                    backgroundImage: AssetImage(
                                                        MyImgs
                                                            .logo), // Replace with your image asset
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${slot.trainer?.firstName} ${slot.trainer?.lastName}",
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
                            .getUserWorkoutPlanDetailsPlan!.trainerSlots.length,
                      )
                    ],
                  ),
                ),
        ));
  }

  bool isSessionValid(Slot slot) {
    if (!workOutController.checkTiming(slot.start, slot.end)) {
      showError("The class has not started yet or has already passed.");
      return false;
    }
    return true;
  }

  void showError(String message) {
    CustomToast.failToast(msg: message);
  }

  Future<void> requestPermissions() async {
    await handleCameraAndMic(Permission.camera);
    await handleCameraAndMic(Permission.microphone);
  }

  Future<bool?> navigateToCallScreen(Slot slot) async {
    return await Get.to(() => CallScreen(
          plan: workOutController.getUserWorkoutPlanDetailsPlan?.plan,
          channelName: slot.trainerLink ?? "",
          token: slot.token ?? "",
          userId: Get.find<AuthController>().logInUser?.id.toString() ?? "",
          title: slot.level ?? 'High Intensity Workout Session',
          trainerUID: slot.trainer?.id,
        ));
  }

  void showFeedbackBottomSheet(BuildContext context, Slot slot) {
    final planId = workOutController.getUserWorkoutPlanDetailsPlan?.plan?.id;
    final trainerId = slot.trainer?.id;

    if (planId == null || trainerId == null) {
      showError("Missing plan or trainer data.");
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.bottomSheet(
          isScrollControlled: true,
          FeedbackBottomSheet(planId.toString(), trainerId.toString()));

      // showModalBottomSheet(
      //   context: context,
      //   //  isScrollControlled: true,
      //   builder: (context) =>
      //       FeedbackBottomSheet(planId.toString(), trainerId.toString()),
      // );
    });
  }
}
