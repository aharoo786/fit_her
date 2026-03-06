import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:get/get.dart';

class AllPlanModel extends Serializable {
  List<Plan> plans;

  AllPlanModel({
    required this.plans,
  });

  factory AllPlanModel.fromRawJson(String str) =>
      AllPlanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AllPlanModel.fromJson(Map<String, dynamic> json) => AllPlanModel(
        plans: json["plans"] == null
            ? []
            : List<Plan>.from(json["plans"]!.map((x) => Plan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
      };
}

class Plan extends Serializable {
  int id;
  String title;
  String shortDescription;
  String longDescription;
  int? catId;
  int? subId;
  int? priceId;
  var selectedDurationId = 0.obs;
  List<CountryUser>? countries;

  Plan({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    this.catId,
    this.subId,
    this.countries,
    this.priceId,
  });

  factory Plan.fromRawJson(String str) => Plan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"] ?? 0,
        title: json["title"] ?? 0,
        catId: json["catId"] ?? 0,
        subId: json["subId"] ?? 0,
        priceId: json["priceId"] ?? 0,
        shortDescription: json["shortDescription"] ?? "N/A",
        longDescription: json["longDescription"] ?? "N/A",
        countries: json["countries"] == null
            ? []
            : List<CountryUser>.from(
                json["countries"]!.map((x) => CountryUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "catId": catId,
        "subId": subId,
        "priceId": priceId,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "countries": countries == null
            ? []
            : List<dynamic>.from(countries!.map((x) => x.toJson())),
      };
}

class CountryUser {
  String? name;
  int? id;
  String? currency;
  List<DurationPlan>? duration;

  CountryUser({
    this.name,
    this.duration,
    this.currency,
    this.id,
  });

  factory CountryUser.fromRawJson(String str) =>
      CountryUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CountryUser.fromJson(Map<String, dynamic> json) => CountryUser(
        name: json["name"],
        id: json["id"],
        currency: json["currency"] ?? "Rs.",
        duration: json["duration"] == null
            ? []
            : List<DurationPlan>.from(
                json["duration"]!.map((x) => DurationPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "currency": currency,
        "duration": duration == null
            ? []
            : List<dynamic>.from(duration!.map((x) => x.toJson())),
      };
}

class DurationPlan {
  int? id;
  String? days;
  String? priceAmount;

  DurationPlan({
    this.id,
    this.days,
    this.priceAmount,
  });

  factory DurationPlan.fromRawJson(String str) =>
      DurationPlan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DurationPlan.fromJson(Map<String, dynamic> json) => DurationPlan(
        days: json["days"],
        id: json["id"],
        priceAmount: json["priceAmount"],
      );

  Map<String, dynamic> toJson() => {
        "days": days,
        "id": id,
        "priceAmount": priceAmount,
      };
}
