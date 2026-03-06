import 'package:fitness_zone_2/UI/diet_screen/day_slots_screen.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/diet_contoller/diet_controller.dart';
import '../../widgets/circular_progress.dart';
import '../../widgets/dietitian_home_screen.dart';

class SlotsScreen extends StatelessWidget {
  SlotsScreen({super.key});
  DietController dietController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(
        () {
          Get.back();
        },
        text: "Slots Available",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              "Set your available time slots to let clients easily book appointments during your free hours.",
              style: textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.8,
                  color: Colors.black.withOpacity(0.3)),
            ),
            Obx(() => dietController.timesLoad.value
                ? Expanded(
                    child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemBuilder: (context, index) {
                          var time = dietController
                              .dietitianTimingModel!.dietTimes[index];

                          return AppointmentCard(name: time.day,onTap: (){
                            dietController.getSlotsOfDay(time.id);
                            Get.to(()=>DaySlotsScreen(day: time));
                          },);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 15,
                          );
                        },
                        itemCount: dietController
                            .dietitianTimingModel!.dietTimes.length))
                : CircularProgress())
          ],
        ),
      ),
    );
  }
}
