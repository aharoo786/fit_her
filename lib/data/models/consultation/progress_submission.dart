/// Mirrors backend ProgressSubmissions row. Day 15 / Day 30 mandatory.
/// Photos are NEVER serialized here — device-only per Section 10.
class ProgressSubmission {
  final int? id;
  final int? userId;
  final int? userPlanId;
  final int? cycle; // 15 or 30
  final double? weightKg;
  final double? waistCm;
  final double? hipsCm;
  final double? chestCm;
  final double? armsCm;
  final double? thighsCm;
  final String? clothesFit; // tighter | same | looser
  final int? sleepQuality; // 1..5
  final int? satisfaction; // 1..5
  final String? strengthNotes;
  final DateTime? submittedAt;

  const ProgressSubmission({
    this.id,
    this.userId,
    this.userPlanId,
    this.cycle,
    this.weightKg,
    this.waistCm,
    this.hipsCm,
    this.chestCm,
    this.armsCm,
    this.thighsCm,
    this.clothesFit,
    this.sleepQuality,
    this.satisfaction,
    this.strengthNotes,
    this.submittedAt,
  });

  factory ProgressSubmission.fromJson(Map<String, dynamic> json) {
    double? d(dynamic x) {
      if (x is num) return x.toDouble();
      if (x is String) return double.tryParse(x);
      return null;
    }
    return ProgressSubmission(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      userPlanId: json['userPlanId'] as int?,
      cycle: json['cycle'] as int?,
      weightKg: d(json['weightKg']),
      waistCm: d(json['waistCm']),
      hipsCm: d(json['hipsCm']),
      chestCm: d(json['chestCm']),
      armsCm: d(json['armsCm']),
      thighsCm: d(json['thighsCm']),
      clothesFit: json['clothesFit'] as String?,
      sleepQuality: json['sleepQuality'] as int?,
      satisfaction: json['satisfaction'] as int?,
      strengthNotes: json['strengthNotes'] as String?,
      submittedAt: json['submittedAt'] is String
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (userPlanId != null) 'userPlanId': userPlanId,
        if (cycle != null) 'cycle': cycle,
        if (weightKg != null) 'weightKg': weightKg,
        if (waistCm != null) 'waistCm': waistCm,
        if (hipsCm != null) 'hipsCm': hipsCm,
        if (chestCm != null) 'chestCm': chestCm,
        if (armsCm != null) 'armsCm': armsCm,
        if (thighsCm != null) 'thighsCm': thighsCm,
        if (clothesFit != null) 'clothesFit': clothesFit,
        if (sleepQuality != null) 'sleepQuality': sleepQuality,
        if (satisfaction != null) 'satisfaction': satisfaction,
        if (strengthNotes != null) 'strengthNotes': strengthNotes,
      };
}
