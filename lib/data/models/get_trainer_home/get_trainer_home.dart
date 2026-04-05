// To parse this JSON data, do
//
//     final getTrainerHome = getTrainerHomeFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetTrainerHome getTrainerHomeFromJson(String str) => GetTrainerHome.fromJson(json.decode(str));

String getTrainerHomeToJson(GetTrainerHome data) => json.encode(data.toJson());

class GetTrainerHome  extends Serializable{
  List<Plans> plans;

  GetTrainerHome({
    required this.plans,
  });

  factory GetTrainerHome.fromJson(Map<String, dynamic> json) => GetTrainerHome(
    plans: List<Plans>.from(json["plans"].map((x) => Plans.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
  };
}

class Plans {
  int id;
  String shortDescription;
  String longDescription;
  String duration;
  String title;
  List<Time> times;

  Plans({
    required this.id,
    required this.shortDescription,
    required this.longDescription,
    required this.duration,
    required this.times,
    required this.title,
  });

  factory Plans.fromJson(Map<String, dynamic> json) => Plans(
    id: json["id"],
    shortDescription: json["shortDescription"],
    longDescription: json["longDescription"],
    duration: json["duration"],
    title: json["title"],
    times: List<Time>.from(json["Times"].map((x) => Time.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "shortDescription": shortDescription,
    "longDescription": longDescription,
    "duration": duration,
    "title": title,
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
  dynamic trainerLink;
  DateTime createdAt;
  DateTime updatedAt;
  int timeId;

  Slot({
    required this.id,
    required this.start,
    required this.end,
    required this.trainerLink,
    required this.createdAt,
    required this.updatedAt,
    required this.timeId,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json["id"],
    start: json["start"],
    end: json["end"],
    trainerLink: json["trainerLink"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    timeId: json["TimeId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start": start,
    "end": end,
    "trainerLink": trainerLink,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "TimeId": timeId,
  };
}
