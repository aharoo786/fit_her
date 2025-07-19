import 'package:fitness_zone_2/UI/diet_screen/dietry_module/rescheduleRequestScreen.dart';
import 'package:fitness_zone_2/UI/diet_screen/dietry_module/widgets/statusTile.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../../../widgets/circular_progress.dart';

class DietaryCheckScreen extends StatefulWidget {
  const DietaryCheckScreen({super.key});

  @override
  State<DietaryCheckScreen> createState() => _DietaryCheckScreenState();
}

class _DietaryCheckScreenState extends State<DietaryCheckScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DietController dietController = Get.find();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    dietController.getDietPlanScheduleStatus();
    dietController.getConsultationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(
        () {
          Get.back();
        },
        actionWidget: GestureDetector(
          onTap: () {
            Get.to(() => RescheduleRequestScreen());
            dietController.getRescheduleAppointments(reschedule: true);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SvgPicture.asset(MyImgs.rescheduleIcon),
          ),
        ),
        text: "Dietary Check",
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: MyColors.buttonColor,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black,
          unselectedLabelStyle:
              textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          labelStyle:
              textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Consultations'),
            Tab(text: 'Diet Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Obx(() {
            if (!dietController.consultationStatusLoad.value) {
              return const CircularProgress();
            }
            if (dietController.consultationStatus.isEmpty) {
              return const Center(
                child: Text("Nothing to show"),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dietController.consultationStatus.length,
              itemBuilder: (context, index) {
                var item = dietController.consultationStatus[index];

                return StatusTile(
                  name: item.clientUser?.fullName ?? "",
                  status: item.status ?? "",
                  time: item.slotDiet?.time ?? "",
                );
              },
            );
          }),
          Obx(() {
            if (!dietController.dietPlanStatusLoad.value) {
              return CircularProgress();
            }
            if (dietController.pdfDietStatus.isEmpty) {
              return Center(
                child: Text("Nothing to show"),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dietController.pdfDietStatus.length,
              itemBuilder: (context, index) {
                var item = dietController.pdfDietStatus[index];
                return StatusTile(
                  name: item.user?.fullName ?? "",
                  status: item.dietStatus ?? "",
                  time: "",
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
