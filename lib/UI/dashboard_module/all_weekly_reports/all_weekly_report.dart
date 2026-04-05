import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/material.dart';

import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllWeeklyReport extends StatelessWidget {
  AllWeeklyReport({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "All Weekly Reports"),
      body: Column(
        children: [
          Expanded(
              child: Obx(
            () => homeController.weeklyReportLoad.value
                ? ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (BuildContext context, int index) {
                      var measure =
                          homeController.getWeeklyReportsModel!.reports[index];

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int reportIndex) {
                          var report = measure.reports[reportIndex];

                          return Container(
                            padding: EdgeInsets.all(20.h),
                            decoration: BoxDecoration(
                                color: MyColors.appBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.6))),
                            child: Column(children: [
                              reportRow(
                                  "Name",
                                  "${measure.firstName} ${measure.lastName}",
                                  context),
                              reportRow(
                                  "Starting Date", report.istDayDate, context),
                              reportRow(
                                  "End Date", report.currentDate, context),
                              reportRow(
                                  "1st Day Weight", report.weight, context),
                              reportRow("Current Day Weight",
                                  report.currentWeight, context),
                              reportRow("Waist", report.weist, context),
                              reportRow("Shoulder", report.shoulder, context),
                              reportRow("Arms", report.arms, context),
                              reportRow("Chest", report.chest, context),
                              reportRow("Abdomen", report.abdoman, context),
                              reportRow("Hips", report.hips, context),
                              reportRow("Thighs", report.thighs, context),
                            ]),
                          );
                        },
                        itemCount: measure.reports.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 20.h,
                          );
                        },
                      );
                    },
                    itemCount:
                        homeController.getWeeklyReportsModel!.reports.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 20.h,
                      );
                    },
                  )
                : CircularProgress(),
          ))
        ],
      ),
    );
  }

  Widget reportRow(String text1, String text2, context) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text1,
              style: textTheme.bodyMedium!.copyWith(
                  color: MyColors.textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              text2,
              style: textTheme.bodySmall!.copyWith(
                  color: MyColors.textColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        )
      ],
    );
  }
}
