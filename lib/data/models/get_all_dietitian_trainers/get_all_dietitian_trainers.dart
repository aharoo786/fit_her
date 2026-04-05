// To parse this JSON data, do
//
//     final getAllDietitianAndTrainers = getAllDietitianAndTrainersFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetAllDietitianAndTrainers getAllDietitianAndTrainersFromJson(String str) =>
    GetAllDietitianAndTrainers.fromJson(json.decode(str));

String getAllDietitianAndTrainersToJson(GetAllDietitianAndTrainers data) =>
    json.encode(data.toJson());

class GetAllDietitianAndTrainers extends Serializable {
  List<Dietition> dietitions;
  List<Dietition> trainers;

  GetAllDietitianAndTrainers({
    required this.dietitions,
    required this.trainers,
  });

  factory GetAllDietitianAndTrainers.fromJson(Map<String, dynamic> json) =>
      GetAllDietitianAndTrainers(
        dietitions: List<Dietition>.from(
            json["dietitions"].map((x) => Dietition.fromJson(x))),
        trainers: List<Dietition>.from(
            json["trainers"].map((x) => Dietition.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dietitions": List<dynamic>.from(dietitions.map((x) => x.toJson())),
        "trainers": List<dynamic>.from(trainers.map((x) => x.toJson())),
      };
}

class Dietition {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;



  Dietition({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,

  });

  factory Dietition.fromJson(Map<String, dynamic> json) => Dietition(
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
