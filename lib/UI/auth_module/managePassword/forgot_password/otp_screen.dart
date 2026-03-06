import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/managePassword/forgot_password/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
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
  FocusNode focusNode = FocusNode();
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
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);

    final defaultPinTheme = PinTheme(
      width: 55,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.transparent,
        border: Border.all(color: Colors.black),
      ),
    );
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

                SizedBox(
                  height: 60,
                ),
                Center(
                  child: Text(
                    "Enter Verification Code".tr,
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
                // CustomPinEntryField(
                //   //    decoration: InputDecoration(),
                //   keyboard: TextInputType.number,
                //   onSubmit: (otp) {
                //     otpController.text = otp;
                //   },
                //
                //   textStyle: TextStyle(
                //       fontSize: 24.sp,
                //       fontWeight: FontWeight.bold,
                //       color: MyColors.primaryColor),
                //   fields: 4,
                //
                //   fieldWidth: 42.w,
                // ),
                Pinput(
                  // You can pass your own SmsRetriever implementation based on any package
                  // in this example we are using the SmartAuth
                  controller: otpController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  length: 4,
                  separatorBuilder: (index) => const SizedBox(width: 15),
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) async {
                    otpController.text = pin;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 1,
                        height: 30,
                        color: Colors.black,
                      ),
                    ],
                  ),

                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black),
                    ),
                  ),

                  disabledPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black),
                    ),
                  ),

                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.black),
                  ),
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
