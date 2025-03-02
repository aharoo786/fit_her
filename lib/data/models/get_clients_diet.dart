// To parse this JSON data, do
//
//     final dietClients = dietClientsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

DietClients dietClientsFromJson(String str) => DietClients.fromJson(json.decode(str));

String dietClientsToJson(DietClients data) => json.encode(data.toJson());

class DietClients  extends Serializable{
  List<Cliet> cliets;

  DietClients({
    required this.cliets,
  });

  factory DietClients.fromJson(Map<String, dynamic> json) => DietClients(
    cliets: List<Cliet>.from(json["cliets"].map((x) => Cliet.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cliets": List<dynamic>.from(cliets.map((x) => x.toJson())),
  };
}

class Cliet {
  int id;
  DateTime buyingDate;
  DateTime expireDate;
  ClientUser? user;

  Cliet({
    required this.id,
    required this.buyingDate,
    required this.expireDate,
    required this.user,
  });

  factory Cliet.fromJson(Map<String, dynamic> json) => Cliet(
    id: json["id"],
    buyingDate: DateTime.parse(json["buyingDate"]??DateTime.now()),
    expireDate: DateTime.parse(json["expireDate"]??DateTime.now()),
    user:json["User"]==null?null: ClientUser.fromJson(json["User"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "buyingDate": buyingDate.toIso8601String(),
    "expireDate": expireDate.toIso8601String(),
    "User": user?.toJson(),
  };
}

class ClientUser {
  int id;
  String firstName;
  String lastName;
  String email;
  String experience;

  ClientUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.experience,
  });

  factory ClientUser.fromJson(Map<String, dynamic> json) => ClientUser(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    experience: json["experience"]??"N/A",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "experience": experience,
  };
}
