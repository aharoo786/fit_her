import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../widgets/onboarding_scaffold.dart';

class CycleDataScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final void Function(Map<String, dynamic> cycleData) onContinue;
  final void Function() onSkip;

  const CycleDataScreen({
    Key? key,
    this.currentStep = 3,
    this.totalSteps = 8,
    required this.onContinue,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<CycleDataScreen> createState() => _CycleDataScreenState();
}

class _CycleDataScreenState extends State<CycleDataScreen> {
  DateTime _selectedDate = DateTime.now();
  double _cycleLength = 28;
  String? _periodDuration = '3–5 days';
  String? _flowType = 'Moderate';
  String? _isRegular = '✓ Yes';

  Map<String, dynamic> get cycleData => {
        'lastPeriodDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'averageCycleLength': _cycleLength.round(),
        'isRegular': _isRegular == '✓ Yes'
            ? 'yes'
            : _isRegular == '✗ No'
                ? 'no'
                : 'not sure',
        'periodDuration': _periodDuration,
        'flowType': _flowType,
        'dataProvided': 1,
      };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(days: 60));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: earliest,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: OnboardingScaffold.green,
              onPrimary: Colors.white,
              onSurface: OnboardingScaffold.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Your cycle',
      questionLine1: 'Tell us about',
      questionLine2: 'your cycle',
      subtitle:
          'This powers your hormonal intelligence and phase tracking',
      onNext: () => widget.onContinue(cycleData),
      onSkip: widget.onSkip,
      skipText: 'Skip any question — update anytime',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Q1: Last period date ──
          OnboardingScaffold.buildLabel(
              'When did your ', 'last period', ' start?'),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 18.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: OnboardingScaffold.optionBg,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                    color: OnboardingScaffold.radioBorder, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy')
                            .format(_selectedDate),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: OnboardingScaffold.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Tap to change',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: OnboardingScaffold.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text('📅', style: TextStyle(fontSize: 20.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Q2: Cycle length slider ──
          OnboardingScaffold.buildLabel('Average ', 'cycle length?'),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: OnboardingScaffold.optionBg,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${_cycleLength.round()}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: OnboardingScaffold.textDark,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'days',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            color: OnboardingScaffold.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '21 — 35 days',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: OnboardingScaffold.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: OnboardingScaffold.green,
                    inactiveTrackColor: OnboardingScaffold.radioBorder,
                    thumbColor: OnboardingScaffold.green,
                    overlayColor:
                        OnboardingScaffold.green.withValues(alpha: 0.15),
                    trackHeight: 6.h,
                    thumbShape: _GreenThumb(),
                  ),
                  child: Slider(
                    value: _cycleLength,
                    min: 21,
                    max: 35,
                    divisions: 14,
                    onChanged: (v) => setState(() => _cycleLength = v),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Center(
              child: Text(
                'Not sure? Leave at 28 — the average',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: OnboardingScaffold.radioBorder,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Q3: Period duration ──
          OnboardingScaffold.buildLabel(
              'How long does it ', 'usually last?'),
          SizedBox(height: 10.h),
          OnboardingScaffold.buildPillRow(
            options: const ['1–2 days', '3–5 days', '6–7 days', '7+ days'],
            selected: _periodDuration,
            onSelect: (v) => setState(() => _periodDuration = v),
          ),
          SizedBox(height: 20.h),

          // ── Q4: Flow type ──
          OnboardingScaffold.buildLabel(
              'How would you describe your ', 'flow?'),
          SizedBox(height: 10.h),
          OnboardingScaffold.buildPillRow(
            options: const ['Light', 'Moderate', 'Heavy', 'Irregular'],
            selected: _flowType,
            onSelect: (v) => setState(() => _flowType = v),
          ),
          SizedBox(height: 20.h),

          // ── Q5: Regular? ──
          OnboardingScaffold.buildLabel(
              'Are your cycles ', 'regular?'),
          SizedBox(height: 10.h),
          OnboardingScaffold.buildYesNoRow(
            options: const ['✓ Yes', '✗ No', '🤷 Not sure'],
            selected: _isRegular,
            onSelect: (v) => setState(() => _isRegular = v),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

/// Custom slider thumb matching S05 HTML: 24px circle, green, white border, shadow.
class _GreenThumb extends SliderComponentShape {
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

    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      12,
      Paint()
        ..color = OnboardingScaffold.green.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // White border
    canvas.drawCircle(
      center,
      12,
      Paint()..color = Colors.white,
    );

    // Green fill
    canvas.drawCircle(
      center,
      9,
      Paint()..color = OnboardingScaffold.green,
    );
  }
}
