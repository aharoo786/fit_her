import 'package:fitness_zone_2/UI/auth_module/questionair_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:flutter/material.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../values/my_imgs.dart';
import '../../../widgets/custom_button.dart';
import '../../dashboard_module/profile_screen/profile_screen.dart';
import '../choose_any_one/choose_any_one.dart';

class WalkThroughScreen extends StatelessWidget {
  const WalkThroughScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  MyImgs.walkThroughBack2,
                ),
                fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50.h,
            ),
            Image.asset(
              MyImgs.logo3,
              scale: 3,
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.9),
                  ])),
              child: Column(
                children: [
                  const SizedBox(
                    height: 230,
                  ),
                  Text(
                    "Welcome To FitHer!",
                    style: textTheme.titleLarge!.copyWith(
                        fontSize: 28.sp,
                        color: MyColors.textColor3,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Unleash your Inner Strength with us",
                    style: textTheme.titleLarge!.copyWith(
                        fontSize: 18.sp,
                        color: MyColors.textColor3,
                        fontWeight: FontWeight.w500),
                  ),

                  SizedBox(
                    height: 10.h,
                  ),
                  CustomButton(
                      text: "Get Started",
                      onPressed: () {
                        Get.to(() => SignUpNewUser());
                      }),

                  SizedBox(
                    height: 20.h,
                  ),
                  CustomButton(
                      text: "Log In",
                      onPressed: () {
                        Get.to(() => ChooseAnyOne());
                      }),
                  // CustomButton(
                  //     text: "Free PCOS Risk Assessment Task",
                  //     onPressed: () {
                  //       Get.find<AuthController>()
                  //           .sharedPreferences
                  //           .setBool(Constants.isGuest, true);
                  //       // Get.to(() => ProfileScreen(fromWelcomeScreen: true,));
                  //       Get.to(() => SignUpScreen());
                  //     }),

                  // GestureDetector(
                  //   onTap: () {
                  //     Get.to(() => ChooseAnyOne());
                  //   },
                  //   child: RichText(
                  //       text: TextSpan(
                  //           text: "Already have an account? ",
                  //           children: [
                  //             TextSpan(
                  //                 text: "Log in",
                  //                 style: textTheme.bodyMedium!.copyWith(
                  //                     decoration: TextDecoration.underline))
                  //           ],
                  //           style: textTheme.bodyMedium)),
                  // ),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),

            //  Container(height: 5.h,width: 140.w,decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
