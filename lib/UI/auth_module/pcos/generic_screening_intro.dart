import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'generic_screening_questions.dart';
import 'screening_data.dart';

class GenericScreeningIntro extends StatelessWidget {
  final ScreeningConfig config;

  const GenericScreeningIntro({Key? key, required this.config})
      : super(key: key);

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textMuted = Color(0xFF9AB09A);
  static const Color _dividerLine = Color(0xFFD8EDD4);
  static const Color _warnBg = Color(0xFFFFF8E6);
  static const Color _warnBorder = Color(0xFFFAC775);
  static const Color _warnText = Color(0xFF856404);

  @override
  Widget build(BuildContext context) {
    final intro = config.intro;

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
                width: 280.w,
                height: 280.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: intro.accentBgLight.withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 120.h,
              left: -60.w,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: intro.accentBgLight.withValues(alpha: 0.35),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 28.w, right: 28.w, top: 14.h),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border:
                                Border.all(color: _dividerLine, width: 1.5),
                          ),
                          child: Center(
                            child: Icon(Icons.arrow_back_ios_new,
                                size: 16.sp, color: _textDark),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 24.h),
                      child: Column(
                        children: [
                          // Hero icon
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: intro.accentBgLight,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Center(
                              child: Text(intro.emoji,
                                  style: TextStyle(fontSize: 38.sp)),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            intro.label.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: intro.accentColor,
                              letterSpacing: 0.1 * 11.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: intro.titleBefore),
                                TextSpan(
                                  text: intro.titleHighlight,
                                  style: TextStyle(color: intro.accentColor),
                                ),
                                if (intro.titleAfter.isNotEmpty)
                                  TextSpan(text: intro.titleAfter),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            intro.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                              color: _textMuted,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 28.h),

                          // Check items
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: intro.accentBgDark,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "What we'll ask you about",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                ...intro.checkItems.map((item) =>
                                    _buildCheckItem(item, intro.accentColor)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Disclaimer
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              color: _warnBg,
                              borderRadius: BorderRadius.circular(14.r),
                              border: const Border(
                                left: BorderSide(
                                    color: _warnBorder, width: 4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('⚠️',
                                        style: TextStyle(fontSize: 16.sp)),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Medical disclaimer',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: _warnText,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  intro.disclaimer,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w300,
                                    color: _warnText,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
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
                            onPressed: () {
                              Get.to(() =>
                                  GenericScreeningQuestions(config: config));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: intro.accentColor,
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
                              'Start screening →',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Takes less than 2 minutes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            color: _textMuted,
                          ),
                        ),
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

  Widget _buildCheckItem(ScreeningCheckItem item, Color accent) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
            ),
            child: Center(
              child: Icon(Icons.check, size: 12.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: _textDark,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
