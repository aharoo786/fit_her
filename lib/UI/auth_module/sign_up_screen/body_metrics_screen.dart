import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/onboarding_scaffold.dart';

/// Combined onboarding screen collecting Age, Weight, and Height on a single page (Step 2/5).
class BodyMetricsScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final int initialAge;
  final double initialWeight;
  final double initialHeight;
  final void Function(int age, double weight, double height) onNext;

  const BodyMetricsScreen({
    Key? key,
    this.currentStep = 2,
    this.totalSteps = 5,
    this.initialAge = 25,
    this.initialWeight = 55,
    this.initialHeight = 5.4,
    required this.onNext,
  }) : super(key: key);

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  late double _age;
  late double _weight;
  late double _height;

  @override
  void initState() {
    super.initState();
    _age = widget.initialAge.toDouble().clamp(18.0, 70.0);
    _weight = widget.initialWeight.clamp(30.0, 150.0);
    _height = widget.initialHeight.clamp(3.0, 7.0);
  }

  String get _displayHeight {
    final feet = _height.floor();
    final inches = ((_height - feet) * 12).round();
    return "$feet' $inches\"";
  }

  double get _bmi {
    final heightInMeters = _height * 0.3048;
    if (heightInMeters <= 0) return 0;
    return _weight / (heightInMeters * heightInMeters);
  }

  String get _bmiCategory {
    final b = _bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Healthy weight';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      questionLine1: 'Tell us about',
      questionLine2: 'your body',
      subtitle: "We'll tailor your calorie targets and workout intensity using these metrics",
      caption: 'You can always update these anytime in your profile',
      onNext: () => widget.onNext(_age.round(), _weight, _height),
      body: Column(
        children: [
          // ── Age Card ──
          _buildMetricCard(
            emoji: '🎂',
            label: 'Age',
            valueText: '${_age.round()}',
            unitText: 'years old',
            sliderValue: _age,
            min: 18,
            max: 70,
            divisions: 52,
            minLabel: '18 yrs',
            maxLabel: '70 yrs',
            onChanged: (v) => setState(() => _age = v),
          ),
          SizedBox(height: 14.h),

          // ── Weight Card ──
          _buildMetricCard(
            emoji: '⚖️',
            label: 'Weight',
            valueText: '${_weight.round()}',
            unitText: 'kg',
            sliderValue: _weight,
            min: 30,
            max: 150,
            divisions: 120,
            minLabel: '30 kg',
            maxLabel: '150 kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
          SizedBox(height: 14.h),

          // ── Height Card ──
          _buildMetricCard(
            emoji: '📏',
            label: 'Height',
            valueText: _displayHeight,
            unitText: 'ft',
            sliderValue: _height,
            min: 3.0,
            max: 7.0,
            divisions: 48,
            minLabel: "3' 0\"",
            maxLabel: "7' 0\"",
            onChanged: (v) => setState(() => _height = v),
          ),
          SizedBox(height: 16.h),

          // ── Live BMI Preview Card ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: OnboardingScaffold.optionSelectedBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: OnboardingScaffold.green.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 8.w),
                    Text(
                      'Est. BMI: ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: OnboardingScaffold.textDark,
                      ),
                    ),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: OnboardingScaffold.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: OnboardingScaffold.circleBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _bmiCategory,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: OnboardingScaffold.textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String emoji,
    required String label,
    required String valueText,
    required String unitText,
    required double sliderValue,
    required double min,
    required double max,
    required int divisions,
    required String minLabel,
    required String maxLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: OnboardingScaffold.optionBg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: TextStyle(fontSize: 18.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: OnboardingScaffold.textDark,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valueText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: OnboardingScaffold.green,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    unitText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: OnboardingScaffold.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: OnboardingScaffold.green,
              inactiveTrackColor: OnboardingScaffold.radioBorder,
              thumbColor: OnboardingScaffold.green,
              overlayColor: OnboardingScaffold.green.withValues(alpha: 0.15),
              trackHeight: 5.h,
              thumbShape: _OnboardingThumb(),
            ),
            child: Slider(
              value: sliderValue,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: OnboardingScaffold.textMuted,
                  ),
                ),
                Text(
                  maxLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: OnboardingScaffold.textMuted,
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

class _OnboardingThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(22, 22);

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
      11,
      Paint()
        ..color = OnboardingScaffold.green.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, 11, Paint()..color = Colors.white);
    canvas.drawCircle(center, 8, Paint()..color = OnboardingScaffold.green);
  }
}
