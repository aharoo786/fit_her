enum MealType { breakfast, lunch, dinner }
enum MealStatus { pending, followed, alternative, skipped }

/// Maps the current local time to a meal slot. Used by the home
/// Nutrition card to deep-link into the meal log for the meal the user
/// is most likely about to eat.
///   04:00–10:59 → breakfast
///   11:00–16:59 → lunch
///   17:00–03:59 → dinner   (late-evening + post-midnight both stay
///                           on dinner so a 1am log goes to today's
///                           dinner, not tomorrow's breakfast)
MealType currentMealForNow([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h >= 4 && h < 11) return MealType.breakfast;
  if (h >= 11 && h < 17) return MealType.lunch;
  return MealType.dinner;
}

MealType mealTypeFromString(String? s) {
  switch (s) {
    case 'breakfast': return MealType.breakfast;
    case 'lunch': return MealType.lunch;
    case 'dinner': return MealType.dinner;
    default: return MealType.breakfast;
  }
}

String mealTypeToString(MealType t) {
  switch (t) {
    case MealType.breakfast: return 'breakfast';
    case MealType.lunch: return 'lunch';
    case MealType.dinner: return 'dinner';
  }
}

MealStatus mealStatusFromString(String? s) {
  switch (s) {
    case 'followed': return MealStatus.followed;
    case 'alternative': return MealStatus.alternative;
    case 'skipped': return MealStatus.skipped;
    case 'pending': default: return MealStatus.pending;
  }
}

String mealStatusToString(MealStatus s) {
  switch (s) {
    case MealStatus.pending: return 'pending';
    case MealStatus.followed: return 'followed';
    case MealStatus.alternative: return 'alternative';
    case MealStatus.skipped: return 'skipped';
  }
}

/// Mirrors backend MealLogs row. `editable` is computed server-side from
/// the 7-day edit window (Section 6.6) and returned per row.
class MealLog {
  final int? id;
  final int? userId;
  final String date; // YYYY-MM-DD
  final MealType mealType;
  final MealStatus status;
  final String? reasonCode;
  final String? alternativeText;
  final DateTime? firstLoggedAt;
  final int editCount;
  final bool editable;

  const MealLog({
    this.id,
    this.userId,
    required this.date,
    required this.mealType,
    required this.status,
    this.reasonCode,
    this.alternativeText,
    this.firstLoggedAt,
    this.editCount = 0,
    this.editable = true,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      date: (json['date'] as String?) ?? '',
      mealType: mealTypeFromString(json['mealType'] as String?),
      status: mealStatusFromString(json['status'] as String?),
      reasonCode: json['reasonCode'] as String?,
      alternativeText: json['alternativeText'] as String?,
      firstLoggedAt: json['firstLoggedAt'] is String
          ? DateTime.tryParse(json['firstLoggedAt'] as String)
          : null,
      editCount: (json['editCount'] as int?) ?? 0,
      editable: (json['editable'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'mealType': mealTypeToString(mealType),
        'status': mealStatusToString(status),
        if (reasonCode != null) 'reasonCode': reasonCode,
        if (alternativeText != null) 'alternativeText': alternativeText,
      };
}
