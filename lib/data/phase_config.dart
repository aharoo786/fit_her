class PhaseEnergyEntry {
  final int dayStart;
  final int dayEnd;
  final int energy;
  final String label;

  const PhaseEnergyEntry({
    required this.dayStart,
    required this.dayEnd,
    required this.energy,
    required this.label,
  });
}

class PhaseMoodEntry {
  final int dayStart;
  final int dayEnd;
  final int mood;
  final String label;

  const PhaseMoodEntry({
    required this.dayStart,
    required this.dayEnd,
    required this.mood,
    required this.label,
  });
}

class PhaseCravingEntry {
  final String craving;
  final String detail;

  const PhaseCravingEntry({
    required this.craving,
    required this.detail,
  });
}

class PhaseWorkoutEntry {
  final String intensity;
  final List<String> bestTypes;
  final List<String> avoid;

  const PhaseWorkoutEntry({
    required this.intensity,
    required this.bestTypes,
    required this.avoid,
  });
}

class PhaseConfig {
  PhaseConfig._();

  // --- Energy Predictions (keyed by phase) ---
  static const Map<String, List<PhaseEnergyEntry>> energy = {
    'menstrual': [
      PhaseEnergyEntry(dayStart: 1, dayEnd: 2, energy: 2, label: 'Low'),
      PhaseEnergyEntry(dayStart: 3, dayEnd: 5, energy: 2, label: 'Low to Moderate'),
    ],
    'follicular': [
      PhaseEnergyEntry(dayStart: 6, dayEnd: 9, energy: 3, label: 'Rising'),
      PhaseEnergyEntry(dayStart: 10, dayEnd: 13, energy: 4, label: 'High'),
    ],
    'ovulatory': [
      PhaseEnergyEntry(dayStart: 14, dayEnd: 16, energy: 5, label: 'Peak'),
    ],
    'luteal': [
      PhaseEnergyEntry(dayStart: 17, dayEnd: 21, energy: 3, label: 'Moderate'),
      PhaseEnergyEntry(dayStart: 22, dayEnd: 25, energy: 2, label: 'Declining'),
      PhaseEnergyEntry(dayStart: 26, dayEnd: 28, energy: 2, label: 'Low'),
    ],
  };

  // --- Mood Predictions (keyed by phase) ---
  static const Map<String, List<PhaseMoodEntry>> mood = {
    'menstrual': [
      PhaseMoodEntry(dayStart: 1, dayEnd: 2, mood: 2, label: 'Low'),
      PhaseMoodEntry(dayStart: 3, dayEnd: 5, mood: 3, label: 'Improving'),
    ],
    'follicular': [
      PhaseMoodEntry(dayStart: 6, dayEnd: 13, mood: 4, label: 'Positive'),
    ],
    'ovulatory': [
      PhaseMoodEntry(dayStart: 14, dayEnd: 16, mood: 5, label: 'Peak'),
    ],
    'luteal': [
      PhaseMoodEntry(dayStart: 17, dayEnd: 21, mood: 3, label: 'Stable'),
      PhaseMoodEntry(dayStart: 22, dayEnd: 25, mood: 2, label: 'Irritability may increase'),
      PhaseMoodEntry(dayStart: 26, dayEnd: 28, mood: 2, label: 'PMS zone'),
    ],
  };

  // --- Craving Predictions (keyed by phase, luteal split by day range) ---
  static const Map<String, List<PhaseCravingEntry>> cravings = {
    'menstrual': [
      PhaseCravingEntry(
        craving: 'comfort',
        detail: 'Warm, salty, or iron-rich food cravings.',
      ),
    ],
    'follicular': [
      PhaseCravingEntry(
        craving: 'minimal',
        detail: 'Cravings low. Fresh food feels right.',
      ),
    ],
    'ovulatory': [
      PhaseCravingEntry(
        craving: 'none',
        detail: 'Energy high, appetite stable.',
      ),
    ],
    'luteal_early': [
      PhaseCravingEntry(
        craving: 'sweet',
        detail: 'Sugar cravings begin. Chocolate typical.',
      ),
    ],
    'luteal_late': [
      PhaseCravingEntry(
        craving: 'carbs_sweet',
        detail: 'Strong carb and sugar cravings. Hormonal.',
      ),
    ],
  };

  // --- Workout Intensity Recommendations (keyed by phase) ---
  static const Map<String, List<PhaseWorkoutEntry>> workout = {
    'menstrual': [
      PhaseWorkoutEntry(
        intensity: 'low',
        bestTypes: ['Gentle Yoga', 'Stretch', 'Meditation'],
        avoid: ['HIIT', 'Cardio Blast'],
      ),
    ],
    'follicular': [
      PhaseWorkoutEntry(
        intensity: 'medium_high',
        bestTypes: ['Strength', 'Cardio', 'Dance', 'Full Body'],
        avoid: [],
      ),
    ],
    'ovulatory': [
      PhaseWorkoutEntry(
        intensity: 'high',
        bestTypes: ['Power HIIT', 'Cardio', 'Strength', 'Dance'],
        avoid: [],
      ),
    ],
    'luteal_early': [
      PhaseWorkoutEntry(
        intensity: 'medium',
        bestTypes: ['Power Yoga', 'Pilates', 'Full Body'],
        avoid: ['Very high intensity'],
      ),
    ],
    'luteal_late': [
      PhaseWorkoutEntry(
        intensity: 'low_medium',
        bestTypes: ['Pilates', 'Gentle Yoga', 'Stretch'],
        avoid: ['Power HIIT'],
      ),
    ],
  };

  /// Returns the luteal sub-key based on cycle day.
  /// Day 17-21 = 'luteal_early', Day 22+ = 'luteal_late'.
  static String getLutealSubKey(int cycleDay) {
    return cycleDay <= 21 ? 'luteal_early' : 'luteal_late';
  }
}
