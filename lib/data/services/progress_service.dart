class ProgressReport {
  final int checkinsThisWeek;
  final bool weeklyReportReady;
  final int checkinsThisCycle;
  final bool monthlyReportReady;

  const ProgressReport({
    required this.checkinsThisWeek,
    required this.weeklyReportReady,
    required this.checkinsThisCycle,
    required this.monthlyReportReady,
  });
}

class ProgressService {
  ProgressService._();

  /// Count checkins this week (Mon-Sun).
  /// [weekCheckins] should be the list from GET /users/daily_checkins/week.
  static int countCheckinsThisWeek(
    List<Map<String, dynamic>> weekCheckins,
  ) {
    return weekCheckins.length;
  }

  /// Count checkins since lastPeriodDate.
  /// [recentCheckins] should have a 'date' field (YYYY-MM-DD).
  static int countCheckinsThisCycle(
    List<Map<String, dynamic>> recentCheckins,
    DateTime lastPeriodDate,
  ) {
    final periodDateStr =
        '${lastPeriodDate.year}-${lastPeriodDate.month.toString().padLeft(2, '0')}-${lastPeriodDate.day.toString().padLeft(2, '0')}';

    int count = 0;
    for (final checkin in recentCheckins) {
      final date = checkin['date'] as String?;
      if (date != null && date.compareTo(periodDateStr) >= 0) {
        count++;
      }
    }
    return count;
  }

  /// Build full progress report.
  static ProgressReport getProgressReport({
    required List<Map<String, dynamic>> weekCheckins,
    required List<Map<String, dynamic>> recentCheckins,
    DateTime? lastPeriodDate,
  }) {
    final checkinsThisWeek = countCheckinsThisWeek(weekCheckins);

    int checkinsThisCycle = 0;
    if (lastPeriodDate != null) {
      checkinsThisCycle = countCheckinsThisCycle(recentCheckins, lastPeriodDate);
    }

    return ProgressReport(
      checkinsThisWeek: checkinsThisWeek,
      weeklyReportReady: checkinsThisWeek >= 4,
      checkinsThisCycle: checkinsThisCycle,
      monthlyReportReady: checkinsThisCycle >= 15,
    );
  }
}
