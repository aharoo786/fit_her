import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/diet_contoller/diet_controller.dart';
import '../../widgets/circular_progress.dart';

class RequestsScreen extends StatelessWidget {
  RequestsScreen({super.key});
  DietController dietController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Requests"),
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
            final request = dietController.rescheduleAppointments[index];
            return RequestCard(
              name: request.clientUser?.fullName ?? "",
              subtitle: "1st Request",
              time: request.slotDiet?.time ?? "",
              imageUrl: MyImgs.logo, id: request.id,
            );
          },
        );
      }),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String name;
  final int id;
  final String subtitle;
  final String time;
  final String imageUrl;

   RequestCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.time,
    required this.imageUrl, required this.id,
  });
  DietController dietController = Get.find();


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imageUrl),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CustomButton(
                    text: "Cancel",
                    onPressed: () {
                      dietController.updateAppointmentStatus(id,"canceled");
                    },
                    height: 25,
                    width: 70,
                    roundCorner: 20,
                    fontSize: 8,
                    color: Colors.transparent,
                    textColor: MyColors.buttonColor,
                  ),
                  const SizedBox(width: 6),
                  CustomButton(
                    text: "Approve",
                    onPressed: () {
                      dietController.updateAppointmentStatus(id,"confirmed");

                    },
                    height: 25,
                    width: 70,
                    roundCorner: 20,
                    fontSize: 8,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
