// To parse this JSON data, do
//
//     final addPackageModel = addPackageModelFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

AddPackageModel addPackageModelFromJson(String str) =>
    AddPackageModel.fromJson(json.decode(str));

String addPackageModelToJson(AddPackageModel data) =>
    json.encode(data.toJson());

class AddPackageModel {
  String? id;
  String title;
  String shortDescription;
  String longDescription;
  String categoryId;
  String subCategoryId;
  String? dietitianId;
  List<AddCountriesListToPackage> countriesList;

  AddPackageModel({
    required this.title,
    this.id,
    required this.shortDescription,
    required this.longDescription,
    required this.categoryId,
    required this.subCategoryId,
    this.dietitianId,
    required this.countriesList,
  });

  factory AddPackageModel.fromJson(Map<String, dynamic> json) =>
      AddPackageModel(
        title: json["title"],
        id: null,
        shortDescription: json["shortDescription"],
        dietitianId: json["dietitianId"],
        longDescription: json["longDescription"],
        categoryId: json["CategoryId"],
        subCategoryId: json["subCategoryId"],
        countriesList: List<AddCountriesListToPackage>.from(
            json["countriesList"]
                .map((x) => AddCountriesListToPackage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "CategoryId": categoryId,
        "subCategoryId": subCategoryId,
        "dietitianId": dietitianId,
        "countriesList":
            List<dynamic>.from(countriesList.map((x) => x.toJson())),
      };
}

class Time {
  String day;
  int id;
  List<Slot> slots;

  Time({
    required this.day,
    required this.id,
    required this.slots,
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
        day: json["day"],
        id: json["id"],
        slots: List<Slot>.from(json["Slots"].map((x) => Slot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "id": id,
        "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
      };
}

class Slot {
  String start;
  String end;
  int? id;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  int? trainerId;
  // String? trainerLink;
  int? dayId;

  Slot({
    required this.start,
    required this.end,
    this.trainerId,
    this.id,
    this.dayId,
    //    this.trainerLink
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        start: json["start"] == "Start Time"
            ? "Start Time"
            : DateFormat('hh:mm a')
                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(json["start"]))),
        end: json["end"] == "End Time"
            ? "End Time"
            : DateFormat('hh:mm a')
                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(json["end"]))),
        id: json["id"],
        dayId: json["TimeId"],
        // trainerLink: json["trainerLink"],
        trainerId: json["trainerId"],
      );

  Map<String, dynamic> toJson() => {
        "start": start,
        "end": end,
        "trainerId": trainerId,
        "id": id,
        //  "trainerLink": trainerLink,
        "dayId": dayId
      };
}

class AddCountriesListToPackage {
  int id;
  String name = "Select Country";
  List<DurationPackageSent> durationList;

  AddCountriesListToPackage({
    required this.id,
    required this.durationList,
  });

  // Factory constructor to create an AddCountriesListToPackage instance from JSON
  factory AddCountriesListToPackage.fromJson(Map<String, dynamic> json) {
    return AddCountriesListToPackage(
      id: json['id'] as int,
      durationList: (json['durationList'] as List)
          .map((item) => DurationPackageSent.fromJson(item))
          .toList(),
    );
  }

  // Method to convert an AddCountriesListToPackage instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationList': durationList.map((item) => item.toJson()).toList(),
    };
  }
}

class DurationPackageSent {
  int id;
  String duration = "Select Duration";
  TextEditingController amount = TextEditingController();

  DurationPackageSent({required this.id});

  // Factory constructor to create a DurationPackageSent instance from JSON
  factory DurationPackageSent.fromJson(Map<String, dynamic> json) {
    DurationPackageSent durationPackageSent = DurationPackageSent(
      id: json['id'] as int,
    );
    durationPackageSent.amount.text =
        json['amount'] as String; // Initialize the controller text
    return durationPackageSent;
  }

  // Method to convert a DurationPackageSent instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount.text, // Get the text from TextEditingController
    };
  }
}
