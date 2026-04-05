import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_users/get_all_users_based_on_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/social_login_buttons.dart';
import '../../../helper/analytics_helper.dart';

class SignUpNewUser extends StatefulWidget {
  SignUpNewUser({Key? key, this.supporterId, this.isSocial = false}) : super(key: key);
  String? supporterId;
  bool isSocial;

  @override
  State<SignUpNewUser> createState() => _SignUpNewUserState();
}

class _SignUpNewUserState extends State<SignUpNewUser> {
  final AuthController authController = Get.find();

  @override
  void initState() {
    authController.getUsersBasedOnUserType(authController.addTeamMember[4].replaceAll(" ", "_"));

    super.initState();
    // Track screen view
    AnalyticsHelper.trackScreenView('signup_screen');
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        if (widget.supporterId == null) {
          Get.back();
        } else {
          Get.off(Login());
        }
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
                style: textTheme.headlineSmall!.copyWith(fontSize: 24.sp, color: MyColors.textColor3, fontWeight: FontWeight.w600),
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
                      text: "Create an account to get in and explore different ",
                      children: [
                        TextSpan(
                            text: "Workouts, Diet Plans, Gynaecological & Psychological",
                            style: textTheme.titleLarge!.copyWith(height: 1.8, color: MyColors.black, fontWeight: FontWeight.w600)),
                        TextSpan(
                            text: " appointments",
                            style: textTheme.titleLarge!.copyWith(height: 1.8, color: MyColors.black, fontWeight: FontWeight.w400)),
                      ],
                      style: textTheme.titleLarge!.copyWith(height: 1.8, color: MyColors.black, fontWeight: FontWeight.w400))),
              SizedBox(
                height: 15.h,
              ),
              if (!widget.isSocial)
                Column(
                  children: [
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      text: "First Name".tr,
                      length: 30,
                      height: 48,
                      background: Colors.white,
                      controller: authController.firstNameController,
                      inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                      icon: const Icon(Icons.person, color: MyColors.textColor3),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      text: "Last Name".tr,
                      length: 30,
                      height: 48,
                      background: Colors.white,
                      controller: authController.lastNameController,
                      inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                      icon: Icon(Icons.person, color: MyColors.textColor3),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      text: "Email".tr,
                      length: 30,
                      height: 48,
                      background: Colors.white,
                      Readonly: widget.isSocial,
                      controller: authController.emailNameController,
                      inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                      icon: Icon(Icons.email, color: MyColors.textColor3),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),

              CustomTextField(
                keyboardType: TextInputType.number,
                text: "Phone no".tr,
                length: 30,
                height: 48,
                background: Colors.white,
                controller: authController.phoneNumberController,
                inputFormatters: FilteringTextInputFormatter.digitsOnly,
                icon: Icon(Icons.phone, color: MyColors.textColor3),
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Password".tr,
                length: 30,
                height: 48,
                background: Colors.white,
                controller: authController.passwordController,
                inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                icon: Icon(Icons.lock, color: MyColors.textColor3),
              ),
              SizedBox(
                height: 20.h,
              ),

              Text(
                widget.supporterId == null ? "Please select customer support representative" : "Your sales representative",
                style: textTheme.headlineSmall!.copyWith(fontSize: 15.sp, color: MyColors.textColor3, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.h,
              ),
              Obx(() => authController.getUsersBasedOnUserTypeLoad.value
                  ? authController.getUsersBasedOnUserTypeModel!.users.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<UserTypeData>(
                            style: TextStyle(color: MyColors.textColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              border: InputBorder.none,
                            ),

                            //padding: EdgeInsets.symmetric(horizontal: 10.w),
                            value: authController.getUsersBasedOnUserTypeModel!.users.firstWhere(
                                (element) => element.id.toString() == (widget.supporterId ?? authController.selectCustomerSupport.value.toString())),
                            onChanged: widget.supporterId != null
                                ? null
                                : (UserTypeData? newValue) {
                                    if (newValue != null) {
                                      authController.selectCustomerSupport.value = newValue.id;
                                    }
                                  },
                            items: authController.getUsersBasedOnUserTypeModel!.users.map((UserTypeData cat) {
                              return DropdownMenuItem<UserTypeData>(
                                value: cat,
                                child: SizedBox(
                                  width: 200.w,
                                  child: Text(
                                    "${cat.id}: ${cat.firstName} ${cat.lastName}",
                                    maxLines: 2,
                                    style: textTheme.bodySmall!.copyWith(color: Colors.black, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : SizedBox.shrink()
                  : const Center(
                      child: CircularProgressIndicator(
                      color: MyColors.buttonColor,
                    ))),
              SizedBox(height: 40.h),
              RichText(
                text: TextSpan(
                  text: 'By continuing, I agree to ',
                  style: textTheme.titleLarge!.copyWith(color: MyColors.black, height: 2, fontWeight: FontWeight.w400),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Terms of Services',
                      style: textTheme.titleLarge!
                          .copyWith(decoration: TextDecoration.underline, color: MyColors.black, height: 2, fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: ' and acknowledge the ',
                      style: textTheme.titleLarge!.copyWith(height: 2, color: MyColors.black, fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: textTheme.titleLarge!.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: MyColors.buttonColor,
                          color: MyColors.buttonColor,
                          height: 2,
                          fontWeight: FontWeight.w400),
                    ),
                    const TextSpan(
                      text: '.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomButton(
                  text: "Continue",
                  onPressed: () async {
                    // Track button click
                    await AnalyticsHelper.trackButtonClick('continue_button', screenName: 'signup_screen');

                    print('HomeController.addUser ${authController.selectCustomerSupport.value}');

                    if (authController.firstNameController.text.isEmpty ||
                        authController.lastNameController.text.isEmpty ||
                        authController.emailNameController.text.isEmpty ||
                        authController.phoneNumberController.text.isEmpty ||
                        authController.passwordController.text.isEmpty) {
                      CustomToast.failToast(msg: "Please provide all information");
                      // Track validation error
                      await AnalyticsHelper.trackError('validation_error', errorMessage: 'Missing required fields', screenName: 'signup_screen');
                    } else if (!authController.emailNameController.text.removeAllWhitespace.isEmail) {
                      CustomToast.failToast(msg: "Please provide valid email");
                      // Track validation error
                      await AnalyticsHelper.trackError('validation_error', errorMessage: 'Invalid email format', screenName: 'signup_screen');
                    } else {
                      // Track sign up attempt
                      await AnalyticsHelper.trackSignUp('email');
                      Get.find<HomeController>().addUser(
                          status: false,
                          firstName: authController.firstNameController.text,
                          lastName: authController.lastNameController.text,
                          email: authController.emailNameController.text,
                          phone: authController.phoneNumberController.text,
                          password: authController.passwordController.text,
                          customerSupportId: authController.selectCustomerSupport.value);
                    }
                  }),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  "or continue with",
                  style: textTheme.titleMedium!.copyWith(
                    color: MyColors.textColor3,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SocialLoginButtons(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
