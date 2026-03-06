import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_textfield.dart';

class ClassDetails extends StatelessWidget {
  ClassDetails({super.key, required this.slotId});
  int slotId;

  TextEditingController level = TextEditingController();
  TextEditingController type = TextEditingController();
  TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Class Details"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              keyboardType: TextInputType.text,
              text: "Class Type".tr,
              length: 30,
              controller: type,
              inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
            ),
            SizedBox(
              height: 20.h,
            ),
            CustomTextField(
              keyboardType: TextInputType.text,
              text: "Intensity Level".tr,
              length: 30,
              controller: level,
              inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
            ),
            SizedBox(
              height: 20.h,
            ),
            CustomTextField(
              height: 100,
              keyboardType: TextInputType.text,
              text: "Description".tr,
              length: 300,
              controller: description,
              inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
            ),
          ],
        ),
      ),
      bottomNavigationBar: HelpingWidgets().bottomBarButtonWidget(onTap: () {
        Get.find<WorkOutController>()
            .updateClassDetails(slotId, type, level, description);
      }),
    );
  }
}
