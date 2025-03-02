import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen_questions.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_users/get_all_users_based_on_type.dart';
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

class SignUpNewUser extends StatefulWidget {
  SignUpNewUser({Key? key}) : super(key: key);

  @override
  State<SignUpNewUser> createState() => _SignUpNewUserState();
}

class _SignUpNewUserState extends State<SignUpNewUser> {
  final AuthController authController = Get.find();

  final HomeController homeController = Get.find();

  @override
  void initState() {
    homeController.getUsersBasedOnUserType(
        homeController.addTeamMember[4].replaceAll(" ", "_"));
    super.initState();
  }

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
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.number,
                text: "Phone no".tr,
                length: 30,
                controller: homeController.phoneController,
                inputFormatters: FilteringTextInputFormatter.digitsOnly,
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
              Text(
                "Please select customer support representative",
                style: textTheme.headlineSmall!.copyWith(
                    fontSize: 15.sp,
                    color: MyColors.textColor3,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.h,
              ),
              Obx(() => homeController.getUsersBasedOnUserTypeLoad.value
                  ? homeController
                          .getUsersBasedOnUserTypeModel!.users.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: MyColors.textFieldColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<UserTypeData>(
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
                            value: homeController
                                .getUsersBasedOnUserTypeModel!.users
                                .firstWhere((element) =>
                                    element.id ==
                                    homeController.selectCustomerSupport.value),
                            onChanged: (UserTypeData? newValue) {
                              if (newValue != null) {
                                homeController.selectCustomerSupport.value =
                                    newValue.id;
                              }
                            },
                            items: homeController
                                .getUsersBasedOnUserTypeModel!.users
                                .map((UserTypeData cat) {
                              return DropdownMenuItem<UserTypeData>(
                                value: cat,
                                child: SizedBox(
                                  width: 200.w,
                                  child: Text(
                                    "${cat.id}: ${cat.firstName} ${cat.lastName}",
                                    maxLines: 2,
                                    style: textTheme.bodySmall!.copyWith(
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis),
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
                      homeController.phoneController.text.isEmpty ||
                      homeController.passwordController.text.isEmpty) {
                    CustomToast.failToast(
                        msg: "Please provide all information");
                  } else if (!homeController.emailController.text.isEmail) {
                    CustomToast.failToast(msg: "Please provide valid email");
                  } else {
                    Get.to(() => SignUpScreenQuestions());

                    // homeController.addUser(status: false);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
