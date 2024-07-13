import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../../helper/validators.dart';
import '../../../../values/dimens.dart';
import '../../../../values/my_colors.dart';
import '../../../../values/my_imgs.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/toasts.dart';

class ForgotPassword extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final GlobalKey<FormState> emailFormKey = GlobalKey();

  ForgotPassword({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: HelpingWidgets().appBarWidget(() {
            Get.back();
          }, text: "Forgot Password"),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.size20.w),
              child: Form(
                key: emailFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: Dimens.size40.h,
                    ),
                    Text(
                      'Forgot Password?'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: Dimens.size32.sp,
                          color: MyColors.black),
                    ),
                    SizedBox(
                      height: (Dimens.size140).h,
                    ),
                    Text(
                      'Please enter your email address to receive a verification code'
                          .tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: (Dimens.size16).sp,
                        color: MyColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 31.h,
                    ),
                    CustomTextField(
                        height: 48.h,
                        controller: email,
                        text: "Enter email".tr,
                        background: MyColors.textFieldColor,
                        length: 50,
                        validator: (value) => Validators.emailValidator(value!),
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters:
                            FilteringTextInputFormatter.singleLineFormatter),
                    SizedBox(
                      height: Dimens.size60.h,
                    ),
                    CustomButton(
                      text: 'Send Code'.tr,
                      onPressed: () {
                        if (emailFormKey.currentState!.validate()) {
                          // authController.forgotPassword(email: email.text);
                        } else {
                          CustomToast.failToast(
                              msg: "Please enter valid data".tr);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
