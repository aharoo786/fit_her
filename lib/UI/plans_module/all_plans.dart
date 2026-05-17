import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/meal_details.dart';
import 'package:fitness_zone_2/widgets/v2/v2_price_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/get_user_plan/get_user_plan.dart';

class OurPlansScreen extends StatelessWidget {
  OurPlansScreen({super.key});
  final HomeController homeController = Get.find();

  static const _kCream = Color(0xFFEAF7E4);
  static const _kHeroDark = Color(0xFF163220);
  static const _kSage = Color(0xFF9AB09A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: Obx(
                () => homeController.getPlanLoaded.value
                    ? _buildList()
                    : const Center(child: CircularProgress()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: _kHeroDark, size: 22),
          ),
          const Spacer(),
          const Text(
            'OUR PLANS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kSage,
              letterSpacing: 0.84,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildList() {
    final plans = homeController.allPlanModel?.plans ?? const <Plan>[];
    if (plans.isEmpty) {
      return const Center(
        child: Text(
          'No plans available',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF6F8B7A),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final plan = plans[index];
        if (plan.countries != null &&
            plan.countries!.isNotEmpty &&
            plan.countries!.first.duration!.isNotEmpty) {
          if (plan.selectedDurationId.value == 0) {
            plan.selectedDurationId.value =
                plan.countries!.first.duration!.first.id ?? 0;
          }
        }
        return V2PriceCard(
          plan: plan,
          onSubscribe: () => _onSubscribe(plan),
        );
      },
    );
  }

  void _onSubscribe(Plan plan) {
    DurationPlan? durationPlan;
    if (plan.countries != null &&
        plan.countries!.isNotEmpty &&
        plan.countries!.first.duration!.isNotEmpty) {
      durationPlan = plan.countries!.first.duration!.firstWhere(
        (d) => d.id == plan.selectedDurationId.value,
        orElse: () => plan.countries!.first.duration!.first,
      );
    }

    Get.to(() => DietDetails(
          isPlan: true,
          title: plan.title,
          description: plan.shortDescription,
          longDescription: plan.longDescription,
          planId: plan.id.toString(),
          currency: plan.countries?.first.currency ?? 'Rs.',
          price: durationPlan?.priceAmount ?? '',
          duration: durationPlan?.days ?? '',
          durationId: plan.selectedDurationId.value,
        ));
  }
}
