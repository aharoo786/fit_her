import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../../widgets/v2/v2_today_meals_section.dart';
import 'trial_journey_screen.dart';

// Trial-to-Plan funnel — Step 6 ("Land on meal log"). Hosts the exact
// same V2TodayMealsSection paid users see (it self-loads from
// GET /users/diet-plan/me/active via DietPlanUserController, which has
// no payment-tier gating — see docs/diet_system_full_audit.md), so once
// the trial's starter DietPlan is generated + auto-activated it "just
// works" here with no changes to that widget at all.
//
// A standalone screen rather than folding this into the existing
// paid/unpaid home routing on purpose — trial users shouldn't suddenly
// see paid-only surfaces (renewal prompts, follow-up booking, etc.) just
// because they now have an active DietPlan; popupEligibility.js's
// isTrial guardrail keeps those out of the popup feed too.
class TrialMealPlanScreen extends StatefulWidget {
  const TrialMealPlanScreen({Key? key}) : super(key: key);

  @override
  State<TrialMealPlanScreen> createState() => _TrialMealPlanScreenState();
}

class _TrialMealPlanScreenState extends State<TrialMealPlanScreen> {
  static const Color _kBg = Color(0xFFE8F4E0);
  static const Color _kInk = Color(0xFF163220);
  static const Color _kInkSoft = Color(0xFF6F8B7A);

  @override
  void initState() {
    super.initState();
    // Force a refresh rather than trusting whatever DietPlanUserController
    // last cached — if it was instantiated earlier in this session (e.g.
    // the user briefly touched a paid-only surface before), its
    // activePlan could still be null from before the plan we just
    // generated existed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DietPlanUserController>().loadActivePlan(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your simple plan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Log each meal below as you go.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: _kInkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Get.to<void>(() => const TrialJourneyScreen()),
                    child: const Text(
                      'Live classes →',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: const V2TodayMealsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
