import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/controllers/plan_controller/plan_controller.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';

import '../../widgets/custom_textfield.dart';

class AddTimeDurations extends StatelessWidget {
  AddTimeDurations({super.key});
  PlanController planController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Add Time Duration"),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              keyboardType: TextInputType.text,
              text: "Duration".tr,
              length: 30,
              controller: planController.packageDuration,
              Readonly: true,
              inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
              suffixIcon: GestureDetector(
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
                    planController.packageDuration.text =
                        "${picked.difference(DateTime.now()).inDays} days";
                  }
                },
                child: Image.asset(
                  MyImgs.calender2,
                  scale: 3,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HelpingWidgets().bottomBarButtonWidget(onTap: () {
        planController.addTimeDuration();
      }),
    );
  }
}
