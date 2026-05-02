import 'package:flutter/material.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// Cycle card — full-width display of the user's current cycle position.
/// Shell mirrors water/sleep/stats: white bg, mint border, 20 radius, soft
/// shadow. Renders only when `dashboard.cycle.cycleDay` is available; null
/// state collapses to nothing (onboarding is a separate concern).
class PaidCycleCard extends StatelessWidget {
  final HomeDashboardModel dashboard;

  const PaidCycleCard({Key? key, required this.dashboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cycle = dashboard.cycle;
    if (cycle == null || cycle.cycleDay == null) {
      return const SizedBox.shrink();
    }

    final phaseTheme = PhaseTheme.forPhaseString(cycle.phase);
    final phaseLabel = cycle.phaseLabel ?? phaseTheme.phaseLabel;
    final periodLine = _formatPeriodLine(cycle.periodInDays);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🌸 Cycle',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AB09A),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${cycle.cycleDay}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF163220),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            phaseLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: phaseTheme.accent,
            ),
          ),
          if (periodLine != null) ...[
            const SizedBox(height: 2),
            Text(
              periodLine,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9AB09A),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _formatPeriodLine(int? periodInDays) {
    if (periodInDays == null) return null;
    if (periodInDays == 0) return 'Period today';
    if (periodInDays == 1) return 'Period tomorrow';
    return 'Period in $periodInDays days';
  }
}
