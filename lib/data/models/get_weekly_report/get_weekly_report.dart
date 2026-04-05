// To parse this JSON data, do
//
//     final getWeeklyReportsModel = getWeeklyReportsModelFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

GetWeeklyReportsModel getWeeklyReportsModelFromJson(String str) =>
    GetWeeklyReportsModel.fromJson(json.decode(str));

String getWeeklyReportsModelToJson(GetWeeklyReportsModel data) =>
    json.encode(data.toJson());

class GetWeeklyReportsModel extends Serializable {
  List<Report> reports;

  GetWeeklyReportsModel({
    required this.reports,
  });

  factory GetWeeklyReportsModel.fromJson(Map<String, dynamic> json) =>
      GetWeeklyReportsModel(
        reports:
            List<Report>.from(json["reports"].map((x) => Report.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reports": List<dynamic>.from(reports.map((x) => x.toJson())),
      };
}

class Report {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone;
  List<ReportElement> reports;

  Report({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.reports,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"]??"",
        reports: List<ReportElement>.from(
            json["Reports"].map((x) => ReportElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "Reports": List<dynamic>.from(reports.map((x) => x.toJson())),
      };
}

class ReportElement {
  int id;
  String weight;
  String currentWeight;
  String weist;
  String hips;
  String arms;
  String shoulder;
  String chest;
  String abdoman;
  String thighs;
  String istDayDate;
  String currentDate;
  dynamic status;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;

  ReportElement({
    required this.id,
    required this.weight,
    required this.currentWeight,
    required this.weist,
    required this.hips,
    required this.arms,
    required this.shoulder,
    required this.chest,
    required this.abdoman,
    required this.thighs,
    required this.istDayDate,
    required this.currentDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory ReportElement.fromJson(Map<String, dynamic> json) => ReportElement(
        id: json["id"],
        weight: json["weight"],
        currentWeight: json["currentWeight"],
        weist: json["weist"],
        hips: json["hips"],
        arms: json["arms"],
        shoulder: json["shoulder"],
        chest: json["chest"],
        abdoman: json["abdoman"],
        thighs: json["thighs"],
        istDayDate: json["istDayDate"],
        currentDate: json["currentDate"]??DateTime.now().toString(),
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "weight": weight,
        "currentWeight": currentWeight,
        "weist": weist,
        "hips": hips,
        "arms": arms,
        "shoulder": shoulder,
        "chest": chest,
        "abdoman": abdoman,
        "thighs": thighs,
        "istDayDate": istDayDate,
        "currentDate": currentDate,
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "userId": userId,
      };
}
