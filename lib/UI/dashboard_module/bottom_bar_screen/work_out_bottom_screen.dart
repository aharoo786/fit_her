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
import '../../../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../../../helper/custom_print.dart';
import '../../../values/constants.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/review_bottom_sheet.dart';
import '../../../widgets/toasts.dart';
import 'package:permission_handler/permission_handler.dart';
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
        appBar: HelpingWidgets().appBarWidget(() {
          Get.back();
        }, text: "Workout Schedule"),
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
                                      HelpingWidgets.showWorkoutBottomSheet(
                                          context: context,
                                          slot: slot,
                                          homeController: homeController);
                                    },
                                    child: Container(
                                      height: 90,
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
                                          Text(
                                            slot.status ??"",
                                            style: textTheme.bodySmall!
                                                .copyWith(
                                                fontWeight:
                                                FontWeight.w500),
                                          ),
                                          // SvgPicture.asset(MyImgs.progressbar)
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
