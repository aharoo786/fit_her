// To parse this JSON data, do
//
//     final getDietitianUsers = getDietitianUsersFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetDietitianUsers getDietitianUsersFromJson(String str) => GetDietitianUsers.fromJson(json.decode(str));

String getDietitianUsersToJson(GetDietitianUsers data) => json.encode(data.toJson());

class GetDietitianUsers  extends Serializable{
  List<DietPlan> plans;

  GetDietitianUsers({
    required this.plans,
  });

  factory GetDietitianUsers.fromJson(Map<String, dynamic> json) => GetDietitianUsers(
    plans: List<DietPlan>.from(json["plans"].map((x) => DietPlan.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
  };
}

class DietPlan {
  int id;
  DateTime buyingDate;
  DateTime expireDate;
  dynamic dietitionLink;
  User? user;
  PlanClass plan;

  DietPlan({
    required this.id,
    required this.buyingDate,
    required this.expireDate,
    required this.dietitionLink,
    required this.plan,

    required this.user,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
    id: json["id"],
    buyingDate: DateTime.parse(json["buyingDate"]),
    expireDate: DateTime.parse(json["expireDate"]),
    dietitionLink: json["dietitionLink"],
    user: User.fromJson(json["User"]),
    plan: PlanClass.fromJson(json["Plan"]),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "buyingDate": buyingDate.toIso8601String(),
    "expireDate": expireDate.toIso8601String(),
    "dietitionLink": dietitionLink,
    "User": user==null?null:user!.toJson(),
    "Plan": plan.toJson(),
  };
}

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
  };

}
class PlanClass {
  String title;

  PlanClass({
    required this.title,
  });

  factory PlanClass.fromJson(Map<String, dynamic> json) => PlanClass(
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
  };
}