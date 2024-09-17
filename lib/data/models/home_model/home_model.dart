// To parse this JSON data, do
//
//     final userHomeData = userHomeDataFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

UserHomeData userHomeDataFromJson(String str) =>
    UserHomeData.fromJson(json.decode(str));

String userHomeDataToJson(UserHomeData data) => json.encode(data.toJson());

class UserHomeData extends Serializable {
  UserData userData;
  int freeze;
  List<UserAllPlan> userAllPlans;

  UserHomeData({
    required this.userData,
    required this.freeze,
    required this.userAllPlans,
  });

  factory UserHomeData.fromJson(Map<String, dynamic> json) => UserHomeData(
        userData: UserData.fromJson(json["userData"]),
        freeze: json["freeze"],
        userAllPlans: List<UserAllPlan>.from(
            json["plans"].map((x) => UserAllPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "userData": userData.toJson(),
        "freeze": freeze,
        "UserAllPlans": List<dynamic>.from(userAllPlans.map((x) => x.toJson())),
      };
}

class UserAllPlan {
  int spendDays;
  int remainingDays;
  int price;
  String title;
  String shortDescription;
  String longDescription;
  int categoryId;

  UserAllPlan({
    required this.spendDays,
    required this.remainingDays,
    required this.price,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.categoryId,
  });

  factory UserAllPlan.fromJson(Map<String, dynamic> json) => UserAllPlan(
        spendDays: json["spendDays"],
        remainingDays: json["remainingDays"],
        price: json["price"],
        title: json["title"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        categoryId: json["CategoryId"],
      );

  Map<String, dynamic> toJson() => {
        "spendDays": spendDays,
        "remainingDays": remainingDays,
        "price": price,
        "title": title,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "CategoryId": categoryId,
      };
}

class UserData {
  int id;
  dynamic freeze;

  UserData({
    required this.id,
    required this.freeze,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        freeze: json["freeze"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "freeze": freeze,
      };
}
