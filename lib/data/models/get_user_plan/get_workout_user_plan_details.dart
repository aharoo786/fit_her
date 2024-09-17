// To parse this JSON data, do
//
//     final getUserWorkoutPlanDetails = getUserWorkoutPlanDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetUserWorkoutPlanDetails getUserWorkoutPlanDetailsFromJson(String str) =>
    GetUserWorkoutPlanDetails.fromJson(json.decode(str));

String getUserWorkoutPlanDetailsToJson(GetUserWorkoutPlanDetails data) =>
    json.encode(data.toJson());

class GetUserWorkoutPlanDetails extends Serializable {
  Plan plan;

  GetUserWorkoutPlanDetails({
    required this.plan,
  });

  factory GetUserWorkoutPlanDetails.fromJson(Map<String, dynamic> json) =>
      GetUserWorkoutPlanDetails(
        plan: Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "plan": plan.toJson(),
      };
}

class Plan {
  int id;
  String title;
  String shortDescription;
  String longDescription;
  String duration;
  int price;
  bool status;
  String? image;
  List<Time> times;

  Plan({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.duration,
    required this.price,
    required this.status,
    this.image,
    required this.times,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        title: json["title"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        duration: json["duration"],
        price: json["price"],
        status: json["status"],
        image: json["image"] ?? "",
        times: List<Time>.from(json["Times"].map((x) => Time.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "duration": duration,
        "price": price,
        "status": status,
        "image": image,
        "Times": List<dynamic>.from(times.map((x) => x.toJson())),
      };
}

class Time {
  int id;
  String day;
  List<Slot> slots;

  Time({
    required this.id,
    required this.day,
    required this.slots,
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
        id: json["id"],
        day: json["day"],
        slots: List<Slot>.from(json["Slots"].map((x) => Slot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "day": day,
        "Slots": List<dynamic>.from(slots.map((x) => x.toJson())),
      };
}

class Slot {
  int id;
  String start;
  String end;
  String? trainerLink;

  Slot({
    required this.id,
    required this.start,
    required this.end,
     this.trainerLink,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        id: json["id"],
        start: json["start"],
        end: json["end"], trainerLink: json["trainerLink"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start": start,
        "end": end,
        "trainerLink": trainerLink,
      };
}
