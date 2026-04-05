import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class GetUsersBasedOnUserType  extends Serializable{
  List<UserTypeData> users;

  GetUsersBasedOnUserType({
    required this.users,
  });

  factory GetUsersBasedOnUserType.fromRawJson(String str) => GetUsersBasedOnUserType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetUsersBasedOnUserType.fromJson(Map<String, dynamic> json) => GetUsersBasedOnUserType(
    users: List<UserTypeData>.from(json["users"].map((x) => UserTypeData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
  };
}

class UserTypeData {
  int id;
  String firstName;
  String lastName;
  String email;
  String? image;
  String phone;
  String? speciality;
  String? totalPatients;
  String? experience;
  String? description;

  UserTypeData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.image,
    required this.phone,
    this.speciality,
    this.totalPatients,
    this.experience,
    this.description,
  });

  factory UserTypeData.fromRawJson(String str) => UserTypeData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserTypeData.fromJson(Map<String, dynamic> json) => UserTypeData(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    image: json["image"],
    phone: json["phone"],
    speciality: json["speciality"],
    totalPatients: json["totalPatients"],
    experience: json["experience"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "image": image,
    "phone": phone,
    "speciality": speciality,
    "totalPatients": totalPatients,
    "experience": experience,
    "description": description,
  };
}
