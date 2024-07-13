import 'package:fitness_zone_2/UI/dashboard_module/paste_link/paste_link.dart';
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

class TrainerHomeScreen extends StatelessWidget {
  TrainerHomeScreen({Key? key}) : super(key: key);

  final List days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  Widget build(BuildContext context) {
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
            GetBuilder<HomeController>(builder: (homeController) {
              return homeController.trainerHomeLoad.value
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int planIndex) {
                      var plan=  homeController
                            .getTrainerHome!.plans[planIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeController
                                  .getTrainerHome!.plans[planIndex].title,
                              style: textTheme.headlineSmall,
                            ),
                            ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, int index) {
                                  var dayTime = homeController.getTrainerHome!
                                      .plans[planIndex].times[index];
                                  return ExpansionTile(
                                    onExpansionChanged: (bool value) {
                                      if (value) {}
                                    },
                                    trailing: const Icon(
                                        Icons.keyboard_arrow_down_rounded),
                                    tilePadding: EdgeInsets.zero,
                                    title: Text(
                                      dayTime.day,
                                      style: textTheme.bodyLarge,
                                    ),
                                    children: [
                                      ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder:
                                              (context, int timeIndex) {
                                            var slot = dayTime.slots[timeIndex];
                                            return Row(children: [
                                              Container(
                                                height: 56.h,
                                                width: 120.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w),
                                                alignment: Alignment.centerLeft,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                child: Text(
                                                  slot.start,
                                                  style: TextStyle(
                                                      color: MyColors.textColor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Container(
                                                height: 56.h,
                                                width: 120.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w),
                                                alignment: Alignment.centerLeft,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                child: Text(
                                                  slot.end,
                                                  style: TextStyle(
                                                      color: MyColors.textColor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    Get.to(() => SessionScreen(
                                                          slotId: slot.id, userId: 0,
                                                        )),
                                                // Get.to(() => PasteLink(
                                                //       slotId: slot.id,
                                                //     )),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 100.w,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          MyColors.buttonColor),
                                                  child: Text(
                                                    "Paste Link",
                                                    style: textTheme.bodySmall,
                                                  ),
                                                ),
                                              ),
                                            ]);
                                          },
                                          separatorBuilder:
                                              (context, int index) {
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
                                itemCount: homeController.getTrainerHome!
                                    .plans[planIndex].times.length),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 10.h,
                        );
                      },
                      itemCount: homeController.getTrainerHome!.plans.length,
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
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
