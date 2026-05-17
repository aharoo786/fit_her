// Lightweight MealLog model for the Phase F.2 user-side logging flow.
//
// Why a parallel model: the legacy `lib/data/models/meal_log/meal_log.dart`
// uses a 3-value `MealType` enum hardcoded to breakfast/lunch/dinner.
// Phase F.2 needs to log all 6 meal types from the structured plan.
// Extending the legacy enum would force changes to PaidMealLogCard +
// MealLogController + 5 other call sites. Per the F.2 spec ("don't
// refactor PaidMealLogCard"), keep the legacy model untouched and use
// this V2 model in the new flow only.
//
// `mealTypeWire` is the snake_case backend ENUM string — kept as a raw
// String here because the consumer (V2TodayMealsSection) resolves it
// against `MealTypeV2` from the diet-plan model when rendering. The
// wire string is the source of truth for backend interop.

enum MealLogStatusV2 { pending, followed, alternative, skipped }

MealLogStatusV2 mealLogStatusV2FromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'followed':
      return MealLogStatusV2.followed;
    case 'alternative':
      return MealLogStatusV2.alternative;
    case 'skipped':
      return MealLogStatusV2.skipped;
    case 'pending':
    default:
      return MealLogStatusV2.pending;
  }
}

String mealLogStatusV2ToString(MealLogStatusV2 s) {
  switch (s) {
    case MealLogStatusV2.pending:
      return 'pending';
    case MealLogStatusV2.followed:
      return 'followed';
    case MealLogStatusV2.alternative:
      return 'alternative';
    case MealLogStatusV2.skipped:
      return 'skipped';
  }
}

class MealLogV2 {
  final int? id;
  final String date; // YYYY-MM-DD
  final String mealTypeWire; // backend ENUM string
  final MealLogStatusV2 status;
  final String? reasonCode;
  final String? alternativeText;
  final int? dietPlanMealId;

  const MealLogV2({
    this.id,
    required this.date,
    required this.mealTypeWire,
    required this.status,
    this.reasonCode,
    this.alternativeText,
    this.dietPlanMealId,
  });

  /// Pending placeholder for a meal slot the user hasn't logged yet —
  /// the controller seeds this so the UI can read a status off every
  /// meal without null-checking everywhere.
  factory MealLogV2.pending({
    required String date,
    required String mealTypeWire,
    int? dietPlanMealId,
  }) =>
      MealLogV2(
        date: date,
        mealTypeWire: mealTypeWire,
        status: MealLogStatusV2.pending,
        dietPlanMealId: dietPlanMealId,
      );

  factory MealLogV2.fromJson(Map<String, dynamic> json) {
    return MealLogV2(
      id: _toInt(json['id']),
      date: (json['date'] ?? '').toString(),
      mealTypeWire: (json['mealType'] ?? '').toString(),
      status: mealLogStatusV2FromString(json['status']?.toString()),
      reasonCode: json['reasonCode']?.toString(),
      alternativeText: json['alternativeText']?.toString(),
      dietPlanMealId: _toInt(json['dietPlanMealId']),
    );
  }

  MealLogV2 copyWith({
    int? id,
    String? date,
    String? mealTypeWire,
    MealLogStatusV2? status,
    String? reasonCode,
    String? alternativeText,
    int? dietPlanMealId,
    bool clearAlternativeText = false,
  }) {
    return MealLogV2(
      id: id ?? this.id,
      date: date ?? this.date,
      mealTypeWire: mealTypeWire ?? this.mealTypeWire,
      status: status ?? this.status,
      reasonCode: reasonCode ?? this.reasonCode,
      alternativeText: clearAlternativeText
          ? null
          : (alternativeText ?? this.alternativeText),
      dietPlanMealId: dietPlanMealId ?? this.dietPlanMealId,
    );
  }
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
