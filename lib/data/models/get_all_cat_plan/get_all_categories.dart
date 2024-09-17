// To parse this JSON data, do
//
//     final allCategoriesOfPlan = allCategoriesOfPlanFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

AllCategoriesOfPlan allCategoriesOfPlanFromJson(String str) => AllCategoriesOfPlan.fromJson(json.decode(str));

String allCategoriesOfPlanToJson(AllCategoriesOfPlan data) => json.encode(data.toJson());

class AllCategoriesOfPlan extends Serializable {
  List<Category> categories;

  AllCategoriesOfPlan({
    required this.categories,
  });

  factory AllCategoriesOfPlan.fromJson(Map<String, dynamic> json) => AllCategoriesOfPlan(
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
  };
}

class Category {
  int id;
  String title;


  Category({
    required this.id,
    required this.title,

  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    title: json["title"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,

  };
}
