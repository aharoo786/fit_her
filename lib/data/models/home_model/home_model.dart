// To parse this JSON data, do
//
//     final userHomeData = userHomeDataFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:get/get.dart';

import '../get_clients_diet.dart';

UserHomeData userHomeDataFromJson(String str) =>
    UserHomeData.fromJson(json.decode(str));

String userHomeDataToJson(UserHomeData data) => json.encode(data.toJson());

class UserHomeData extends Serializable {
  UserData userData;
  RxInt freeze;
  List<UserAllPlan> userAllPlans;
  ClientUser? customSupporter;

  UserHomeData({
    required this.userData,
    required this.freeze,
    required this.userAllPlans,
    required this.customSupporter,
  });

  factory UserHomeData.fromJson(Map<String, dynamic> json) => UserHomeData(
        userData: UserData.fromJson(json["userData"]),
        customSupporter: json["customSupporterData"] == null
            ? null
            : ClientUser.fromJson(json["customSupporterData"]),
        freeze: RxInt(json["freeze"] ?? 0),
        userAllPlans: json["plans"] == null || json["plans"] == [null]
            ? []
            : List<UserAllPlan>.from(
                json["plans"].map((x) => UserAllPlan.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "userData": userData.toJson(),
        "customSupporterData": customSupporter?.toJson(),
        "freeze": freeze,
        "UserAllPlans": List<dynamic>.from(userAllPlans.map((x) => x.toJson())),
      };
}

class UserAllPlan {
  int planId;
  int spendDays;
  int remainingDays;
  String title;
  String shortDescription;
  String longDescription;
  int categoryId;
  String price;
  String currency;
  DateTime? buyingDate;
  DateTime? expireDate;
  PriceData? priceData;

  UserAllPlan({
    required this.spendDays,
    required this.planId,
    required this.remainingDays,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.categoryId,
    required this.buyingDate,
    required this.expireDate,
    required this.price,
    required this.currency,
    this.priceData,
  });

  factory UserAllPlan.fromJson(Map<String, dynamic> json) => UserAllPlan(
        spendDays: json["spendDays"],
        price: json["price"].toString(),
        currency: json["currency"].toString(),
        planId: json["planId"],
        remainingDays: json["remainingDays"],
        title: json["title"] ?? "",
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        categoryId: json["CategoryId"],
        buyingDate: json["buyingDate"] == null
            ? null
            : DateTime.parse(json["buyingDate"]),
        expireDate: json["expireDate"] == null
            ? null
            : DateTime.parse(json["expireDate"]),
        priceData: json["priceData"] == null
            ? PriceData(id: 0, priceAmount: "N/A")
            : PriceData.fromJson(json["priceData"]),
      );

  Map<String, dynamic> toJson() => {
        "spendDays": spendDays,
        "planId": planId,
        "remainingDays": remainingDays,
        "title": title,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "CategoryId": categoryId,
        "buyingDate": buyingDate?.toIso8601String(),
        "expireDate": expireDate?.toIso8601String(),
        "priceData": priceData?.toJson(),
      };
}

class PriceData {
  int? id;
  String? priceAmount;

  PriceData({
    this.id,
    this.priceAmount,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) => PriceData(
        id: json["id"],
        priceAmount: json["priceAmount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "priceAmount": priceAmount,
      };
}

class UserData {
  int id;
  RxBool freeze;
  RxBool usedFreezeOption;

  UserData({
    required this.id,
    required this.freeze,
    required this.usedFreezeOption,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        freeze: RxBool(json["freeze"] ?? false),
        usedFreezeOption: RxBool(json["usedFreezeOption"] ?? false),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "freeze": freeze,
        "usedFreezeOption": usedFreezeOption,
      };
}
