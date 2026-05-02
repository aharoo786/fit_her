import 'package:flutter/material.dart';

/// Cycle phases as emitted by the backend (`CyclePhaseCalculator`,
/// `UserCycleData.currentPhase`, and the dashboard endpoint's `cycle.phase`).
/// Note: the engine emits `ovulatory`, not `ovulation` — the distinction
/// matters for [parseCyclePhase].
enum CyclePhase { follicular, ovulatory, luteal, menstrual }

/// Tolerant parse from any string source. Returns follicular for null,
/// empty, or unknown input. Never throws.
CyclePhase parseCyclePhase(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'ovulatory':
      return CyclePhase.ovulatory;
    case 'luteal':
      return CyclePhase.luteal;
    case 'menstrual':
      return CyclePhase.menstrual;
    case 'follicular':
    default:
      return CyclePhase.follicular;
  }
}

/// Per-phase visual + copy bundle used by every PaidHomeScreenV2 widget.
/// Values traced to the H-01..H-04 HTML reference
/// (new screens/Home_All43_Variants.html lines 227-254).
class PhaseTheme {
  final Color heroBackground;
  final Color accent;
  final String emoji;
  final String energyLabel;
  final String phaseLabel;

  const PhaseTheme({
    required this.heroBackground,
    required this.accent,
    required this.emoji,
    required this.energyLabel,
    required this.phaseLabel,
  });

  /// Kept as a distinct getter so future tweaks (e.g. softer accent on the
  /// insight card) don't require touching every call site.
  Color get insightAccent => accent;

  static const PhaseTheme follicular = PhaseTheme(
    heroBackground: Color(0xFF163220),
    accent: Color(0xFF6DC55A),
    emoji: '⚡',
    energyLabel: 'Peak energy',
    phaseLabel: 'Follicular Phase',
  );

  static const PhaseTheme ovulatory = PhaseTheme(
    heroBackground: Color(0xFF0A2420),
    accent: Color(0xFF5ECFB0),
    emoji: '✨',
    energyLabel: 'Peak performance',
    // "Ovulation" (not "Ovulation Phase") matches the backend's phaseLabel
    // emitted by DashboardController.PHASE_LABELS — keeps the client-side
    // fallback consistent with the server's value.
    phaseLabel: 'Ovulation',
  );

  static const PhaseTheme luteal = PhaseTheme(
    heroBackground: Color(0xFF1E1208),
    accent: Color(0xFFFAC775),
    emoji: '🌙',
    energyLabel: 'Energy dipping',
    phaseLabel: 'Luteal Phase',
  );

  static const PhaseTheme menstrual = PhaseTheme(
    heroBackground: Color(0xFF1E0808),
    accent: Color(0xFFFF8A8A),
    emoji: '🌺',
    energyLabel: 'Rest & restore',
    phaseLabel: 'Menstrual Phase',
  );

  static PhaseTheme forPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.follicular:
        return follicular;
      case CyclePhase.ovulatory:
        return ovulatory;
      case CyclePhase.luteal:
        return luteal;
      case CyclePhase.menstrual:
        return menstrual;
    }
  }

  /// Convenience that combines [parseCyclePhase] + [forPhase] so widgets
  /// can feed in the raw `dashboard.cycle.phase` string directly.
  static PhaseTheme forPhaseString(String? raw) =>
      forPhase(parseCyclePhase(raw));
}
