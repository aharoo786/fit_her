import 'package:fitness_zone_2/UI/auth_module/managePassword/forgot_password/enter_email.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/social_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/validators.dart';
import '../../../values/constants.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';
import '../sign_up_screen/signup_screen_user.dart';
import '../../../helper/analytics_helper.dart';

class Login extends StatefulWidget {
  Login({super.key, this.showDropDown = false});

  final bool showDropDown;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.trackScreenView('login_screen');
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // appBar: HelpingWidgets().appBarWidget(() {
        //   Get.back();
        // }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    MyImgs.chooseAnyOne,
                    fit: BoxFit.fill,
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: Dimens.size12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    // Center(
                    //   child: Text(
                    //     "Welcome to FitHer!",
                    //     style: textTheme.headlineSmall!.copyWith(fontSize: 24.sp, color: MyColors.textColor3, fontWeight: FontWeight.w600),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: Dimens.size5.h,
                    // ),
                    // Center(
                    //   child: Text(
                    //     "Welcome back, Sign in to your account",
                    //     style: textTheme.bodyMedium!.copyWith(color: MyColors.black, fontWeight: FontWeight.w400),
                    //   ),
                    // ),
                    SizedBox(
                      height: Dimens.size32.h,
                    ),
                    CustomTextField(
                      controller: authController.loginUserPhone,
                      keyboardType: TextInputType.emailAddress,
                      text: "Email".tr,
                      length: 30,
                      height: 48,
                      background: Colors.white,
                      inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                      icon: const Icon(Icons.email, color: MyColors.textColor3),
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    CustomTextField(
                      controller: authController.loginUserPassword,
                      keyboardType: TextInputType.text,
                      text: "Password".tr,
                      length: 30,
                      height: 48,
                      background: Colors.white,
                      inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                      icon: const Icon(Icons.lock, color: MyColors.textColor3),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Obx(() => authController.loginAsA.value != Constants.user
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<String>(
                              style: TextStyle(color: MyColors.textColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                border: InputBorder.none,
                              ),

                              //padding: EdgeInsets.symmetric(horizontal: 10.w),
                              value: authController.loginAsA.value,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  authController.loginAsA.value = newValue;
                                }
                              },
                              items: authController.addTeamMember.map((String cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: textTheme.bodySmall!.copyWith(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : const SizedBox.shrink()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => ForgotPassword());
                          },
                          child: Text(
                            "Forgot password?",
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        // Text(
                        //   "By continuing, I agree to Fit Her Terms of Services and acknowledge the Privacy Policy.",
                        //   style: textTheme.bodySmall!.copyWith(color: MyColors.textColor3, fontWeight: FontWeight.w500),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Specify if you’re a Team Member? ", style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () {
                                if (authController.loginAsA.value == Constants.user) {
                                  authController.loginAsA.value = Constants.trainer;
                                } else {
                                  authController.loginAsA.value = Constants.user;
                                }
                              },
                              child: Obx(
                                () => Text(
                                  authController.loginAsA.value == Constants.user ? "Team" : "User",
                                  style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 20.h,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              await AnalyticsHelper.trackButtonClick('continue_button', screenName: 'login_screen');

                              if (authController.loginUserPhone.text.isEmpty || authController.loginUserPassword.text.isEmpty) {
                                CustomToast.failToast(msg: "Please provide all information");
                                // Track error
                                await AnalyticsHelper.trackError('validation_error',
                                    errorMessage: 'Missing required fields', screenName: 'login_screen');
                              } else if (!authController.loginUserPhone.text.removeAllWhitespace.isEmail) {
                                CustomToast.failToast(msg: "Please provide valid email");
                                // Track error
                                await AnalyticsHelper.trackError('validation_error',
                                    errorMessage: 'Invalid email format', screenName: 'login_screen');
                              } else {
                                // Track login attempt
                                await AnalyticsHelper.trackLogin('email');
                                authController.login();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(50, 50),
                              // Foreground (icon) color
                              backgroundColor: MyColors.buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            )),

                        SizedBox(
                          height: 20.h,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.size12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (authController.loginAsA.value == Constants.user) ...[
                Center(
                  child: Text(
                    "or continue with",
                    style: textTheme.titleMedium!.copyWith(
                      color: MyColors.textColor3,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SocialLoginButtons(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Does not have an account? ", style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () async {
                        // Track navigation to sign up
                        await AnalyticsHelper.trackButtonClick('create_account_link', screenName: 'login_screen');
                        Get.off(() => SignUpNewUser());
                      },
                      child: Text(
                        "Create Account",
                        style: textTheme.titleLarge!.copyWith(color: MyColors.buttonColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
