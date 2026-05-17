import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../UI/auth_module/cycle_data_screen.dart';
import '../../UI/auth_module/notification_screen.dart';
import '../../UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/Repos/cycle_repo/cycle_data_repository.dart';
import '../../values/constants.dart';
import '../../values/dimens.dart';
import '../../values/my_colors.dart';
import '../../widgets/custom_button.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({Key? key}) : super(key: key);

  void _goToHome() {
    Get.offAll(() => BottomBarScreen());
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

              // Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: MyColors.buttonColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 60.sp,
                  color: MyColors.buttonColor,
                ),
              ),
              SizedBox(height: 40.h),

              // Heading
              Text(
                'FitHer Just Got Smarter',
                style: textTheme.headlineSmall!.copyWith(
                  fontSize: 24.sp,
                  color: MyColors.textColor3,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Dimens.size5.h),

              // Subtitle
              Text(
                'We now understand your cycle. Get daily insights, workout recommendations matched to your energy, and see your body\'s rhythm like never before.',
                style: textTheme.titleLarge!.copyWith(
                  color: MyColors.textColorLow,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Set It Up button
              CustomButton(
                text: 'Set It Up',
                onPressed: () {
                  Get.to(() => CycleDataScreen(
                    onContinue: (cycleData) async {
                      final repo = Get.find<CycleDataRepository>();
                      final token = Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken) ?? '';
                      await repo.saveCycleData(accessToken: token, body: cycleData);
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "You're all set! \u{1F389}",
                                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: MyColors.textColor3),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Your AI insights start tomorrow. Follow them to understand your body better every day.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.sp, color: MyColors.textColorLow, height: 1.5),
                                ),
                                SizedBox(height: 24.h),
                                CustomButton(
                                  text: "Let's go!",
                                  onPressed: () {
                                    Get.back();
                                    _goToHome();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        barrierDismissible: false,
                      );
                    },
                    onSkip: () async {
                      final repo = Get.find<CycleDataRepository>();
                      final token = Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken) ?? '';
                      await repo.saveCycleData(accessToken: token, body: {'dataProvided': 0});
                      _goToHome();
                    },
                  ));
                },
              ),
              SizedBox(height: 16.h),

              // Later text
              GestureDetector(
                onTap: () async {
                  final repo = Get.find<CycleDataRepository>();
                  final token = Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken) ?? '';
                  await repo.saveCycleData(accessToken: token, body: {'dataProvided': 0});
                  _goToHome();
                },
                child: Text(
                  'Later',
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
