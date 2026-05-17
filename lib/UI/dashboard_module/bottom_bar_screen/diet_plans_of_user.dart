import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import '../../../widgets/v2/v2_diet_hero.dart';
import '../../../widgets/v2/v2_today_meals_section.dart';

/// User's Diet bottom-nav tab.
///
/// Phase F.1 hard-switched this surface from the legacy assigned-plans
/// list to the structured-plan "today's meals" view. Phase H upgrades
/// the visual shell to mirror the paid-home v2 layout: edge-to-edge
/// dark phase-themed `V2DietHero` at the top, cream body below with
/// the existing meal-section content.
///
/// The class name + constructor signature stay stable so
/// `bottom_bar_screen.dart` doesn't need to know about the swap.
class DietPlansOfUser extends StatelessWidget {
  // Kept for source compatibility with the existing call site at
  // bottom_bar_screen.dart:69. When mounted as a bottom-nav tab the
  // back button is hidden; when pushed (legacy entry points) it shows.
  final bool showBackButton;

  const DietPlansOfUser({super.key, this.showBackButton = true});

  static const Color _kCream = Color(0xFFEAF7E4);
  static const Color _kAccent = Color(0xFF6DC55A);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DietPlanUserController>();
    // Hero paints edge-to-edge under the system status bar (matches
    // paid_home_screen_v2.dart). No outer SafeArea — the hero handles
    // its own top padding via MediaQuery.padding.top inside _TopBar.
    return Scaffold(
      backgroundColor: _kCream,
      body: RefreshIndicator(
        color: _kAccent,
        onRefresh: () => ctrl.loadActivePlan(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              V2DietHero(showBackButton: showBackButton),
              const V2TodayMealsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
