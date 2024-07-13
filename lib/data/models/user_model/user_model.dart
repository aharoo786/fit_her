// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String fullName;
  String packageStatus;
  String password;
  bool recording;
  bool screenShot;
  String subscriptionDuration;
  String type;
  String userCountryCode;
  String userId;
  String startDate;
  String expireDate;

  String userMobileNumber;
  String memberDesignation;

  UserModel({
    required this.fullName,
    required this.packageStatus,
    required this.password,
    required this.recording,
    required this.screenShot,
    required this.subscriptionDuration,
    required this.type,
    required this.userCountryCode,
    required this.userId,
    required this.userMobileNumber,
    required this.memberDesignation,
    required this.startDate,
    required this.expireDate
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      fullName: json["fullName"],
      packageStatus: json["packageStatus"],
      password: json["password"],
      recording: json["recording"],
      screenShot: json["screenShot"],
      subscriptionDuration: json["subscriptionDuration"],
      type: json["type"],
      userCountryCode: json["userCountryCode"],
      userId: json["userId"],
      userMobileNumber: json["userMobileNumber"],
      startDate: json["startDate"],
      expireDate: json["expireDate"],
      memberDesignation: json["memberDesignation"]);

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "packageStatus": packageStatus,
        "password": password,
        "recording": recording,
        "screenShot": screenShot,
        "subscriptionDuration": subscriptionDuration,
        "type": type,
        "userCountryCode": userCountryCode,
        "userId": userId,
        "userMobileNumber": userMobileNumber,
        "expireDate": expireDate,
        "startDate": startDate,
        "memberDesignation": memberDesignation
      };
}
