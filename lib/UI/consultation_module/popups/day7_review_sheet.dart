import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/rating_star_row.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';
import '../../../widgets/v2/v2_slider_input.dart';

/// `POPUP_DAY7_REVIEW` — fires Day 7 of cycle 1 + Day 22 of cycle 2.
/// Single sheet branches internally on `planType`:
///   diet      → diet section only
///   workout   → workout section only
///   combined  → both sections + shared flag inputs
///
/// Server-side hook computes the flag from Decision 6 thresholds:
///   adherence < 40 OR pain reported OR severe side effects OR
///   satisfaction < 2  → flagged=true → REVIEW_FLAG escalation.
class Day7ReviewSheet extends StatefulWidget {
  static const String variable = 'POPUP_DAY7_REVIEW';

  /// "diet" | "workout" | "combined".
  final String planType;
  final int userPlanId;
  final int cycle; // 1 or 2

  const Day7ReviewSheet({
    Key? key,
    required this.planType,
    required this.userPlanId,
    required this.cycle,
  }) : super(key: key);

  static Future<void> show({
    required String planType,
    required int userPlanId,
    required int cycle,
  }) {
    return V2BottomSheet.show(
      title: 'Day 7 review',
      child: Day7ReviewSheet(
        planType: planType,
        userPlanId: userPlanId,
        cycle: cycle,
      ),
    );
  }

  @override
  State<Day7ReviewSheet> createState() => _Day7ReviewSheetState();
}

class _Day7ReviewSheetState extends State<Day7ReviewSheet> {
  late final ConsultationController _ctrl;
  bool _busy = false;

  // Diet section
  int _adherence = 70;
  final Set<String> _mealsStruggled = <String>{};
  String? _hungerLevel;
  final Set<String> _sideEffects = <String>{};

  // Workout section
  String? _difficulty;
  bool? _sessionTimingIssues;

  // Shared / flag inputs
  bool _painReported = false;
  final TextEditingController _painLocationCtrl = TextEditingController();
  bool _severeReported = false;
  int? _satisfaction;

  bool get _showsDiet =>
      widget.planType == 'diet' || widget.planType == 'combined';
  bool get _showsWorkout =>
      widget.planType == 'workout' || widget.planType == 'combined';

  static const _meals = <_LabeledValue>[
    _LabeledValue('breakfast', 'Breakfast'),
    _LabeledValue('lunch', 'Lunch'),
    _LabeledValue('dinner', 'Dinner'),
    _LabeledValue('snacks', 'Snacks'),
    _LabeledValue('none', 'None'),
  ];

  static const _hungerOptions = <_LabeledValue>[
    _LabeledValue('always_hungry', 'Always hungry'),
    _LabeledValue('just_right', 'Just right'),
    _LabeledValue('too_full', 'Too full'),
  ];

  static const _sideEffectOptions = <_LabeledValue>[
    _LabeledValue('bloating', 'Bloating'),
    _LabeledValue('headaches', 'Headaches'),
    _LabeledValue('cravings', 'Cravings'),
    _LabeledValue('other', 'Other'),
    _LabeledValue('none', 'None'),
  ];

  static const _difficultyOptions = <_LabeledValue>[
    _LabeledValue('too_easy', 'Too easy'),
    _LabeledValue('just_right', 'Just right'),
    _LabeledValue('too_hard', 'Too hard'),
  ];

  @override
  void dispose() {
    _painLocationCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ConsultationController>();
  }

  bool get _canSubmit {
    // Minimum required to submit: satisfaction always, plus the section
    // primary fields for the active plan type.
    if (_satisfaction == null) return false;
    if (_showsDiet) {
      if (_hungerLevel == null) return false;
    }
    if (_showsWorkout) {
      if (_difficulty == null) return false;
      if (_sessionTimingIssues == null) return false;
    }
    if (_painReported && _painLocationCtrl.text.trim().isEmpty) return false;
    return true;
  }

  Map<String, dynamic> _buildBody() {
    return {
      'userPlanId': widget.userPlanId,
      'cycle': widget.cycle,
      'planType': widget.planType,
      if (_showsDiet) ...{
        'adherencePct': _adherence,
        'mealsStruggled': _mealsStruggled.toList(),
        'hungerLevel': _hungerLevel,
        'sideEffects': _sideEffects.toList(),
      },
      if (_showsWorkout) ...{
        'difficultyLevel': _difficulty,
        'sessionTimingIssues': _sessionTimingIssues ?? false,
      },
      'painReported': _painReported,
      if (_painReported && _painLocationCtrl.text.trim().isNotEmpty)
        'painLocation': _painLocationCtrl.text.trim(),
      'severeSideEffectsReported': _severeReported,
      'satisfaction': _satisfaction,
    };
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _busy = true);
    final ok = await _ctrl.submitDay7Review(_buildBody());
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    // Server hook already retired POPUP_DAY7_REVIEW completedAt for the
    // current cycle, but mirror it client-side as defence in depth.
    await _ctrl.completePopup(Day7ReviewSheet.variable, metadata: {
      'cycle': widget.cycle,
      'userPlanId': widget.userPlanId,
    });
    Get.back<dynamic>();
    CustomToast.successToast(msg: "Thanks — your dietitian will see this.");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Two minutes. Tap to answer — your dietitian uses these to tune the next 7 days.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        if (_showsDiet) ...[
          const SizedBox(height: 22),
          _SectionHeader('Diet'),
          const SizedBox(height: 12),
          const _SectionLabel('How well did you stick to the plan?'),
          const SizedBox(height: 8),
          V2SliderInput(
            value: _adherence,
            onChanged: (v) => setState(() => _adherence = v),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Which meals did you struggle with?'),
          const SizedBox(height: 6),
          _ChipWrap(
            options: _meals,
            selected: _mealsStruggled,
            singleSelect: false,
            onToggle: (v) => setState(() {
              if (_mealsStruggled.contains(v)) {
                _mealsStruggled.remove(v);
              } else {
                _mealsStruggled.add(v);
              }
            }),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Hunger this week'),
          const SizedBox(height: 6),
          _ChipWrap(
            options: _hungerOptions,
            selected: _hungerLevel == null
                ? const <String>{}
                : {_hungerLevel!},
            singleSelect: true,
            onToggle: (v) => setState(() => _hungerLevel = v),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Side effects (pick all that apply)'),
          const SizedBox(height: 6),
          _ChipWrap(
            options: _sideEffectOptions,
            selected: _sideEffects,
            singleSelect: false,
            onToggle: (v) => setState(() {
              // 'none' is mutually exclusive with the rest.
              if (v == 'none') {
                _sideEffects
                  ..clear()
                  ..add('none');
              } else {
                _sideEffects.remove('none');
                if (_sideEffects.contains(v)) {
                  _sideEffects.remove(v);
                } else {
                  _sideEffects.add(v);
                }
              }
            }),
          ),
        ],
        if (_showsWorkout) ...[
          const SizedBox(height: 22),
          _SectionHeader('Workout'),
          const SizedBox(height: 12),
          const _SectionLabel('Difficulty this week'),
          const SizedBox(height: 6),
          _ChipWrap(
            options: _difficultyOptions,
            selected: _difficulty == null
                ? const <String>{}
                : {_difficulty!},
            singleSelect: true,
            onToggle: (v) => setState(() => _difficulty = v),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Did session timings work for you?'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _YesNoButton(
                  label: 'Yes',
                  selected: _sessionTimingIssues == false,
                  onTap: () =>
                      setState(() => _sessionTimingIssues = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _YesNoButton(
                  label: 'No',
                  selected: _sessionTimingIssues == true,
                  onTap: () => setState(() => _sessionTimingIssues = true),
                ),
              ),
            ],
          ),
        ],

        // ── Shared / flag inputs ──
        const SizedBox(height: 22),
        _SectionHeader("This week's experience"),
        const SizedBox(height: 12),

        const _SectionLabel('Any pain or soreness beyond normal?'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _YesNoButton(
                label: 'No',
                selected: !_painReported,
                onTap: () => setState(() {
                  _painReported = false;
                  _painLocationCtrl.clear();
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _YesNoButton(
                label: 'Yes',
                selected: _painReported,
                tone: _PillTone.warn,
                onTap: () => setState(() => _painReported = true),
              ),
            ),
          ],
        ),
        if (_painReported) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _painLocationCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Where? (e.g. lower back, knee)',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF9AB09A),
              ),
              filled: true,
              fillColor: const Color(0xFFF5FDF2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFC8DEC4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFC8DEC4)),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF1A3A22),
            ),
          ),
        ],
        const SizedBox(height: 14),
        const _SectionLabel('Any severe reactions or side effects?'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _YesNoButton(
                label: 'No',
                selected: !_severeReported,
                onTap: () => setState(() => _severeReported = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _YesNoButton(
                label: 'Yes',
                selected: _severeReported,
                tone: _PillTone.warn,
                onTap: () => setState(() => _severeReported = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel('Overall, how was this week?'),
        const SizedBox(height: 8),
        RatingStarRow(
          value: _satisfaction,
          onChanged: (v) => setState(() => _satisfaction = v),
        ),
        const SizedBox(height: 24),
        V2PrimaryButton(
          label: 'Submit review',
          busy: _busy,
          onPressed: _canSubmit ? _submit : null,
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: "I'll do it later",
          onPressed: _busy
              ? null
              : () {
                  _ctrl.dismissPopup(Day7ReviewSheet.variable, metadata: {
                    'cycle': widget.cycle,
                  });
                  Get.back<dynamic>();
                },
        ),
      ],
    );
  }
}

// ── Private helpers (keep tight to this file) ─────────────────────────

class _LabeledValue {
  final String value;
  final String label;
  const _LabeledValue(this.value, this.label);
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A3A22),
          letterSpacing: -0.2,
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A3A22),
          letterSpacing: 0.4,
        ),
      );
}

class _ChipWrap extends StatelessWidget {
  final List<_LabeledValue> options;
  final Set<String> selected;
  final bool singleSelect;
  final ValueChanged<String> onToggle;

  const _ChipWrap({
    required this.options,
    required this.selected,
    required this.singleSelect,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isOn = selected.contains(o.value);
        return GestureDetector(
          onTap: () => onToggle(o.value),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOn
                  ? const Color(0xFF1A3A22)
                  : const Color(0xFFF5FDF2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn
                    ? const Color(0xFF1A3A22)
                    : const Color(0xFFC8DEC4),
              ),
            ),
            child: Text(
              o.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOn ? Colors.white : const Color(0xFF1A3A22),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

enum _PillTone { neutral, warn }

class _YesNoButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _PillTone tone;

  const _YesNoButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tone = _PillTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = tone == _PillTone.warn
        ? const Color(0xFFE24B4A)
        : const Color(0xFF1A3A22);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedBg : const Color(0xFFF5FDF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? selectedBg : const Color(0xFFC8DEC4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF1A3A22),
          ),
        ),
      ),
    );
  }
}
