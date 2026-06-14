import 'package:fitness_zone_2/data/api_provider/api_provider.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/widgets/onboarding_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class _Block {
  final String emoji;
  final String label;
  final String subtitle;
  final String value;

  const _Block({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.value,
  });
}

/// Shown as the last onboarding step OR standalone for existing users on first login.
///
/// When [onCompleted] is provided (onboarding flow), it is called with the
/// selected timeBlock after saving — the caller handles navigation.
/// When [onCompleted] is null (standalone), navigates to BottomBarScreen directly.
class TimePreferenceScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final void Function(String timeBlock)? onCompleted;

  const TimePreferenceScreen({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 1,
    this.onCompleted,
  });

  @override
  State<TimePreferenceScreen> createState() => _TimePreferenceScreenState();
}

class _TimePreferenceScreenState extends State<TimePreferenceScreen> {
  int _selectedIndex = 0;

  static const List<_Block> _blocks = [
    _Block(
      emoji: '🌅',
      label: 'Morning',
      subtitle: '6 AM – 11 AM, start the day strong',
      value: 'morning',
    ),
    _Block(
      emoji: '☀️',
      label: 'Afternoon',
      subtitle: '11 AM – 4 PM, midday energy boost',
      value: 'afternoon',
    ),
    _Block(
      emoji: '🌇',
      label: 'Evening',
      subtitle: '4 PM – 8 PM, unwind after work',
      value: 'evening',
    ),
    _Block(
      emoji: '🌙',
      label: 'Night',
      subtitle: '8 PM – 11 PM, late session crew',
      value: 'night',
    ),
  ];

  Future<void> _save(String timeBlock) async {
    final auth = Get.find<AuthController>();
    final prefs = auth.sharedPreferences;
    final token = prefs.getString(Constants.accessToken) ?? '';

    // Persist locally — must happen before onCompleted so updateUserDetails
    // sees hasTimeBlock = true and skips showing this screen again.
    prefs.setString(Constants.timeBlock, timeBlock);

    // Persist to backend (best-effort — don't block navigation on failure)
    try {
      final api = Get.find<ApiProvider>();
      await api.postData(
        '/users/notification_preferences',
        body: {'timeBlock': timeBlock},
        headers: {'accessToken': token},
      );
    } catch (_) {
      // Silent — local pref is source of truth on device
    }

    if (widget.onCompleted != null) {
      // Onboarding flow — caller handles navigation
      widget.onCompleted!(timeBlock);
    } else {
      // Standalone (existing user on first login after update)
      Get.offAll(() => BottomBarScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Notifications',
      questionLine1: 'When do you like',
      questionLine2: 'to work out?',
      subtitle: "We'll only notify you about classes\nduring your preferred time",
      onBack: () => _save('all'), // skip = all if they go back
      buttonText: "Let's go →",
      onNext: () => _save(_blocks[_selectedIndex].value),
      onSkip: () => _save('all'),
      skipText: 'Skip — notify me about all classes',
      body: Column(
        children: List.generate(_blocks.length, (i) {
          final block = _blocks[i];
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
                    Text(block.emoji, style: TextStyle(fontSize: 26.sp)),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            block.label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: OnboardingScaffold.textDark,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            block.subtitle,
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
                    // Radio
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
