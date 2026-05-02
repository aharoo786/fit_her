import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/onboarding_scaffold.dart';
import '../pcos/generic_screening_intro.dart';
import '../pcos/pcos_config.dart';
import '../pcos/thyroid_config.dart';
import '../pcos/menopause_config.dart';
import '../pcos/postpartum_config.dart';
import '../pcos/endometriosis_config.dart';
import '../pcos/screening_data.dart';

class _Condition {
  final String emoji;
  final String label;

  const _Condition(this.emoji, this.label);
}

class HealthConditionsScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final String? initialConditions;
  final void Function(String selectedConditions) onNext;

  const HealthConditionsScreen({
    Key? key,
    this.currentStep = 2,
    this.totalSteps = 8,
    this.initialConditions,
    required this.onNext,
  }) : super(key: key);

  @override
  State<HealthConditionsScreen> createState() =>
      _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  static const List<_Condition> _conditions = [
    _Condition('🔬', 'PCOS'),
    _Condition('🤱', 'Postpartum'),
    _Condition('🦋', 'Thyroid'),
    _Condition('🌸', 'Menopause'),
    _Condition('🦴', 'Arthritis'),
    _Condition('🩸', 'Endometriosis'),
    _Condition('💉', 'Diabetes'),
  ];

  final Set<String> _selected = {};
  bool _noneSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialConditions != null &&
        widget.initialConditions!.isNotEmpty) {
      if (widget.initialConditions == 'none') {
        _noneSelected = true;
      } else {
        _selected.addAll(widget.initialConditions!.split(','));
      }
    }
  }

  void _toggleChip(String label) {
    setState(() {
      _noneSelected = false;
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  void _toggleNone() {
    setState(() {
      _selected.clear();
      _noneSelected = !_noneSelected;
    });
  }

  String get _result {
    if (_noneSelected) return 'none';
    if (_selected.isEmpty) return '';
    return _selected.join(',');
  }

  static final Map<String, ScreeningConfig> _screeningConfigs = {
    'PCOS': pcosConfig,
    'Thyroid': thyroidConfig,
    'Menopause': menopauseConfig,
    'Postpartum': postpartumConfig,
    'Endometriosis': endometriosisConfig,
  };

  ScreeningConfig? _getScreeningConfig() {
    // Find first selected condition that has a screening
    for (final label in _selected) {
      if (_screeningConfigs.containsKey(label)) {
        return _screeningConfigs[label];
      }
    }
    // Default to PCOS screening
    return pcosConfig;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Health conditions',
      questionLine1: 'Are you managing',
      questionLine2: 'any conditions?',
      subtitle:
          "Select all that apply — we'll personalise your program, diet plan and symptom tracking around each one",
      onNext: () => widget.onNext(_result),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Condition chips (multi-select) ──
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _conditions.map((c) {
              final isSel = _selected.contains(c.label);
              return GestureDetector(
                onTap: () => _toggleChip(c.label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSel
                        ? OnboardingScaffold.optionSelectedBg
                        : OnboardingScaffold.optionBg,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: isSel
                          ? OnboardingScaffold.green
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.emoji, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 8.w),
                      Text(
                        c.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          fontWeight:
                              isSel ? FontWeight.w600 : FontWeight.w500,
                          color: OnboardingScaffold.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),

          // ── Divider ──
          Row(
            children: [
              Expanded(
                  child: Container(
                      height: 1, color: OnboardingScaffold.circleBg)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'not sure if you have a condition?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: OnboardingScaffold.textMuted,
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                      height: 1, color: OnboardingScaffold.circleBg)),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Symptom checker card ──
          GestureDetector(
            onTap: () {
              // Navigate to screening for the first selected condition, or PCOS by default
              final config = _getScreeningConfig();
              if (config != null) {
                Get.to(() => GenericScreeningIntro(config: config));
              }
            },
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: OnboardingScaffold.optionBg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: OnboardingScaffold.green, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: OnboardingScaffold.green,
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: Center(
                          child: Text('🔍',
                              style: TextStyle(fontSize: 20.sp)),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check my symptoms',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: OnboardingScaffold.textDark,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Answer 5 quick questions and we'll tell you if your symptoms suggest a hormonal condition",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300,
                                color: OnboardingScaffold.textSub,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Tags
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      'Irregular periods',
                      'Fatigue',
                      'Weight gain',
                      'Hair growth',
                      'Acne'
                    ]
                        .map((tag) => Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 11.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: OnboardingScaffold.textSub,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── None of these apply ──
          GestureDetector(
            onTap: _toggleNone,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                  horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _noneSelected
                    ? const Color(0xFFF8FDF6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _noneSelected
                      ? OnboardingScaffold.green
                      : OnboardingScaffold.dividerLine,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'None of these apply',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: OnboardingScaffold.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "I don't have any diagnosed conditions",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.sp,
                          color: OnboardingScaffold.textMuted,
                        ),
                      ),
                    ],
                  ),
                  // Radio
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _noneSelected
                          ? OnboardingScaffold.green
                          : Colors.transparent,
                      border: Border.all(
                        color: _noneSelected
                            ? OnboardingScaffold.green
                            : OnboardingScaffold.dividerLine,
                        width: 2,
                      ),
                    ),
                    child: _noneSelected
                        ? Center(
                            child: Icon(Icons.check,
                                size: 12.sp, color: Colors.white),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Note
          Center(
            child: Text(
              'You can update this anytime in your profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                color: OnboardingScaffold.textMuted,
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
