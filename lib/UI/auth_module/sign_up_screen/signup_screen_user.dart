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
          padding: const EdgeInsets.symmetric(horizontal: Dimens.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Welcome to FitHer",
                style: textTheme.headlineSmall!.copyWith(
                    fontSize: 24.sp,
                    color: MyColors.textColor3,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: Dimens.size5.h,
              ),
              // Text(
              //   "Create an account to get in and explore different Workouts, Diet Plans, Gynaecological & Psychological appointments.",
              //   style: textTheme.titleLarge!.copyWith(
              //       height: 1.8,
              //       color: MyColors.black,
              //       fontWeight: FontWeight.w500),
              // ),
              RichText(
                  text: TextSpan(
                      text:
                          "Create an account to get in and explore different ",
                      children: [
                        TextSpan(
                            text:
                                "Workouts, Diet Plans, Gynaecological & Psychological",
                            style: textTheme.titleLarge!.copyWith(
                                height: 1.8,
                                color: MyColors.black,
                                fontWeight: FontWeight.w600)),
                        TextSpan(
                            text: " appointments",
                            style: textTheme.titleLarge!.copyWith(
                                height: 1.8,
                                color: MyColors.black,
                                fontWeight: FontWeight.w400)),
                      ],
                      style: textTheme.titleLarge!.copyWith(
                          height: 1.8,
                          color: MyColors.black,
                          fontWeight: FontWeight.w400))),
              SizedBox(
                height: 15.h,
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
              // SizedBox(
              //   height: 20.h,
              // ),
              // CustomTextField(
              //   keyboardType: TextInputType.text,
              //   text: "Phone no".tr,
              //   length: 30,
              //   controller: homeController.phoneController,
              //   inputFormatters:
              //       FilteringTextInputFormatter.singleLineFormatter,
              // ),
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
            RichText(
              text: TextSpan(
                text: 'By continuing, I agree to ',
                style: textTheme.titleLarge!.copyWith(
                    color: MyColors.black,
                    height: 2,
                    fontWeight: FontWeight.w400), // Default text style
                children: <TextSpan>[
                  TextSpan(
                    text: 'Terms of Services',
                    style: textTheme.titleLarge!.copyWith(
                        decoration: TextDecoration.underline,
                        color: MyColors.black,
                        height: 2,
                        fontWeight: FontWeight.w400),
                    // You can add a gesture recognizer here to handle clicks
                  ),
                  TextSpan(
                    text: ' and acknowledge the ',
                    style: textTheme.titleLarge!.copyWith(
                        height: 2,
                        color: MyColors.black,
                        fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: textTheme.titleLarge!.copyWith(
                        decoration: TextDecoration.underline,
                        color: MyColors.black,
                        height: 2,
                        fontWeight: FontWeight.w400),
                    // You can add a gesture recognizer here to handle clicks
                  ),
                  const TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            CustomButton(
                text: "Continue",
                onPressed: () async {
                  if (homeController.firstNameController.text.isEmpty ||
                      homeController.lastNameController.text.isEmpty ||
                      homeController.emailController.text.isEmpty ||
                      // homeController.phoneController.text.isEmpty ||
                      homeController.passwordController.text.isEmpty) {
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
