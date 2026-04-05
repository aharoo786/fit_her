import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class AttendanceHistoryItem implements Serializable {
  final String date;
  final int attended;

  AttendanceHistoryItem({
    required this.date,
    required this.attended,
  });

  factory AttendanceHistoryItem.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryItem(
      date: json['date'] ?? '',
      attended: json['attended'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'date': date,
        'attended': attended,
      };
}

class MotivationStatsData implements Serializable {
  final int streak;
  final int daysAttendedLast7;
  final int daysAttendedLast30;
  final int regularityPercentage;
  final List<AttendanceHistoryItem> attendanceHistory;

  MotivationStatsData({
    required this.streak,
    required this.daysAttendedLast7,
    required this.daysAttendedLast30,
    required this.regularityPercentage,
    required this.attendanceHistory,
  });

  factory MotivationStatsData.fromJson(Map<String, dynamic> json) {
    return MotivationStatsData(
      streak: json['streak'] ?? 0,
      daysAttendedLast7: json['daysAttendedLast7'] ?? 0,
      daysAttendedLast30: json['daysAttendedLast30'] ?? 0,
      regularityPercentage: json['regularityPercentage'] ?? 0,
      attendanceHistory: (json['attendanceHistory'] as List<dynamic>?)
              ?.map((e) => AttendanceHistoryItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'streak': streak,
        'daysAttendedLast7': daysAttendedLast7,
        'daysAttendedLast30': daysAttendedLast30,
        'regularityPercentage': regularityPercentage,
        'attendanceHistory': attendanceHistory.map((e) => e.toJson()).toList(),
      };
}
