import 'package:fitness_zone_2/UI/dashboard_module/paste_link/paste_link.dart';
import 'package:fitness_zone_2/UI/workout_module/class_details.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../UI/dashboard_module/session_screen/session_screen.dart';
import '../data/controllers/home_controller/home_controller.dart';
import '../data/models/add_package/add_package_model.dart';
import '../values/my_imgs.dart';

class TrainerHomeScreen extends StatefulWidget {
  TrainerHomeScreen({Key? key}) : super(key: key);
  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  WorkOutController workOutController = Get.find();

  final List days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  @override
  initState() {
    workOutController.getTrainerHomeFunc();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("i am here to update");
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(
              height: 50.h,
            ),
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: 42.h, bottom: 42.h, right: 15.w, left: 130.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xffFAD8CD)),
                  child: Text(
                    "Make Your Body\nHealthy & Fit With Us",
                    style: textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Image.asset(
                  MyImgs.girl,
                  scale: 3,
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Obx(() => workOutController.trainerHomeLoad.value
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int planIndex) {
                      var day = workOutController
                          .getTrainerHome!.trainerSlots[planIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.day,
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, int timeIndex) {
                                var slot = day.slots[timeIndex];
                                return Row(children: [
                                  Container(
                                    height: 56.h,
                                    width: 120.w,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.w),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
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
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Container(
                                    height: 56.h,
                                    width: 120.w,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.w),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
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
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Get.to(() => SessionScreen(
                                              slotId: slot.id,
                                              isDiet: false,
                                              planId: workOutController
                                                  .getTrainerHome?.plan?.id
                                                  .toString(),
                                              userId: 0,
                                              link: slot.trainerLink,
                                            )),
                                        // Get.to(() => PasteLink(
                                        //       slotId: slot.id,
                                        //     )),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 100.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: MyColors.buttonColor),
                                          child: Text(
                                            "Paste Link",
                                            style: textTheme.titleLarge,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      GestureDetector(
                                        onTap: () => Get.to(() =>
                                            ClassDetails(slotId: slot.id)),
                                        // Get.to(() => PasteLink(
                                        //       slotId: slot.id,
                                        //     )),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 100.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: MyColors.buttonColor),
                                          child: Text(
                                            "Class Details",
                                            style: textTheme.titleLarge,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]);
                              },
                              separatorBuilder: (context, int index) {
                                return SizedBox(
                                  height: 10.h,
                                );
                              },
                              itemCount: day.slots.length)
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 10.h,
                      );
                    },
                    itemCount:
                        workOutController.getTrainerHome!.trainerSlots.length,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  )),
            const SizedBox(
              height: 20,
            )

            // Expanded(
            //   child: ListView.builder(
            //
            //       itemBuilder: (BuildContext context, int index) => ListTile(
            //         visualDensity: const VisualDensity(vertical: 0),
            //             title: Text(
            //               days[index],
            //               style: textTheme.headlineSmall,
            //             ),
            //         trailing:  GestureDetector(
            //           onTap: ()=>Get.to(()=>PasteLink()),
            //           child: Container(
            //             alignment: Alignment.center,
            //             width: 100.w,
            //             height: 30.h,
            //
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(10),
            //               color: MyColors.buttonColor
            //             ),
            //             child: Text("Paste Link",style: textTheme.bodySmall,),
            //           ),
            //         ),
            //           ),
            //
            //
            //       itemCount: 6),
            // )
          ],
        ),
      ),
    );
  }
}
