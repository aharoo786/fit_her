// To parse this JSON data, do
//
//     final dietitianTiming = dietitianTimingFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

DietitianTiming dietitianTimingFromJson(String str) => DietitianTiming.fromJson(json.decode(str));

String dietitianTimingToJson(DietitianTiming data) => json.encode(data.toJson());

class DietitianTiming extends Serializable {
  List<DietTime> dietTimes;

  DietitianTiming({
    required this.dietTimes,
  });

  factory DietitianTiming.fromJson(Map<String, dynamic> json) => DietitianTiming(
    dietTimes: List<DietTime>.from(json["dietTimes"].map((x) => DietTime.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "dietTimes": List<dynamic>.from(dietTimes.map((x) => x.toJson())),
  };
}

class DietTime {
  int id;
  String day;

  DietTime({
    required this.id,
    required this.day,
  });

  factory DietTime.fromJson(Map<String, dynamic> json) => DietTime(
    id: json["id"],
    day: json["day"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day": day,
  };
}
