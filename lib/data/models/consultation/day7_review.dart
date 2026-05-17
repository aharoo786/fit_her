/// Mirrors backend Day7Reviews row. The flag fields are read-only from
/// the client's perspective — server hook computes them on save (Decision
/// 6 thresholds: adherence < 40, pain reported, severe side effects,
/// satisfaction < 2).
class Day7Review {
  final int? id;
  final int? userId;
  final int? userPlanId;
  final int? cycle;
  final String? planType; // diet | workout | combined

  // Diet-side
  final int? adherencePct; // 0..100
  final List<dynamic>? mealsStruggled;
  final String? hungerLevel;
  final List<dynamic>? sideEffects;

  // Workout-side
  final String? difficultyLevel;
  final bool? sessionTimingIssues;

  // Shared / flag inputs
  final bool painReported;
  final String? painLocation;
  final bool severeSideEffectsReported;
  final int? satisfaction; // 1..5

  // Server-computed
  final bool flagged;
  final List<dynamic>? flagReasons;

  final DateTime? createdAt;

  const Day7Review({
    this.id,
    this.userId,
    this.userPlanId,
    this.cycle,
    this.planType,
    this.adherencePct,
    this.mealsStruggled,
    this.hungerLevel,
    this.sideEffects,
    this.difficultyLevel,
    this.sessionTimingIssues,
    this.painReported = false,
    this.painLocation,
    this.severeSideEffectsReported = false,
    this.satisfaction,
    this.flagged = false,
    this.flagReasons,
    this.createdAt,
  });

  factory Day7Review.fromJson(Map<String, dynamic> json) {
    return Day7Review(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      userPlanId: json['userPlanId'] as int?,
      cycle: json['cycle'] as int?,
      planType: json['planType'] as String?,
      adherencePct: json['adherencePct'] as int?,
      mealsStruggled: json['mealsStruggled'] as List<dynamic>?,
      hungerLevel: json['hungerLevel'] as String?,
      sideEffects: json['sideEffects'] as List<dynamic>?,
      difficultyLevel: json['difficultyLevel'] as String?,
      sessionTimingIssues: json['sessionTimingIssues'] as bool?,
      painReported: (json['painReported'] as bool?) ?? false,
      painLocation: json['painLocation'] as String?,
      severeSideEffectsReported:
          (json['severeSideEffectsReported'] as bool?) ?? false,
      satisfaction: json['satisfaction'] as int?,
      flagged: (json['flagged'] as bool?) ?? false,
      flagReasons: json['flagReasons'] as List<dynamic>?,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Submission body — server computes flag on its end. No flag fields here.
  Map<String, dynamic> toJson() => {
        if (userPlanId != null) 'userPlanId': userPlanId,
        if (cycle != null) 'cycle': cycle,
        if (planType != null) 'planType': planType,
        if (adherencePct != null) 'adherencePct': adherencePct,
        if (mealsStruggled != null) 'mealsStruggled': mealsStruggled,
        if (hungerLevel != null) 'hungerLevel': hungerLevel,
        if (sideEffects != null) 'sideEffects': sideEffects,
        if (difficultyLevel != null) 'difficultyLevel': difficultyLevel,
        if (sessionTimingIssues != null)
          'sessionTimingIssues': sessionTimingIssues,
        'painReported': painReported,
        if (painLocation != null) 'painLocation': painLocation,
        'severeSideEffectsReported': severeSideEffectsReported,
        if (satisfaction != null) 'satisfaction': satisfaction,
      };
}
