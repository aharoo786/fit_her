import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../helper/validators.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import 'package:intl/intl.dart';

import '../../../widgets/toasts.dart';

class MeasureMentScreen extends StatelessWidget {
  MeasureMentScreen({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      // appBar: HelpingWidgets().appBarWidget(() {
      //   Get.back();
      // }, text: "My Weekly Report"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32.h,
              ),

              rowTextFields(context, homeController.firstDay,
                  homeController.currentDate, "1st Day Date", "Current Date"),
              SizedBox(
                height: 16.h,
              ),
              rowTextFields(
                  context,
                  homeController.firstWeight,
                  homeController.currentWeight,
                  "1st Day Weight",
                  "Current Weight"),
              SizedBox(
                height: 16.h,
              ),
              rowTextFields(context, homeController.waist, homeController.hips,
                  "Waist", "Hips"),
              SizedBox(
                height: 16.h,
              ),
              rowTextFields(context, homeController.shoulder,
                  homeController.arms, "Shoulder", "Arms"),
              SizedBox(
                height: 16.h,
              ),
              rowTextFields(context, homeController.chest,
                  homeController.abdonmen, "Chest", "Abdomnen"),
              SizedBox(
                height: 16.h,
              ),
              // rowTextFields(null, null, "First Name", "Last Name"),
              // SizedBox(
              //   height: 16.h,
              // ),

              CustomTextField(
                text: "Thighs",
                length: 500,
                controller: homeController.thighs,
                validator: (value) =>
                    Validators.emailValidator(value!.toString()),
                keyboardType: TextInputType.number,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                text: "Tell us about our services",
                length: 1500,
                controller: homeController.tellUsMore,
                validator: (value) =>
                    Validators.emailValidator(value!.toString()),
                keyboardType: TextInputType.text,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
                moreThanOneLine: true,
                height: 150,
              ),
              SizedBox(
                height: 16.h,
              ),
              Obx(
                () => Text(
                  "Give a Review about Progress: ${homeController.labels[homeController.selectedSatisfaction.value]}",
                  style: textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    homeController.satisfactionEmojis.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      homeController.selectedSatisfaction.value = index;
                    },
                    child: Obx(
                      () => Container(
                        padding: EdgeInsets.all(
                            3.0), // Add some padding around emoji
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Circle shape for border
                          border: Border.all(
                            color: homeController.selectedSatisfaction.value ==
                                    index
                                ? MyColors
                                    .buttonColor // Highlight the border when selected
                                : Colors
                                    .transparent, // No border when not selected
                            width: 3.0, // Border width
                          ),
                        ),
                        child: Text(
                          homeController
                              .satisfactionEmojis[index], // Display emoji
                          style: TextStyle(
                            fontSize: 30,
                            color: homeController.selectedSatisfaction.value ==
                                    index
                                ? Colors.blue // Highlight the selected emoji
                                : Colors
                                    .grey, // Default color for unselected emojis
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 10.h,
              ),
              CustomButton(
                  text: "Update Progress".tr,
                  onPressed: () async {
                    if (homeController.firstDay.text.isEmpty ||
                        homeController.currentDate.text.isEmpty ||
                        homeController.firstWeight.text.isEmpty ||
                        homeController.currentWeight.text.isEmpty ||
                        homeController.waist.text.isEmpty ||
                        homeController.hips.text.isEmpty ||
                        homeController.shoulder.text.isEmpty ||
                        homeController.arms.text.isEmpty ||
                        homeController.chest.text.isEmpty ||
                        homeController.abdonmen.text.isEmpty ||
                        homeController.tellUsMore.text.isEmpty ||
                        homeController.thighs.text.isEmpty) {
                      CustomToast.failToast(
                          msg: "Please provide all necessary information");
                    } else {
                      homeController.updateMyWeeklyReport();
                    }
                  }),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       CustomButton(
      //           text: "Share".tr,
      //           onPressed: () async {
      //             if (homeController.firstDay.text.isEmpty ||
      //                 homeController.currentDate.text.isEmpty ||
      //                 homeController.firstWeight.text.isEmpty ||
      //                 homeController.currentWeight.text.isEmpty ||
      //                 homeController.waist.text.isEmpty ||
      //                 homeController.hips.text.isEmpty ||
      //                 homeController.shoulder.text.isEmpty ||
      //                 homeController.arms.text.isEmpty ||
      //                 homeController.chest.text.isEmpty ||
      //                 homeController.abdonmen.text.isEmpty ||
      //                 homeController.tellUsMore.text.isEmpty ||
      //                 homeController.thighs.text.isEmpty) {
      //               CustomToast.failToast(
      //                   msg: "Please provide all necessary information");
      //             } else {
      //               homeController.updateMyWeeklyReport();
      //             }
      //           }),
      //     ],
      //   ),
      // ),
    );
  }

  rowTextFields(
      BuildContext context,
      TextEditingController? firstEditingController,
      TextEditingController? secondTextEditingController,
      String firstText,
      String secondText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextField(
          text: firstText,
          length: 500,
          width: 180.w,
          Readonly: secondText == "Current Date",
          controller: firstEditingController,
          validator: (value) =>
              Validators.firstNameValidation(value!.toString()),
          keyboardType: TextInputType.number,
          inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
          suffixIcon: secondText == "Current Date"
              ? GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: MyColors
                                  .buttonColor, // OK button background color
                              hintColor:
                                  MyColors.buttonColor, // OK button text color
                              dialogBackgroundColor:
                                  Colors.white, // Dialog background color
                            ),
                            child: child!,
                          );
                        },
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2099));
                    if (picked != null) {
                      firstEditingController!.text =
                          DateFormat("dd/MM/yyyy").format(picked);
                    }
                  },
                  child: Icon(
                    Icons.calendar_today_sharp,
                    size: 20.h,
                    color: MyColors.buttonColor,
                  ),
                )
              : SizedBox(),
        ),
        CustomTextField(
          text: secondText,
          length: 500,
          width: 180.w,
          Readonly: secondText == "Current Date",
          controller: secondTextEditingController,
          validator: (value) =>
              Validators.firstNameValidation(value!.toString()),
          keyboardType: TextInputType.number,
          inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
          suffixIcon: secondText == "Current Date"
              ? GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: MyColors
                                  .buttonColor, // OK button background color
                              hintColor:
                                  MyColors.buttonColor, // OK button text color
                              dialogBackgroundColor:
                                  Colors.white, // Dialog background color
                            ),
                            child: child!,
                          );
                        },
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year),
                        lastDate: DateTime(2099));
                    if (picked != null) {
                      secondTextEditingController!.text =
                          DateFormat("dd/MM/yyyy").format(picked);
                    }
                  },
                  child: Icon(
                    Icons.calendar_today_sharp,
                    size: 20.h,
                    color: MyColors.buttonColor,
                  ),
                )
              : SizedBox(),
        ),
      ],
    );
  }
}
