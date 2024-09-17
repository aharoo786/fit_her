// To parse this JSON data, do
//
//     final getAllPlansImages = getAllPlansImagesFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetAllPlansImages getAllPlansImagesFromJson(String str) =>
    GetAllPlansImages.fromJson(json.decode(str));

String getAllPlansImagesToJson(GetAllPlansImages data) =>
    json.encode(data.toJson());

class GetAllPlansImages extends Serializable {
  List<Datum> data;

  GetAllPlansImages({
    required this.data,
  });

  factory GetAllPlansImages.fromJson(Map<String, dynamic> json) =>
      GetAllPlansImages(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int id;
  String? image;
  bool status;
  int planId;
  int userId;
  User user;
  UserImagePlan? plan;

  Datum({
    required this.id,
    required this.image,
    required this.status,
    required this.planId,
    required this.userId,
    required this.user,
    required this.plan,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        image: json["image"],
        status: json["status"],
        planId: json["PlanId"],
        userId: json["UserId"],
        user: User.fromJson(json["User"]),
        plan:json["Plan"]==null?null: UserImagePlan.fromJson(json["Plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,

        "status": status,
        "PlanId": planId,
        "UserId": userId,
        "User": user.toJson(),
        "Plan": plan?.toJson(),
      };
}

class UserImagePlan {
  int id;
  String title;
  String shortDescription;
  String longDescription;
  String duration;
  int price;
  bool status;
  dynamic image;
  DateTime createdAt;
  DateTime updatedAt;
  int categoryId;

  UserImagePlan({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.duration,
    required this.price,
    required this.status,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
  });

  factory UserImagePlan.fromJson(Map<String, dynamic> json) => UserImagePlan(
        id: json["id"],
        title: json["title"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        duration: json["duration"],
        price: json["price"],
        status: json["status"],
        image: json["image"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        categoryId: json["CategoryId"],
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
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "CategoryId": categoryId,
      };
}

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String? deviceToken;
  String phone;
  String password;
  bool status;
  dynamic freeze;
  dynamic freezingDays;
  String userType;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.deviceToken,
    required this.phone,
    required this.password,
    required this.status,
    required this.freeze,
    required this.freezingDays,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        deviceToken: json["deviceToken"],
        phone: json["phone"],
        password: json["password"],
        status: json["status"],
        freeze: json["freeze"],
        freezingDays: json["freezingDays"],
        userType: json["userType"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "deviceToken": deviceToken,
        "phone": phone,
        "password": password,
        "status": status,
        "freeze": freeze,
        "freezingDays": freezingDays,
        "userType": userType,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
