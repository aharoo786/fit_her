import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/Repos/cycle_repo/cycle_data_repository.dart';
import '../data/controllers/auth_controller/auth_controller.dart';
import '../data/controllers/cycle_theme_controller/cycle_theme_controller.dart';
import '../data/services/cycle_engine.dart';
import '../values/constants.dart';
import '../widgets/new_home/community_footer.dart';
import '../widgets/new_home/feel_selector_card.dart';
import '../widgets/new_home/home_hero.dart';
import '../widgets/new_home/locked_insight_card.dart';
import '../widgets/new_home/locked_stats_grid.dart';
import '../widgets/new_home/trial_cta_card.dart';

/// Unpaid (free-trial / pre-purchase) home screen — composes the
/// `widgets/new_home/` set into a single scroll view. Mounted by
/// `home_screen.dart:45-47` for every unpaid user
/// (`logInUser.status == false`); the previous `useNewUnpaidHome`
/// feature-flag gate has been removed so new sign-ups land here
/// directly instead of the legacy UserHomeScreen.
///
/// Data sources today:
///   • firstName — `AuthController.logInUser.firstName`
///   • cycleInfo — `CycleDataRepository.getCycleData()`, cached for the
///     widget's lifetime so the FutureBuilder doesn't re-fire on every
///     rebuild (same pattern as profile_screen_user.dart's phase chip).
///   • upcomingSlots — empty list for now; the unpaid hero's
///     `HeroComingUpRow` self-hides on empty (returns `SizedBox.shrink()`),
///     so this teases nothing rather than showing fake classes. Wire to
///     a real "browse classes" endpoint when one exists.
class UnpaidHomeScreenV2 extends StatefulWidget {
  const UnpaidHomeScreenV2({super.key});

  @override
  State<UnpaidHomeScreenV2> createState() => _UnpaidHomeScreenV2State();
}

class _UnpaidHomeScreenV2State extends State<UnpaidHomeScreenV2> {
  final AuthController _auth = Get.find();

  // Cache the cycle fetch — without `late final`, the FutureBuilder would
  // create a new Future on every rebuild and flash through its loading
  // state each time, making the phase pill appear to flicker.
  late final Future<CycleInfo?> _cycleFuture = _fetchCycleInfo();

  Future<CycleInfo?> _fetchCycleInfo() async {
    try {
      final repo = Get.find<CycleDataRepository>();
      final token =
          _auth.sharedPreferences.getString(Constants.accessToken) ?? '';
      final response = await repo.getCycleData(accessToken: token);
      final body = response.body;
      if (body == null || body['status'] != '1' || body['data'] == null) {
        return null;
      }
      final data = body['data'];
      final provided = data['dataProvided'];
      final hasProvided =
          provided == 1 || provided == true || provided == '1';
      final last = data['lastPeriodDate'];
      if (!hasProvided || last == null) return null;
      final info = CycleEngine.calculate(
        lastPeriodDate: DateTime.parse(last.toString()),
        cycleLength: data['averageCycleLength'] ?? 28,
      );
      // Push phase to the global theme controller.
      try { Get.find<CycleThemeController>().setPhase(info?.phase); } catch (_) {}
      return info;
    } catch (_) {
      // Network blip / parse error → hero falls back to its
      // "Preview mode" label without crashing.
      return null;
    }
  }

  String _firstName() {
    final n = _auth.logInUser?.firstName.trim();
    return (n == null || n.isEmpty) ? '' : n;
  }

  @override
  Widget build(BuildContext context) {
    // Dark hero → white status-bar icons. Matches paid_home_screen_v2.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FCF7),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<CycleInfo?>(
                future: _cycleFuture,
                builder: (_, snap) {
                  return HomeHero(
                    firstName: _firstName(),
                    cycleInfo: snap.data,
                    // Empty list — HeroComingUpRow self-hides when no
                    // slots, so no "Tomorrow's classes" placeholder UI
                    // is shown for now.
                    upcomingSlots: const [],
                  );
                },
              ),
              Padding(
                // Bumped from (12, 14, 12, 24) — the first card sat too
                // close to the hero's bottom edge and aligned to a tighter
                // grid than the hero's 22-px content margin, so it looked
                // off-axis. 20-px horizontals + 20-px top lift give the
                // first banner room to breathe under "Strength Training".
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    FeelSelectorCard(),
                    LockedInsightCard(),
                    LockedStatsGrid(),
                    TrialCtaCard(),
                    CommunityFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
