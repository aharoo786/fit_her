// To parse this JSON data, do
//
//     final getAllUsers = getAllUsersFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

import '../get_user_plan/get_user_plan.dart';
import "package:get/get.dart";

GetAllUsers getAllUsersFromJson(String str) =>
    GetAllUsers.fromJson(json.decode(str));

String getAllUsersToJson(GetAllUsers data) => json.encode(data.toJson());

class GetAllUsers extends Serializable {
  List<UserElement> users;

  GetAllUsers({
    required this.users,
  });

  factory GetAllUsers.fromJson(Map<String, dynamic> json) => GetAllUsers(
        users: List<UserElement>.from(
            json["users"].map((x) => UserElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
      };
}

class UserElement {
  UserUser user;
  Plans? plans;
  Assigned? assigned;

  UserElement({
    required this.user,
    required this.plans,
    required this.assigned,
  });

  factory UserElement.fromJson(Map<String, dynamic> json) => UserElement(
        user: UserUser.fromJson(json["user"]),
        plans: json["plans"] == null ? null : Plans.fromJson(json["plans"]),
        assigned: json["assigned"] == null
            ? null
            : Assigned.fromJson(json["assigned"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "plans": plans?.toJson(),
        "assigned": assigned?.toJson(),
      };
}

class Assigned {
  int id;
  Trainer? user;
  Trainer? trainer;

  Assigned({
    required this.id,
    required this.user,
    required this.trainer,
  });

  factory Assigned.fromJson(Map<String, dynamic> json) => Assigned(
        id: json["id"],
        user: json["User"] == null ? null : Trainer.fromJson(json["User"]),
        trainer:
            json["Trainer"] == null ? null : Trainer.fromJson(json["Trainer"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "User": user?.toJson(),
        "Trainer": trainer?.toJson(),
      };
}

class Trainer {
  int id;
  String firstName;
  String lastName;

  Trainer({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
      };
}

class Plans {
  int id;
  DateTime buyingDate;
  DateTime expireDate;
  int price;
  bool status;
  int planId;
  int userId;
  int? trainerId;
  int? dietitianId;
  Plan plan;

  Plans({
    required this.id,
    required this.buyingDate,
    required this.expireDate,
    required this.price,
    required this.status,
    required this.planId,
    required this.userId,
    required this.trainerId,
    this.dietitianId,
    required this.plan,
  });

  factory Plans.fromJson(Map<String, dynamic> json) => Plans(
        id: json["id"],
        buyingDate: DateTime.parse(json["buyingDate"]),
        expireDate: DateTime.parse(json["expireDate"]),
        price: json["price"],
        status: json["status"],
        planId: json["PlanId"],
        userId: json["userId"],
        trainerId: json["trainerId"],
        dietitianId: json["dietitianId"],
        plan: Plan.fromJson(json["Plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "buyingDate": buyingDate.toIso8601String(),
        "expireDate": expireDate.toIso8601String(),
        "price": price,
        "status": status,
        "PlanId": planId,
        "userId": userId,
        "trainerId": trainerId,
        "dietitianId": dietitianId,
        "Plan": plan.toJson(),
      };
}



class UserUser {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  bool status;

  RxBool freeze;

  UserUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    required this.freeze,
  });

  factory UserUser.fromJson(Map<String, dynamic> json) => UserUser(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"]??"",
        status: json["status"]??false,
        freeze: RxBool(json["freeze"]??false),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "status": status,
        "freeze": freeze,
      };
}
