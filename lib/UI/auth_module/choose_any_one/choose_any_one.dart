import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:fitness_zone_2/UI/dashboard_module/add_new_user/add_new_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../login/login.dart';

class ChooseAnyOne extends StatelessWidget {
  ChooseAnyOne({Key? key}) : super(key: key);
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    return Scaffold(
      // appBar: HelpingWidgets().appBarWidget(() {
      //   Get.back();
      // }),
      body: ListView(
        children: [
          Stack(
            children: [
              Image.asset(MyImgs.chooseAnyOne,scale: 3,),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Choose Any One",
                  style: textTheme.titleLarge!.copyWith(
                    fontSize: 28.sp,
                  ),
                ),
                Text(
                  "Select your account type",
                  style: textTheme.titleLarge!.copyWith(
                      fontSize: 11.sp, color: MyColors.black.withOpacity(0.6)),
                ),
                SizedBox(
                  height: 30.h,
                ),
                GetBuilder<AuthController>(builder: (cont) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          containerWidget(context, "i’am a\nAdmin",
                              MyImgs.userIcon, Constants.admin, () {
                            cont.loginAsA.value = Constants.admin;
                            cont.update();
                          }),
                          containerWidget(context, "i’am a\nUser",
                              MyImgs.userIcon, Constants.user, () {
                            cont.loginAsA.value = Constants.user;
                            cont.update();
                          }),
                          containerWidget(context, "i’am a\nDietitian",
                              MyImgs.hostIcon, Constants.dietitian, () {
                            cont.loginAsA.value = Constants.dietitian;
                            cont.update();
                          }),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      containerWidget(context, "i’am a\nTrainer",
                          MyImgs.adminIcon, Constants.trainer, () {
                        cont.loginAsA.value = Constants.trainer;
                        cont.update();
                      }),
                    ],
                  );
                }),

                SizedBox(
                  height: 30.h,
                ),
                ElevatedButton(
                    onPressed: () {
                      Get.to(() => Login());
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(50, 50),
                      // Foreground (icon) color
                      backgroundColor: MyColors.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    )),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Does not have an account? "),
                    GestureDetector(
                      onTap: (){
                        Get.to(()=>SignUpNewUser());
                      },
                      child: Text(
                        "Create Account",
                        style: textTheme.bodyMedium!
                            .copyWith(color: MyColors.buttonColor,fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  containerWidget(BuildContext context, String text, String image, String user,
      VoidCallback onTap) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 120.h,
            alignment: Alignment.bottomCenter,
            // color: Colors.black,
            child: Container(
              height: 100.h,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(
                  top: 49.h, left: 30.w, right: 30.w, bottom: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: authController.loginAsA.value == user
                    ? Colors.white
                    : const Color.fromRGBO(211, 211, 214, 0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 33.0,
                    spreadRadius: 0.0,
                    offset: const Offset(
                        0.0, 2.0), // shadow direction: bottom right
                  )
                ],
              ),
              child: Text(
                text,
                style: textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: authController.loginAsA.value == user
                        ? Colors.black
                        : Colors.black.withOpacity(0.33)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            height: 50.h,
            width: 50.h,
            alignment: Alignment.center,
            //  margin: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
                color: authController.loginAsA.value == user
                    ? MyColors.buttonColor
                    : Colors.white,
                shape: BoxShape.circle),
            child: Image.asset(
              image,
              scale: 4,
              color: authController.loginAsA.value == user
                  ? Colors.white
                  : const Color.fromRGBO(211, 211, 214, 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
