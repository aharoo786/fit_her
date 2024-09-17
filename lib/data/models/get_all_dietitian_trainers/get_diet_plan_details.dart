import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class GetDietPlanDetails extends Serializable{
  Details details;
  DietitionDetails dietitionDetails;

  GetDietPlanDetails({
    required this.details,
    required this.dietitionDetails,
  });

  factory GetDietPlanDetails.fromRawJson(String str) => GetDietPlanDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetDietPlanDetails.fromJson(Map<String, dynamic> json) => GetDietPlanDetails(
    details: Details.fromJson(json["details"]),
    dietitionDetails: DietitionDetails.fromJson(json["dietitionDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "details": details.toJson(),
    "dietitionDetails": dietitionDetails.toJson(),
  };
}

class Details {
  int id;
  String? dietitionLink;
  List<DietTime> dietTimes;

  Details({
    required this.id,
    required this.dietTimes,
    required this.dietitionLink,
  });

  factory Details.fromRawJson(String str) => Details.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    id: json["id"],
    dietitionLink: json["dietitionLink"],
    dietTimes: List<DietTime>.from(json["DietTimes"].map((x) => DietTime.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "DietTimes": List<dynamic>.from(dietTimes.map((x) => x.toJson())),
    "dietitionLink":dietitionLink
  };
}

class DietTime {
  int id;
  String day;
  int? userPlanId;
  List<Diet> diets;

  DietTime({
    required this.id,
    required this.day,
    this.userPlanId,
    required this.diets,
  });

  factory DietTime.fromRawJson(String str) => DietTime.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DietTime.fromJson(Map<String, dynamic> json) => DietTime(
    id: json["id"],
    day: json["day"],
    userPlanId: json["UserPlanId"],
    diets: List<Diet>.from(json["Diets"].map((x) => Diet.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day": day,
    "UserPlanId": userPlanId,
    "Diets": List<dynamic>.from(diets.map((x) => x.toJson())),
  };
}

class Diet {
  int id;
  String time;
  String food;
  String calories;
  int? dietTimeId;

  Diet({
    required this.id,
    required this.time,
    required this.food,
    required this.calories,
    this.dietTimeId,
  });

  factory Diet.fromRawJson(String str) => Diet.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Diet.fromJson(Map<String, dynamic> json) => Diet(
    id: json["id"],
    time: json["time"],
    food: json["food"],
    calories: json["calories"],
    dietTimeId: json["DietTimeId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "time": time,
    "food": food,
    "calories": calories,
    "DietTimeId": dietTimeId,
  };
}

class DietitionDetails {
  User user;

  DietitionDetails({
    required this.user,
  });

  factory DietitionDetails.fromRawJson(String str) => DietitionDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DietitionDetails.fromJson(Map<String, dynamic> json) => DietitionDetails(
    user: User.fromJson(json["User"]),
  );

  Map<String, dynamic> toJson() => {
    "User": user.toJson(),
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
