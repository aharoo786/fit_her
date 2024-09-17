// To parse this JSON data, do
//
//     final allPlanModel = allPlanModelFromJson(jsonString);

import 'dart:convert';
import 'package:get/get.dart';
import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

AllPlanModel allPlanModelFromJson(String str) =>
    AllPlanModel.fromJson(json.decode(str));

String allPlanModelToJson(AllPlanModel data) => json.encode(data.toJson());

class AllPlanModel extends Serializable {
  List<Plan> plans;

  AllPlanModel({
    required this.plans,
  });

  factory AllPlanModel.fromJson(Map<String, dynamic> json) => AllPlanModel(
        plans: List<Plan>.from(json["plans"].map((x) => Plan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
      };
}

class Plan  extends Serializable{
  int id;
  String title;
  String shortDescription;
  String longDescription;
  String duration;
  int price;
  RxBool status;
  dynamic image;

  int categoryId;
  int subCategoryId;

  Plan({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.duration,
    required this.price,
    required this.status,
    required this.image,
    required this.categoryId,
    required this.subCategoryId,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        title: json["title"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        duration: json["duration"]??"",
        price: json["price"],
        status: RxBool(json["status"]??false),
        image: json["image"],
        categoryId: json["CategoryId"],
        subCategoryId: json["subCategoryId"] ?? 0,
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
        "CategoryId": categoryId,
        "subCategoryId": subCategoryId,
      };
}
