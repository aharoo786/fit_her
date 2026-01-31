// To parse this JSON data, do
//
//     final nutritionModel = nutritionModelFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

NutritionModel nutritionModelFromJson(String str) => NutritionModel.fromJson(json.decode(str));

String nutritionModelToJson(NutritionModel data) => json.encode(data.toJson());

class NutritionModel extends Serializable {
  String? name;
  String? servingSize;
  Calories? calories;
  Calories? protein;
  Calories? fat;
  Calories? carbs;
  int? remainingChecks;

  NutritionModel({
    this.name,
    this.servingSize,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.remainingChecks,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) => NutritionModel(
    name: json["name"],
    servingSize: json["servingSize"],
    calories: json["calories"] == null ? null : Calories.fromJson(json["calories"]),
    protein: json["protein"] == null ? null : Calories.fromJson(json["protein"]),
    fat: json["fat"] == null ? null : Calories.fromJson(json["fat"]),
    carbs: json["carbs"] == null ? null : Calories.fromJson(json["carbs"]),
    remainingChecks: json["remainingChecks"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "name": name,
    "servingSize": servingSize,
    "calories": calories?.toJson(),
    "protein": protein?.toJson(),
    "fat": fat?.toJson(),
    "carbs": carbs?.toJson(),
    "remainingChecks": remainingChecks,
  };
}

class Calories {
  double? amount;
  String? unit;

  Calories({
    this.amount,
    this.unit,
  });

  factory Calories.fromJson(Map<String, dynamic> json) => Calories(
    amount: json["amount"]?.toDouble(),
    unit: json["unit"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "unit": unit,
  };
}
