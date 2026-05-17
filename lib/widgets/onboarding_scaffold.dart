import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Shared scaffold for onboarding step screens (S03–S05 design language).
/// Provides: background circles, nav row (back + progress + step count),
/// step badge, question title, subtitle, scrollable body, and bottom action area.
class OnboardingScaffold extends StatelessWidget {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color circleBg = Color(0xFFEAF7E4);
  static const Color green = Color(0xFF6DC55A);
  static const Color textDark = Color(0xFF163220);
  static const Color textSub = Color(0xFF5A7A56);
  static const Color textMuted = Color(0xFF9AB09A);
  static const Color dividerLine = Color(0xFFD8EDD4);
  static const Color radioBorder = Color(0xFFC8E8C0);
  static const Color optionBg = Color(0xFFEAF7E4);
  static const Color optionSelectedBg = Color(0xFFF0FBEE);

  final int currentStep;
  final int totalSteps;
  final String badgeText;
  final String questionLine1;
  final String questionLine2;
  final String subtitle;
  final Widget body;
  final VoidCallback onNext;
  final String buttonText;
  final VoidCallback? onSkip;
  final String? skipText;
  final VoidCallback? onBack;

  const OnboardingScaffold({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.badgeText,
    required this.questionLine1,
    required this.questionLine2,
    required this.subtitle,
    required this.body,
    required this.onNext,
    this.buttonText = 'Next →',
    this.onSkip,
    this.skipText,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background circles
            Positioned(
              top: -80.h,
              right: -70.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleBg.withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 140.h,
              left: -60.w,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleBg.withValues(alpha: 0.3),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Nav row
                  Padding(
                    padding: EdgeInsets.only(
                        left: 28.w, right: 28.w, top: 14.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: onBack ?? () => Get.back(),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: dividerLine, width: 1.5),
                            ),
                            child: Center(
                              child: Icon(Icons.arrow_back_ios_new,
                                  size: 16.sp, color: textDark),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: circleBg,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: currentStep / totalSteps,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: green,
                                  borderRadius:
                                      BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '$currentStep / $totalSteps',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: circleBg,
                              borderRadius:
                                  BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7.w,
                                  height: 7.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: green,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18.h),

                          // Question
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: '$questionLine1\n'),
                                TextSpan(
                                  text: questionLine2,
                                  style: const TextStyle(color: green),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),

                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                              color: textMuted,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Content
                          body,
                        ],
                      ),
                    ),
                  ),

                  // Bottom
                  Padding(
                    padding: EdgeInsets.fromLTRB(28.w, 12.h, 28.w, 40.h),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  EdgeInsets.symmetric(vertical: 17.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (onSkip != null) ...[
                          SizedBox(height: 4.h),
                          TextButton(
                            onPressed: onSkip,
                            child: Text(
                              skipText ?? 'Skip any question — update anytime',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a pill chip selector row.
  static Widget buildPillRow({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((opt) {
        final isSel = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSel ? optionSelectedBg : optionBg,
              borderRadius: BorderRadius.circular(50.r),
              border: Border.all(
                color: isSel ? green : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                color: textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds a Yes/No/Not sure selector row.
  static Widget buildYesNoRow({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children: options.map((opt) {
        final isSel = selected == opt;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: opt != options.last ? 10.w : 0),
            child: GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSel ? optionSelectedBg : optionBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSel ? green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds a question label with green-highlighted span.
  static Widget buildLabel(String before, String highlight, [String after = '']) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(text: highlight, style: const TextStyle(color: green)),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}
