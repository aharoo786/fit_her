// To parse this JSON data, do
//
//     final getGuestData = getGuestDataFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetGuestData getGuestDataFromJson(String str) =>
    GetGuestData.fromJson(json.decode(str));

String getGuestDataToJson(GetGuestData data) => json.encode(data.toJson());

class GetGuestData extends Serializable {
  List<Datum> data;

  GetGuestData({
    required this.data,
  });

  factory GetGuestData.fromJson(Map<String, dynamic> json) => GetGuestData(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int id;
  String name;
  String email;
  String phone;
  String? result;
  DateTime createdAt;
  DateTime updatedAt;

  Datum({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        result: json["result"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "result": result,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
