class CycleInfo {
  final int cycleDay;
  final String phase;

  const CycleInfo({
    required this.cycleDay,
    required this.phase,
  });

  @override
  String toString() => 'CycleInfo(day: $cycleDay, phase: $phase)';
}

class CycleEngine {
  CycleEngine._();

  /// Calculates current cycle day and phase from last period date and cycle length.
  ///
  /// Returns null if [lastPeriodDate] is null (no data provided).
  /// If the user is past her expected cycle length, continues counting
  /// beyond cycleLength (does NOT modulo). Phase stays 'luteal'.
  static CycleInfo? calculate({
    required DateTime? lastPeriodDate,
    required int cycleLength,
    DateTime? today,
  }) {
    if (lastPeriodDate == null) return null;

    final now = today ?? DateTime.now();
    final daysSince = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastPeriodDate.year, lastPeriodDate.month, lastPeriodDate.day))
        .inDays;

    final int cycleDay;
    if (daysSince >= cycleLength) {
      // Period is late — continue counting, do NOT modulo
      cycleDay = daysSince + 1;
    } else {
      cycleDay = (daysSince % cycleLength) + 1;
    }

    final phase = _getPhase(cycleDay, cycleLength);
    return CycleInfo(cycleDay: cycleDay, phase: phase);
  }

  /// Determines the phase based on cycle day and cycle length.
  /// Phase boundaries scale proportionally to cycle length.
  static String _getPhase(int cycleDay, int cycleLength) {
    final menstrualEnd = (cycleLength * 0.18).round();
    final follicularEnd = (cycleLength * 0.46).round();
    final ovulatoryEnd = (cycleLength * 0.57).round();

    if (cycleDay <= menstrualEnd) return 'menstrual';
    if (cycleDay <= follicularEnd) return 'follicular';
    if (cycleDay <= ovulatoryEnd) return 'ovulatory';
    return 'luteal';
  }

  /// Returns the phase boundaries for a given cycle length.
  static Map<String, List<int>> getPhaseBoundaries(int cycleLength) {
    final menstrualEnd = (cycleLength * 0.18).round();
    final follicularEnd = (cycleLength * 0.46).round();
    final ovulatoryEnd = (cycleLength * 0.57).round();

    return {
      'menstrual': [1, menstrualEnd],
      'follicular': [menstrualEnd + 1, follicularEnd],
      'ovulatory': [follicularEnd + 1, ovulatoryEnd],
      'luteal': [ovulatoryEnd + 1, cycleLength],
    };
  }
}
