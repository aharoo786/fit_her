// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel extends Serializable {
  int id;
  String firstName;
  String lastName;
  String phone;
  String email;
  int adminId;
  bool status;
  String accessToken;
  String userType;
  String? age;
  String? height;
  String? weight;
  String? bmiResult;
  String? mainGoal;
  String? healthConditions;
  // Option-C feature flags. Backend always returns these; fromJson defaults
  // to false when missing (older clients / offline JSON caches).
  bool useNewPaidHome;
  bool useNewUnpaidHome;
  // Phase A — Progress Screen rebuild. Defaults false; backend flips this
  // per-user to opt into the new hub. See bottom_bar_screen.dart for the
  // routing decision.
  bool useNewProgressHub;

  LoginModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.accessToken,
    required this.userType,
    required this.adminId,
    required this.status,
    this.height,
    this.age,
    this.weight,
    this.bmiResult,
    this.mainGoal,
    this.healthConditions,
    this.useNewPaidHome = false,
    this.useNewUnpaidHome = false,
    this.useNewProgressHub = false,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        phone: json["phone"] ?? "",
        email: json["email"],
        accessToken: json["accessToken"],
        status: json["status"],
        userType: json["userType"],
        adminId: json["adminId"],
        age: json["age"],
        weight: json["weight"],
        height: json["height"],
        bmiResult: json["bmiResult"],
        mainGoal: json["mainGoal"],
        healthConditions: json["healthConditions"],
        useNewPaidHome: json["useNewPaidHome"] ?? false,
        useNewUnpaidHome: json["useNewUnpaidHome"] ?? false,
        useNewProgressHub: json["useNewProgressHub"] ?? false,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "status": status,
        "email": email,
        "userType": userType,
        "adminId": adminId,
        "accessToken": accessToken,
        "mainGoal": mainGoal,
        "healthConditions": healthConditions,
        "useNewPaidHome": useNewPaidHome,
        "useNewUnpaidHome": useNewUnpaidHome,
        "useNewProgressHub": useNewProgressHub,
      };

  String get fullName => "${firstName} ${lastName}";
}
