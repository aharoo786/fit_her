import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';
import '../../UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import '../../values/dimens.dart';
import '../../values/my_colors.dart';
import '../../widgets/custom_button.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  void _goToHome() {
    final authController = Get.find<AuthController>();
    authController.updateUserDetails(updateFields: false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.size20),
          child: Column(
            children: [
              SizedBox(height: 80.h),

              // Bell icon
              Icon(
                Icons.notifications_outlined,
                size: 100.sp,
                color: MyColors.buttonColor,
              ),
              SizedBox(height: 40.h),

              // Heading
              Text(
                'Stay in the Loop',
                style: textTheme.headlineSmall!.copyWith(
                  fontSize: 24.sp,
                  color: MyColors.textColor3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimens.size5.h),

              // Subtitle
              Text(
                'Get reminders for your sessions and daily insights',
                style: textTheme.titleLarge!.copyWith(
                  color: MyColors.textColorLow,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Allow button
              CustomButton(
                text: 'Allow',
                onPressed: () {
                  final authController = Get.find<AuthController>();
                  authController.notificationServices.requestNotificationPermission();
                  _goToHome();
                },
              ),
              SizedBox(height: 16.h),

              // Maybe later
              GestureDetector(
                onTap: _goToHome,
                child: Text(
                  'Maybe later',
                  style: textTheme.bodyMedium!.copyWith(
                    fontSize: 16.sp,
                    color: MyColors.textColorLow,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
