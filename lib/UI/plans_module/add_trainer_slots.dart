import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_users/get_all_users_based_on_type.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/add_package/add_package_model.dart';
import '../../values/my_colors.dart';

class AddTrainerSlots extends StatelessWidget {
  AddTrainerSlots({super.key});
  WorkOutController workOutController = Get.find();
  HomeController home = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Add Trainer Slots"),
      body: ListView(
        children: [
          GetBuilder<WorkOutController>(builder: (homeController) {
            return homeController.getAllTimesSlotsLoad.value
                ? ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      var dayTime = homeController.addPackageTimeTable[index];
                      return ExpansionTile(
                        onExpansionChanged: (bool value) {
                          if (value) {}
                        },
                        trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          dayTime.day,
                          style: textTheme.bodyLarge,
                        ),
                        children: [
                          ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, int timeIndex) {
                                var slot = dayTime.slots[timeIndex];
                                print("${slot.toJson()}");
                                return Container(
                                  height: 130,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                child: GestureDetector(
                                                    onTap: () async {
                                                      TimeOfDay? time =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                        builder: (BuildContext
                                                                context,
                                                            Widget? child) {
                                                          return Theme(
                                                            data: ThemeData
                                                                    .light()
                                                                .copyWith(
                                                              primaryColor: Colors
                                                                  .blue, // Change the primary color
                                                              dialogBackgroundColor:
                                                                  Colors
                                                                      .white, // Change the dialog background color
                                                              textTheme:
                                                                  const TextTheme(
                                                                bodyLarge: TextStyle(
                                                                    color: Colors
                                                                        .black), // Change the text color
                                                              ),
                                                            ),
                                                            child: child!,
                                                          );
                                                        },
                                                      );
                                                      if (time != null) {
                                                        slot.start = time
                                                            .format(context);
                                                        homeController.update();
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 56.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.w),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black)),
                                                      child: Text(
                                                        slot.start,
                                                        style: slot.start ==
                                                                "Start Time"
                                                            ? TextStyle(
                                                                color: MyColors
                                                                    .hintText,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.sp)
                                                            : TextStyle(
                                                                color: MyColors
                                                                    .textColor,
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    )),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Expanded(
                                                child: GestureDetector(
                                                    onTap: () async {
                                                      TimeOfDay? time =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                        builder: (BuildContext
                                                                context,
                                                            Widget? child) {
                                                          return Theme(
                                                            data: ThemeData
                                                                    .light()
                                                                .copyWith(
                                                              primaryColor: Colors
                                                                  .blue, // Change the primary color
                                                              dialogBackgroundColor:
                                                                  Colors
                                                                      .white, // Change the dialog background color
                                                              textTheme:
                                                                  const TextTheme(
                                                                bodyLarge: TextStyle(
                                                                    color: Colors
                                                                        .black), // Change the text color
                                                              ),
                                                            ),
                                                            child: child!,
                                                          );
                                                        },
                                                      );
                                                      if (time != null) {
                                                        slot.end = time
                                                            .format(context);
                                                        homeController.update();
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 56.h,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.w),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black)),
                                                      child: Text(
                                                        slot.end,
                                                        style: slot.end ==
                                                                "End Time"
                                                            ? TextStyle(
                                                                color: MyColors
                                                                    .hintText,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.sp)
                                                            : TextStyle(
                                                                color: MyColors
                                                                    .textColor,
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    )),
                                              ),
                                              //               Obx(() => homeController.getSubCatLoaded.value
                                            ]),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Obx(() => home
                                                    .getUsersBasedOnUserTypeLoad
                                                    .value
                                                ? Flexible(
                                                    child: Container(
                                                      // width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        color: MyColors
                                                            .textFieldColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child:
                                                          DropdownButtonFormField<
                                                              UserTypeData>(
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .textColor,
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          16.w,
                                                                      vertical:
                                                                          12.h),
                                                          border:
                                                              InputBorder.none,
                                                        ),

                                                        //padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        value: slot.trainerId ==
                                                                null
                                                            ? home
                                                                .getUsersBasedOnUserTypeModel
                                                                ?.users[0]
                                                            : home
                                                                .getUsersBasedOnUserTypeModel
                                                                ?.users
                                                                .firstWhere((value) =>
                                                                    value.id
                                                                        ==
                                                                    (slot.trainerId )),
                                                        onChanged:
                                                            (UserTypeData?
                                                                newValue) {
                                                          if (newValue !=
                                                              null) {
                                                            slot.trainerId =
                                                                newValue.id == 0
                                                                    ? null
                                                                    : newValue
                                                                        .id;
                                                          }
                                                        },
                                                        items: home
                                                            .getUsersBasedOnUserTypeModel!
                                                            .users
                                                            .map((UserTypeData
                                                                cat) {
                                                          return DropdownMenuItem<
                                                              UserTypeData>(
                                                            value: cat,
                                                            child: SizedBox(
                                                              //  width: 60.w,
                                                              child: Text(
                                                                ("${cat.firstName} ${cat.lastName}")
                                                                    .toString(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  )
                                                : CircularProgress()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      timeIndex == dayTime.slots.length - 1
                                          ? GestureDetector(
                                              onTap: () {
                                                dayTime.slots.add(Slot(
                                                    trainerId: null,
                                                    id: null,
                                                    dayId: dayTime.id,
                                                    start: "Start Time",
                                                    end: "End Time"));
                                                homeController.update();
                                              },
                                              child: Container(
                                                height: 40.h,
                                                width: 40.h,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: MyColors
                                                            .buttonColor,
                                                        width: 2)),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: MyColors.buttonColor,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                dayTime.slots
                                                    .removeAt(timeIndex);
                                                homeController.update();
                                              },
                                              child: Container(
                                                height: 40.h,
                                                width: 40.h,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: MyColors
                                                            .buttonColor,
                                                        width: 2)),
                                                child: const Icon(
                                                  Icons.remove,
                                                  color: MyColors.buttonColor,
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
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
                    itemCount: homeController.addPackageTimeTable.length)
                : CircularProgress();
          }),
        ],
      ),
      bottomNavigationBar: HelpingWidgets().bottomBarButtonWidget(onTap: () {
        workOutController.addTrainerSlots();
      }),
    );
  }
}
