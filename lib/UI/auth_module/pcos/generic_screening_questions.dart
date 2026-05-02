import 'package:fitness_zone_2/data/Repos/home_repo/home_repo.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'generic_screening_result.dart';
import 'screening_data.dart';

class GenericScreeningQuestions extends StatefulWidget {
  final ScreeningConfig config;

  const GenericScreeningQuestions({Key? key, required this.config})
      : super(key: key);

  @override
  State<GenericScreeningQuestions> createState() =>
      _GenericScreeningQuestionsState();
}

class _GenericScreeningQuestionsState
    extends State<GenericScreeningQuestions> {
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
  late final List<int?> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.config.questions.length, null);
  }

  int get _totalQ => widget.config.questions.length;

  void _next() {
    if (_answers[_currentQ] == null) _answers[_currentQ] = -1;
    if (_currentQ < _totalQ - 1) {
      setState(() => _currentQ++);
    } else {
      _showResult();
    }
  }

  void _skip() {
    _answers[_currentQ] = -1;
    if (_currentQ < _totalQ - 1) {
      setState(() => _currentQ++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    int riskPoints = 0;
    for (int i = 0; i < _totalQ; i++) {
      final ans = _answers[i];
      if (ans == null || ans == -1) continue;
      final q = widget.config.questions[i];
      if (q.riskOptionIndices.contains(ans)) {
        riskPoints += 2;
      }
    }

    String riskLevel;
    if (riskPoints >= widget.config.highThreshold) {
      riskLevel = 'high';
    } else if (riskPoints >= widget.config.moderateThreshold) {
      riskLevel = 'moderate';
    } else {
      riskLevel = 'low';
    }

    final answersMap = <String, String>{};
    for (int i = 0; i < _totalQ; i++) {
      final ans = _answers[i];
      if (ans == null || ans == -1) {
        answersMap[i.toString()] = 'Skipped';
      } else {
        answersMap[i.toString()] = widget.config.questions[i].options[ans];
      }
    }

    // Save to backend
    final token = Get.find<AuthController>()
        .sharedPreferences
        .getString(Constants.accessToken) ?? '';
    Get.find<HomeRepo>().saveHealthScreening(
      accessToken: token,
      body: {
        'conditionType': widget.config.conditionType,
        'riskLevel': riskLevel,
        'riskScore': riskPoints,
        'answers': answersMap,
      },
    );

    // If high risk, auto-add to health conditions locally
    if (riskLevel == 'high' || riskLevel == 'moderate') {
      final auth = Get.find<AuthController>();
      final current = auth.healthConditions.value;
      final condition = widget.config.conditionType;
      if (!current.contains(condition)) {
        auth.healthConditions.value =
            current.isEmpty ? condition : '$current,$condition';
      }
    }

    Get.off(() => GenericScreeningResult(
          config: widget.config,
          riskLevel: riskLevel,
          riskScore: riskPoints,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.config.questions[_currentQ];
    final progress = (_currentQ + 1) / _totalQ;
    final isLast = _currentQ == _totalQ - 1;

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleBg.withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 140.h, left: -60.w,
              child: Container(
                width: 180.w, height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleBg.withValues(alpha: 0.3),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Nav
                  Padding(
                    padding: EdgeInsets.only(left: 28.w, right: 28.w, top: 14.h),
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
                            width: 40.w, height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: _dividerLine, width: 1.5),
                            ),
                            child: Center(child: Icon(Icons.arrow_back_ios_new, size: 16.sp, color: _textDark)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 4.h,
                            decoration: BoxDecoration(color: _circleBg, borderRadius: BorderRadius.circular(2.r)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2.r)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text('${_currentQ + 1} / $_totalQ',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, fontWeight: FontWeight.w600, color: _textMuted)),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Condition tag
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: _radioBorder, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.config.intro.emoji, style: TextStyle(fontSize: 14.sp)),
                                SizedBox(width: 7.w),
                                Text(widget.config.conditionTag,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11.sp, fontWeight: FontWeight.w600, color: _textSub)),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Text(
                            isLast ? 'Question $_totalQ of $_totalQ — Last one!' : 'Question ${_currentQ + 1} of $_totalQ',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp, fontWeight: FontWeight.w700, color: _textMuted),
                          ),
                          SizedBox(height: 8.h),

                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 22.sp, fontWeight: FontWeight.w700, color: _textDark, height: 1.35),
                              children: [
                                TextSpan(text: q.questionText),
                                TextSpan(text: q.questionHighlight, style: const TextStyle(color: _green)),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(q.subtitle,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.w300, color: _textMuted, height: 1.6)),
                          SizedBox(height: 32.h),

                          // Options
                          ...List.generate(q.options.length, (i) {
                            final isSel = _answers[_currentQ] == i;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: GestureDetector(
                                onTap: () => setState(() => _answers[_currentQ] = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                                  decoration: BoxDecoration(
                                    color: isSel ? _optionSelBg : _optionBg,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(color: isSel ? _green : Colors.transparent, width: 2),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(q.options[i],
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: 15.sp, fontWeight: FontWeight.w500, color: _textDark))),
                                      Container(
                                        width: 22.w, height: 22.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSel ? _green : Colors.transparent,
                                          border: Border.all(color: isSel ? _green : _radioBorder, width: 2),
                                        ),
                                        child: isSel ? Center(child: Icon(Icons.check, size: 12.sp, color: Colors.white)) : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Research note
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: _radioBorder, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📋', style: TextStyle(fontSize: 13.sp)),
                                SizedBox(width: 8.w),
                                Expanded(child: Text(q.researchNote,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 10.sp, color: _textSub, height: 1.5))),
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
                              backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 17.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            ),
                            child: Text(isLast ? 'See my results →' : 'Next →',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        TextButton(
                          onPressed: _skip,
                          child: Text('Skip this question',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp, fontWeight: FontWeight.w500, color: _textMuted)),
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
