import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/models/get_all_users/get_all_users.dart';
import '../../../values/dimens.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class EditUser extends StatelessWidget {
  EditUser({Key? key, required this.user}) : super(key: key);

  final UserElement user;
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Edit User"),
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
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Duration".tr,
                length: 30,
                controller: homeController.dateExtendController,
                Readonly: true,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
                suffixIcon: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: MyColors
                                  .buttonColor, // OK button background color
                              hintColor:
                                  MyColors.buttonColor, // OK button text color
                              dialogBackgroundColor:
                                  Colors.white, // Dialog background color
                            ),
                            child: child!,
                          );
                        },
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2099));
                    if (picked != null) {
                      homeController.dateExtendController.text =
                          "${picked.difference(DateTime.now()).inDays} days";
                    }
                  },
                  child: Image.asset(
                    MyImgs.calender2,
                    scale: 3,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Freeze",
                    style: textTheme.headlineSmall,
                  ),
                  Obx(
                    () => Switch(
                        value: user.user.freeze.value,
                        activeColor: MyColors.buttonColor,
                        activeTrackColor: MyColors.buttonColor.withOpacity(0.5),
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.redAccent,
                        onChanged: (value) {
                          user.user.freeze.value = value;
                        }),
                  )
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              if (user.plans != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "User Plan",
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          user.plans!.plan.title,
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    if (user.assigned != null)
                      if (user.assigned!.user != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dietitian name",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "${user.assigned!.user!.firstName} ${user!.assigned!.user!.lastName}",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                    if (user.assigned != null) ...{
                      if (user.assigned!.trainer != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Trainer name",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "${user.assigned!.trainer!.firstName} ${user!.assigned!.trainer!.lastName}",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                    }
                  ],
                )
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
                text: "Update",
                onPressed: () async {
                  if (user.plans == null) {
                    CustomToast.failToast(
                        msg: "No Plan assign to this user yet");
                  } else {
                    homeController.updateUser(
                        user.user.id,
                        user.user.freeze.value,
                        homeController.dateExtendController.text.split(" ")[0],
                        user.plans!.planId.toString());
                  }
                }),
          ],
        ),
      ),
    );
  }
}
