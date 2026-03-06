import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/controllers/zoom_controller.dart';
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
import 'package:fitness_zone_2/data/controllers/motivation_controller/motivation_controller.dart';

class WorkOutBottomScreen extends StatelessWidget {
  WorkOutBottomScreen({super.key, required this.planId});
  final String planId;

  HomeController homeController = Get.find();

  WorkOutController workOutController = Get.find();
  MotivationController motivationController = Get.find();
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
              ? const CircularProgress()
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
                          style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Builder(builder: (context) {
                        if (motivationController.motivationStats.value == null && !motivationController.isLoadingStats.value) {
                          motivationController.fetchMotivationStats();
                        }

                        DateTime today = DateTime.now();
                        DateTime firstDate = today.subtract(const Duration(days: 29));
                        DateTime lastDate = today;

                        // Pick most recent attended date, fallback to today
                        DateTime initialDate = today;
                        final stats = motivationController.motivationStats.value;
                        if (stats != null) {
                          final attendedDates = stats.attendanceHistory
                              .where((e) => e.attended == 1)
                              .map((e) => DateTime.tryParse(e.date))
                              .whereType<DateTime>()
                              .toList()
                            ..sort((a, b) => a.compareTo(b));
                          if (attendedDates.isNotEmpty) {
                            initialDate = attendedDates.last;
                          }
                        }

                        return Obx(() {
                          if (motivationController.isLoadingStats.value) {
                            // Show shimmer loading
                            return Column(
                              children: [
                                Container(
                                  height: 20,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 7,
                                  children: List.generate(
                                      42,
                                      (index) => Container(
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                          )),
                                ),
                              ],
                            );
                          }

                          final s = motivationController.motivationStats.value;
                          if (s == null) {
                            return const SizedBox.shrink();
                          }

                          // Build current month grid
                          final DateTime now = DateTime.now();
                          final DateTime firstOfMonth = DateTime(now.year, now.month, 1);
                          final int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
                          final DateTime lastOfMonth = DateTime(now.year, now.month, daysInMonth);

                          // Align grid start to the beginning of the week (Sunday=0)
                          final int startOffset = firstOfMonth.weekday % 7;
                          final DateTime gridStart = firstOfMonth.subtract(Duration(days: startOffset));

                          final Set<String> attendedSet = s.attendanceHistory.where((e) => e.attended == 1).map((e) => e.date).toSet();

                          List<Widget> buildGrid() {
                            final List<Widget> cells = [];
                            for (int i = 0; i < 42; i++) {
                              final DateTime date = gridStart.add(Duration(days: i));
                              final bool isCurrentMonth = date.month == now.month && date.year == now.year;
                              if (!isCurrentMonth) {
                                cells.add(const SizedBox.shrink());
                                continue;
                              }

                              final String dateStr = DateFormat('yyyy-MM-dd').format(date);
                              final bool isAttended = attendedSet.contains(dateStr);
                              cells.add(Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isAttended ? MyColors.buttonColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${date.day}',
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: isAttended ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ));
                            }
                            return cells;
                          }

                          final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(now),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: daysOfWeek
                                    .map((d) => SizedBox(
                                          width: 36,
                                          child: Center(
                                            child: Text(
                                              d,
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 6),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 7,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 2,
                                children: buildGrid(),
                              ),
                            ],
                          );
                        });
                      }),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        itemBuilder: (BuildContext context, int timeIndex) {
                          var time = workOutController.getUserWorkoutPlanDetailsPlan!.trainerSlots[timeIndex];
                          return ExpansionTile(
                            iconColor: Colors.black,
                            initiallyExpanded: DateFormat('EEEE').format(DateTime.now()) == time.day,
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
                                itemCount: time.slots.length, // Number of stars (you can make this dynamic)
                                itemBuilder: (context, index) {
                                  var slot = time.slots[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      HelpingWidgets.showWorkoutBottomSheet(context: context, slot: slot, homeController: homeController);
                                    },
                                    child: Container(
                                      height: 90,
                                      width: double.maxFinite,
                                      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
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
                                          Text(
                                            slot.status ?? "",
                                            style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
                                          ),
                                          // SvgPicture.asset(MyImgs.progressbar)
                                        ],
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
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 10.h,
                          );
                        },
                        itemCount: workOutController.getUserWorkoutPlanDetailsPlan!.trainerSlots.length,
                      )
                    ],
                  ),
                ),
        ));
  }
}
