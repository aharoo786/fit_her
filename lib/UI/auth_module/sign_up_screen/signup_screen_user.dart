import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/circular_progress.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class SignUpNewUser extends StatelessWidget {
  SignUpNewUser({Key? key}) : super(key: key);
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Sign Up"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.size20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Dimens.size32.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "First Name".tr,
                length: 30,
                controller: homeController.firstNameController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Last Name".tr,
                length: 30,
                controller: homeController.lastNameController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Email".tr,
                length: 30,
                controller: homeController.emailController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Phone no".tr,
                length: 30,
                controller: homeController.phoneController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Password".tr,
                length: 30,
                controller: homeController.passwordController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
                text: "Add",
                onPressed: () async {
                  if (homeController.firstNameController.text.isEmpty ||
                      homeController.lastNameController.text.isEmpty ||
                      homeController.emailController.text.isEmpty ||
                      homeController.phoneController.text.isEmpty ||
                      homeController.passwordController.text.isEmpty ) {
                    CustomToast.failToast(
                        msg: "Please provide all information");
                  } else if (!homeController.emailController.text.isEmail) {
                    CustomToast.failToast(msg: "Please provide valid email");
                  } else {
                    homeController.addUser(status: false);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
