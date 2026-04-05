import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class GetSubCategories extends Serializable{
  List<SubCategory> data;

  GetSubCategories({
    required this.data,
  });

  factory GetSubCategories.fromRawJson(String str) => GetSubCategories.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetSubCategories.fromJson(Map<String, dynamic> json) => GetSubCategories(
    data: List<SubCategory>.from(json["data"].map((x) => SubCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class SubCategory {
  int id;
  String title;

  SubCategory({
    required this.id,
    required this.title,
  });

  factory SubCategory.fromRawJson(String str) => SubCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}
