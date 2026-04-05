import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_completion_screen.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrialJourneyScreen extends StatefulWidget {
  const TrialJourneyScreen({super.key});

  @override
  State<TrialJourneyScreen> createState() => _TrialJourneyScreenState();
}

class _TrialJourneyScreenState extends State<TrialJourneyScreen> {
  final HomeController homeController = Get.find();
  final WorkOutController workOutController = Get.find();

  int? selectedSlotId;

  @override
  void initState() {
    super.initState();
    _loadJourney();
    workOutController.getDietPlanDetailsFunc("0", showSlots: true);
  }

  Future<void> _loadJourney() async {
    await homeController.getMyTrialJourney();
    if (homeController.trialJourney == null) {
      await homeController.startTrial();
      await homeController.getMyTrialJourney();
    }
  }

  int? get nextBookableDay => homeController.trialJourney?["nextBookableDay"] as int?;

  int? get pendingAttendanceDay {
    for (int day = 1; day <= 3; day++) {
      final bookedAt = homeController.trialJourney?["day${day}BookedAt"];
      final attendedAt = homeController.trialJourney?["day${day}AttendedAt"];
      if (bookedAt != null && attendedAt == null) {
        return day;
      }
    }
    return null;
  }

  List<Slot> get allSlots {
    final details = workOutController.getUserWorkoutPlanDetailsPlan;
    if (details == null) {
      return [];
    }

    return details.trainerSlots.expand((daySlot) => daySlot.slots).toList();
  }

  Future<void> onBookDay() async {
    if (nextBookableDay == null) {
      CustomToast.failToast(msg: "No day is available for booking right now");
      return;
    }
    if (selectedSlotId == null) {
      CustomToast.failToast(msg: "Please select one slot first");
      return;
    }

    await homeController.bookTrialDay(day: nextBookableDay!, slotId: selectedSlotId!);
    await homeController.getMyTrialJourney();
    setState(() {
      selectedSlotId = null;
    });
  }

  Future<void> onMarkAttendance() async {
    final day = pendingAttendanceDay;
    if (day == null) {
      CustomToast.failToast(msg: "No pending attendance found");
      return;
    }

    await homeController.markTrialAttendance(day: day, attendedMinutes: 30);
    await homeController.getMyTrialJourney();
  }

  Widget buildDayCard(int day) {
    final bookedAt = homeController.trialJourney?["day${day}BookedAt"];
    final attendedAt = homeController.trialJourney?["day${day}AttendedAt"];

    String status = "Not booked";
    Color color = Colors.grey;

    if (bookedAt != null) {
      status = "Booked";
      color = Colors.orange;
    }
    if (attendedAt != null) {
      status = "Attended";
      color = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Day $day", style: Theme.of(context).textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "3-Day Trial"),
      body: Obx(() {
        if (!workOutController.workOutPlanDetailsLoad.value || !homeController.trialLoad.value) {
          return const CircularProgress();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadJourney();
            workOutController.getDietPlanDetailsFunc("0", showSlots: true);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Your Transformation Journey",
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                "Book one class per day, attend it, and unlock the next day.",
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              buildDayCard(1),
              buildDayCard(2),
              buildDayCard(3),
              const SizedBox(height: 12),
              if (nextBookableDay != null) ...[
                Text(
                  "Book Day $nextBookableDay",
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...allSlots.map((slot) {
                  final selected = selectedSlotId == slot.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSlotId = slot.id;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? MyColors.buttonColor : Colors.white,
                        border: Border.all(color: selected ? MyColors.buttonColor : Colors.black26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.type ?? "Workout Slot",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: selected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${slot.start} - ${slot.end}",
                                style: textTheme.bodySmall?.copyWith(
                                  color: selected ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              if (slot.trainer != null)
                                Text(
                                  "${slot.trainer?.firstName ?? ""} ${slot.trainer?.lastName ?? ""}",
                                  style: textTheme.bodySmall?.copyWith(
                                    color: selected ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                          if (selected) const Icon(Icons.check_circle, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                }),
                CustomButton(
                  text: "Book Day $nextBookableDay",
                  onPressed: onBookDay,
                ),
                const SizedBox(height: 16),
              ],
              if (pendingAttendanceDay != null)
                CustomButton(
                  text: "Mark Day $pendingAttendanceDay Attendance",
                  onPressed: onMarkAttendance,
                ),
              if (homeController.trialJourney != null && pendingAttendanceDay == null && nextBookableDay == null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    "Great job! Your 3-day trial is complete.",
                    style: textTheme.bodyMedium?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "Continue to Review & Subscription",
                  onPressed: () {
                    Get.to(() => const TrialCompletionScreen());
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
