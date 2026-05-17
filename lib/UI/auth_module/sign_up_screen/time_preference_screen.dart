import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/onboarding_scaffold.dart';

class _TimeOption {
  final String emoji;
  final String title;
  final String subtitle;

  const _TimeOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class TimePreferenceScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final String? initialValue;
  final void Function(String timePreference) onNext;

  const TimePreferenceScreen({
    Key? key,
    this.currentStep = 6,
    this.totalSteps = 8,
    this.initialValue,
    required this.onNext,
  }) : super(key: key);

  @override
  State<TimePreferenceScreen> createState() => _TimePreferenceScreenState();
}

class _TimePreferenceScreenState extends State<TimePreferenceScreen> {
  int _selectedIndex = 0;

  static const List<_TimeOption> _options = [
    _TimeOption(
      emoji: '🌅',
      title: 'Morning',
      subtitle: 'Early bird energy boost',
    ),
    _TimeOption(
      emoji: '☀️',
      title: 'Afternoon',
      subtitle: 'Midday power session',
    ),
    _TimeOption(
      emoji: '🌆',
      title: 'Evening',
      subtitle: 'Wind down with movement',
    ),
    _TimeOption(
      emoji: '🤷',
      title: 'No preference',
      subtitle: 'Flexible with my schedule',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final idx = _options.indexWhere(
        (o) => o.title.toLowerCase() == widget.initialValue!.toLowerCase(),
      );
      if (idx != -1) _selectedIndex = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Your routine',
      questionLine1: "What time",
      questionLine2: 'suits you?',
      subtitle: "We'll schedule recommendations around your preference",
      buttonText: 'Done ✓',
      onNext: () => widget.onNext(_options[_selectedIndex].title),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          ...List.generate(_options.length, (i) {
            final option = _options[i];
            final isSelected = _selectedIndex == i;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 18.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? OnboardingScaffold.optionSelectedBg
                        : OnboardingScaffold.optionBg,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected
                          ? OnboardingScaffold.green
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(option.emoji,
                          style: TextStyle(fontSize: 26.sp)),
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
                                color: OnboardingScaffold.textDark,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              option.subtitle,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300,
                                color: OnboardingScaffold.textMuted,
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
                              ? OnboardingScaffold.green
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? OnboardingScaffold.green
                                : OnboardingScaffold.radioBorder,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Icon(Icons.check,
                                    size: 14.sp, color: Colors.white),
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
    );
  }
}
