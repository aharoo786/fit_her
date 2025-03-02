import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/managePassword/forgot_password/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import '../../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../../values/dimens.dart';
import '../../../../values/my_colors.dart';
import '../../../../values/my_imgs.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/otp_fields.dart';
import '../../../../widgets/toasts.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String otp;
  final AuthController authController = Get.find();
  OtpScreen({Key? key, required this.email, required this.otp})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<OtpScreen> {
  // final CountDownController timerController = CountDownController();

  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  onBack() {
    Get.offAll(() => Login());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var mediaQuery = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: (() => onBack()),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: MyColors.bodyBackground,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: Dimens.size110.h,
                ),
                Image.asset(
                  MyImgs.logo3,
                  scale: 3,
                ),
                SizedBox(
                  height: 60,
                ),
                Center(
                  child: Text(
                    "Verify OTP".tr,
                    style: textTheme.headlineMedium!.copyWith(
                        //fontFamily: "TiemposHeadline-Regular",
                        color: MyColors.black,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: Dimens.size20.h,
                ),
                Text(
                  'Enter your 4 digits OTP sent to'.tr,
                  style: textTheme.bodyLarge!.copyWith(
                    color: MyColors.black.withOpacity(0.6),

                    //fontFamily: "TiemposHeadline-Regular",
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.email} ".tr,
                      style: textTheme.bodyLarge!.copyWith(
                          color: MyColors.black, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                        onTap: () {
                          onBack();
                        },
                        child: Text(
                          "Edit",
                          style: textTheme.bodyLarge!.copyWith(
                            decoration: TextDecoration.underline,
                            color: MyColors.black.withOpacity(.6),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: Dimens.size50.h,
                ),
                CustomPinEntryField(
                  //    decoration: InputDecoration(),
                  keyboard: TextInputType.number,
                  onSubmit: (otp) {
                    otpController.text = otp;
                    print(otpController.text);
                  },

                  textStyle: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: MyColors.primaryColor),
                  fields: 4,

                  fieldWidth: 42.w,
                ),
                SizedBox(
                  height: Dimens.size20.h,
                ),
                // Visibility(
                //   visible: true,
                //   child: GestureDetector(
                //     onTap: () {
                //       Get.find<AuthController>().resendOtp(email: widget.email);
                //     },
                //     child: Text(
                //       "Resend OTP".tr,
                //       style: textTheme.headline3!.copyWith(
                //           color: MyColors.textColor,
                //           fontWeight: FontWeight.w500),
                //     ),
                //   ),
                // ),
                // Container(
                //   child: Visibility(
                //     visible: false,
                //     child: CircularCountDownTimer(
                //       duration: 60,
                //       initialDuration: 0,
                //       controller: timerController,
                //       width: 40.w,
                //       height: 40.h,
                //       ringColor: MyColors.primaryColor,
                //       fillColor: MyColors.textColor2,
                //       backgroundColor: MyColors.grey,
                //       strokeWidth: 5.0,
                //       strokeCap: StrokeCap.round,
                //       textStyle: TextStyle(
                //           fontSize: 12.sp,
                //           color: MyColors.textColor2,
                //           fontWeight: FontWeight.bold),
                //       textFormat: CountdownTextFormat.S,
                //       isReverse: true,
                //       isReverseAnimation: true,
                //       isTimerTextShown: true,
                //       autoStart: true,
                //       onComplete: () {},
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: Dimens.size50.h,
                ),
                Center(
                  child: CustomButton(
                      text: 'Next'.tr,
                      onPressed: () {
                        if (otpController.text.length < 4) {
                          CustomToast.failToast(msg: "Invalid otp");
                        } else {
                          if (otpController.text != widget.otp) {
                            CustomToast.failToast(msg: "Invalid otp");
                          } else {
                            Get.off(() => ResetPassword(
                                  email: widget.email,
                                ));
                          }
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
