import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/onboarding_scaffold.dart';

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
  final bool showBackButton;

  const GoalScreen({
    Key? key,
    this.currentStep = 1,
    this.totalSteps = 5,
    this.initialGoal,
    required this.onNext,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  static const Color _green = Color(0xFF6DC55A);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textMuted = Color(0xFF9AB09A);
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
      emoji: '🥑',
      title: 'Gain weight',
      subtitle: 'Healthy calorie surplus, nutrition guidance',
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
    return OnboardingScaffold(
      showBackButton: widget.showBackButton,
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      questionLine1: "What's your",
      questionLine2: 'main goal?',
      subtitle: "We'll personalise your entire\nexperience around this",
      caption: 'You can always change this later',
      onNext: () {
        widget.onNext(_options[_selectedIndex].title);
      },
      body: Column(
        children: List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = _selectedIndex == i;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _optionSelectedBg
                      : _optionBg,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: isSelected
                        ? _green
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      option.emoji,
                      style: TextStyle(fontSize: 26.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
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
