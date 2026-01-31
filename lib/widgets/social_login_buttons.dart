import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../data/controllers/auth_controller/auth_controller.dart';
import '../helper/analytics_helper.dart';

class SocialLoginButtons extends StatelessWidget {
  SocialLoginButtons({super.key});
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              // Track Apple login attempt
              await AnalyticsHelper.trackLogin('apple');
              authController.handleappleLogin();
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                  color: Colors.black,
                  // border: Border.all(color: MyColors.black),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Image.asset(
                        MyImgs.appleIcon,
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      )),
                  Expanded(
                      child: Text(
                    "Apple".tr,
                    style: textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              // Track Google login attempt
              await AnalyticsHelper.trackLogin('google');
              authController.showEmailsDialog();
            },
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: MyColors.black.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(
                      MyImgs.googleIcon,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  Expanded(
                      child: Text(
                    "Google".tr,
                    style: textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
