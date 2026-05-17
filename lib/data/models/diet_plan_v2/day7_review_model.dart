// Phase G.3 — Day 7 check-in submission + response shapes.
// Wire payload mirrors `partner_backend/controllers/FrontSite/day7ReviewController.js`
// `submitReview`. Required: userPlanId + cycle + planType. Everything
// else is optional — the user picks whichever sections she fills out.

/// Hunger level ENUM the backend whitelists. Free-form strings on the
/// wire; the enum here is just the authoring surface for the form.
enum HungerLevelV2 { alwaysHungry, justRight, tooFull }

String hungerLevelToWire(HungerLevelV2 v) {
  switch (v) {
    case HungerLevelV2.alwaysHungry:
      return 'always_hungry';
    case HungerLevelV2.justRight:
      return 'just_right';
    case HungerLevelV2.tooFull:
      return 'too_full';
  }
}

enum DifficultyLevelV2 { tooEasy, justRight, tooHard }

String difficultyLevelToWire(DifficultyLevelV2 v) {
  switch (v) {
    case DifficultyLevelV2.tooEasy:
      return 'too_easy';
    case DifficultyLevelV2.justRight:
      return 'just_right';
    case DifficultyLevelV2.tooHard:
      return 'too_hard';
  }
}

/// One half of the wire shape — the *input* to POST /users/day7-review.
/// Builder-style toJson lets us send only the fields the user
/// actually filled, matching the backend's `pickReviewFields` whitelist.
class Day7ReviewSubmission {
  final int userPlanId;
  final int cycle;
  final String planType; // 'diet' | 'workout' | 'combined'

  // All optional — user can submit a partial review.
  final int? adherencePct;
  final List<String> mealsStruggled;
  final HungerLevelV2? hungerLevel;
  final List<String> sideEffects;
  final DifficultyLevelV2? difficultyLevel;
  final bool? sessionTimingIssues;
  final bool painReported;
  final String? painLocation;
  final bool severeSideEffectsReported;
  final int? satisfaction; // 1..5

  const Day7ReviewSubmission({
    required this.userPlanId,
    required this.cycle,
    required this.planType,
    this.adherencePct,
    this.mealsStruggled = const [],
    this.hungerLevel,
    this.sideEffects = const [],
    this.difficultyLevel,
    this.sessionTimingIssues,
    this.painReported = false,
    this.painLocation,
    this.severeSideEffectsReported = false,
    this.satisfaction,
  });

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{
      'userPlanId': userPlanId,
      'cycle': cycle,
      'planType': planType,
      // Booleans always sent — backend whitelist accepts them as-is and
      // false is meaningful (versus "not asked", which we just don't
      // surface in the form for these specific fields).
      'painReported': painReported,
      'severeSideEffectsReported': severeSideEffectsReported,
    };
    if (adherencePct != null) out['adherencePct'] = adherencePct;
    if (mealsStruggled.isNotEmpty) out['mealsStruggled'] = mealsStruggled;
    if (hungerLevel != null) {
      out['hungerLevel'] = hungerLevelToWire(hungerLevel!);
    }
    if (sideEffects.isNotEmpty) out['sideEffects'] = sideEffects;
    if (difficultyLevel != null) {
      out['difficultyLevel'] = difficultyLevelToWire(difficultyLevel!);
    }
    if (sessionTimingIssues != null) {
      out['sessionTimingIssues'] = sessionTimingIssues;
    }
    if (painLocation != null && painLocation!.trim().isNotEmpty) {
      out['painLocation'] = painLocation!.trim();
    }
    if (satisfaction != null) out['satisfaction'] = satisfaction;
    return out;
  }
}

/// Response shape — the saved Day7Review row. `flagged` + `flagReasons`
/// are server-computed via the model hook so the client never needs to
/// derive them. We only parse the bits Phase G.3's UI needs (id +
/// flagged) — adding fields later is additive.
class Day7Review {
  final int id;
  final int userPlanId;
  final int cycle;
  final bool flagged;
  final List<String> flagReasons;

  const Day7Review({
    required this.id,
    required this.userPlanId,
    required this.cycle,
    required this.flagged,
    this.flagReasons = const [],
  });

  factory Day7Review.fromJson(Map<String, dynamic> json) {
    final raw = json['flagReasons'];
    final reasons = raw is List
        ? raw.map((e) => e.toString()).toList()
        : const <String>[];
    return Day7Review(
      id: _toInt(json['id']) ?? 0,
      userPlanId: _toInt(json['userPlanId']) ?? 0,
      cycle: _toInt(json['cycle']) ?? 0,
      flagged: json['flagged'] == true,
      flagReasons: reasons,
    );
  }
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
