import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/home_controller/home_controller.dart';
import '../../widgets/v2/v2_buttons.dart';
import 'trial_journey_screen.dart';
import 'trial_meal_plan_screen.dart';

// Trial-to-Plan funnel — Step 3. Shown as a direct screen transition
// right after /trial/start succeeds (not popup-gated — the popup engine
// skips users with no active-and-non-trial UserPlan, and even once the
// trial UserPlan exists this shouldn't depend on popup priority/cooldown
// competing with other sheets). Deliberately a trimmed 3-field version
// of the full dietitian-facing PreConsultationFormSheet (goal, allergies,
// meals/day) — see the "Trial-to-Plan Funnel" design artifact's Decision
// 1 ("Leaning: trimmed").
//
// Submitting calls POST /trial/quick-intake, which generates AND
// auto-activates the starter plan server-side in one call (Steps 4+5) —
// this screen only has to wait for that one request and route to the
// meal log on success.
class TrialQuickIntakeScreen extends StatefulWidget {
  const TrialQuickIntakeScreen({Key? key}) : super(key: key);

  @override
  State<TrialQuickIntakeScreen> createState() =>
      _TrialQuickIntakeScreenState();
}

class _TrialQuickIntakeScreenState extends State<TrialQuickIntakeScreen> {
  static const Color _kBg = Color(0xFFE8F4E0);
  static const Color _kInk = Color(0xFF163220);
  static const Color _kInkSoft = Color(0xFF6F8B7A);
  static const Color _kAccent = Color(0xFF6DC55A);
  static const Color _kAccentBg = Color(0xFFEAF7E4);
  static const Color _kBorder = Color(0xFFD8EDD4);

  // Mirrors PreConsultationFormSheet's `_goals` list (same value strings
  // the backend/AI prompt expect) — kept as its own trimmed copy here
  // since this screen intentionally shows only goal + allergies +
  // meals/day, not the full multi-step form.
  static const List<_LabeledValue> _goals = [
    _LabeledValue('weight_loss', 'Lose weight'),
    _LabeledValue('weight_gain', 'Gain weight'),
    _LabeledValue('maintain', 'Maintain'),
    _LabeledValue('pcos_management', 'Manage PCOS'),
    _LabeledValue('postpartum', 'Postpartum recovery'),
    _LabeledValue('pregnancy_prep', 'Pregnancy prep'),
    _LabeledValue('general_wellness', 'General wellness'),
  ];

  static const List<int> _mealsPerDayOptions = [3, 4, 5, 6];
  // "Leaning: 4" per the funnel artifact's Decision 2.
  static const int _defaultMealsPerDay = 4;

  static const List<String> _busyMessages = [
    'Reading your goal…',
    'Checking your allergies…',
    'Building your first few days…',
    'Almost ready…',
  ];

  String? _goal;
  int _mealsPerDay = _defaultMealsPerDay;
  final TextEditingController _allergiesCtrl = TextEditingController();
  Timer? _busyMessageTimer;
  int _busyMessageIndex = 0;

  @override
  void dispose() {
    _busyMessageTimer?.cancel();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  void _startBusyMessages() {
    _busyMessageIndex = 0;
    _busyMessageTimer?.cancel();
    _busyMessageTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _busyMessageIndex = (_busyMessageIndex + 1) % _busyMessages.length;
      });
    });
  }

  Future<void> _submit(HomeController home) async {
    if (_goal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your main goal')),
      );
      return;
    }
    _startBusyMessages();
    final ok = await home.submitTrialQuickIntake(
      goal: _goal!,
      allergies: _allergiesCtrl.text.trim(),
      mealsPerDay: _mealsPerDay,
    );
    _busyMessageTimer?.cancel();
    if (ok && mounted) {
      Get.off<void>(() => const TrialMealPlanScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Obx(() {
          final busy = home.trialQuickIntakeLoad.value;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'One quick step',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Tell us a little about you and we'll put together "
                      'a simple starter plan you can start logging today.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        height: 1.5,
                        color: _kInkSoft,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const _SectionLabel('YOUR MAIN GOAL'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _goals
                          .map((g) => _SelectChip(
                                label: g.label,
                                selected: _goal == g.value,
                                onTap: () => setState(() => _goal = g.value),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('ANY ALLERGIES? (OPTIONAL)'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kBorder),
                      ),
                      child: TextField(
                        controller: _allergiesCtrl,
                        maxLines: 2,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: _kInk,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          hintText: 'e.g. peanuts, shellfish — separate with commas',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: _kInkSoft,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('MEALS PER DAY'),
                    const SizedBox(height: 10),
                    Row(
                      children: _mealsPerDayOptions
                          .map((n) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _SelectChip(
                                  label: '$n',
                                  selected: _mealsPerDay == n,
                                  onTap: () => setState(() => _mealsPerDay = n),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 34),
                    V2PrimaryButton(
                      label: 'Create my plan',
                      busy: busy,
                      onPressed: busy ? null : () => _submit(home),
                    ),
                    const SizedBox(height: 8),
                    V2GhostButton(
                      label: 'Skip for now',
                      onPressed: busy
                          ? null
                          : () => Get.off<void>(() => const TrialJourneyScreen()),
                    ),
                  ],
                ),
              ),
              if (busy)
                Positioned.fill(
                  child: Container(
                    color: _kBg.withOpacity(0.92),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_kAccent),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _busyMessages[_busyMessageIndex],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: _TrialQuickIntakeScreenState._kInkSoft,
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? _TrialQuickIntakeScreenState._kAccent
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _TrialQuickIntakeScreenState._kAccent
                : _TrialQuickIntakeScreenState._kBorder,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : _TrialQuickIntakeScreenState._kInk,
          ),
        ),
      ),
    );
  }
}

class _LabeledValue {
  final String value;
  final String label;
  const _LabeledValue(this.value, this.label);
}
