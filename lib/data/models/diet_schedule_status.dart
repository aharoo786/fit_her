// To parse this JSON data, do
//
//     final dietPlanScheduleStatus = dietPlanScheduleStatusFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';

DietPlanScheduleStatus dietPlanScheduleStatusFromJson(String str) => DietPlanScheduleStatus.fromJson(json.decode(str));

String dietPlanScheduleStatusToJson(DietPlanScheduleStatus data) => json.encode(data.toJson());

class DietPlanScheduleStatus  extends Serializable{
  List<PdfDiet>? pdfDiets;

  DietPlanScheduleStatus({
    this.pdfDiets,
  });

  factory DietPlanScheduleStatus.fromJson(Map<String, dynamic> json) => DietPlanScheduleStatus(
    pdfDiets: json["pdfDiets"] == null ? [] : List<PdfDiet>.from(json["pdfDiets"]!.map((x) => PdfDiet.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pdfDiets": pdfDiets == null ? [] : List<dynamic>.from(pdfDiets!.map((x) => x.toJson())),
  };
}

class PdfDiet {
  int? id;
  DateTime? date;
  String? pdfFile;
  bool? status;
  String? dietStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? userId;
  int? userPlanId;
  ClientUser? user;

  PdfDiet({
    this.id,
    this.date,
    this.pdfFile,
    this.status,
    this.dietStatus,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userPlanId,
    this.user,
  });

  factory PdfDiet.fromJson(Map<String, dynamic> json) => PdfDiet(
    id: json["id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    pdfFile: json["pdfFile"],
    status: json["status"],
    dietStatus: json["dietStatus"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    userId: json["userId"],
    userPlanId: json["userPlanId"],
    user: json["User"] == null ? null : ClientUser.fromJson(json["User"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date?.toIso8601String(),
    "pdfFile": pdfFile,
    "status": status,
    "dietStatus": dietStatus,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "userId": userId,
    "userPlanId": userPlanId,
    "User": user?.toJson(),
  };

}


