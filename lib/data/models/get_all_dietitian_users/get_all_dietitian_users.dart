import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class GetDietitianUsers  extends Serializable{
  List<Result> result;

  GetDietitianUsers({
    required this.result,
  });

  factory GetDietitianUsers.fromRawJson(String str) => GetDietitianUsers.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetDietitianUsers.fromJson(Map<String, dynamic> json) => GetDietitianUsers(
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class Result {
  UserPlan userPlan;

  Result({
    required this.userPlan,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    userPlan: UserPlan.fromJson(json["UserPlan"]),
  );

  Map<String, dynamic> toJson() => {
    "UserPlan": userPlan.toJson(),
  };
}

class UserPlan {
  String title;
  int id;
  DateTime? buyingDate;
  DateTime? expireDate;
  int price;
  dynamic dietitionLink;
  bool status;
  User? user;

  UserPlan({
    required this.title,
    required this.id,
    required this.buyingDate,
    required this.expireDate,
    required this.price,
    required this.dietitionLink,
    required this.status,
    required this.user,
  });

  factory UserPlan.fromRawJson(String str) => UserPlan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
    title: json["title"],
    id: json["id"],
    buyingDate: json["buyingDate"] == null ? DateTime.now() : DateTime.parse(json["buyingDate"]),
    expireDate: json["expireDate"] == null ? DateTime.now() : DateTime.parse(json["expireDate"]),
    price: json["price"],
    dietitionLink: json["dietitionLink"],
    status: json["status"],
    user: json["User"] ==null?null:User.fromJson(json["User"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "id": id,
    "buyingDate": buyingDate?.toIso8601String(),
    "expireDate": expireDate?.toIso8601String(),
    "price": price,
    "dietitionLink": dietitionLink,
    "status": status,
    "User": user?.toJson(),
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

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

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
