import 'package:fitness_zone_2/UI/diet_screen/dietry_module/widgets/rescheduleCard.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class RescheduleRequestScreen extends StatelessWidget {
  RescheduleRequestScreen({super.key});

  DietController dietController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Reschedule Request"),
      body: Obx(() {
        if (!dietController.appointmentLoad.value) {
          return const CircularProgress();
        }
        if (dietController.rescheduleAppointments.isEmpty) {
          return const Center(
            child: Text("Nothing to show"),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dietController.rescheduleAppointments.length,
          itemBuilder: (context, index) {
            var item = dietController.rescheduleAppointments[index];
            return RescheduleCard(
              name: item.clientUser?.fullName ?? "",
              subtitle: "1st Request",
              message: item.message,
              imageUrl: "https://i.pravatar.cc/150?img=3",
              firstOnTap: () {
                dietController.updateAppointmentStatus(item.id, "canceled");
              },
              secondOnTap: () {
                dietController.updateAppointmentStatus(item.id, "confirmed");
              },
            );
          },
        );
      }),
    );
  }
}
