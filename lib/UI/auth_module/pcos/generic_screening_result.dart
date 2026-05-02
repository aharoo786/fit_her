import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'screening_data.dart';

class GenericScreeningResult extends StatelessWidget {
  final ScreeningConfig config;
  final String riskLevel;
  final int riskScore;

  const GenericScreeningResult({
    Key? key,
    required this.config,
    required this.riskLevel,
    required this.riskScore,
  }) : super(key: key);

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _circleBg = Color(0xFFEAF7E4);
  static const Color _green = Color(0xFF6DC55A);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF5A7A56);
  static const Color _textMuted = Color(0xFF9AB09A);

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
    final r = config.result;

    final cardBg = isHigh ? _highBg : (isMod ? _modBg : _lowBg);
    final cardBorder = isHigh ? _highBorder : (isMod ? _modBorder : _lowBorder);
    final badgeBg = isHigh ? _highBadgeBg : (isMod ? _modBadgeBg : _lowBadgeBg);
    final badgeText = isHigh ? _highBadgeText : (isMod ? _modBadgeText : _lowBadgeText);

    final badgeLabel = isHigh ? 'Higher likelihood' : (isMod ? 'Moderate likelihood' : 'Lower likelihood');
    final cardTitle = isHigh ? r.highTitle : (isMod ? r.moderateTitle : r.lowTitle);
    final cardBody = isHigh ? r.highBody : (isMod ? r.moderateBody : r.lowBody);
    final nextSteps = (isHigh || isMod) ? r.highNextSteps : r.lowNextSteps;
    final nextStepsTitle = (isHigh || isMod) ? 'What Fit Her will do for you' : 'What we recommend';

    return Scaffold(
      backgroundColor: _bg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: -80.h, right: -70.w,
              child: Container(
                width: 260.w, height: 260.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _circleBg.withValues(alpha: 0.5)),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
                child: Column(
                  children: [
                    Text(config.intro.emoji, style: TextStyle(fontSize: 32.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      '${config.conditionType} Screening Complete',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18.sp, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Based on your answers',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, color: _textMuted),
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
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6.r)),
                            child: Text(badgeLabel,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 10.sp, fontWeight: FontWeight.w700, color: badgeText)),
                          ),
                          SizedBox(height: 8.h),
                          Text(cardTitle,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.w700, color: _textDark)),
                          SizedBox(height: 5.h),
                          Text(cardBody,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, color: _textSub, height: 1.55)),
                          SizedBox(height: 10.h),
                          Text(
                            'This is not a medical diagnosis. Please consult a qualified doctor for proper assessment.',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 10.sp, color: _textMuted, fontStyle: FontStyle.italic, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Next steps
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(color: _circleBg, borderRadius: BorderRadius.circular(14.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nextStepsTitle,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, fontWeight: FontWeight.w700, color: _textDark)),
                          SizedBox(height: 8.h),
                          ...nextSteps.map((step) => Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 18.w, height: 18.w,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
                                  child: Center(child: Icon(Icons.check, size: 10.sp, color: Colors.white)),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(child: Text(step,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, color: _textSub))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    if (isHigh || isMod) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to specialist booking
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text(config.result.ctaButtonText,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _green, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text('Continue to Fit Her',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.w600, color: _green)),
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
}
