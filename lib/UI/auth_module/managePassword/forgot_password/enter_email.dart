import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../../helper/validators.dart';
import '../../../../values/my_imgs.dart';
import '../../../../widgets/app_bar_widget.dart';
import '../../../../widgets/toasts.dart';
import 'otp_screen.dart';

/// Sprint 1 / S-02 Forgot Password — V2 redesign.
///
/// Class signature, local controllers, validator, API call, success dialog,
/// post-success navigation and failure toast are preserved exactly. Only
/// the widget tree is replaced + the success-dialog delay is reduced
/// from 2s to 1.5s per founder Q2.
class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController email = TextEditingController();
  final GlobalKey<FormState> emailFormKey = GlobalKey();
  final AuthController authController = Get.find();

  // ── SA-02 design tokens (verbatim from Sprint1_WithLogo, starting,login.html) ──
  static const Color _bg = Color(0xFFEAF7E4);
  static const Color _circleColor = Color(0xFFC8E8BC);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF7B947A);
  static const Color _label = Color(0xFF5A7A56);
  static const Color _primaryGreen = Color(0xFF6DC55A);
  static const Color _bannerBg = Color(0xFFEAF7E4);
  static const Color _bannerBorder = Color(0xFFC8E8BC);
  static const Color _bannerSub = Color(0xFF7A8C78);
  static const Color _sheetBorder = Color(0xFFD8EDD4);
  static const Color _placeholder = Color(0xFFBCD5B8);
  static const Color _error = Color(0xFFD14343);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: _bg,
      statusBarIconBrightness: Brightness.dark,
    ));

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            _buildBlobs(),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildBackButton(),
                  SizedBox(height: 26.h),
                  _buildHeroIcon(),
                  SizedBox(height: 32.h),
                  Expanded(child: _buildSheet(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background blobs ────────────────────────────────────────────────────
  Widget _buildBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -130.h,
          right: -110.w,
          child: Container(
            width: 360.w,
            height: 360.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _circleColor.withValues(alpha: 0.55),
            ),
          ),
        ),
        Positioned(
          top: 90.h,
          left: -100.w,
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _circleColor.withValues(alpha: 0.40),
            ),
          ),
        ),
      ],
    );
  }

  // ── 44×44 white circle back button (top-left) ──────────────────────────
  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _textDark.withValues(alpha: 0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back,
              color: _textDark,
              size: 18.w,
            ),
          ),
        ),
      ),
    );
  }

  // ── 88×88 hero block with lock icon ────────────────────────────────────
  Widget _buildHeroIcon() {
    return Center(
      child: Container(
        width: 88.w,
        height: 88.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: _circleColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _textDark.withValues(alpha: 0.08),
              offset: const Offset(0, 12),
              blurRadius: 28,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.lock_outline,
          color: _primaryGreen,
          size: 38.w,
        ),
      ),
    );
  }

  // ── White rounded-top sheet with form content ─────────────────────────
  Widget _buildSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        border: const Border(
          top: BorderSide(color: _sheetBorder, width: 1),
          left: BorderSide(color: _sheetBorder, width: 1),
          right: BorderSide(color: _sheetBorder, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28.w, 30.h, 28.w, 28.h),
        child: Form(
          key: emailFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              SizedBox(height: 6.h),
              _buildSub(),
              SizedBox(height: 28.h),
              _buildEmailLabel(),
              SizedBox(height: 6.h),
              _buildEmailInput(),
              SizedBox(height: 20.h),
              _buildInfoBanner(),
              SizedBox(height: 20.h),
              _buildSendButton(context),
              SizedBox(height: 20.h),
              _buildFooterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Forgot password?'.tr,
      style: GoogleFonts.dmSerifDisplay(
        textStyle: TextStyle(
          fontSize: 32.sp,
          color: _textDark,
          height: 1.1,
          letterSpacing: -0.16,
        ),
      ),
    );
  }

  Widget _buildSub() {
    return Text(
      "No worries. Enter your email and we'll send you a verification code.".tr,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.sp,
        color: _textSub,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildEmailLabel() {
    return Text(
      'Email address'.tr,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w600,
        color: _label,
        letterSpacing: 0.23,
      ),
    );
  }

  // ── TextFormField — preserves Validators.emailValidator + emailFormKey ─
  Widget _buildEmailInput() {
    return TextFormField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      cursorColor: _primaryGreen,
      validator: (value) => Validators.emailValidator(value!),
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      maxLength: 50,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.sp,
        color: _textDark,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        hintStyle: const TextStyle(color: _placeholder),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _sheetBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        errorStyle: TextStyle(
          color: _error,
          fontSize: 11.sp,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // ── Info banner (NEW) — code-expiry reassurance ────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _bannerBg,
        border: Border.all(color: _bannerBorder, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryGreen,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.access_time,
              color: Colors.white,
              size: 12.w,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code expires in 30 minutes'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'For your security, the verification code can only be used once.'
                      .tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: _bannerSub,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Primary CTA — preserves authController.forgotPassword + dialog +
  //    1.5s delay + Get.off(OtpScreen) navigation exactly. ──────────────
  Widget _buildSendButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withValues(alpha: 0.28),
              offset: const Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            if (emailFormKey.currentState!.validate()) {
              String? otp = await authController.forgotPassword(email.text);
              if (otp != null) {
                // Guard against stale context if the user navigated away
                // mid-request. Flutter 3+ idiom; replaces the inherited
                // `use_build_context_synchronously` lint without altering
                // happy-path behaviour.
                if (!context.mounted) return;
                HelpingWidgets.showCustomDialog(
                    context,
                    null,
                    "Check your email",
                    "We have sent password recovery instruction to your email.",
                    MyImgs.checkEmail);

                Future.delayed(const Duration(milliseconds: 1500), () {
                  Get.off(() => OtpScreen(
                        email: email.text,
                        otp: otp,
                      ));
                });
              }
            } else {
              CustomToast.failToast(msg: "Please enter valid data".tr);
            }
          },
          child: Text(
            'Send code'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
            ),
          ),
        ),
      ),
    );
  }

  // ── "Back to sign in" footer — Get.back() per Q4 ──────────────────────
  Widget _buildFooterLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Text(
          'Back to sign in'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _primaryGreen,
          ),
        ),
      ),
    );
  }
}
