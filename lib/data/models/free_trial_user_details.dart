// To parse this JSON data, do
//
//     final getFreeTrialUserDetails = getFreeTrialUserDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

import 'get_clients_diet.dart';
import 'get_user_plan/get_workout_user_plan_details.dart';

GetFreeTrialUserDetails getFreeTrialUserDetailsFromJson(String str) =>
    GetFreeTrialUserDetails.fromJson(json.decode(str));

String getFreeTrialUserDetailsToJson(GetFreeTrialUserDetails data) =>
    json.encode(data.toJson());

class GetFreeTrialUserDetails extends Serializable {
  List<FreeTrialUser>? user;

  GetFreeTrialUserDetails({
    this.user,
  });

  factory GetFreeTrialUserDetails.fromJson(Map<String, dynamic> json) =>
      GetFreeTrialUserDetails(
        user: json["filteredUsers"] == null
            ? []
            : List<FreeTrialUser>.from(
                json["filteredUsers"]!.map((x) => FreeTrialUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "filteredUsers": user == null
            ? []
            : List<dynamic>.from(user!.map((x) => x.toJson())),
      };
}

class FreeTrialUser {
  int? id;
  String? mainGoal;
  String? specificIssues;
  String? prefrences;
  DateTime? createdAt;
  List<FreeUserSlot>? freeUserSlots;
  ClientUser? freeUserId;

  FreeTrialUser({
    this.id,
    this.mainGoal,
    this.specificIssues,
    this.prefrences,
    this.freeUserSlots,
    this.createdAt,
    this.freeUserId,
  });

  factory FreeTrialUser.fromJson(Map<String, dynamic> json) => FreeTrialUser(
        id: json["id"],
        mainGoal: json["mainGoal"],
        createdAt:
            DateTime.tryParse(json["createdAt"] ?? DateTime.now().toString()),
        specificIssues: json["specificIssues"],
        prefrences: json["prefrences"],
        freeUserSlots: json["freeUserSlots"] == null
            ? []
            : List<FreeUserSlot>.from(
                json["freeUserSlots"]!.map((x) => FreeUserSlot.fromJson(x))),
        freeUserId: json["freeUserId"] == null
            ? null
            : ClientUser.fromJson(json["freeUserId"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mainGoal": mainGoal,
        "specificIssues": specificIssues,
        "prefrences": prefrences,
        "freeUserSlots": freeUserSlots == null
            ? []
            : List<dynamic>.from(freeUserSlots!.map((x) => x.toJson())),
        "freeUserId": freeUserId?.toJson(),
      };
}

class FreeUserSlot {
  int? id;
  Slot? slot;

  FreeUserSlot({
    this.id,
    this.slot,
  });

  factory FreeUserSlot.fromJson(Map<String, dynamic> json) => FreeUserSlot(
        id: json["id"],
        slot: json["slot"] == null ? null : Slot.fromJson(json["slot"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slot": slot?.toJson(),
      };
}
