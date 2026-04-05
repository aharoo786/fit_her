import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/questionair_screen.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../helper/validators.dart';
import '../../../values/constants.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> signUpformKey = GlobalKey();
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: signUpformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 23.h,
                ),
                RichText(
                  text: TextSpan(
                    text: "PCOS Assessment Task Information",
                    style: textTheme.headlineLarge!.copyWith(
                        fontSize: 24.sp,
                        color: MyColors.textColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 32.h,
                ),
                CustomTextField(
                  text: "Your name",
                  length: 500,
                  controller: authController.firstNameController,
                  validator: (value) =>
                      Validators.firstNameValidation(value!.toString()),
                  keyboardType: TextInputType.name,
                  inputFormatters:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                SizedBox(
                  height: 16.h,
                ),
                // CustomTextField(
                //   text: "Phone",
                //   length: 500,
                //   controller: authController.phoneNumberController,
                //   validator: (value) =>
                //       Validators.emailValidator(value!.toString()),
                //   keyboardType: TextInputType.emailAddress,
                //   inputFormatters:
                //       FilteringTextInputFormatter.singleLineFormatter,
                // ),
                // SizedBox(
                //   height: 16.h,
                // ),
                CustomTextField(
                  text: "Email",
                  length: 500,
                  controller: authController.emailNameController,
                  validator: (value) =>
                      Validators.emailValidator(value!.toString()),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
                text: "Check Your PCOS".tr,
                onPressed: () async {
                  if (!signUpformKey.currentState!.validate()) {
                    CustomToast.failToast(
                        msg: "Please provide all necessary information");
                  } else {
                    if (!Get.find<AuthController>()
                        .emailNameController
                        .text
                        .isEmail) {
                      CustomToast.failToast(msg: "Please provide valid email");
                    } else {
                      Get.to(()=>const QuestionnaireScreen());
                    }
                  }
                }),
            SizedBox(
              height: 15.h,
            ),
          ],
        ),
      ),
    );
  }
}
