import 'package:fitness_zone_2/data/models/day_slots_of_diet.dart';
import 'package:fitness_zone_2/data/models/dietitian_times.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/controllers/diet_contoller/diet_controller.dart';
import '../../values/my_colors.dart';
import '../../widgets/circular_progress.dart';
import '../../widgets/dietitian_home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Backend (`addOrUpdateDaySlot` in dietController.js) strictly
// validates each slot's start/end against
// `^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$` — e.g. "9:00 AM". Using
// `TimeOfDay.format(context)` directly is locale-dependent: on a
// device with 24-hour system time format (common default on some
// Android phones), it returns "09:00" with NO am/pm suffix at all,
// which fails that regex for every slot, not just unedited ones.
// Formatting manually via intl's DateFormat sidesteps the device's
// clock-format setting entirely so the string sent to the backend is
// always well-formed.
String _formatSlotTime(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('h:mm a').format(dt);
}

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
                    // Must already match the backend's strict
                    // "h:mm AM/PM" validation — see _formatSlotTime.
                    start: "9:00 AM",
                    end: "7:00 PM",
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

                            // Keyed so Flutter preserves the link
                            // field's editing state across rebuilds
                            // (time-picker taps, add/remove) instead
                            // of resetting it each time.
                            return Column(
                              key: ValueKey(slot.id ?? 'new_$index'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
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
                                        slot.start = _formatSlotTime(time);
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
                                        slot.end = _formatSlotTime(time);
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
                                ]),
                                const SizedBox(height: 10),
                                TextFormField(
                                  initialValue:
                                      (slot.dietitionLink as String?) ?? '',
                                  onChanged: (v) => slot.dietitionLink = v,
                                  style: TextStyle(fontSize: 13.sp),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    prefixIcon: const Icon(
                                        Icons.videocam_outlined,
                                        size: 18),
                                    hintText:
                                        'Google Meet link for this slot',
                                    hintStyle: TextStyle(fontSize: 12.sp),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            );
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
