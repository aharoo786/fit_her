import 'package:fitness_zone_2/UI/auth_module/managePassword/forgot_password/enter_email.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
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
  Login({super.key,this.showDropDown=false});

  final bool showDropDown;

  // TextEditingController countryCode =

  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          Get.back();
        }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.size12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50.h,
                    ),
                    Text(
                      "Welcome to FitHer!",
                      style: textTheme.headlineSmall!.copyWith(
                          fontSize: 24.sp,
                          color: MyColors.textColor3,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: Dimens.size5.h,
                    ),
                    Text(
                      "Welcome back, Sign in to your account",
                      style: textTheme.bodyMedium!.copyWith(
                          color: MyColors.black, fontWeight: FontWeight.w400),
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
             showDropDown?          Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        style: TextStyle(
                            color: MyColors.textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          border: InputBorder.none,
                        ),

                        //padding: EdgeInsets.symmetric(horizontal: 10.w),
                        value: authController.loginAsA.value,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            authController.loginAsA.value = newValue;
                          }
                        },
                        items: authController.addTeamMember.map((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(
                              cat,
                              style: textTheme.bodySmall!
                                  .copyWith(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ):SizedBox.shrink(),
                    SizedBox(
                      height: Dimens.size40.h,
                    ),

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
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Text(
                "By continuing, I agree to Fit Her Terms of Services and acknowledge the Privacy Policy.",
                style: textTheme.bodySmall!.copyWith(
                    color: MyColors.textColor3, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.h,
              ),
              CustomButton(
                  text: "Continue",
                  onPressed: () async {
                    if (authController.loginUserPhone.text.isEmpty ||
                        authController.loginUserPassword.text.isEmpty) {
                      CustomToast.failToast(
                          msg: "Please provide all information");
                    } else if (!authController.loginUserPhone.text.isEmail) {
                      CustomToast.failToast(msg: "Please provide valid email");
                    } else {
                      authController
                          .login(homeController.addedTeamMember.value);
                    }
                    // Get.offAll(()=>BottomBarScreen());
                  }),
              // SizedBox(
              //   height: 10.h,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     // Get.to(() => ChooseAnyOne());
              //   },
              //   child: RichText(
              //       text: TextSpan(
              //           text: "Specify if you’re a Team Member ",
              //           children: [
              //             TextSpan(
              //                 text: "Team",
              //                 style: textTheme.bodyMedium!.copyWith(
              //                     decoration: TextDecoration.underline,
              //                     fontWeight: FontWeight.w700))
              //           ],
              //           style: textTheme.bodyMedium)),
              // ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
