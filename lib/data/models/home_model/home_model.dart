// To parse this JSON data, do
//
//     final userHomeData = userHomeDataFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

UserHomeData userHomeDataFromJson(String str) =>
    UserHomeData.fromJson(json.decode(str));

String userHomeDataToJson(UserHomeData data) => json.encode(data.toJson());

class UserHomeData extends Serializable {
  int spendDays;
  int remainingDays;
  int price;
  String title;
  dynamic dietitionLink;
  String shortDescription;
  String longDescription;
  List<Time> time;
  int freeze;
  int CategoryId;
  DietitionDetails? dietitionDetails;
  List<Testimonial> testimonial;

  UserHomeData({
    required this.spendDays,
    required this.remainingDays,
    required this.price,
    required this.title,
    required this.dietitionLink,
    required this.shortDescription,
    required this.longDescription,
    required this.time,
    required this.dietitionDetails,
    required this.testimonial,
    required this.freeze,
    required this.CategoryId,
  });

  factory UserHomeData.fromJson(Map<String, dynamic> json) => UserHomeData(
        spendDays: json["spendDays"],
        remainingDays: json["remainingDays"],
        price: json["price"],
        title: json["title"],
        freeze: json["freeze"],
        CategoryId: json["CategoryId"],
        dietitionLink: json["dietitionLink"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        time: List<Time>.from(json["Time"].map((x) => Time.fromJson(x))),
        dietitionDetails: json["dietitionDetails"] == null
            ? null
            : DietitionDetails.fromJson(json["dietitionDetails"]),
        testimonial: List<Testimonial>.from(
            json["testimonial"].map((x) => Testimonial.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "spendDays": spendDays,
        "remainingDays": remainingDays,
        "price": price,
        "title": title,
        "freeze": freeze,
        "CategoryId": CategoryId,
        "dietitionLink": dietitionLink,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "Time": List<dynamic>.from(time.map((x) => x.toJson())),
        "dietitionDetails": dietitionDetails?.toJson(),
        "testimonial": List<dynamic>.from(testimonial.map((x) => x.toJson())),
      };
}

class DietitionDetails {
  int id;
  String firstName;
  String lastName;
  String email;

  DietitionDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory DietitionDetails.fromJson(Map<String, dynamic> json) =>
      DietitionDetails(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
      };
}

class Testimonial {
  int id;
  String image;

  Testimonial({
    required this.id,
    required this.image,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
        id: json["id"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
      };
}

class Time {
  int id;
  String day;
  List<Slot> slots;

  Time({
    required this.id,
    required this.day,
    required this.slots,
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
        id: json["id"],
        day: json["day"],
        slots: List<Slot>.from(json["Slots"].map((x) => Slot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "day": day,
        "Slots": List<dynamic>.from(slots.map((x) => x.toJson())),
      };
}

class Slot {
  int id;
  String start;
  String end;
  dynamic trainerLink;

  Slot({
    required this.id,
    required this.start,
    required this.end,
    required this.trainerLink,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        id: json["id"],
        start: json["start"],
        end: json["end"],
        trainerLink: json["trainerLink"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start": start,
        "end": end,
        "trainerLink": trainerLink,
      };
}
