import 'package:flutter/material.dart';

import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../new_home/phase_theme.dart';

/// H-01 greeting block: time-aware greeting + split-weight phase title
/// + dynamic chip row. Separators only appear between visible chips.
class PaidHeroGreeting extends StatelessWidget {
  final HomeDashboardModel dashboard;
  final PhaseTheme theme;
  final CyclePhase phase;

  const PaidHeroGreeting({
    Key? key,
    required this.dashboard,
    required this.theme,
    required this.phase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = (dashboard.user?.firstName ?? '').trim();
    final resolvedName = name.isEmpty ? 'there' : name;
    final greeting = '${_timeAwareGreeting()}, $resolvedName 🌿';

    final phaseLabel =
        dashboard.cycle?.phaseLabel ?? theme.phaseLabel;
    final emoji = theme.emoji;

    final chipColors = _chipColors(phase);
    final chips = <Widget>[];

    // Day chip — hidden entirely when cycleDay is null.
    final cycleDay = dashboard.cycle?.cycleDay;
    if (cycleDay != null) {
      chips.add(
        _chip('Day $cycleDay', 12, FontWeight.w700, chipColors.day),
      );
    }

    // Energy chip — always shown (theme-derived).
    chips.add(
      _chip(theme.energyLabel, 11, null,
          Colors.white.withOpacity(0.45)),
    );

    // Streak chip — show even at 0 (per B2.3 clarification).
    final streak = dashboard.goal?.streakDays;
    if (streak != null) {
      chips.add(
        _chip('$streak🔥', 11, FontWeight.w600, chipColors.streak),
      );
    }

    // Goal chip — "Set goal →" CTA when deltaKg is null; formatted delta
    // otherwise. Uses mathematical minus (U+2212), not a hyphen.
    chips.add(_goalChip(dashboard.goal?.deltaKg, theme.accent));

    // Interleave '·' separators only between visible chips.
    final interleaved = <Widget>[];
    for (int i = 0; i < chips.length; i++) {
      interleaved.add(chips[i]);
      if (i < chips.length - 1) interleaved.add(_separator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            greeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              // HTML: rgba(255,255,255,.22). We bumped this to 0.75 for the
              // unpaid hero based on user feedback "too dull to read"; the
              // paid hero is identical design intent — applying same bump.
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$phaseLabel ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.55),
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: emoji,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: interleaved,
          ),
        ],
      ),
    );
  }

  String _timeAwareGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _separator() => Text(
        '·',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withOpacity(0.18),
        ),
      );

  Widget _chip(String text, double size, FontWeight? weight, Color color) =>
      Text(
        text,
        style: TextStyle(fontSize: size, fontWeight: weight, color: color),
      );

  Widget _goalChip(double? deltaKg, Color accent) {
    if (deltaKg == null) {
      return Text(
        'Set goal →',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      );
    }
    final prefix = deltaKg < 0 ? '−' : (deltaKg > 0 ? '+' : '');
    final abs = deltaKg.abs().toStringAsFixed(1);
    return Text(
      '$prefix$abs kg',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: accent,
      ),
    );
  }
}

// Per-phase chip tint palette, traced exactly to H-01..H-04 in the HTML
// reference. Lives here (not PhaseTheme) because these colors are chip-row
// specific, don't apply elsewhere, and PhaseTheme is frozen.
({Color day, Color streak}) _chipColors(CyclePhase phase) {
  switch (phase) {
    case CyclePhase.follicular:
      return (day: const Color(0xFFA8F0C0), streak: const Color(0xFFFAC775));
    case CyclePhase.ovulatory:
      return (day: const Color(0xFF9FE1CB), streak: const Color(0xFFFAC775));
    case CyclePhase.luteal:
      return (day: const Color(0xFFFDE4A0), streak: const Color(0xFFFAC775));
    case CyclePhase.menstrual:
      // H-04 uses white @ 25% for streak color — period day 1 de-emphasis.
      return (
        day: const Color(0xFFFFB8B8),
        streak: Color.fromRGBO(255, 255, 255, 0.25),
      );
  }
}
