import 'package:fitness_zone_2/data/Repos/home_repo/home_repo.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PcosResultScreen extends StatelessWidget {
  final String riskLevel; // 'high', 'moderate', 'low'
  final int riskScore;
  final Map<int, String> answers;

  const PcosResultScreen({
    Key? key,
    required this.riskLevel,
    required this.riskScore,
    required this.answers,
  }) : super(key: key);

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _circleBg = Color(0xFFEAF7E4);
  static const Color _green = Color(0xFF6DC55A);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF5A7A56);
  static const Color _textMuted = Color(0xFF9AB09A);
  static const Color _dividerLine = Color(0xFFD8EDD4);

  // Risk card colors
  static const Color _highBg = Color(0xFFFFF5F5);
  static const Color _highBorder = Color(0xFFFFCDD2);
  static const Color _highBadgeBg = Color(0xFFFFCDD2);
  static const Color _highBadgeText = Color(0xFFC62828);

  static const Color _modBg = Color(0xFFFFF8E6);
  static const Color _modBorder = Color(0xFFFFE082);
  static const Color _modBadgeBg = Color(0xFFFFE082);
  static const Color _modBadgeText = Color(0xFF856404);

  static const Color _lowBg = Color(0xFFEAF7E4);
  static const Color _lowBorder = Color(0xFFC8E8C0);
  static const Color _lowBadgeBg = Color(0xFFC8E8C0);
  static const Color _lowBadgeText = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final isHigh = riskLevel == 'high';
    final isMod = riskLevel == 'moderate';

    final cardBg = isHigh ? _highBg : (isMod ? _modBg : _lowBg);
    final cardBorder =
        isHigh ? _highBorder : (isMod ? _modBorder : _lowBorder);
    final badgeBg =
        isHigh ? _highBadgeBg : (isMod ? _modBadgeBg : _lowBadgeBg);
    final badgeText =
        isHigh ? _highBadgeText : (isMod ? _modBadgeText : _lowBadgeText);

    final badgeLabel = isHigh
        ? 'Higher likelihood'
        : (isMod ? 'Moderate likelihood' : 'Lower likelihood');
    final cardTitle = isHigh
        ? 'Your symptoms are consistent with PCOS'
        : (isMod
            ? 'Some symptoms align with PCOS'
            : 'Your symptoms are less consistent with PCOS');
    final cardBody = isHigh
        ? 'You reported patterns that align with Rotterdam Criteria indicators. This does not confirm a diagnosis but warrants further investigation by a doctor.'
        : (isMod
            ? 'You reported some patterns that could indicate PCOS. Consider monitoring your symptoms and discussing with a healthcare provider.'
            : "Your answers show fewer of the typical PCOS indicators. This doesn't rule it out entirely — PCOS presents differently in every woman — but your symptoms are less aligned with the Rotterdam Criteria patterns.");

    final nextStepsTitle =
        isHigh ? 'What Fit Her will do for you' : 'What we recommend';
    final nextSteps = isHigh
        ? [
            'Add PCOS program to your profile',
            'Build you a PCOS-friendly diet plan',
            'Track your symptoms over time',
            'Recommend low-androgen workouts',
          ]
        : [
            'Continue tracking your cycle in Fit Her',
            'Retake screening if symptoms change',
            'Still concerned? Book a consultation',
          ];

    return Scaffold(
      backgroundColor: _bg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: -80.h,
              right: -70.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleBg.withValues(alpha: 0.5),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: 28.w, vertical: 24.h),
                child: Column(
                  children: [
                    // Hero
                    Text('🔬', style: TextStyle(fontSize: 32.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      'PCOS Screening Complete',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Based on your answers · Rotterdam Criteria',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: _textMuted,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Risk card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: cardBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: badgeText,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            cardTitle,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            cardBody,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              color: _textSub,
                              height: 1.55,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'This is not a medical diagnosis. Only a gynaecologist can confirm PCOS through blood tests and an ovarian ultrasound. Please consult a qualified doctor.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              color: _textMuted,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Next steps
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: _circleBg,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextStepsTitle,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...nextSteps.map((step) => Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18.w,
                                      height: 18.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _green,
                                      ),
                                      child: Center(
                                        child: Icon(Icons.check,
                                            size: 10.sp,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12.sp,
                                          color: _textSub,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Buttons
                    if (isHigh || isMod) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to gynecologist booking
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Book a gynaecologist consultation',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _saveAndContinue();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _green, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          isHigh
                              ? 'Continue to Fit Her'
                              : 'Continue to Fit Her',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _green,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndContinue() {
    // Save screening result to backend
    final token = Get.find<AuthController>()
        .sharedPreferences
        .getString(Constants.accessToken) ?? '';
    final repo = Get.find<HomeRepo>();

    repo.savePcosScreening(
      accessToken: token,
      body: {
        'riskLevel': riskLevel,
        'riskScore': riskScore,
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      },
    );

    // If high risk, add PCOS to health conditions
    if (riskLevel == 'high') {
      final auth = Get.find<AuthController>();
      final current = auth.healthConditions.value;
      if (!current.contains('PCOS')) {
        auth.healthConditions.value =
            current.isEmpty ? 'PCOS' : '$current,PCOS';
      }
    }

    // Go back to health conditions screen
    Get.back();
    Get.back();
  }
}
