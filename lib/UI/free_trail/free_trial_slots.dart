import 'package:fitness_zone_2/UI/free_trail/free_trail_question.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/helper/analytics_helper.dart';
import 'package:fitness_zone_2/values/constants.dart';
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

import '../../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../../widgets/custom_button.dart';

class FreeTrialSlots extends StatefulWidget {
  FreeTrialSlots({super.key});

  @override
  State<FreeTrialSlots> createState() => _FreeTrialSlotsState();
}

class _FreeTrialSlotsState extends State<FreeTrialSlots> {
  WorkOutController workOutController = Get.find();
  bool showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    // Track free trial slots screen view
    AnalyticsHelper.trackScreenView('free_trial_slots_screen');
    AnalyticsHelper.trackFreeTrialEvent('slots_viewed', step: 'slots');
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: HelpingWidgets().appBarWidget((){
          Get.back();
        }, text: "Workout Slots"),
        body: Obx(
          () => !workOutController.workOutPlanDetailsLoad.value
              ? const CircularProgress()
              : Column(
                  children: [
                    Center(
                      child: Text(
                        "Choose a time that fits your schedule and\nstart your fitness journey with us!\n(Select 2 slots)",
                        style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
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
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemBuilder: (BuildContext context, int timeIndex) {
                          var time = workOutController.getUserWorkoutPlanDetailsPlan!.trainerSlots[timeIndex];
                          return Obx(() {
                            return ExpansionTile(
                              key: UniqueKey(),
                              iconColor: Colors.black,
                              initiallyExpanded: expandTile(time).value,
                              collapsedIconColor: Colors.black,
                              title: Text(
                                time.day,
                                style: textTheme.headlineSmall,
                              ),
                              children: [
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10),
                                  itemCount: time.slots.length,
                                  // Number of stars (you can make this dynamic)
                                  itemBuilder: (context, index) {
                                    var slot = time.slots[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        if (workOutController.freeTrialSlots.contains(slot.id.toString())) {
                                          workOutController.freeTrialSlots.remove(slot.id.toString());
                                          return;
                                        }
                                        if (workOutController.freeTrialSlots.length < 2) {
                                          if (workOutController.freeTrialSlots.isEmpty) {
                                            workOutController.freeTrialSlots.add(slot.id.toString());
                                          } else {
                                            bool contain = workOutController.freeTrialSlots.any((v) => time.slots.any((s) => s.id.toString() == v));
                                            if (contain) {
                                              CustomToast.failToast(msg: "You can select one slot from one day");
                                            } else {
                                              workOutController.freeTrialSlots.add(slot.id.toString());
                                            }
                                          }
                                        } else {
                                          CustomToast.failToast(msg: "You can add up to two slots");
                                        }
                                      },
                                      child: Obx(
                                        () => Container(
                                          height: 90,
                                          width: double.maxFinite,
                                          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                workOutController.freeTrialSlots.contains(slot.id.toString()) ? MyColors.buttonColor : Colors.white,
                                            border: Border.all(color: Colors.black),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    slot.type ?? "N/A",
                                                    style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    "${slot.start} - ${slot.end}",
                                                    style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor: MyColors.buttonColor,

                                                        backgroundImage: AssetImage(MyImgs.logo), // Replace with your image asset
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${slot.trainer?.firstName} ${slot.trainer?.lastName}",
                                                            style: textTheme.bodySmall!
                                                                .copyWith(fontWeight: FontWeight.w400, color: const Color(0xff7F7F7F)),
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
                                  separatorBuilder: (BuildContext context, int index) {
                                    return SizedBox(
                                      height: 15.h,
                                    );
                                  },
                                ),
                              ],
                            );
                          });
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 10.h,
                          );
                        },
                        itemCount: workOutController.getUserWorkoutPlanDetailsPlan!.trainerSlots.length,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                      text: "Continue",
                      onPressed: () {
                        if (workOutController.freeTrialSlots.length < 2) {
                          CustomToast.failToast(msg: "Please select at least two slot");
                          return;
                        }
                        Get.to(() => FreeTrialPersonalizationScreen());
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
        ));
  }

  RxBool expandTile(TrainerSlot time) {
    bool contain = workOutController.freeTrialSlots.any((v) => time.slots.any((s) => s.id.toString() == v));
    print('FreeTrialSlots.expandTile $contain');
    if (contain) {
      return RxBool(false);
    } else {
      if (time.day == today || time.day == tomorrow) {
        return RxBool(true);
      } else {
        return RxBool(false);
      }
    }
  }
}
