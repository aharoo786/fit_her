// To parse this JSON data, do
//
//     final getDietPlanDetails = getDietPlanDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';

import '../day_slots_of_diet.dart';
import "package:get/get.dart";

GetDietPlanDetails getDietPlanDetailsFromJson(String str) =>
    GetDietPlanDetails.fromJson(json.decode(str));

String getDietPlanDetailsToJson(GetDietPlanDetails data) =>
    json.encode(data.toJson());

class GetDietPlanDetails extends Serializable {
  List<TimeDietition> timeDietition;
  ClientUser dietDetails;
  SlotWithTime? bookedSlot;
  var pdfFile=''.obs;

  GetDietPlanDetails({
    required this.timeDietition,
    required this.dietDetails,
    required this.bookedSlot,
  });

  factory GetDietPlanDetails.fromJson(Map<String, dynamic> json) =>
      GetDietPlanDetails(
        timeDietition: List<TimeDietition>.from(
            json["TimeDietition"].map((x) => TimeDietition.fromJson(x))),
        dietDetails: ClientUser.fromJson(json["dietDetails"]),
        bookedSlot: json["bookedSlot"] == null
            ? null
            : SlotWithTime.fromJson(json["bookedSlot"]),
      );

  Map<String, dynamic> toJson() => {
        "TimeDietition":
            List<dynamic>.from(timeDietition.map((x) => x.toJson())),
        "dietDetails": dietDetails.toJson(),
        "bookedSlot": bookedSlot?.toJson(),
      };
}

class TimeDietition {
  int id;
  String day;
  List<Slot> slots;

  TimeDietition({
    required this.id,
    required this.day,
    required this.slots,
  });

  factory TimeDietition.fromJson(Map<String, dynamic> json) => TimeDietition(
        id: json["id"],
        day: json["day"],
        slots: List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "day": day,
        "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
      };
}

class TimeDietitionNot {
  int? id;
  String? day;

  TimeDietitionNot({
    this.id,
    this.day,
  });

  factory TimeDietitionNot.fromJson(Map<String, dynamic> json) =>
      TimeDietitionNot(
        id: json["id"],
        day: json["day"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "day": day,
      };
}

class SlotWithTime {
  int? id;
  String? start;
  String? end;
  dynamic dietitionLink;
  TimeDietitionNot? timeDietition;

  SlotWithTime({
    this.id,
    this.start,
    this.end,
    this.dietitionLink,
    this.timeDietition,
  });

  factory SlotWithTime.fromJson(Map<String, dynamic> json) => SlotWithTime(
        id: json["id"],
        start: json["start"],
        end: json["end"],
        dietitionLink: json["dietitionLink"],
        timeDietition: json["TimeDietition"] == null
            ? null
            : TimeDietitionNot.fromJson(json["TimeDietition"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start": start,
        "end": end,
        "dietitionLink": dietitionLink,
        "TimeDietition": timeDietition?.toJson(),
      };
}
