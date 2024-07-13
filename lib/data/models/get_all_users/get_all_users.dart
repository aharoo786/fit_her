// To parse this JSON data, do
//
//     final getAllUsers = getAllUsersFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:get/get.dart';

GetAllUsers getAllUsersFromJson(String str) =>
    GetAllUsers.fromJson(json.decode(str));

String getAllUsersToJson(GetAllUsers data) => json.encode(data.toJson());

class GetAllUsers extends Serializable {
  List<User> users;

  GetAllUsers({
    required this.users,
  });

  factory GetAllUsers.fromJson(Map<String, dynamic> json) => GetAllUsers(
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
      };
}

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  bool status;
  RxBool freeze;
  String password;
  List<UserPlan> userPlans;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    required this.password,
    required this.freeze,
    required this.userPlans,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        freeze: RxBool(json["freeze"] ?? false),
        status: json["status"] ?? false,
        userPlans: List<UserPlan>.from(
            json["UserPlans"].map((x) => UserPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "status": status,
        "freeze": freeze,
        "password": password,
        "UserPlans": List<dynamic>.from(userPlans.map((x) => x.toJson())),
      };
}

class UserPlan {
  int id;
  DateTime buyingDate;
  DateTime expireDate;
  int price;
  dynamic dietitionLink;
  dynamic status;
  DateTime createdAt;
  DateTime updatedAt;
  int planId;
  dynamic userId;
  int trainerId;
  int dietitianId;
  MyPlan? myPlan;

  UserPlan({
    required this.id,
    required this.buyingDate,
    required this.expireDate,
    required this.price,
    required this.dietitionLink,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.planId,
    required this.userId,
    required this.trainerId,
    required this.dietitianId,
    required this.myPlan,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
        id: json["id"],
        buyingDate: DateTime.parse(json["buyingDate"]),
        expireDate: DateTime.parse(json["expireDate"]),
        price: json["price"],
        dietitionLink: json["dietitionLink"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        planId: json["PlanId"],
        userId: json["userId"],
        trainerId: json["trainerId"],
        dietitianId: json["dietitianId"],
        myPlan: json["Plan"] == null ? null : MyPlan.fromJson(json["Plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "buyingDate": buyingDate.toIso8601String(),
        "expireDate": expireDate.toIso8601String(),
        "price": price,
        "dietitionLink": dietitionLink,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "PlanId": planId,
        "userId": userId,
        "trainerId": trainerId,
        "dietitianId": dietitianId,
        "Plan": myPlan?.toJson(),
      };
}

class MyPlan {
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

  MyPlan({
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

  factory MyPlan.fromJson(Map<String, dynamic> json) => MyPlan(
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
