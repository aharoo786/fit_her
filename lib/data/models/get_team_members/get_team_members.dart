// To parse this JSON data, do
//
//     final getTeamMembers = getTeamMembersFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetTeamMembers getTeamMembersFromJson(String str) =>
    GetTeamMembers.fromJson(json.decode(str));

String getTeamMembersToJson(GetTeamMembers data) => json.encode(data.toJson());

class GetTeamMembers extends Serializable{
  List<Datum> data;

  GetTeamMembers({
    required this.data,
  });

  factory GetTeamMembers.fromJson(Map<String, dynamic> json) => GetTeamMembers(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String? image;

  Datum({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "image": image,
      };
}
