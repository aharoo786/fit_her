// To parse this JSON data, do
//
//     final getAllHealthTips = getAllHealthTipsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetAllHealthTips getAllHealthTipsFromJson(String str) => GetAllHealthTips.fromJson(json.decode(str));

String getAllHealthTipsToJson(GetAllHealthTips data) => json.encode(data.toJson());

class GetAllHealthTips extends Serializable{
  List<HealthTip> healthTips;

  GetAllHealthTips({
    required this.healthTips,
  });

  factory GetAllHealthTips.fromJson(Map<String, dynamic> json) => GetAllHealthTips(
    healthTips: List<HealthTip>.from(json["healthTips"].map((x) => HealthTip.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "healthTips": List<dynamic>.from(healthTips.map((x) => x.toJson())),
  };
}

class HealthTip {
  int id;
  dynamic image;
  String title;
  String description;

  HealthTip({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) => HealthTip(
    id: json["id"],
    image: json["image"],
    title: json["title"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "title": title,
    "description": description,
  };
}
