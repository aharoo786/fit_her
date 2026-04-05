import 'dart:convert';

import 'package:flutter/cupertino.dart';

class AddDietOfUser {
  String userId;
  String userPlanId;
  List<DietOfUser> dietOfUser;

  AddDietOfUser({
    required this.userId,
    required this.userPlanId,
    required this.dietOfUser,
  });

  factory AddDietOfUser.fromRawJson(String str) => AddDietOfUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddDietOfUser.fromJson(Map<String, dynamic> json) => AddDietOfUser(
    userId: json["userId"],
    userPlanId: json["userPlanId"],
    dietOfUser: List<DietOfUser>.from(json["diet"].map((x) => DietOfUser.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "userPlanId": userPlanId,
    "diet": List<dynamic>.from(dietOfUser.map((x) => x.toJson())),
  };
}

class DietOfUser {
  String day;
  List<MealOfUser> meals;

  DietOfUser({
    required this.day,
    required this.meals,
  });

  factory DietOfUser.fromRawJson(String str) => DietOfUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DietOfUser.fromJson(Map<String, dynamic> json) => DietOfUser(
    day: json["day"],
    meals: List<MealOfUser>.from(json["meals"].map((x) => MealOfUser.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "meals": List<dynamic>.from(meals.map((x) => x.toJson())),
  };
}

class MealOfUser {
  String time;
  String food;
  String calories;
   TextEditingController dietName = TextEditingController();
  final TextEditingController alternatives = TextEditingController();
  final TextEditingController kcal = TextEditingController();
  final TextEditingController description = TextEditingController();
  String addText = "";


  MealOfUser({
    required this.time,
    required this.food,
    required this.calories,
  });

  factory MealOfUser.fromRawJson(String str) => MealOfUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MealOfUser.fromJson(Map<String, dynamic> json) => MealOfUser(
    time: json["time"],
    food: json["food"],
    calories: json["calories"],
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "food": food,
    "calories": calories,
  };
}
