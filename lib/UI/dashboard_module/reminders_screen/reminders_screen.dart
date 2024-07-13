import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../helper/validators.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class RemindersScreen extends StatelessWidget {
  RemindersScreen({Key? key, this.isAnnouncement = false}) : super(key: key);
  final bool isAnnouncement;
  final TextEditingController reminderTitle = TextEditingController();
  final TextEditingController reminderBody = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        //onBack();
        Get.back();
      }, text: "Reminders"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: isAnnouncement
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50.h,
                  ),
                  CustomTextField(
                    text: "Reminder Title",
                    length: 500,
                    controller: reminderTitle,
                    validator: (value) =>
                        Validators.firstNameValidation(value!.toString()),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  CustomTextField(
                    text: "Reminder Message",
                    controller: reminderBody,
                    length: 500,
                    validator: (value) =>
                        Validators.emailValidator(value!.toString()),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter,
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    "Package Expiry Reminder",
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    "This is a friendly reminder regarding the impending expiration of certain packages within our system. It's crucial to take action to ensure smooth operations and prevent any disruptions",
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                  )
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
                text: "Send".tr,
                onPressed: () async {
                  if (isAnnouncement) {
                    if (reminderTitle.text.isEmpty ||
                        reminderBody.text.isEmpty) {
                      CustomToast.failToast(
                          msg: "Please provide all information");
                    } else {
                      Get.find<HomeController>()
                          .addAnnouncement(reminderTitle, reminderBody);
                    }
                  }
                  else{
                    Get.find<HomeController>().synchronization();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
