import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'pcos_result_screen.dart';

class _PcosQuestion {
  final String questionText;
  final String questionHighlight;
  final String subtitle;
  final List<String> options;
  final String researchNote;
  final int riskStartIndex;

  const _PcosQuestion({
    required this.questionText,
    required this.questionHighlight,
    required this.subtitle,
    required this.options,
    required this.researchNote,
    this.riskStartIndex = 1,
  });
}

class PcosQuestionScreen extends StatefulWidget {
  const PcosQuestionScreen({Key? key}) : super(key: key);

  @override
  State<PcosQuestionScreen> createState() => _PcosQuestionScreenState();
}

class _PcosQuestionScreenState extends State<PcosQuestionScreen> {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _circleBg = Color(0xFFEAF7E4);
  static const Color _green = Color(0xFF6DC55A);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF5A7A56);
  static const Color _textMuted = Color(0xFF9AB09A);
  static const Color _dividerLine = Color(0xFFD8EDD4);
  static const Color _radioBorder = Color(0xFFC8E8C0);
  static const Color _optionBg = Color(0xFFEAF7E4);
  static const Color _optionSelBg = Color(0xFFF0FBEE);

  int _currentQ = 0;
  final List<int?> _answers = List.filled(5, null);

  static const List<_PcosQuestion> _questions = [
    _PcosQuestion(
      questionText: 'How regular are\nyour ',
      questionHighlight: 'periods?',
      subtitle:
          'This helps us understand your ovulation patterns — a key indicator of hormonal balance',
      options: [
        'Regular — every 21 to 35 days',
        'Irregular — varies a lot each month',
        'Infrequent — fewer than 8 per year',
        'Absent — no period for 3+ months',
      ],
      researchNote:
          'Irregular or infrequent periods (oligomenorrhoea) are one of the three core Rotterdam Criteria for PCOS assessment, used by gynaecologists worldwide.',
      riskStartIndex: 1,
    ),
    _PcosQuestion(
      questionText: 'Do you have unusual\n',
      questionHighlight: 'hair growth',
      subtitle:
          'This refers to dark or coarse hair appearing on the face, chin, chest, stomach or upper thighs',
      options: [
        'No — no unusual hair growth',
        'Mild — a little on face or body',
        'Moderate — noticeable in multiple areas',
        'Significant — affects daily confidence',
      ],
      researchNote:
          'Hirsutism — excess hair growth in a male pattern — is a clinical sign of elevated androgens, one of the three core Rotterdam Criteria used to screen for PCOS.',
      riskStartIndex: 1,
    ),
    _PcosQuestion(
      questionText: 'Do you struggle with\n',
      questionHighlight: 'weight loss?',
      subtitle: 'Despite eating well and exercising regularly',
      options: [
        'Yes — very difficult to lose weight',
        'Somewhat — slower than expected',
        'No — weight responds normally',
        "I haven't tried to lose weight",
      ],
      researchNote:
          'Insulin resistance — common in PCOS — causes the body to store fat more easily and makes weight loss significantly harder despite diet and exercise.',
      riskStartIndex: 0,
    ),
    _PcosQuestion(
      questionText: 'How would you describe\nyour ',
      questionHighlight: 'skin and acne?',
      subtitle: 'Especially around jawline, chin and cheeks',
      options: [
        'Clear — rarely get spots',
        'Mild — occasional breakouts',
        'Moderate — frequent, hard to control',
        'Severe — persistent, deep or cystic',
      ],
      researchNote:
          'Elevated androgens in PCOS trigger excess sebum production, leading to persistent adult acne — particularly along the lower face and jawline.',
      riskStartIndex: 2,
    ),
    _PcosQuestion(
      questionText: 'Have you had any\n',
      questionHighlight: 'hormone tests',
      subtitle:
          'Blood tests or ultrasound related to your cycle or hormones',
      options: [
        'Yes — told I have elevated androgens',
        'Yes — cysts seen on ovary ultrasound',
        'Yes — tests done but all normal',
        'No — never had hormone tests',
      ],
      researchNote:
          'Polycystic ovarian morphology on ultrasound is the third Rotterdam Criterion. However PCOS can be present even without visible cysts if other criteria are met.',
      riskStartIndex: 0,
    ),
  ];

  void _next() {
    if (_answers[_currentQ] == null) {
      // Skip — mark as -1
      _answers[_currentQ] = -1;
    }

    if (_currentQ < 4) {
      setState(() => _currentQ++);
    } else {
      _showResult();
    }
  }

  void _skip() {
    _answers[_currentQ] = -1;
    if (_currentQ < 4) {
      setState(() => _currentQ++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    // Calculate risk score
    int riskPoints = 0;
    for (int i = 0; i < 5; i++) {
      final ans = _answers[i];
      if (ans == null || ans == -1) continue;
      final q = _questions[i];
      if (ans >= q.riskStartIndex) {
        // Higher index = more risk (except Q3 where 0,1 are risk)
        if (i == 2) {
          // Weight: 0=yes(risk), 1=somewhat(risk), 2=no, 3=not tried
          if (ans <= 1) riskPoints += 2;
        } else if (i == 4) {
          // Hormones: 0=elevated(high risk), 1=cysts(high risk), 2=normal, 3=never
          if (ans <= 1) riskPoints += 2;
        } else {
          riskPoints += (ans >= 2) ? 2 : 1;
        }
      }
    }

    // Determine risk level
    String riskLevel;
    if (riskPoints >= 5) {
      riskLevel = 'high';
    } else if (riskPoints >= 3) {
      riskLevel = 'moderate';
    } else {
      riskLevel = 'low';
    }

    final answers = Map<int, String>.fromEntries(
      List.generate(5, (i) {
        final ans = _answers[i];
        if (ans == null || ans == -1) return MapEntry(i, 'Skipped');
        return MapEntry(i, _questions[i].options[ans]);
      }),
    );

    Get.off(() => PcosResultScreen(
          riskLevel: riskLevel,
          riskScore: riskPoints,
          answers: answers,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQ];
    final progress = (_currentQ + 1) / 5;

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
            Positioned(
              bottom: 140.h,
              left: -60.w,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleBg.withValues(alpha: 0.3),
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
                          onTap: () {
                            if (_currentQ > 0) {
                              setState(() => _currentQ--);
                            } else {
                              Get.back();
                            }
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: _dividerLine, width: 1.5),
                            ),
                            child: Center(
                              child: Icon(Icons.arrow_back_ios_new,
                                  size: 16.sp, color: _textDark),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius:
                                      BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${_currentQ + 1} / 5',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 28.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Condition tag
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(20.r),
                              border:
                                  Border.all(color: _radioBorder, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔬',
                                    style: TextStyle(fontSize: 14.sp)),
                                SizedBox(width: 7.w),
                                Text(
                                  'PCOS Screening · Rotterdam Criteria',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Question number
                          Text(
                            _currentQ < 4
                                ? 'Question ${_currentQ + 1} of 5'
                                : 'Question 5 of 5 — Last one!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Question text
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                                height: 1.35,
                              ),
                              children: [
                                TextSpan(text: q.questionText),
                                TextSpan(
                                  text: q.questionHighlight,
                                  style: const TextStyle(color: _green),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),

                          Text(
                            q.subtitle,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w300,
                              color: _textMuted,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // Options
                          ...List.generate(q.options.length, (i) {
                            final isSelected =
                                _answers[_currentQ] == i;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _answers[_currentQ] = i;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 150),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18.w, vertical: 16.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _optionSelBg
                                        : _optionBg,
                                    borderRadius:
                                        BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? _green
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.options[i],
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: _textDark,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? _green
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? _green
                                                : _radioBorder,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Icon(Icons.check,
                                                    size: 12.sp,
                                                    color: Colors.white),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Research note
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 13.w, vertical: 11.h),
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(12.r),
                              border:
                                  Border.all(color: _radioBorder, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('📋',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    q.researchNote,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.sp,
                                      color: _textSub,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
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
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  vertical: 17.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              _currentQ < 4
                                  ? 'Next →'
                                  : 'See my results →',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _skip,
                          child: Text(
                            'Skip this question',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
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
}
