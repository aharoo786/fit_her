import 'package:fitness_zone_2/data/models/day_slots_of_diet.dart';
import 'package:fitness_zone_2/data/models/dietitian_times.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/diet_contoller/diet_controller.dart';
import '../../values/my_colors.dart';
import '../../widgets/circular_progress.dart';
import '../../widgets/dietitian_home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaySlotsScreen extends StatelessWidget {
  DaySlotsScreen({super.key, required this.day});
  DietTime day;
  DietController dietController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      },
          text: day.day,
          actionWidget: IconButton(
              onPressed: () {
                dietController.daySlotsOfDietModel!.slots.add(Slot(
                    id: null,
                    start: "9 am",
                    end: "7 pm",
                    dietitionLink: "",
                    isAvailble: null,
                    dietitionId: 0,
                    timeDietitionId: day.id));
                dietController.update();
              },
              icon: Icon(Icons.add))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GetBuilder<DietController>(builder: (cont) {
          return Column(
            children: [
              Text(
                "Set your available time slots on ${day.day}",
                style: textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.8,
                    color: Colors.black.withOpacity(0.3)),
              ),
              Obx(() => dietController.slotsLoad.value
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemBuilder: (context, index) {
                            var slot = dietController
                                .daySlotsOfDietModel!.slots[index];

                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              primaryColor: Colors
                                                  .blue, // Change the primary color
                                              dialogBackgroundColor: Colors
                                                  .white, // Change the dialog background color
                                              textTheme: const TextTheme(
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
                                        slot.start = time.format(context);
                                        cont.update();
                                      }
                                    },
                                    child: Container(
                                      height: 35.h,
                                      width: 95.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Text(
                                        slot.start,
                                        style: TextStyle(
                                            color: MyColors.textColor,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Container(
                                    height: 3,
                                    width: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              primaryColor: Colors
                                                  .blue, // Change the primary color
                                              dialogBackgroundColor: Colors
                                                  .white, // Change the dialog background color
                                              textTheme: const TextTheme(
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
                                        slot.end = time.format(context);
                                        cont.update();
                                      }
                                    },
                                    child: Container(
                                      height: 35.h,
                                      width: 95.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Text(
                                        slot.end,
                                        style: TextStyle(
                                            color: MyColors.textColor,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dietController.daySlotsOfDietModel!.slots.removeAt(index);
                                      dietController.update();
                                    },
                                    child: Container(
                                      height: 40.h,
                                      width: 40.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: MyColors.buttonColor,
                                              width: 2)),
                                      child: const Icon(
                                        Icons.remove,
                                        color: MyColors.buttonColor,
                                      ),
                                    ),
                                  )
                                ]);
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 15,
                            );
                          },
                          itemCount:
                              dietController.daySlotsOfDietModel!.slots.length))
                  : CircularProgress())
            ],
          );
        }),
      ),

      bottomNavigationBar: HelpingWidgets().bottomBarButtonWidget(onTap: (){
        dietController.addDaySlots(day.id.toString());
      }),
    );
  }
}
