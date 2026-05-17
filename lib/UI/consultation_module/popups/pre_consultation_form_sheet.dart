import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/multi_step_form_scaffold.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';

/// `POPUP_PRE_CONSULTATION_FORM` (Section 4.5).
///
/// Multi-step health profile filled before the initial consultation.
/// Auto-save per step (Decision 5) — every Next button hits PATCH so a
/// hard exit doesn't lose progress; resume picks up at the first
/// incomplete step. The workout step (last) is conditional: only
/// rendered for combined / workout-only plan types (Decision 10).
///
/// Required vs optional (Decision 7):
///   Required: goals, allergies, pregnancy/menstrual status,
///             dietary preferences, medical conditions
///   Optional: family history, lifestyle, fasting habits, surgeries,
///             current medications
class PreConsultationFormSheet extends StatefulWidget {
  static const String variable = 'POPUP_PRE_CONSULTATION_FORM';

  /// "diet" | "workout" | "combined" — drives whether the workout step
  /// is included in the flow.
  final String planType;

  const PreConsultationFormSheet({Key? key, required this.planType})
      : super(key: key);

  static Future<void> show({required String planType}) {
    return V2BottomSheet.show(
      title: 'A few quick questions',
      // Form auto-saves each step server-side, so swipe-down is OK —
      // worst case the user resumes where they left off next time.
      child: PreConsultationFormSheet(planType: planType),
    );
  }

  @override
  State<PreConsultationFormSheet> createState() =>
      _PreConsultationFormSheetState();
}

class _PreConsultationFormSheetState extends State<PreConsultationFormSheet> {
  late final ConsultationController _ctrl;
  bool _initLoading = true;
  bool _busy = false;
  int _currentStep = 0;

  // ── Step 1: Goals ──
  String? _goal;

  // ── Step 2: Health ──
  final TextEditingController _allergies = TextEditingController();
  final TextEditingController _medicalConditions = TextEditingController();
  String? _pregnancyMenstrual;

  // ── Step 3: Diet & lifestyle ──
  final Set<String> _diet = <String>{};
  final TextEditingController _lifestyleNotes = TextEditingController();
  final TextEditingController _fasting = TextEditingController();

  // ── Step 4: History (optional) ──
  final TextEditingController _familyHistory = TextEditingController();
  final TextEditingController _surgeries = TextEditingController();
  final TextEditingController _meds = TextEditingController();

  // ── Step 5: Workout (combined / workout-only) ──
  String? _fitnessLevel;
  final TextEditingController _injuries = TextEditingController();
  final Set<String> _equipment = <String>{};

  bool get _includesWorkout =>
      widget.planType == 'workout' || widget.planType == 'combined';
  int get _totalSteps => _includesWorkout ? 5 : 4;

  static const _goals = <_LabeledValue>[
    _LabeledValue('weight_loss', 'Lose weight'),
    _LabeledValue('weight_gain', 'Gain weight'),
    _LabeledValue('maintain', 'Maintain'),
    _LabeledValue('pcos_management', 'Manage PCOS'),
    _LabeledValue('postpartum', 'Postpartum recovery'),
    _LabeledValue('pregnancy_prep', 'Pregnancy prep'),
    _LabeledValue('general_wellness', 'General wellness'),
  ];

  static const _pregnancyOptions = <_LabeledValue>[
    _LabeledValue('regular_cycle', 'Regular cycle'),
    _LabeledValue('irregular_cycle', 'Irregular cycle'),
    _LabeledValue('pcos', 'PCOS'),
    _LabeledValue('pregnant', 'Pregnant'),
    _LabeledValue('postpartum', 'Postpartum'),
    _LabeledValue('menopause', 'Menopause'),
    _LabeledValue('prefer_not_to_say', 'Prefer not to say'),
  ];

  static const _dietOptions = <_LabeledValue>[
    _LabeledValue('vegetarian', 'Vegetarian'),
    _LabeledValue('halal', 'Halal'),
    _LabeledValue('lactose_free', 'Lactose-free'),
    _LabeledValue('gluten_free', 'Gluten-free'),
    _LabeledValue('eggs_ok', 'Eggs OK'),
    _LabeledValue('seafood_ok', 'Seafood OK'),
    _LabeledValue('no_restrictions', 'No restrictions'),
  ];

  static const _fitnessLevels = <_LabeledValue>[
    _LabeledValue('beginner', 'Beginner'),
    _LabeledValue('intermediate', 'Intermediate'),
    _LabeledValue('advanced', 'Advanced'),
  ];

  static const _equipmentOptions = <_LabeledValue>[
    _LabeledValue('none', 'None'),
    _LabeledValue('dumbbells', 'Dumbbells'),
    _LabeledValue('resistance_bands', 'Resistance bands'),
    _LabeledValue('mat', 'Yoga mat'),
    _LabeledValue('treadmill', 'Treadmill'),
    _LabeledValue('full_gym', 'Full gym'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ConsultationController>();
    _bootstrap();
  }

  @override
  void dispose() {
    _allergies.dispose();
    _medicalConditions.dispose();
    _lifestyleNotes.dispose();
    _fasting.dispose();
    _familyHistory.dispose();
    _surgeries.dispose();
    _meds.dispose();
    _injuries.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final profile = await _ctrl.loadProfile();
    if (!mounted) return;
    if (profile != null) {
      _goal = profile.goals;
      _allergies.text = profile.allergies ?? '';
      _medicalConditions.text = profile.medicalConditions ?? '';
      _pregnancyMenstrual = profile.pregnancyMenstrualStatus;
      if (profile.dietaryPreferences is List) {
        _diet.addAll((profile.dietaryPreferences as List).whereType<String>());
      }
      _familyHistory.text = profile.familyHistory ?? '';
      _surgeries.text = profile.surgeries ?? '';
      _meds.text = profile.currentMedications ?? '';
      _fasting.text = profile.fastingHabits ?? '';
      // Lifestyle is JSON; flatten any free-text 'notes' field if present.
      final ls = profile.lifestyle;
      if (ls != null && ls['notes'] is String) {
        _lifestyleNotes.text = ls['notes'] as String;
      }
      // Workout section (optional sub-object).
      final ws = profile.workoutSection;
      if (ws != null) {
        _fitnessLevel = ws['fitnessLevel'] as String?;
        if (ws['injuries'] is String) {
          _injuries.text = ws['injuries'] as String;
        }
        if (ws['equipment'] is List) {
          _equipment.addAll(
              (ws['equipment'] as List).whereType<String>());
        }
      }

      // Resume from the first incomplete step (build plan risk #6).
      _currentStep = _firstIncompleteStep();
    }
    setState(() => _initLoading = false);
  }

  int _firstIncompleteStep() {
    if (_goal == null) return 0;
    if (_allergies.text.trim().isEmpty ||
        _medicalConditions.text.trim().isEmpty ||
        _pregnancyMenstrual == null) {
      return 1;
    }
    if (_diet.isEmpty) return 2;
    // Step 3 (history) is optional — skip ahead unless workout step exists
    // and is incomplete.
    if (_includesWorkout && _fitnessLevel == null) return 4;
    return _includesWorkout ? 4 : 3;
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return _goal != null;
      case 1:
        return _allergies.text.trim().isNotEmpty &&
            _medicalConditions.text.trim().isNotEmpty &&
            _pregnancyMenstrual != null;
      case 2:
        return _diet.isNotEmpty;
      case 3:
        return true; // history step is optional
      case 4:
        return _fitnessLevel != null;
      default:
        return true;
    }
  }

  /// Builds the partial body to PATCH for the step that just finished.
  /// Each step sends only its own fields so the server has minimal
  /// blast radius if validation rejects something.
  Map<String, dynamic> _patchBodyForStep(int step) {
    switch (step) {
      case 0:
        return {'goals': _goal, 'step': 'goals'};
      case 1:
        return {
          'allergies': _allergies.text.trim(),
          'medicalConditions': _medicalConditions.text.trim(),
          'pregnancyMenstrualStatus': _pregnancyMenstrual,
          'step': 'health',
        };
      case 2:
        return {
          'dietaryPreferences': _diet.toList(),
          'lifestyle': _lifestyleNotes.text.trim().isEmpty
              ? null
              : {'notes': _lifestyleNotes.text.trim()},
          'fastingHabits': _fasting.text.trim().isEmpty
              ? null
              : _fasting.text.trim(),
          'step': 'diet_lifestyle',
        };
      case 3:
        return {
          'familyHistory': _familyHistory.text.trim().isEmpty
              ? null
              : _familyHistory.text.trim(),
          'surgeries': _surgeries.text.trim().isEmpty
              ? null
              : _surgeries.text.trim(),
          'currentMedications': _meds.text.trim().isEmpty
              ? null
              : _meds.text.trim(),
          'step': 'history',
        };
      case 4:
        return {
          'workoutSection': {
            'fitnessLevel': _fitnessLevel,
            'injuries': _injuries.text.trim().isEmpty
                ? null
                : _injuries.text.trim(),
            'equipment': _equipment.toList(),
          },
          'step': 'workout',
        };
      default:
        return {};
    }
  }

  Future<void> _onNext() async {
    setState(() => _busy = true);
    final ok = await _ctrl.patchProfile(_patchBodyForStep(_currentStep));
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      CustomToast.failToast(msg: 'Could not save. Please try again.');
      return;
    }
    setState(() => _currentStep++);
  }

  Future<void> _onSubmit() async {
    setState(() => _busy = true);
    final body = _patchBodyForStep(_currentStep);
    body['isComplete'] = true;
    final ok = await _ctrl.patchProfile(body);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      CustomToast.failToast(msg: 'Could not submit. Please try again.');
      return;
    }
    await _ctrl.completePopup(PreConsultationFormSheet.variable);
    Get.back<dynamic>();
    CustomToast.successToast(
        msg: 'Thanks! Your dietitian will review this before your call.');
  }

  void _onBack() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6DC55A)),
          ),
        ),
      );
    }

    return MultiStepFormScaffold(
      title: _stepTitles[_currentStep],
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      body: _stepBody(),
      onBack: _onBack,
      onNext: _onNext,
      onSubmit: _onSubmit,
      nextEnabled: _isCurrentStepValid(),
      busy: _busy,
      // History step is optional — let user skip without filling fields.
      skipLabel: _currentStep == 3 ? 'Skip — fill later' : null,
      onSkip: _currentStep == 3
          ? () async {
              setState(() => _busy = true);
              await _ctrl.patchProfile(_patchBodyForStep(3));
              if (!mounted) return;
              setState(() {
                _busy = false;
                _currentStep = _includesWorkout ? 4 : _currentStep;
              });
            }
          : null,
    );
  }

  static const List<String> _stepTitles = [
    "What's your goal?",
    'Health basics',
    'Diet & lifestyle',
    'Medical history (optional)',
    'About your workouts',
  ];

  Widget _stepBody() {
    switch (_currentStep) {
      case 0:
        return _SingleSelectColumn(
          options: _goals,
          selected: _goal,
          onSelect: (v) => setState(() => _goal = v),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledTextField(
              label: 'Allergies',
              hint: 'List anything we should avoid (or "none")',
              controller: _allergies,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            _LabeledTextField(
              label: 'Existing medical conditions',
              hint: 'Diabetes, thyroid, BP, etc. (or "none")',
              controller: _medicalConditions,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            const _SectionLabel('Cycle & reproductive health'),
            const SizedBox(height: 6),
            _ChipWrap(
              options: _pregnancyOptions,
              selected: _pregnancyMenstrual == null
                  ? const <String>{}
                  : {_pregnancyMenstrual!},
              singleSelect: true,
              onToggle: (v) =>
                  setState(() => _pregnancyMenstrual = v),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionLabel('Dietary preferences (pick all that apply)'),
            const SizedBox(height: 6),
            _ChipWrap(
              options: _dietOptions,
              selected: _diet,
              singleSelect: false,
              onToggle: (v) => setState(() {
                if (_diet.contains(v)) {
                  _diet.remove(v);
                } else {
                  _diet.add(v);
                }
              }),
            ),
            const SizedBox(height: 14),
            _LabeledTextField(
              label: 'Lifestyle notes (optional)',
              hint: 'Sleep pattern, work hours, smoking, alcohol…',
              controller: _lifestyleNotes,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            _LabeledTextField(
              label: 'Fasting habits (optional)',
              hint: 'Ramadan plans, intermittent fasting, etc.',
              controller: _fasting,
              maxLines: 2,
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledTextField(
              label: 'Family medical history (optional)',
              hint: 'Diabetes, heart disease, thyroid, etc.',
              controller: _familyHistory,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            _LabeledTextField(
              label: 'Past surgeries (optional)',
              hint: 'Surgeries, hospitalisations',
              controller: _surgeries,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            _LabeledTextField(
              label: 'Current medications (optional)',
              hint: 'List any medication you take regularly',
              controller: _meds,
              maxLines: 2,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionLabel('Fitness level'),
            const SizedBox(height: 6),
            _ChipWrap(
              options: _fitnessLevels,
              selected: _fitnessLevel == null
                  ? const <String>{}
                  : {_fitnessLevel!},
              singleSelect: true,
              onToggle: (v) => setState(() => _fitnessLevel = v),
            ),
            const SizedBox(height: 14),
            _LabeledTextField(
              label: 'Injuries / conditions to avoid (optional)',
              hint: 'Knee, lower back, shoulder, etc.',
              controller: _injuries,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            const _SectionLabel('Equipment available (pick all that apply)'),
            const SizedBox(height: 6),
            _ChipWrap(
              options: _equipmentOptions,
              selected: _equipment,
              singleSelect: false,
              onToggle: (v) => setState(() {
                if (_equipment.contains(v)) {
                  _equipment.remove(v);
                } else {
                  _equipment.add(v);
                }
              }),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Private helpers ──────────────────────────────────────────────────

class _LabeledValue {
  final String value;
  final String label;
  const _LabeledValue(this.value, this.label);
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

class _LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const _LabeledTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6DC55A), width: 1.4),
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF1A3A22),
          ),
        ),
      ],
    );
  }
}

class _SingleSelectColumn extends StatelessWidget {
  final List<_LabeledValue> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SingleSelectColumn({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onSelect(o.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected == o.value
                          ? const Color(0xFFE4F9D7)
                          : const Color(0xFFF5FDF2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected == o.value
                            ? const Color(0xFF6DC55A)
                            : const Color(0xFFC8DEC4),
                        width: selected == o.value ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected == o.value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected == o.value
                              ? const Color(0xFF6DC55A)
                              : const Color(0xFF9AB09A),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          o.label,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A3A22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
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
