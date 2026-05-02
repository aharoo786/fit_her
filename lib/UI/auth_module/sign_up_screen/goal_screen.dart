import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GoalOption {
  final String emoji;
  final String title;
  final String subtitle;

  const GoalOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class GoalScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final String? initialGoal;
  final void Function(String selectedGoal) onNext;

  const GoalScreen({
    Key? key,
    this.currentStep = 1,
    this.totalSteps = 8,
    this.initialGoal,
    required this.onNext,
  }) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  // ── Exact colors from S03_Final.html ──
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _circleBg = Color(0xFFEAF7E4);
  static const Color _green = Color(0xFF6DC55A);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF5A7A56);
  static const Color _textMuted = Color(0xFF9AB09A);
  static const Color _dividerLine = Color(0xFFD8EDD4);
  static const Color _optionBg = Color(0xFFEAF7E4);
  static const Color _optionSelectedBg = Color(0xFFF0FBEE);
  static const Color _radioBorder = Color(0xFFC8E8C0);

  int _selectedIndex = 0;

  static const List<GoalOption> _options = [
    GoalOption(
      emoji: '⚖️',
      title: 'Lose weight',
      subtitle: 'Calorie tracking, fat burn classes',
    ),
    GoalOption(
      emoji: '💪',
      title: 'Build strength & tone',
      subtitle: 'Resistance training, body recomposition',
    ),
    GoalOption(
      emoji: '🏃',
      title: 'Improve fitness',
      subtitle: 'Cardio, stamina, daily energy',
    ),
    GoalOption(
      emoji: '🧘',
      title: 'Reduce stress',
      subtitle: 'Yoga, mindfulness, wellness',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialGoal != null && widget.initialGoal!.isNotEmpty) {
      final idx = _options.indexWhere(
        (o) => o.title.toLowerCase() == widget.initialGoal!.toLowerCase(),
      );
      if (idx != -1) _selectedIndex = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // ── Background circles (exact from HTML) ──
            // c1: 300x300, top:-100, right:-80
            Positioned(
              top: -100.h,
              right: -80.w,
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleBg,
                ),
              ),
            ),
            // c2: 200x200, bottom:80, left:-70
            Positioned(
              bottom: 80.h,
              left: -70.w,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleBg,
                ),
              ),
            ),

            // ── Content ──
            SafeArea(
              child: Column(
                children: [
                  // ── Nav row: padding 16px 28px 0 ──
                  Padding(
                    padding: EdgeInsets.only(
                        left: 28.w, right: 28.w, top: 16.h),
                    child: Row(
                      children: [
                        // Back button: 40x40, border 1.5px #D8EDD4
                        GestureDetector(
                          onTap: () => Get.back(),
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
                        // Progress bar: 4px height, #EAF7E4 bg, #6DC55A fill
                        Expanded(
                          child: Container(
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  widget.currentStep / widget.totalSteps,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Step count: 12px w600 #9ab09a
                        Text(
                          '${widget.currentStep} / ${widget.totalSteps}',
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

                  // ── Body: padding 32px 28px ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step badge: bg #EAF7E4, radius 20, padding 6px 14px
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _circleBg,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 7px green dot
                                Container(
                                  width: 7.w,
                                  height: 7.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _green,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                // 11px w600 #5A7A56
                                Text(
                                  'Your goal',
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
                          // margin-bottom: 24px
                          SizedBox(height: 24.h),

                          // Question: 26px w700 #163220, em = #6DC55A
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                                height: 1.3,
                              ),
                              children: const [
                                TextSpan(text: "What's your\n"),
                                TextSpan(
                                  text: 'main goal?',
                                  style: TextStyle(color: _green),
                                ),
                              ],
                            ),
                          ),
                          // margin-bottom: 8px
                          SizedBox(height: 8.h),

                          // Subtitle: 14px w300 #9ab09a, mb 36
                          Text(
                            "We'll personalise your entire\nexperience around this",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                              color: _textMuted,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 36.h),

                          // ── Options ──
                          ...List.generate(_options.length, (i) {
                            final option = _options[i];
                            final isSelected = _selectedIndex == i;
                            return Padding(
                              // margin-bottom: 12px
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedIndex = i);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  // padding: 18px 20px
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 18.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _optionSelectedBg
                                        : _optionBg,
                                    // border-radius: 18px
                                    borderRadius:
                                        BorderRadius.circular(18.r),
                                    // border: 2px solid transparent / #6DC55A
                                    border: Border.all(
                                      color: isSelected
                                          ? _green
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Emoji: 26px
                                      Text(
                                        option.emoji,
                                        style: TextStyle(fontSize: 26.sp),
                                      ),
                                      // gap: 14px
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // title: 16px w600 #163220
                                            Text(
                                              option.title,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: _textDark,
                                              ),
                                            ),
                                            // sub: 12px #9ab09a w300, mt 2
                                            SizedBox(height: 2.h),
                                            Text(
                                              option.subtitle,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w300,
                                                color: _textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Radio: 24x24, border 2px #C8E8C0
                                      Container(
                                        width: 24.w,
                                        height: 24.w,
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
                                                child: CustomPaint(
                                                  size: Size(12.w, 12.w),
                                                  painter: _CheckPainter(),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom: padding 0 28px 40px ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 40.h),
                    child: Column(
                      children: [
                        // Button: radius 16, padding 17, 16px w600
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onNext(
                                  _options[_selectedIndex].title);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 17.h),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              'Next →',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.01 * 16.sp,
                              ),
                            ),
                          ),
                        ),
                        // note: 12px #9ab09a, mt 10
                        SizedBox(height: 10.h),
                        Text(
                          'You can always change this later',
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
}

/// Custom check mark painter matching the HTML SVG:
/// <path d="M2 6l2.5 3L10 3" stroke="white" stroke-width="1.8"
///   stroke-linecap="round" stroke-linejoin="round"/>
class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final sx = size.width / 12;
    final sy = size.height / 12;

    final path = Path()
      ..moveTo(2 * sx, 6 * sy)
      ..lineTo(4.5 * sx, 9 * sy)
      ..lineTo(10 * sx, 3 * sy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
