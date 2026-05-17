import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class CycleData extends Serializable {
  final int? id;
  final int userId;
  final String? lastPeriodDate;
  final int averageCycleLength;
  final String? isRegular;
  final int? currentCycleDay;
  final String? currentPhase;
  final int dataProvided;
  final String? createdAt;
  final String? updatedAt;

  CycleData({
    this.id,
    required this.userId,
    this.lastPeriodDate,
    this.averageCycleLength = 28,
    this.isRegular,
    this.currentCycleDay,
    this.currentPhase,
    this.dataProvided = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      lastPeriodDate: json['last_period_date'] as String?,
      averageCycleLength: json['average_cycle_length'] as int? ?? 28,
      isRegular: json['is_regular'] as String?,
      currentCycleDay: json['current_cycle_day'] as int?,
      currentPhase: json['current_phase'] as String?,
      dataProvided: json['data_provided'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'last_period_date': lastPeriodDate,
      'average_cycle_length': averageCycleLength,
      'is_regular': isRegular,
      'current_cycle_day': currentCycleDay,
      'current_phase': currentPhase,
      'data_provided': dataProvided,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  CycleData copyWith({
    int? id,
    int? userId,
    String? lastPeriodDate,
    int? averageCycleLength,
    String? isRegular,
    int? currentCycleDay,
    String? currentPhase,
    int? dataProvided,
    String? createdAt,
    String? updatedAt,
  }) {
    return CycleData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      isRegular: isRegular ?? this.isRegular,
      currentCycleDay: currentCycleDay ?? this.currentCycleDay,
      currentPhase: currentPhase ?? this.currentPhase,
      dataProvided: dataProvided ?? this.dataProvided,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
