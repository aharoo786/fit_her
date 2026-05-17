import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/Repos/diet_plan_v2/diet_plan_admin_repository.dart';
import '../../data/Repos/diet_plan_v2/diet_plan_user_repository.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../values/constants.dart';

/// Dev-only screen for hand-testing the Phase E.1 diet-plan repos
/// without the production dietitian / user UI being built yet. Wire it
/// in temporarily during development (e.g. `Get.to(() => const
/// DietPlanApiTestScreen())`) and remove the route before shipping.
///
/// NOT in main navigation by design.
class DietPlanApiTestScreen extends StatelessWidget {
  const DietPlanApiTestScreen({super.key});

  String _token() {
    final auth = Get.find<AuthController>();
    return auth.sharedPreferences.getString(Constants.accessToken) ?? '';
  }

  Future<void> _testDrafts() async {
    final repo = Get.find<DietPlanAdminRepository>();
    try {
      final drafts = await repo.listMyDrafts(accessToken: _token());
      debugPrint(
        '[DietPlanApiTest] listMyDrafts → ${drafts.length} draft(s); '
        'ids=${drafts.map((p) => p.id).toList()}',
      );
      Get.snackbar(
        'Drafts',
        '${drafts.length} draft(s) — see console for ids',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DietPlanApiException catch (e) {
      debugPrint('[DietPlanApiTest] listMyDrafts FAILED: $e');
      Get.snackbar('Drafts failed', e.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _testActivePlan() async {
    final repo = Get.find<DietPlanUserRepository>();
    try {
      final plan = await repo.getMyActivePlan(accessToken: _token());
      if (plan == null) {
        debugPrint('[DietPlanApiTest] getMyActivePlan → null (no active plan)');
        Get.snackbar('Active plan', 'No active plan',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      debugPrint(
        '[DietPlanApiTest] getMyActivePlan → id=${plan.id} status=${plan.status} '
        'days=${plan.days.length} mealsPerDay=${plan.mealsPerDay}',
      );
      Get.snackbar(
        'Active plan',
        'id=${plan.id}, ${plan.days.length} days — see console',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DietPlanApiException catch (e) {
      debugPrint('[DietPlanApiTest] getMyActivePlan FAILED: $e');
      Get.snackbar('Active plan failed', e.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diet Plan API — dev test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tap a button — the result prints to the debug console '
              'and shows a brief snackbar. Both endpoints require a '
              'logged-in session (accessToken in SharedPreferences).',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testDrafts,
              child: const Text('Test: list my drafts (admin)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _testActivePlan,
              child: const Text('Test: get my active plan (user)'),
            ),
          ],
        ),
      ),
    );
  }
}
