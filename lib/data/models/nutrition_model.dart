// To parse this JSON data, do
//
//     final nutritionModel = nutritionModelFromJson(jsonString);

import 'dart:convert';

NutritionModel nutritionModelFromJson(String str) =>
    NutritionModel.fromJson(json.decode(str));

String nutritionModelToJson(NutritionModel data) => json.encode(data.toJson());

class NutritionModel {
  String? status;
  Nutrition? nutrition;
  Category? category;

  NutritionModel({
    this.status,
    this.nutrition,
    this.category,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) => NutritionModel(
        status: json["status"],
        nutrition: json["nutrition"] == null
            ? null
            : Nutrition.fromJson(json["nutrition"]),
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "nutrition": nutrition?.toJson(),
        "category": category?.toJson(),
      };
}

class Nutrition {
  int? recipesUsed;
  Calories? calories;
  Calories? fat;
  Calories? protein;
  Calories? carbs;

  Nutrition({
    this.recipesUsed,
    this.calories,
    this.fat,
    this.protein,
    this.carbs,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
        recipesUsed: json["recipesUsed"],
        calories: json["calories"] == null
            ? null
            : Calories.fromJson(json["calories"]),
        fat: json["fat"] == null ? null : Calories.fromJson(json["fat"]),
        protein:
            json["protein"] == null ? null : Calories.fromJson(json["protein"]),
        carbs: json["carbs"] == null ? null : Calories.fromJson(json["carbs"]),
      );

  Map<String, dynamic> toJson() => {
        "recipesUsed": recipesUsed,
        "calories": calories?.toJson(),
        "fat": fat?.toJson(),
        "protein": protein?.toJson(),
        "carbs": carbs?.toJson(),
      };
}

class Category {
  String? name;
  double? probability;

  Category({
    this.name,
    this.probability,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        probability: json["probability"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "probability": probability,
      };
}

class Calories {
  double? value;
  String? unit;
  double? standardDeviation;

  Calories({
    this.value,
    this.unit,
    this.standardDeviation,
  });

  factory Calories.fromJson(Map<String, dynamic> json) => Calories(
        value: json["value"],
        unit: json["unit"],
        standardDeviation: json["standardDeviation"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "unit": unit,
        "standardDeviation": standardDeviation,
      };
}
