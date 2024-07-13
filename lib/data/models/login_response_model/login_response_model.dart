// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

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
      };
}
