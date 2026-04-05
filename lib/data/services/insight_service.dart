import 'package:fitness_zone_2/data/phase_config.dart';
import 'package:fitness_zone_2/data/static_insights.dart';
import 'package:fitness_zone_2/data/services/cycle_engine.dart';

class Insight {
  final String title;
  final String body;
  final PhaseEnergyEntry? energy;
  final PhaseMoodEntry? mood;
  final PhaseCravingEntry? craving;
  final PhaseWorkoutEntry? workout;

  const Insight({
    required this.title,
    required this.body,
    this.energy,
    this.mood,
    this.craving,
    this.workout,
  });
}

class InsightService {
  InsightService._();

  /// Returns today's insight based on cycle info.
  /// If [cycleInfo] is null (no cycle data), returns a generic nudge.
  static Insight getTodayInsight(CycleInfo? cycleInfo) {
    if (cycleInfo == null) {
      return _getGenericInsight();
    }

    final phase = cycleInfo.phase;
    final day = cycleInfo.cycleDay;

    final nudge = _getNudge(phase, day);
    final energy = _getEnergy(phase, day);
    final mood = _getMood(phase, day);
    final craving = _getCraving(phase, day);
    final workout = _getWorkout(phase, day);

    return Insight(
      title: nudge?.title ?? 'Your daily insight',
      body: nudge?.body ?? 'Listen to your body and move at your own pace.',
      energy: energy,
      mood: mood,
      craving: craving,
      workout: workout,
    );
  }

  static Insight _getGenericInsight() {
    final generic = StaticInsights.getGenericNudge();
    return Insight(
      title: generic.title,
      body: generic.body,
    );
  }

  /// Finds the nudge template matching the given phase and cycle day.
  static NudgeTemplate? _getNudge(String phase, int day) {
    final templates = StaticInsights.nudges[phase];
    if (templates == null) return null;

    for (final template in templates) {
      if (day >= template.dayStart && day <= template.dayEnd) {
        return template;
      }
    }

    // Day exceeds template range (e.g. late period, day > 28)
    // Return the last template for the phase
    return templates.isNotEmpty ? templates.last : null;
  }

  /// Finds the energy entry matching the given phase and cycle day.
  static PhaseEnergyEntry? _getEnergy(String phase, int day) {
    final entries = PhaseConfig.energy[phase];
    if (entries == null) return null;

    for (final entry in entries) {
      if (day >= entry.dayStart && day <= entry.dayEnd) {
        return entry;
      }
    }
    return entries.isNotEmpty ? entries.last : null;
  }

  /// Finds the mood entry matching the given phase and cycle day.
  static PhaseMoodEntry? _getMood(String phase, int day) {
    final entries = PhaseConfig.mood[phase];
    if (entries == null) return null;

    for (final entry in entries) {
      if (day >= entry.dayStart && day <= entry.dayEnd) {
        return entry;
      }
    }
    return entries.isNotEmpty ? entries.last : null;
  }

  /// Finds the craving entry matching the given phase and cycle day.
  /// Luteal phase uses sub-keys: luteal_early (day 17-21), luteal_late (day 22+).
  static PhaseCravingEntry? _getCraving(String phase, int day) {
    final key = phase == 'luteal' ? PhaseConfig.getLutealSubKey(day) : phase;
    final entries = PhaseConfig.cravings[key];
    if (entries == null || entries.isEmpty) return null;
    return entries.first;
  }

  /// Finds the workout entry matching the given phase and cycle day.
  /// Luteal phase uses sub-keys: luteal_early (day 17-21), luteal_late (day 22+).
  static PhaseWorkoutEntry? _getWorkout(String phase, int day) {
    final key = phase == 'luteal' ? PhaseConfig.getLutealSubKey(day) : phase;
    final entries = PhaseConfig.workout[key];
    if (entries == null || entries.isEmpty) return null;
    return entries.first;
  }
}
