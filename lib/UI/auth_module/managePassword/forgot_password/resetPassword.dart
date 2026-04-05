import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../helper/validators.dart';
import '../../../../values/dimens.dart';
import '../../../../values/my_colors.dart';
import '../../../../values/my_imgs.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/toasts.dart';

class ResetPassword extends StatelessWidget {
  ResetPassword({required this.email});
  String email;
  AuthController authController = Get.find();
  TextEditingController pwd = TextEditingController();
  TextEditingController confirmPwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: HelpingWidgets().appBarWidget(null, text: "Reset Password"),
        backgroundColor: MyColors.bodyBackground,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: Dimens.size40.h,
                ),
                Image.asset(
                  MyImgs.logo3,
                ),
                SizedBox(
                  height: Dimens.size50.h,
                ),
                Center(
                  child: Text(
                    "Your new password must be different from previous password"
                        .tr,
                    style: textTheme.bodyLarge!.copyWith(
                        color: MyColors.textColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: Dimens.size30.h,
                ),
                CustomTextField(
                    text: "Enter Password".tr,
                    controller: pwd,
                    textColor: MyColors.black,
                    //hintColor: MyColors.black,
                    background: MyColors.textFieldColor,
                    validator: (value) => Validators.passwordValidator(value!),
                    length: 35,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter),
                SizedBox(
                  height: Dimens.size20.h,
                ),
                CustomTextField(
                    text: "Confirm Password",
                    controller: confirmPwd,
                    // hintColor: MyColors.black,
                    background: MyColors.textFieldColor,
                    validator: (value) => Validators.passwordValidator(value!),
                    length: 35,
                    textColor: MyColors.black,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters:
                        FilteringTextInputFormatter.singleLineFormatter),
                SizedBox(
                  height: Dimens.size30.h,
                ),
                Center(
                  child: CustomButton(
                      text: 'Reset Password'.tr,
                      onPressed: () {
                        if (pwd.text == confirmPwd.text) {
                          if (pwd.text == "") {
                            CustomToast.failToast(
                                msg: "Password fields can't be empty".tr);
                          } else {
                            if (pwd.text.length < 6) {
                              CustomToast.failToast(
                                  msg:
                                      "Password must be at least 6 characters long"
                                          .tr);
                            } else {
                              authController.resetPassword(email, pwd.text);
                              // Get.find<AuthController>()
                              //     .resetPassword(otp: otp, password: pwd.text);
                            }
                          }
                        } else {
                          CustomToast.failToast(
                              msg: "Both Passwords must be same".tr);
                        }
                        // Get.offAll(() => Login());

                        // Get.dialog(ProgressBar());
                        // controller.forgotPassword();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
