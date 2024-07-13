import 'package:fitness_zone_2/UI/auth_module/managePassword/forgot_password/enter_email.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/validators.dart';
import '../../../values/constants.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class Login extends StatelessWidget {
  Login({super.key});

  // TextEditingController countryCode =

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 300.h,
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(MyImgs.loginCurve),
                      fit: BoxFit.cover,
                    )),
                    child: Text(
                      "Fit Her",
                      style: textTheme.headlineLarge!
                          .copyWith(fontSize: 48.sp, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    left: 0.w,
                    top: 30.h,
                    child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30.w,
                        )),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.size20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi There!",
                      style: textTheme.headlineSmall!
                          .copyWith(fontSize: 24.sp, color: MyColors.black),
                    ),
                    SizedBox(
                      height: Dimens.size5.h,
                    ),
                    Text(
                      "Welcome back, Sign in to your account",
                      style: textTheme.bodyMedium!.copyWith(
                          color: MyColors.lightTextColor,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: Dimens.size32.h,
                    ),
                    CustomTextField(
                      controller: authController.loginUserPhone,
                      keyboardType: TextInputType.text,
                      text: "Email".tr,
                      length: 30,
                      inputFormatters:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    CustomTextField(
                      controller: authController.loginUserPassword,
                      keyboardType: TextInputType.text,
                      text: "Password".tr,
                      length: 30,
                      inputFormatters:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    SizedBox(
                      height: Dimens.size40.h,
                    ),
                    CustomButton(
                        text: "Sign In",
                        onPressed: () async {
                          if (authController.loginUserPhone.text.isEmpty ||
                              authController.loginUserPassword.text.isEmpty) {
                            CustomToast.failToast(
                                msg: "Please provide all information");
                          } else if (!authController
                              .loginUserPhone.text.isEmail) {
                            CustomToast.failToast(
                                msg: "Please provide valid email");
                          } else {

                              authController.login();

                          }
                          // Get.offAll(()=>BottomBarScreen());
                        }),
                    SizedBox(
                      height: 20.h,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     // Row(
                    //     //   mainAxisAlignment: MainAxisAlignment.center,
                    //     //   children: [
                    //     //     Text(
                    //     //       "No Account Yet? ",
                    //     //       style: textTheme.bodySmall,
                    //     //     ),
                    //     //     GestureDetector(
                    //     //         onTap: () {
                    //     //           Get.off(() => SignUpScreen());
                    //     //         },
                    //     //         child: Text(
                    //     //           "Sign Up",
                    //     //           style: textTheme.bodySmall!
                    //     //               .copyWith(color: MyColors.buttonColor),
                    //     //         )),
                    //     //   ],
                    //     // ),
                    //     GestureDetector(
                    //       onTap: () {
                    //         Get.to(() => ForgotPassword());
                    //       },
                    //       child: Text(
                    //         "Forgot password?",
                    //         style: textTheme.bodySmall,
                    //       ),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
