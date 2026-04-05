// To parse this JSON data, do
//
//     final measurementModel = measurementModelFromJson(jsonString);

import 'dart:convert';

MeasurementModel measurementModelFromJson(String str) =>
    MeasurementModel.fromJson(json.decode(str));

String measurementModelToJson(MeasurementModel data) =>
    json.encode(data.toJson());

class MeasurementModel {
  String firstName;
  String userId;
  String lastName;
  String firstDate;
  String currentDate;
  String firstWeight;
  String currentWeight;
  String waist;
  String hips;
  String shoulder;
  String arms;
  String chest;
  String abdomnen;
  String thighs;

  MeasurementModel({
    required this.firstName,
    required this.userId,
    required this.lastName,
    required this.firstDate,
    required this.currentDate,
    required this.firstWeight,
    required this.currentWeight,
    required this.waist,
    required this.hips,
    required this.shoulder,
    required this.arms,
    required this.chest,
    required this.abdomnen,
    required this.thighs,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) =>
      MeasurementModel(
        firstName: json["firstName"],
        userId: json["userId"],
        lastName: json["lastName"],
        firstDate: json["firstDate"],
        currentDate: json["currentDate"],
        firstWeight: json["firstWeight"],
        currentWeight: json["currentWeight"],
        waist: json["waist"],
        hips: json["hips"],
        shoulder: json["shoulder"],
        arms: json["arms"],
        chest: json["chest"],
        abdomnen: json["abdomnen"],
        thighs: json["thighs"],
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "userId": userId,
        "firstDate": firstDate,
        "currentDate": currentDate,
        "firstWeight": firstWeight,
        "currentWeight": currentWeight,
        "waist": waist,
        "hips": hips,
        "shoulder": shoulder,
        "arms": arms,
        "chest": chest,
        "abdomnen": abdomnen,
        "thighs": thighs,
      };
}
