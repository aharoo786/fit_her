import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/onboarding_scaffold.dart';
import '../../../widgets/toasts.dart';
import 'goal_screen.dart';
import 'sign_up_screen_questions.dart';

/// Screens that follow signup step 5 ("Which of these fits you right now?"):
///   * PregnancyDetailsScreen     "I'm pregnant": due date (or not sure)
///   * PostpartumDetailsScreen    "I recently had a baby": birth date + delivery
///   * DoctorClearanceScreen      waiting time over, "my doctor cleared me" tick
///   * LifeStageComingSoonScreen  pregnant, or still inside the waiting time
///
/// Access rules live on the backend (helper/lifeStage.js) so the waiting
/// times can change from .env without an app release.

/// Restart signup from the goal step (used by "Change my answer" and when
/// a new mother comes back after her waiting time).
void restartSignupFlow() {
  Get.offAll(() => GoalScreen(
        onNext: (goal) =>
            Get.to(() => SignUpScreenQuestions(selectedGoal: goal)),
      ));
}

String _niceDate(String? ymd) {
  if (ymd == null) return '';
  try {
    return DateFormat('d MMMM yyyy').format(DateTime.parse(ymd));
  } catch (_) {
    return ymd;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// "When is your baby due?" (pregnant)
// ─────────────────────────────────────────────────────────────────────────

class PregnancyDetailsScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Map<String, dynamic>? initial;
  final void Function(Map<String, dynamic> result) onSaved;

  const PregnancyDetailsScreen({
    Key? key,
    this.currentStep = 5,
    this.totalSteps = 8,
    this.initial,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<PregnancyDetailsScreen> createState() => _PregnancyDetailsScreenState();
}

class _PregnancyDetailsScreenState extends State<PregnancyDetailsScreen> {
  DateTime? _due;
  bool _notSure = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initial?['dueDate'];
    if (d is String) _due = DateTime.tryParse(d);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now.add(const Duration(days: 120)),
      firstDate: now.subtract(const Duration(days: 28)),
      lastDate: now.add(const Duration(days: 300)),
      helpText: 'When is your baby due?',
    );
    if (picked != null) {
      setState(() {
        _due = picked;
        _notSure = false;
      });
    }
  }

  Future<void> _next() async {
    if (_saving) return;
    if (_due == null && !_notSure) {
      CustomToast.failToast(msg: "Please pick your due date, or tap I'm not sure");
      return;
    }
    setState(() => _saving = true);
    final res = await Get.find<ConsultationController>().saveLifeStage({
      'status': 'pregnant',
      'dueDate': _notSure ? null : DateFormat('yyyy-MM-dd').format(_due!),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (res != null) widget.onSaved(res);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Your body',
      questionLine1: 'Congratulations!',
      questionLine2: 'When is your baby due?',
      subtitle: "We'll check in with you after your baby arrives.",
      buttonText: _saving ? 'Saving…' : 'Next →',
      onNext: _next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingScaffold.buildLabel('Your ', 'due date'),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: OnboardingScaffold.optionBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _due == null
                              ? 'Choose a date'
                              : DateFormat('MMMM d, yyyy').format(_due!),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _due == null
                                ? OnboardingScaffold.textMuted
                                : OnboardingScaffold.textDark,
                          ),
                        ),
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
                  ),
                  Text('📅', style: TextStyle(fontSize: 20.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _ChoiceCard(
            emoji: '🤍',
            title: "I'm not sure yet",
            subtitle: 'You can add it later',
            selected: _notSure,
            onTap: () => setState(() {
              _notSure = !_notSure;
              if (_notSure) _due = null;
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// "Tell us about your baby"
// ─────────────────────────────────────────────────────────────────────────

class PostpartumDetailsScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Map<String, dynamic>? initial;
  final void Function(Map<String, dynamic> result) onSaved;

  const PostpartumDetailsScreen({
    Key? key,
    this.currentStep = 5,
    this.totalSteps = 8,
    this.initial,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<PostpartumDetailsScreen> createState() =>
      _PostpartumDetailsScreenState();
}

class _PostpartumDetailsScreenState extends State<PostpartumDetailsScreen> {
  DateTime? _birth;
  String? _delivery; // normal | c_section
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.initial?['babyBirthDate'];
    if (b is String) _birth = DateTime.tryParse(b);
    final d = widget.initial?['deliveryType'];
    if (d == 'normal' || d == 'c_section') _delivery = d;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? now,
      firstDate: DateTime(now.year - 2, now.month, now.day),
      lastDate: now,
      helpText: 'When was your baby born?',
    );
    if (picked != null) setState(() => _birth = picked);
  }

  Future<void> _next() async {
    if (_saving) return;
    if (_birth == null) {
      CustomToast.failToast(msg: "Please pick your baby's birth date");
      return;
    }
    if (_delivery == null) {
      CustomToast.failToast(msg: 'Please choose how your baby was delivered');
      return;
    }
    setState(() => _saving = true);
    final res = await Get.find<ConsultationController>().saveLifeStage({
      'status': 'postpartum',
      'babyBirthDate': DateFormat('yyyy-MM-dd').format(_birth!),
      'deliveryType': _delivery,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (res != null) widget.onSaved(res);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Your body',
      questionLine1: 'Congratulations!',
      questionLine2: 'Tell us about your baby',
      subtitle: "So we know when it's safe for you to start classes.",
      buttonText: _saving ? 'Saving…' : 'Next →',
      onNext: _next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingScaffold.buildLabel('When was your ', 'baby born?'),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: OnboardingScaffold.optionBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _birth == null
                              ? 'Choose a date'
                              : DateFormat('MMMM d, yyyy').format(_birth!),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _birth == null
                                ? OnboardingScaffold.textMuted
                                : OnboardingScaffold.textDark,
                          ),
                        ),
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
                  ),
                  Text('📅', style: TextStyle(fontSize: 20.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 22.h),
          OnboardingScaffold.buildLabel('How was your baby ', 'delivered?'),
          SizedBox(height: 10.h),
          _ChoiceCard(
            emoji: '👶',
            title: 'Normal delivery',
            subtitle: 'Vaginal birth',
            selected: _delivery == 'normal',
            onTap: () => setState(() => _delivery = 'normal'),
          ),
          SizedBox(height: 12.h),
          _ChoiceCard(
            emoji: '🏥',
            title: 'C-section',
            subtitle: 'Caesarean birth',
            selected: _delivery == 'c_section',
            onTap: () => setState(() => _delivery = 'c_section'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// "My doctor has said I can exercise"
// ─────────────────────────────────────────────────────────────────────────

class DoctorClearanceScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onCleared;

  const DoctorClearanceScreen({
    Key? key,
    this.currentStep = 5,
    this.totalSteps = 8,
    required this.onCleared,
  }) : super(key: key);

  @override
  State<DoctorClearanceScreen> createState() => _DoctorClearanceScreenState();
}

class _DoctorClearanceScreenState extends State<DoctorClearanceScreen> {
  bool _ticked = false;
  bool _saving = false;

  Future<void> _next() async {
    if (_saving) return;
    if (!_ticked) {
      CustomToast.failToast(
          msg: 'Please check with your doctor before starting classes');
      return;
    }
    setState(() => _saving = true);
    final res = await Get.find<ConsultationController>()
        .saveLifeStage({'doctorCleared': true});
    if (!mounted) return;
    setState(() => _saving = false);
    if (res != null && res['access'] == 'full') widget.onCleared();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      badgeText: 'Your body',
      questionLine1: 'Before you start,',
      questionLine2: 'one quick check',
      subtitle:
          'Your recovery time after birth is over. We just need to know your doctor is happy for you to exercise.',
      buttonText: _saving ? 'Saving…' : 'Next →',
      onNext: _next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChoiceCard(
            emoji: '🩺',
            title: 'My doctor has said I can exercise',
            subtitle: 'Tick this once you have their go ahead',
            selected: _ticked,
            onTap: () => setState(() => _ticked = !_ticked),
          ),
          SizedBox(height: 14.h),
          Text(
            "Not sure yet? Check with your doctor first. Your account will be right here when you're ready.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: OnboardingScaffold.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Coming soon (pregnant, or new mother still inside her waiting time)
// ─────────────────────────────────────────────────────────────────────────

class LifeStageComingSoonScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const LifeStageComingSoonScreen({Key? key, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final waiting = data['access'] == 'waiting';
    final emoji = waiting ? '🤱' : '🤰';
    final title = waiting ? 'Rest and recover' : 'Coming soon for you';
    final hasDue = !waiting && data['dueDate'] is String;
    final body = waiting
        ? "Your body needs time to heal after birth. We'll send you a reminder when it's time to join."
        : hasDue
            ? "We're building a program made just for pregnancy. We'll check in with you after your baby arrives."
            : "We're building a program made just for pregnancy. We'll let you know as soon as it's ready.";
    final String? dateLine = waiting
        ? 'You can join from ${_niceDate(data['availableFrom'] as String?)}'
        : hasDue
            ? 'Due ${_niceDate(data['dueDate'] as String?)}'
            : null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: OnboardingScaffold.bg,
        body: Stack(
          children: [
            Positioned(
              top: -80.h,
              right: -70.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OnboardingScaffold.circleBg.withValues(alpha: 0.5),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      width: 96.w,
                      height: 96.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: OnboardingScaffold.circleBg,
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: 44.sp)),
                    ),
                    SizedBox(height: 26.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: OnboardingScaffold.textDark,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w300,
                        color: OnboardingScaffold.textMuted,
                        height: 1.6,
                      ),
                    ),
                    if (dateLine != null) ...[
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: OnboardingScaffold.optionSelectedBg,
                          borderRadius: BorderRadius.circular(50.r),
                          border: Border.all(
                              color: OnboardingScaffold.green, width: 1.5),
                        ),
                        child: Text(
                          '$dateLine 💚',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: OnboardingScaffold.textDark,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: restartSignupFlow,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: OnboardingScaffold.green, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 17.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Change my answer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: OnboardingScaffold.green,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.find<AuthController>().logout(),
                      child: Text(
                        'Log out',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: OnboardingScaffold.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Same card as the goal step (18 radius, emoji 26, title 16, sub 12, radio 24).
class _ChoiceCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: selected
              ? OnboardingScaffold.optionSelectedBg
              : OnboardingScaffold.optionBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? OnboardingScaffold.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 26.sp)),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: OnboardingScaffold.textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
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
                color: selected ? OnboardingScaffold.green : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? OnboardingScaffold.green
                      : OnboardingScaffold.radioBorder,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 15.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
