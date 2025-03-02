import 'package:fitness_zone_2/UI/diet_screen/client_details_screen.dart';
import 'package:fitness_zone_2/UI/diet_screen/clients_screen.dart';
import 'package:fitness_zone_2/UI/diet_screen/slots_screen.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/review_bottom_sheet.dart';
import 'package:flutter/material.dart';

import '../UI/dashboard_module/profile_screen/profile_screen_user.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import 'app_bar_widget.dart';
import 'package:get/get.dart';

class DietitianProfileScreen extends StatelessWidget {
  AuthController authController = Get.find();
  DietController dietController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: MyColors.primaryGradient2,
      appBar: HelpingWidgets().appBarWidget(
        null,
        backGroundColor: MyColors.buttonColor,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25)),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 80),
                        Text(
                          "${authController.logInUser!.firstName} ${authController.logInUser!.lastName}",
                          style: textTheme.bodySmall!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          authController.logInUser!.email,
                          style: textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withOpacity(0.4)),
                        ),
                        const SizedBox(height: 15),
                        // Clients and Slots Buttons
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {

                                  dietController.clientsOfDietFunc();
                                  Get.to(() => ClientsScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.buttonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.group, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text('Clients'),
                                  ],
                                ),
                              ),
                              SizedBox(width: 25),
                              ElevatedButton(
                                onPressed: () {
                                  dietController.getDietTimes();
                                  Get.to(() => SlotsScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.buttonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_calendar_outlined,
                                        color: Colors.white),
                                    SizedBox(width: 5),
                                    Text('Slots'),
                                  ],
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 10,
                        ),

                        Obx(() => dietController.appointmentLoad.value
                            ? Expanded(
                                child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    itemBuilder: (context, index) {
                                      var appointMent = dietController
                                          .dietAppointmentsModel!
                                          .appointments[index];

                                      return AppointmentCard(
                                          onTap: () {
                                            if (appointMent.clientUser !=
                                                null) {
                                              Get.to(() => ClientDetailsScreen(
                                                  clientUser:
                                                      appointMent.clientUser!,
                                                  slotDiet:
                                                      appointMent.slotDiet,
                                                  planId: null));
                                            }
                                          },
                                          name:
                                              "${appointMent.clientUser?.firstName} ${appointMent.clientUser?.lastName}",
                                          time:
                                              '${appointMent.slotDiet?.start} - ${appointMent.slotDiet?.end}');
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(
                                        height: 15,
                                      );
                                    },
                                    itemCount: dietController
                                        .dietAppointmentsModel!
                                        .appointments
                                        .length))
                            : CircularProgress())
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              // left: MediaQuery.of(context).size.width/2.7,
              child: CircleAvatar(
                radius: 60,

                backgroundImage: AssetImage(
                    MyImgs.userProfileIcon), // Replace with your image asset
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ProfileScreenUser());
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String name;
  final String? time;
  final Function()? onTap;

  const AppointmentCard({required this.name, this.time, this.onTap});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        visualDensity: const VisualDensity(horizontal: -4, vertical: -3),
        title: Text(name,
            style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
        subtitle: time == null
            ? null
            : Text(
                time!,
                style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.4)),
              ),
        trailing: Icon(Icons.arrow_right, size: 25),
      ),
    );
  }
}
