import 'package:fitness_zone_2/UI/diet_screen/add_user_diet.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/models/diet_appointments.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../../widgets/app_bar_widget.dart';
import '../dashboard_module/session_screen/session_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  ClientDetailsScreen(
      {super.key,
      required this.clientUser,
      this.slotDiet,
      this.planId,
      this.appointmentId});

  final ClientUser clientUser;
  final SlotDiet? slotDiet;
  final int? planId;
  final int? appointmentId;
  final List<_ChartData> chartData = [
    _ChartData('M', 100),
    _ChartData('T', 80),
    _ChartData('W', 50),
    _ChartData('T', 100),
    _ChartData('F', 70),
    _ChartData('S', 100),
    _ChartData('S', 60),
  ];

  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: MyColors.primaryGradient2,
      appBar: HelpingWidgets().appBarWidget(
        () {
          Get.back();
        },
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
                    child: Column(
                      children: [
                        SizedBox(height: 80),
                        Text(
                          "${clientUser.firstName} ${clientUser.lastName}",
                          style: textTheme.bodySmall!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          clientUser.email,
                          style: textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withOpacity(0.4)),
                        ),
                        SizedBox(height: 15),
                        // Clients and Slots Buttons
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (slotDiet != null)
                                Row(
                                  children: [
                                    CustomIconButton(
                                      onTap: () {
                                        Get.to(() => SessionScreen(
                                              link: slotDiet?.dietitionLink,
                                              slotId: slotDiet?.id ?? 0,
                                              isDiet: true,
                                              userId: clientUser.id,
                                              token: "",
                                            ));
                                        Get.find<WorkOutController>()
                                            .getFreeTrialUserDetails(
                                                slotDiet!.id.toString());
                                      },
                                      iconData: Icons.phone,
                                      text: "Appointment",
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    CustomIconButton(
                                      onTap: () {
                                        Get.find<DietController>()
                                            .updateAppointmentStatus(
                                                appointmentId ?? 0, "completed",
                                                isFromAppointment: true);
                                      },
                                      iconData: Icons.done,
                                      text: "Completed",
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    CustomIconButton(
                                      onTap: () {
                                        Get.find<DietController>()
                                            .updateAppointmentStatus(
                                                appointmentId ?? 0, "confirmed",
                                                isFromAppointment: true);
                                      },
                                      iconData: Icons.done,
                                      text: "Confirm",
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    CustomIconButton(
                                      onTap: () {
                                        Get.find<DietController>()
                                            .updateAppointmentStatus(
                                                appointmentId ?? 0, "canceled",
                                                isFromAppointment: true);
                                      },
                                      iconData: Icons.clear,
                                      text: "Cancel",
                                      backGroundColor: Colors.red,
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              if (planId != null)
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => AddUserDiet(
                                        userId: clientUser.id.toString(),
                                        planId: planId.toString()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.white),
                                      SizedBox(width: 5),
                                      Text('Diet Plan'),
                                    ],
                                  ),
                                ),
                            ]),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16.0),
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                color: const Color(
                                    0xFFF5EFF9), // Background color similar to your image
                                elevation: 2,

                                child: ExpansionTile(
                                  iconColor: Colors.black,
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  collapsedShape: RoundedRectangleBorder(),
                                  collapsedIconColor: Colors.black,
                                  expandedAlignment: Alignment.bottomCenter,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'History',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('Add Information'),
                                                content: Text(
                                                    'Add your new history details here.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text('Close'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  trailing:
                                      const Icon(Icons.arrow_drop_down_sharp),
                                  // Icon similar to the plus sign in the image
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "• Diet Preferences: Vegetarian, no dairy"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Past Diets: Tried keto, didn't work"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                          SizedBox(height: 8),
                                          Text(
                                              "• Medical History: PCOS, lactose intolerant"),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "This Week Progress",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    majorGridLines: MajorGridLines(width: 0),
                                    axisLine: AxisLine(width: 0),
                                    labelStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    maximum: 100,
                                    interval: 20,
                                    labelFormat: '{value}%',
                                    majorGridLines: MajorGridLines(
                                        width: 0.5, color: Colors.grey),
                                    axisLine:
                                        AxisLine(width: 0, color: Colors.grey),
                                    labelStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.bold),
                                    majorTickLines: MajorTickLines(size: 0),
                                  ),
                                  // plotAreaBackgroundColor: Colors.amber,
                                  series: <CartesianSeries<_ChartData, String>>[
                                    ColumnSeries<_ChartData, String>(
                                      dataSource: chartData,
                                      xValueMapper: (_ChartData data, _) =>
                                          data.day,
                                      yValueMapper: (_ChartData data, _) =>
                                          data.percentage,
                                      color: MyColors.buttonColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      width: 0.2,
                                      spacing: 0.0,
                                      // Reduces space between columns

                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: false),
                                      pointColorMapper: (_ChartData data, _) {
                                        return MyColors.buttonColor;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.day, this.percentage);

  final String day;
  final double percentage;
}
