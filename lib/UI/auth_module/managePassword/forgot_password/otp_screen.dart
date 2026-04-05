import 'dart:async';
import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/managePassword/forgot_password/resetPassword.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:fitness_zone_2/theme/app_typography.dart';
import 'package:fitness_zone_2/theme/app_spacing.dart';
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
  int _remainingSeconds = 600;
  Timer? _timer;
  bool get _isExpired => _remainingSeconds <= 0;

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    _isExpired
                        ? 'OTP expired. Please request a new one.'
                        : 'OTP expires in $_timerText',
                    style: AppTypography.bodySmall.copyWith(
                      color: _isExpired || _remainingSeconds < 120
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: Dimens.size50.h,
                ),
                Center(
                  child: CustomButton(
                      text: 'Next'.tr,
                      color: _isExpired ? AppColors.textHint : null,
                      onPressed: () {
                        if (_isExpired) {
                          CustomToast.failToast(msg: "OTP has expired. Please request a new one.");
                          return;
                        }
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
