import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class GetDietAllPlans extends Serializable {
  List<UserPlan> userPlans;

  GetDietAllPlans({
    required this.userPlans,
  });

  factory GetDietAllPlans.fromRawJson(String str) =>
      GetDietAllPlans.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetDietAllPlans.fromJson(Map<String, dynamic> json) =>
      GetDietAllPlans(
        userPlans: List<UserPlan>.from(
            json["userPlans"].map((x) => UserPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "userPlans": List<dynamic>.from(userPlans.map((x) => x.toJson())),
      };
}

class UserPlan {
  int id;
  dynamic dietitionLink;
  bool status;
  dynamic trainerId;
  dynamic dietitianId;
  DietPlanOfUser dietPlanOfUser;

  UserPlan({
    required this.id,
    required this.dietitionLink,
    required this.status,
    required this.trainerId,
    required this.dietitianId,
    required this.dietPlanOfUser,
  });

  factory UserPlan.fromRawJson(String str) =>
      UserPlan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
        id: json["id"],
        dietitionLink: json["dietitionLink"],
        status: json["status"],
        trainerId: json["trainerId"],
        dietitianId: json["dietitianId"],
        dietPlanOfUser: DietPlanOfUser.fromJson(json["Plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dietitionLink": dietitionLink,
        "status": status,
        "trainerId": trainerId,
        "dietitianId": dietitianId,
        "DietPlanOfUser": dietPlanOfUser.toJson(),
      };
}

class DietPlanOfUser {
  String title;
  String shortDescription;
  String longDescription;
  String duration;
  int price;

  DietPlanOfUser({
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.duration,
    required this.price,
  });

  factory DietPlanOfUser.fromRawJson(String str) =>
      DietPlanOfUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DietPlanOfUser.fromJson(Map<String, dynamic> json) => DietPlanOfUser(
        title: json["title"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        duration: json["duration"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "duration": duration,
        "price": price,
      };
}
