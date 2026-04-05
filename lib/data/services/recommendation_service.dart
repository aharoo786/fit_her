/// Recommendation service that maps workout slot types to intensity levels
/// and determines if a slot is recommended for the user's current cycle phase.
///
/// Uses intensity data from [PhaseConfig.workout] to match slots.
class RecommendationService {
  RecommendationService._();

  /// Maps slot type names to intensity: high, medium, or low.
  static const Map<String, String> _typeToIntensity = {
    'Power HIIT': 'high',
    'Cardio Blast': 'high',
    'Strength & Tone': 'high',
    'Full Body Burn': 'medium',
    'Dance Fitness': 'medium',
    'Power Yoga': 'medium',
    'Pilates': 'medium',
    'Gentle Yoga': 'low',
    'Stretch & Restore': 'low',
    'Meditation & Breathwork': 'low',
  };

  /// Phase to recommended intensity set.
  /// Derived from PhaseConfig.workout entries.
  static const Map<String, Set<String>> _phaseToIntensities = {
    'menstrual': {'low'},
    'follicular': {'medium', 'high'},
    'ovulatory': {'high'},
    'luteal': {'low', 'medium'},
    'luteal_early': {'medium'},
    'luteal_late': {'low', 'medium'},
  };

  /// Returns the intensity for a slot type name.
  ///
  /// Case-insensitive partial match — e.g. "power hiit" matches "Power HIIT",
  /// and "Yoga" matches "Gentle Yoga" or "Power Yoga" (first match wins).
  /// Returns null if no match found.
  static String? getSlotIntensity(String? type) {
    if (type == null || type.trim().isEmpty) return null;

    final lower = type.toLowerCase().trim();

    // Exact match first (case-insensitive)
    for (final entry in _typeToIntensity.entries) {
      if (entry.key.toLowerCase() == lower) {
        return entry.value;
      }
    }

    // Partial match: slot type contains the key or key contains the slot type
    for (final entry in _typeToIntensity.entries) {
      final keyLower = entry.key.toLowerCase();
      if (lower.contains(keyLower) || keyLower.contains(lower)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Returns true if the slot type's intensity matches what's recommended
  /// for the given cycle phase.
  ///
  /// - `menstrual` → low only
  /// - `follicular` → medium and high
  /// - `ovulatory` → high only
  /// - `luteal` / `luteal_late` → low and medium
  /// - `luteal_early` → medium only
  ///
  /// Returns false if type or phase is null, or intensity is unknown.
  static bool isRecommended(String? slotType, String? phase) {
    if (slotType == null || phase == null) return false;

    final intensity = getSlotIntensity(slotType);
    if (intensity == null) return false;

    final recommended = _phaseToIntensities[phase.toLowerCase().trim()];
    if (recommended == null) return false;

    return recommended.contains(intensity);
  }

  /// Filters a list of items to only those recommended for the given phase.
  ///
  /// [getType] extracts the slot type name from each item.
  /// Returns at most 5 results.
  static List<T> filterRecommended<T>(
    List<T> slots,
    String? Function(T) getType,
    String? phase,
  ) {
    if (phase == null) return [];

    final results = <T>[];
    for (final slot in slots) {
      if (results.length >= 5) break;
      if (isRecommended(getType(slot), phase)) {
        results.add(slot);
      }
    }
    return results;
  }
}
