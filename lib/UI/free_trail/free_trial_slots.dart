import 'package:fitness_zone_2/UI/free_trail/free_trail_question.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../values/my_imgs.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom_button.dart';

class FreeTrialSlots extends StatelessWidget {
  FreeTrialSlots({super.key});
  WorkOutController workOutController = Get.find();
  bool showBottomSheet = false;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: HelpingWidgets().appBarWidget(null, text: "Workout Slots"),
        body: Obx(
          () => !workOutController.workOutPlanDetailsLoad.value
              ? const CircularProgress()
              : Column(
                  children: [
                    Center(
                      child: Text(
                        "Choose a time that fits your schedule and\nstart your fitness journey with us!",
                        style: textTheme.bodySmall!
                            .copyWith(fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
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
                                itemCount: time.slots.length,
                                // Number of stars (you can make this dynamic)
                                itemBuilder: (context, index) {
                                  var slot = time.slots[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      if (workOutController.freeTrialSlots
                                          .contains(slot.id)) {
                                        workOutController.freeTrialSlots
                                            .removeWhere((v) => v == slot.id);
                                      } else {
                                        if (workOutController
                                                .freeTrialSlots.length <
                                            2) {
                                          workOutController.freeTrialSlots
                                              .add(slot.id);
                                        } else {
                                          CustomToast.failToast(
                                              msg: "You can add up to 2 slots");
                                        }
                                      }
                                    },
                                    child: Obx(
                                      () => Container(
                                        height: 90.h,
                                        width: double.maxFinite,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 13.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: workOutController
                                                  .freeTrialSlots
                                                  .contains(slot.id)
                                              ? MyColors.buttonColor
                                              : Colors.white,
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
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

                                                      backgroundImage:
                                                          AssetImage(MyImgs
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
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                      text: "Continue",
                      onPressed: () {
                        if (workOutController.freeTrialSlots.isEmpty) {
                          CustomToast.failToast(
                              msg: "Please select at least one slot");
                          return;
                        }
                        Get.to(()=>FreeTrialPersonalizationScreen());
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
        ));
  }
}
