// To parse this JSON data, do
//
//     final addPackageModel = addPackageModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';

AddPackageModel addPackageModelFromJson(String str) =>
    AddPackageModel.fromJson(json.decode(str));

String addPackageModelToJson(AddPackageModel data) =>
    json.encode(data.toJson());

class AddPackageModel {
  String title;
  String shortDescription;
  String longDescription;
  String categoryId;
  String subCategoryId;
  String price;
  String duration;
  List<Time> times;

  AddPackageModel(
      {required this.title,
      required this.shortDescription,
      required this.longDescription,
      required this.categoryId,
      required this.subCategoryId,
      required this.price,
      required this.times,
      required this.duration});

  factory AddPackageModel.fromJson(Map<String, dynamic> json) =>
      AddPackageModel(
        title: json["title"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        categoryId: json["CategoryId"],
        subCategoryId: json["subCategoryId"],
        price: json["price"],
        times: List<Time>.from(json["times"].map((x) => Time.fromJson(x))),
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "CategoryId": categoryId,
        "subCategoryId": subCategoryId,
        "price": price,
        "duration": duration,
        "times": List<dynamic>.from(times.map((x) => x.toJson())),
      };
}

class Time {
  String day;
  List<Slot> slots;

  Time({
    required this.day,
    required this.slots,
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
        day: json["day"],
        slots: List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
      };
}

class Slot {
  String start;
  String end;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  Slot({
    required this.start,
    required this.end,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        start: json["start"],
        end: json["end"],
      );

  Map<String, dynamic> toJson() => {
        "start": start,
        "end": end,
      };
}
