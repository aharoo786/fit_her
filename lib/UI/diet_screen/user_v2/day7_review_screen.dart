import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/controllers/day7_review_controller/day7_review_controller.dart';
import '../../../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../../../data/models/diet_plan_v2/day7_review_model.dart';
import '../../../data/models/diet_plan_v2/diet_plan_v2_models.dart';
import '../../../widgets/v2/rating_star_row.dart';
import '../../../widgets/v2/v2_buttons.dart';

const Color _kCream = Color(0xFFEAF7E4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kDanger = Color(0xFFE07B7B);

/// Phase G.3 — user-facing Day 7 check-in. Lives under
/// `UI/diet_screen/user_v2/` to mirror the symmetric `dietitian_v2/`
/// folder for dietitian Diet-domain screens. Spec suggested
/// `dietitian_v2/` but that folder semantically holds dietitian-side
/// surfaces; user-side surfaces deserve their own sibling.
///
/// Closes the Phase 1A consultation feedback loop — submission lands
/// in `Day7Reviews` and the dietitian sees it in her flagged-reviews
/// dashboard before generating the next plan.
class Day7ReviewScreen extends StatefulWidget {
  final int userPlanId;
  final int cycle;

  const Day7ReviewScreen({
    super.key,
    required this.userPlanId,
    required this.cycle,
  });

  @override
  State<Day7ReviewScreen> createState() => _Day7ReviewScreenState();
}

class _Day7ReviewScreenState extends State<Day7ReviewScreen> {
  late final Day7ReviewController _ctrl;

  // Form state — kept local; controller only sees the final submission.
  int _adherence = 75;
  HungerLevelV2? _hunger;
  DifficultyLevelV2? _difficulty;
  final Set<String> _mealsStruggled = <String>{};
  bool _mealsNone = true; // "None" chip selected by default
  final Set<String> _sideEffects = <String>{};
  bool _sideEffectsNone = true;
  bool _sideEffectsOther = false;
  final TextEditingController _otherSideEffectCtrl = TextEditingController();
  bool _severeReported = false;
  bool _painReported = false;
  final TextEditingController _painLocationCtrl = TextEditingController();
  int? _satisfaction;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<Day7ReviewController>();
  }

  @override
  void dispose() {
    _otherSideEffectCtrl.dispose();
    _painLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final sideEffectsList = <String>[];
    if (!_sideEffectsNone) {
      sideEffectsList.addAll(_sideEffects);
      if (_sideEffectsOther) {
        final txt = _otherSideEffectCtrl.text.trim();
        sideEffectsList.add(txt.isEmpty ? 'other' : 'other:$txt');
      }
    }

    final mealsStruggledList = _mealsNone
        ? const <String>[]
        : _mealsStruggled.toList();

    final submission = Day7ReviewSubmission(
      userPlanId: widget.userPlanId,
      cycle: widget.cycle,
      planType: 'diet',
      adherencePct: _adherence,
      mealsStruggled: mealsStruggledList,
      hungerLevel: _hunger,
      sideEffects: sideEffectsList,
      difficultyLevel: _difficulty,
      sessionTimingIssues: null,
      painReported: _painReported,
      painLocation: _painLocationCtrl.text.trim().isEmpty
          ? null
          : _painLocationCtrl.text.trim(),
      severeSideEffectsReported: _severeReported,
      satisfaction: _satisfaction,
    );

    final ok = await _ctrl.submit(submission);
    if (!mounted) return;
    if (!ok) return;

    Get.back<dynamic>();
    Get.snackbar(
      'Thanks!',
      'Your dietitian will review your feedback.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _kAccent.withOpacity(0.92),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _adherenceSection(),
                    SizedBox(height: 24.h),
                    _hungerSection(),
                    SizedBox(height: 24.h),
                    _difficultySection(),
                    SizedBox(height: 24.h),
                    _mealsStruggledSection(),
                    SizedBox(height: 24.h),
                    _sideEffectsSection(),
                    SizedBox(height: 24.h),
                    _painSection(),
                    SizedBox(height: 24.h),
                    _satisfactionSection(),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // ─── Top bar ────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back<dynamic>(),
            icon: const Icon(Icons.close_rounded,
                color: _kHeroDark, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WEEK 1 CHECK-IN',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _kSage,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'How was this week?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: _kHeroDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section helpers ───────────────────────────────────────────────────

  Widget _label(String text, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: color ?? _kSage,
          letterSpacing: 0.84,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kHeroDark.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── Section 1 — adherence ─────────────────────────────────────────────

  Widget _adherenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('HOW MUCH OF THE PLAN DID YOU FOLLOW?'),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$_adherence%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: _kHeroDark,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 4.h),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _kAccent,
                  inactiveTrackColor: _kCardBorder,
                  thumbColor: _kAccent,
                  overlayColor: _kAccent.withOpacity(0.12),
                  trackHeight: 4,
                ),
                child: Slider(
                  min: 0,
                  max: 100,
                  divisions: 20,
                  value: _adherence.toDouble(),
                  onChanged: (v) => setState(() => _adherence = v.round()),
                ),
              ),
              Text(
                'Drag to set',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: _kSage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 2 — hunger ────────────────────────────────────────────────

  Widget _hungerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('HOW WERE YOUR HUNGER LEVELS?'),
        _card(
          Column(
            children: [
              _OptionRow(
                emoji: '😩',
                label: 'Always hungry',
                selected: _hunger == HungerLevelV2.alwaysHungry,
                onTap: () =>
                    setState(() => _hunger = HungerLevelV2.alwaysHungry),
              ),
              SizedBox(height: 8.h),
              _OptionRow(
                emoji: '😊',
                label: 'Just right',
                selected: _hunger == HungerLevelV2.justRight,
                onTap: () =>
                    setState(() => _hunger = HungerLevelV2.justRight),
              ),
              SizedBox(height: 8.h),
              _OptionRow(
                emoji: '😅',
                label: 'Too full / forced',
                selected: _hunger == HungerLevelV2.tooFull,
                onTap: () =>
                    setState(() => _hunger = HungerLevelV2.tooFull),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 3 — difficulty ────────────────────────────────────────────

  Widget _difficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('HOW WAS THE PLAN DIFFICULTY?'),
        _card(
          Column(
            children: [
              _OptionRow(
                emoji: '😴',
                label: 'Too easy',
                selected: _difficulty == DifficultyLevelV2.tooEasy,
                onTap: () =>
                    setState(() => _difficulty = DifficultyLevelV2.tooEasy),
              ),
              SizedBox(height: 8.h),
              _OptionRow(
                emoji: '🎯',
                label: 'Just right',
                selected: _difficulty == DifficultyLevelV2.justRight,
                onTap: () => setState(
                    () => _difficulty = DifficultyLevelV2.justRight),
              ),
              SizedBox(height: 8.h),
              _OptionRow(
                emoji: '🥵',
                label: 'Too hard',
                selected: _difficulty == DifficultyLevelV2.tooHard,
                onTap: () =>
                    setState(() => _difficulty = DifficultyLevelV2.tooHard),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 4 — meals struggled ───────────────────────────────────────

  Widget _mealsStruggledSection() {
    final dietCtrl = Get.find<DietPlanUserController>();
    final firstDay = dietCtrl.activePlan.value?.days.isNotEmpty == true
        ? dietCtrl.activePlan.value!.days.first
        : null;
    // Use only meal types actually in the plan template — keeps the
    // chip set scoped to what the user could have struggled with.
    final mealTypes = firstDay == null
        ? const <MealTypeV2>[]
        : firstDay.meals.map((m) => m.mealType).toSet().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('ANY MEALS YOU STRUGGLED WITH?'),
        _card(
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _Chip(
                label: 'None',
                selected: _mealsNone,
                onTap: () => setState(() {
                  _mealsNone = true;
                  _mealsStruggled.clear();
                }),
              ),
              for (final t in mealTypes)
                _Chip(
                  label: t.label,
                  selected:
                      !_mealsNone && _mealsStruggled.contains(t.wire),
                  onTap: () => setState(() {
                    _mealsNone = false;
                    if (_mealsStruggled.contains(t.wire)) {
                      _mealsStruggled.remove(t.wire);
                    } else {
                      _mealsStruggled.add(t.wire);
                    }
                    if (_mealsStruggled.isEmpty) _mealsNone = true;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 5 — side effects + severe toggle ──────────────────────────

  Widget _sideEffectsSection() {
    const known = ['Bloating', 'Fatigue', 'Headache', 'Cravings', 'Mood swings'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('ANY SIDE EFFECTS?'),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _Chip(
                    label: 'None',
                    selected: _sideEffectsNone,
                    onTap: () => setState(() {
                      _sideEffectsNone = true;
                      _sideEffects.clear();
                      _sideEffectsOther = false;
                    }),
                  ),
                  for (final s in known)
                    _Chip(
                      label: s,
                      selected: !_sideEffectsNone &&
                          _sideEffects.contains(s.toLowerCase()),
                      onTap: () => setState(() {
                        _sideEffectsNone = false;
                        final wire = s.toLowerCase();
                        if (_sideEffects.contains(wire)) {
                          _sideEffects.remove(wire);
                        } else {
                          _sideEffects.add(wire);
                        }
                        if (_sideEffects.isEmpty && !_sideEffectsOther) {
                          _sideEffectsNone = true;
                        }
                      }),
                    ),
                  _Chip(
                    label: 'Other',
                    selected: _sideEffectsOther,
                    onTap: () => setState(() {
                      _sideEffectsOther = !_sideEffectsOther;
                      if (_sideEffectsOther) _sideEffectsNone = false;
                      if (!_sideEffectsOther && _sideEffects.isEmpty) {
                        _sideEffectsNone = true;
                      }
                    }),
                  ),
                ],
              ),
              if (_sideEffectsOther) ...[
                SizedBox(height: 12.h),
                _textField(
                  controller: _otherSideEffectCtrl,
                  hint: 'Briefly describe…',
                  maxLength: 100,
                ),
              ],
              SizedBox(height: 14.h),
              _SevereToggle(
                value: _severeReported,
                onChanged: (v) => setState(() => _severeReported = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 6 — pain ──────────────────────────────────────────────────

  Widget _painSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('ANY PAIN OR DISCOMFORT?'),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _YesNoButton(
                      label: 'No',
                      selected: !_painReported,
                      onTap: () => setState(() => _painReported = false),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _YesNoButton(
                      label: 'Yes',
                      selected: _painReported,
                      accent: _kDanger,
                      onTap: () => setState(() => _painReported = true),
                    ),
                  ),
                ],
              ),
              if (_painReported) ...[
                SizedBox(height: 12.h),
                _textField(
                  controller: _painLocationCtrl,
                  hint: 'Where? (e.g., lower back, stomach)',
                  maxLength: 100,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 7 — satisfaction ──────────────────────────────────────────

  Widget _satisfactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('OVERALL SATISFACTION'),
        _card(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: RatingStarRow(
              value: _satisfaction,
              onChanged: (v) => setState(() => _satisfaction = v),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom bar (sticky submit) ────────────────────────────────────────

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kCardBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final err = _ctrl.submissionError.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (err != null) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: _kDanger, size: 16.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          err,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _kDanger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              V2PrimaryButton(
                label: _ctrl.isSubmitting.value
                    ? 'Submitting…'
                    : 'Submit Check-in',
                busy: _ctrl.isSubmitting.value,
                onPressed: _ctrl.isSubmitting.value ? null : _onSubmit,
              ),
            ],
          );
        }),
      ),
    );
  }

  // ─── Misc reusable bits ────────────────────────────────────────────────

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      inputFormatters:
          maxLength == null ? null : [LengthLimitingTextInputFormatter(maxLength)],
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.sp,
        color: _kHeroDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          color: _kBodyMuted,
        ),
        filled: true,
        fillColor: _kCream,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kCardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kCardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccent, width: 1.4),
        ),
      ),
    );
  }
}

// ─── Local widgets ────────────────────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionRow({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? _kAccent.withOpacity(0.12) : _kCream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _kAccent : _kCardBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _kHeroDark,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    color: _kAccent, size: 20.w),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _kAccent : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _kAccent : _kCardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _kHeroDark,
          ),
        ),
      ),
    );
  }
}

class _YesNoButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _YesNoButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent = _kAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : _kCardBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : _kHeroDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _SevereToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SevereToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: value ? _kDanger.withOpacity(0.10) : _kCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? _kDanger : _kCardBorder,
            width: value ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value
                  ? Icons.warning_rounded
                  : Icons.info_outline_rounded,
              color: value ? _kDanger : _kSage,
              size: 18.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Anything severe? (e.g., dizziness, severe pain)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: value ? _kDanger : _kBodyMuted,
                  height: 1.4,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: _kDanger,
            ),
          ],
        ),
      ),
    );
  }
}
