import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/controllers/paid_home_controller/paid_home_controller.dart';
import '../widgets/paid_home_v2/paid_feel_selector.dart';
import '../widgets/paid_home_v2/paid_footer.dart';
import '../widgets/paid_home_v2/paid_hero.dart';
import '../widgets/paid_home_v2/paid_insight_card.dart';
import '../widgets/paid_home_v2/paid_sleep_card.dart';
import '../widgets/paid_home_v2/paid_stats_row.dart';
import '../widgets/paid_home_v2/paid_water_card.dart';

/// PaidHomeScreenV2 — phase-themed dashboard for paid users behind the
/// `useNewPaidHome` feature flag. Phase B2.3 ships only the hero section
/// (top bar + greeting + LIVE + coming up). The cream body below is a
/// placeholder that will be filled in subsequent phases (insight, mood,
/// water, sleep, stats, cycle/nutrition, footer).
class PaidHomeScreenV2 extends StatefulWidget {
  const PaidHomeScreenV2({super.key});

  @override
  State<PaidHomeScreenV2> createState() => _PaidHomeScreenV2State();
}

class _PaidHomeScreenV2State extends State<PaidHomeScreenV2> {
  final PaidHomeController _controller = Get.find<PaidHomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.dashboard.value == null) {
        _controller.loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Status-bar styling — single mechanism: AnnotatedRegion. The hero
    // (PaidHero) has a flat top and paints from y=0 (Scaffold body has no
    // implicit SafeArea); PaidHeroTopBar already pads its content by
    // `MediaQuery.padding.top + 14` so bell + avatar clear the system
    // chrome. With edgeToEdge enabled in main.dart, a transparent
    // statusBarColor lets the hero's actual phase colour show through
    // the OS bar — no fake-tint scrim, no imperative SystemChrome push,
    // no possibility of a stale "mint band" from splash sticking around.
    return Obx(() {
      // Even though the per-phase colour is no longer wired into the
      // status bar, we still rebuild on dashboard changes so AnnotatedRegion
      // refreshes if anything else (icon brightness, etc.) ever needs to.
      _controller.dashboard.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          // Transparent so the hero's dark phase colour paints the strip.
          statusBarColor: Colors.transparent,
          // Android: light icons render white on dark hero.
          statusBarIconBrightness: Brightness.light,
          // iOS: `Brightness.dark` reads as "the surface is dark" — system
          // renders status-bar content in white. Platform-inverted naming.
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          // Cream body bg matches the H-01 reference scroll area below the
          // hero. Unchanged.
          backgroundColor: const Color(0xFFEAF7E4),
          body: _buildBody(),
        ),
      );
    });
  }

  Widget _buildBody() {
    return Obx(() {
      if (_controller.isLoading.value &&
          _controller.dashboard.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final dashboard = _controller.dashboard.value;
      if (dashboard == null) {
        return Center(
          child: Text(
            _controller.errorMessage.value.isEmpty
                ? 'No data'
                : _controller.errorMessage.value,
            style: const TextStyle(color: Colors.black54),
          ),
        );
      }
      return RefreshIndicator(
          onRefresh: _controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                PaidHero(dashboard: dashboard),
                // Cream scroll body. Insight card is the first section;
                // everything below the `SizedBox` is a placeholder that
                // future phases fill in (mood, water/sleep, stats, etc.).
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PaidInsightCard(dashboard: dashboard),
                      const SizedBox(height: 8),
                      PaidFeelSelector(dashboard: dashboard),
                      const SizedBox(height: 8),
                      // Water + Sleep row. IntrinsicHeight keeps the two
                      // cards the same height even though the water card
                      // has extra button rows underneath the bar.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: PaidWaterCard(dashboard: dashboard)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: PaidSleepCard(dashboard: dashboard)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      PaidStatsRow(dashboard: dashboard),
                      const SizedBox(height: 8),
                      // PaidCycleCard removed from this position —
                      // PaidStatsRow now embeds it in Row 2 alongside
                      // Nutrition. Re-adding it here would render
                      // cycle data twice.
                      PaidFooter(dashboard: dashboard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }
}
