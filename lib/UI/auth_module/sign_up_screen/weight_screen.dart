import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/onboarding_scaffold.dart';

class WeightScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final double initialValue;
  final void Function(double weight) onNext;

  const WeightScreen({
    Key? key,
    this.currentStep = 4,
    this.totalSteps = 8,
    this.initialValue = 55,
    required this.onNext,
  }) : super(key: key);

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  late double _weight;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Your body',
      questionLine1: "Let's get your",
      questionLine2: 'weight',
      subtitle: 'This helps us calculate your BMI and personalise plans',
      onNext: () => widget.onNext(_weight),
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
                _weight.round().toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 64.sp,
                  fontWeight: FontWeight.w700,
                  color: OnboardingScaffold.textDark,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'kg',
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
                      '30 kg',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: OnboardingScaffold.textMuted,
                      ),
                    ),
                    Text(
                      '150 kg',
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
                    value: _weight,
                    min: 30,
                    max: 150,
                    divisions: 120,
                    onChanged: (v) => setState(() => _weight = v),
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
