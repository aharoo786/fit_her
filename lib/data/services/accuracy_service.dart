class AccuracyService {
  AccuracyService._();

  /// Per-day accuracy: compares predicted vs actual energy and mood.
  /// Returns 0.0 to 1.0.
  static double calculateDayAccuracy({
    required int predictedEnergy,
    required int actualEnergy,
    required int predictedMood,
    required int actualMood,
  }) {
    final energyMatch = _matchScore(predictedEnergy, actualEnergy);
    final moodMatch = _matchScore(predictedMood, actualMood);
    return (energyMatch + moodMatch) / 2.0;
  }

  static double _matchScore(int predicted, int actual) {
    final diff = (predicted - actual).abs();
    if (diff <= 1) return 1.0;
    if (diff == 2) return 0.5;
    return 0.0;
  }

  /// Rolling 7-day accuracy from list of checkins.
  /// Each checkin map should have: predictedEnergy, predictedMood,
  /// energyLevel, moodLevel (camelCase, matching API response).
  /// Returns null if less than 3 valid checkins or accuracy < 60%.
  static double? getRolling7DayAccuracy(
    List<Map<String, dynamic>> recentCheckins,
  ) {
    double totalAccuracy = 0;
    int count = 0;

    for (final checkin in recentCheckins) {
      final predictedEnergy = checkin['predictedEnergy'] as int?;
      final predictedMood = checkin['predictedMood'] as int?;
      final actualEnergy = checkin['energyLevel'] as int?;
      final actualMood = checkin['moodLevel'] as int?;

      if (predictedEnergy != null &&
          predictedMood != null &&
          actualEnergy != null &&
          actualMood != null) {
        totalAccuracy += calculateDayAccuracy(
          predictedEnergy: predictedEnergy,
          actualEnergy: actualEnergy,
          predictedMood: predictedMood,
          actualMood: actualMood,
        );
        count++;
      }
    }

    if (count < 3) return null;

    final accuracy = totalAccuracy / count;

    // Positive framing: don't show low accuracy
    if (accuracy < 0.60) return null;

    return accuracy.clamp(0.0, 1.0);
  }

  /// Format for display: 0.78 → "78"
  static String formatAccuracy(double accuracy) {
    return (accuracy * 100).round().toString();
  }
}
