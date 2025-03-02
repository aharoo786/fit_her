// To parse this JSON data, do
//
//     final getAllPlansImages = getAllPlansImagesFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';

import '../duration_model.dart';
import '../get_user_plan/get_user_plan.dart';

GetAllPlansImages getAllPlansImagesFromJson(String str) => GetAllPlansImages.fromJson(json.decode(str));

String getAllPlansImagesToJson(GetAllPlansImages data) => json.encode(data.toJson());

class GetAllPlansImages extends Serializable {
  List<Datum> data;

  GetAllPlansImages({
    required this.data,
  });

  factory GetAllPlansImages.fromJson(Map<String, dynamic> json) => GetAllPlansImages(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String image;
  ClientUser? user;
  Plan? plan;
  DurationModel priceDuration;

  Datum({
    required this.id,
    required this.image,
    required this.user,
    required this.plan,
    required this.priceDuration,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    image: json["image"],
    user:json["User"]==null?null: ClientUser.fromJson(json["User"]),
    plan:json["Plan"]==null?null: Plan.fromJson(json["Plan"]),
    priceDuration: DurationModel.fromJson(json["PriceDuration"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "User": user?.toJson(),
    "Plan": plan?.toJson(),
    "PriceDuration": priceDuration.toJson(),
  };
}



