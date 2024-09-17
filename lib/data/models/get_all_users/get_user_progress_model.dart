import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class GetUserProgressImagesModel extends Serializable{
  List<Progress> progress;

  GetUserProgressImagesModel({
    required this.progress,
  });

  factory GetUserProgressImagesModel.fromRawJson(String str) => GetUserProgressImagesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetUserProgressImagesModel.fromJson(Map<String, dynamic> json) => GetUserProgressImagesModel(
    progress: List<Progress>.from(json["progress"].map((x) => Progress.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "progress": List<dynamic>.from(progress.map((x) => x.toJson())),
  };
}

class Progress {
  int id;
  String before;
  String after;
  dynamic status;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;

  Progress({
    required this.id,
    required this.before,
    required this.after,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Progress.fromRawJson(String str) => Progress.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    id: json["id"],
    before: json["before"],
    after: json["after"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    userId: json["UserId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "before": before,
    "after": after,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "UserId": userId,
  };
}
