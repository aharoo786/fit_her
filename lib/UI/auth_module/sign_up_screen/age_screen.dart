import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/onboarding_scaffold.dart';

class AgeScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final int initialValue;
  final void Function(int age) onNext;

  const AgeScreen({
    Key? key,
    this.currentStep = 2,
    this.totalSteps = 8,
    this.initialValue = 25,
    required this.onNext,
  }) : super(key: key);

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  late double _age;

  @override
  void initState() {
    super.initState();
    _age = widget.initialValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'About you',
      questionLine1: "Let's get your",
      questionLine2: 'age',
      subtitle: 'This helps us tailor workouts and nutrition to your body',
      onNext: () => widget.onNext(_age.round()),
      body: Column(
        children: [
          SizedBox(height: 40.h),

          // Large value display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _age.round().toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 64.sp,
                  fontWeight: FontWeight.w700,
                  color: OnboardingScaffold.textDark,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'years old',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w300,
                  color: OnboardingScaffold.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // Slider
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 18.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: OnboardingScaffold.optionBg,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '18',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: OnboardingScaffold.textMuted,
                      ),
                    ),
                    Text(
                      '70',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: OnboardingScaffold.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: OnboardingScaffold.green,
                    inactiveTrackColor: OnboardingScaffold.radioBorder,
                    thumbColor: OnboardingScaffold.green,
                    overlayColor:
                        OnboardingScaffold.green.withValues(alpha: 0.15),
                    trackHeight: 6.h,
                    thumbShape: _OnboardingThumb(),
                  ),
                  child: Slider(
                    value: _age,
                    min: 18,
                    max: 70,
                    divisions: 52,
                    onChanged: (v) => setState(() => _age = v),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

class _OnboardingThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center + const Offset(0, 2),
      12,
      Paint()
        ..color = OnboardingScaffold.green.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, 12, Paint()..color = Colors.white);
    canvas.drawCircle(center, 9, Paint()..color = OnboardingScaffold.green);
  }
}
