import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class WeeklyCheckin extends Serializable {
  final int? id;
  final int? userId;
  final String? weekDate;
  final double? weightKg;
  final double? waistCm;
  final double? hipCm;
  final int? weekRating;
  final String? createdAt;

  WeeklyCheckin({
    this.id,
    this.userId,
    this.weekDate,
    this.weightKg,
    this.waistCm,
    this.hipCm,
    this.weekRating,
    this.createdAt,
  });

  factory WeeklyCheckin.fromJson(Map<String, dynamic> json) {
    return WeeklyCheckin(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      weekDate: json['weekDate'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      hipCm: (json['hipCm'] as num?)?.toDouble(),
      weekRating: json['weekRating'] as int?,
      createdAt: json['createdAt'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weekDate': weekDate,
      'weightKg': weightKg,
      'waistCm': waistCm,
      'hipCm': hipCm,
      'weekRating': weekRating,
      'createdAt': createdAt,
    };
  }

  WeeklyCheckin copyWith({
    int? id,
    int? userId,
    String? weekDate,
    double? weightKg,
    double? waistCm,
    double? hipCm,
    int? weekRating,
    String? createdAt,
  }) {
    return WeeklyCheckin(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weekDate: weekDate ?? this.weekDate,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      hipCm: hipCm ?? this.hipCm,
      weekRating: weekRating ?? this.weekRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
