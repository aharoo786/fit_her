import 'package:fitness_zone_2/UI/auth_module/questionair_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/plan_widget.dart';

class BmiResult extends StatelessWidget {
  BmiResult({super.key, required this.bmi});
  String bmi;
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: kToolbarHeight,
                ),
                Text(
                  "BMI Result",
                  style: textTheme.bodyMedium!.copyWith(
                      color: MyColors.black, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: Dimens.size5.h,
                ),
                Text(
                  "Track your fitness journey with our BMI Chart, showing your current status, the ideal target you can achieve, and your daily progress towards your goal.",
                  style: textTheme.bodySmall!.copyWith(
                      color: MyColors.black, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Center(
                    child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  series: <CartesianSeries>[
                    StackedBarSeries<BmiData, String>(
                      dataSource: getBmiRanges(),
                      xValueMapper: (BmiData data, _) => data.category,
                      yValueMapper: (BmiData data, _) => data.range,
                      // colorValueMapper: (BmiData data, _) => data.color,
                      pointColorMapper: (BmiData data, _) => data.color,
                      width: 0.5,
                      dataLabelSettings: const DataLabelSettings(
                          textStyle: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                  annotations: <CartesianChartAnnotation>[
                    CartesianChartAnnotation(
                      widget: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          'BMI: ${bmi}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      coordinateUnit: CoordinateUnit.point,
                      region: AnnotationRegion.plotArea,
                      x: 'Your BMI', // You can change this to map to specific BMI range category
                      y: double.parse(
                          bmi), // Ensure it fits within the primaryYAxis range
                    ),
                  ],
                )),
                SizedBox(
                  height: 10.h,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 5,
                              width: 30,
                              color: getYourColor(),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Current Status",
                              style: textTheme.titleMedium!.copyWith(
                                  color: MyColors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        Row(
                          children: [
                            Container(
                              height: 5,
                              width: 30,
                              color: MyColors.buttonColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Ideal Status",
                              style: textTheme.titleMedium!.copyWith(
                                  color: MyColors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          // Obx(() => homeController.getPlanLoaded.value
          //     ? CarouselSlider(
          //         options: CarouselOptions(
          //           height: 270.h,
          //           autoPlay: true,
          //           viewportFraction: 0.7,
          //           enlargeFactor: 0.3,
          //           enlargeCenterPage: true,
          //           enlargeStrategy: CenterPageEnlargeStrategy.scale,
          //         ),
          //         items: homeController.allPlanModel!.plans.map((plan) {
          //           return Builder(
          //             builder: (BuildContext context) {
          //               return PlanWidget(
          //                 plan: plan,
          //               );
          //             },
          //           );
          //         }).toList(),
          //       )
          //     : const CircularProgress()),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: CustomButton(
            text: "Finish",
            onPressed: () {
              if (double.parse(bmi) > 24.9 || double.parse(bmi) < 18.5) {
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(MyImgs.risk),
                                const SizedBox(
                                  height: 14,
                                ),
                                Text(
                                  "You’re at risk of PCOS.",
                                  style: textTheme.bodyMedium!.copyWith(
                                      color: MyColors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Take control of your health with Fit Her’s PCOS Risk Assesment Test, designed specifically for you.",
                                  style: textTheme.titleLarge!.copyWith(
                                      fontSize: 13,
                                      color: MyColors.black.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        text: "Start",
                                        onPressed: () {
                                          Get.off(() => QuestionnaireScreen());
                                        },
                                        height: 40,
                                        fontSize: 14,
                                        roundCorner: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                        child: CustomButton(
                                      text: "Skip",
                                      onPressed: () {
                                        AuthController authController =
                                            Get.find();

                                        authController.updateUserDetails();
                                        homeController.getUserHomeFunc();
                                      },
                                      height: 40,
                                      textColor: Colors.black,
                                      roundCorner: 25,
                                      fontSize: 14,
                                      borderColor: MyColors.buttonColor,
                                      color: Colors.white,
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ));
              } else {
                AuthController authController = Get.find();

                authController.updateUserDetails();
              }
            }),
      ),
    );
  }

  getYourColor() {
    Color color = MyColors.buttonColor;
    double bmiParse = double.parse(bmi);

    if (bmiParse >= 10.0 && bmiParse <= 18.5) {
      color = Colors.blue;
    } else if (bmiParse > 18.5 && bmiParse <= 24.9) {
      color = MyColors.buttonColor;
    } else if (bmiParse > 24.9 && bmiParse <= 29.9) {
      color = Colors.orange;
    } else if (bmiParse > 29.9) {
      color = Colors.red;
    }
    return color;
  }

  List<BmiData> getBmiRanges() {
    return [
      BmiData('Underweight', 18.5, Colors.blue),
      BmiData('Normal', 24.9, MyColors.buttonColor),
      BmiData('Overweight', 29.9, Colors.orange),
      BmiData('Obese', 40, Colors.red),
      BmiData('Your BMI', double.parse(bmi), getYourColor()),
    ];
  }
}

class BmiData {
  BmiData(this.category, this.range, this.color);
  final String category;
  final double range;
  final Color color;
}
