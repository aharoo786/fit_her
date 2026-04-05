// To parse this JSON data, do
//
//     final getAllUsers = getAllUsersFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

import '../get_user_plan/get_workout_user_plan_details.dart';
import 'package:get/get.dart';

GetAllUsers getAllUsersFromJson(String str) =>
    GetAllUsers.fromJson(json.decode(str));

String getAllUsersToJson(GetAllUsers data) => json.encode(data.toJson());

class GetAllUsers extends Serializable {
  List<User> freeTrialUsers;
  List<User> otherPlanUsers;

  GetAllUsers({
    required this.freeTrialUsers,
    required this.otherPlanUsers,
  });

  factory GetAllUsers.fromJson(Map<String, dynamic> json) => GetAllUsers(
        freeTrialUsers: List<User>.from(
            json["freeTrialUsers"].map((x) => User.fromJson(x))),
        otherPlanUsers: List<User>.from(
            json["otherPlanUsers"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "freeTrialUsers":
            List<dynamic>.from(freeTrialUsers.map((x) => x.toJson())),
        "otherPlanUsers":
            List<dynamic>.from(otherPlanUsers.map((x) => x.toJson())),
      };
}

class User {
  UserClass user;
  Plans? plans;

  User({
    required this.user,
    required this.plans,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        user: UserClass.fromJson(json["user"]),
        plans: json["plans"] == null ? null : Plans.fromJson(json["plans"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "plans": plans?.toJson(),
      };
}

class Plans {
  int id;
  DateTime expireDate;
  DateTime buyingDate;
  Plan plan;

  Plans({
    required this.id,
    required this.expireDate,
    required this.buyingDate,
    required this.plan,
  });

  factory Plans.fromJson(Map<String, dynamic> json) => Plans(
        id: json["id"],
        expireDate: DateTime.parse(json["expireDate"]),
        buyingDate: DateTime.parse(json["buyingDate"]),
        plan: Plan.fromJson(json["Plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "expireDate": expireDate.toIso8601String(),
        "buyingDate": buyingDate.toIso8601String(),
        "Plan": plan.toJson(),
      };
}

// class Plan {
//   int id;
//   String title;
//   String shortDescription;
//   String longDescription;
//
//   Plan({
//     required this.id,
//     required this.title,
//     required this.shortDescription,
//     required this.longDescription,
//   });
//
//   factory Plan.fromJson(Map<String, dynamic> json) => Plan(
//         id: json["id"],
//         title: json["title"],
//         shortDescription: json["shortDescription"],
//         longDescription: json["longDescription"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "title": title,
//         "shortDescription": shortDescription,
//         "longDescription": longDescription,
//       };
// }

class UserClass {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String? bmiResult;
  bool status;

  var freeze;

  UserClass({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bmiResult,
    required this.email,
    required this.phone,
    required this.status,
    required this.freeze,
  });

  factory UserClass.fromJson(Map<String, dynamic> json) => UserClass(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        bmiResult: json["bmiResult"],
        email: json["email"],
        phone: json["phone"],
        status: json["status"],
        freeze: RxBool(json["freeze"] ?? false),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "bmiResult": bmiResult,
        "email": email,
        "phone": phone,
        "status": status,
        "freeze": freeze,
      };
}
