import 'package:flutter/material.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';
import 'paid_hero_coming_up.dart';
import 'paid_hero_greeting.dart';
import 'paid_hero_live_section.dart';
import 'paid_hero_top_bar.dart';

/// Dark phase-themed hero for PaidHomeScreenV2.
/// Layered per HTML reference:
///   background: <phase bg> + radial-gradient overlay
///   + 220×220 faint accent ring at top:-70 right:-50
///   border-radius: 0 0 36px 36px (bottom-only, flat top — hero paints
///   edge-to-edge under the status bar).
class PaidHero extends StatelessWidget {
  final HomeDashboardModel dashboard;

  const PaidHero({Key? key, required this.dashboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phase = parseCyclePhase(dashboard.cycle?.phase);
    final theme = PhaseTheme.forPhase(phase);

    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(36),
      bottomRight: Radius.circular(36),
    );

    final initial = _resolveInitial(dashboard);
    final gradTint = _gradTint(phase);
    final gradAlpha = _gradAlpha(phase);

    return Container(
      decoration: BoxDecoration(
        color: theme.heroBackground,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Stack(
            children: [
              // 1. Radial-gradient overlay (phase-specific middle-tone fading
              // to transparent). Alpha-only fade so the base bg shows through.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(1.1, -1.05),
                        radius: 1.3,
                        colors: [
                          gradTint.withOpacity(gradAlpha),
                          gradTint.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
              // 2. Decorative ring — clipped by the hero's ClipRRect on
              // the bottom corners, escapes freely at the top.
              Positioned(
                top: -70,
                right: -50,
                child: IgnorePointer(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.accent.withOpacity(0.07),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // 3. Content — the only non-positioned child, so the Stack
              // sizes to its height. `SizedBox(width: double.infinity)`
              // guards against the loose-constraint collapse pattern.
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PaidHeroTopBar(theme: theme, initial: initial),
                    PaidHeroGreeting(
                      dashboard: dashboard,
                      theme: theme,
                      phase: phase,
                    ),
                    _buildDivider(theme),
                    PaidHeroLiveSection(live: dashboard.live, theme: theme),
                    PaidHeroComingUp(comingUp: dashboard.comingUp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(PhaseTheme theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            theme.accent.withOpacity(0.18),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  String _resolveInitial(HomeDashboardModel dashboard) {
    final explicit = dashboard.user?.initial;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final first = dashboard.user?.firstName;
    if (first != null && first.isNotEmpty) return first[0].toUpperCase();
    return 'U';
  }
}

/// Per-phase middle-tone for the radial-gradient overlay. Traced to
/// `new screens/Home_All43_Variants.html` lines 228-248.
/// Not added to [PhaseTheme] because it only matters for this single
/// visual effect and PhaseTheme is frozen for Phase B.
Color _gradTint(CyclePhase phase) {
  switch (phase) {
    case CyclePhase.follicular:
      return const Color(0xFF46823C); // rgba(70,130,60,·)
    case CyclePhase.ovulatory:
      return const Color(0xFF146E5A); // rgba(20,110,90,·)
    case CyclePhase.luteal:
      return const Color(0xFF6E460F); // rgba(110,70,15,·)
    case CyclePhase.menstrual:
      return const Color(0xFF6E1414); // rgba(110,20,20,·)
  }
}

/// Per-phase overlay alpha. Follicular uses .4; the other three use .5 per
/// HTML. Small variance matters — too much green saturates the top-right.
double _gradAlpha(CyclePhase phase) {
  return phase == CyclePhase.follicular ? 0.40 : 0.50;
}
