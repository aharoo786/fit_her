// To parse this JSON data, do
//
//     final getDietPlanDetails = getDietPlanDetailsFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';

import '../day_slots_of_diet.dart';
import "package:get/get.dart";

GetDietPlanDetails getDietPlanDetailsFromJson(String str) => GetDietPlanDetails.fromJson(json.decode(str));

String getDietPlanDetailsToJson(GetDietPlanDetails data) => json.encode(data.toJson());

class GetDietPlanDetails extends Serializable {
  List<TimeDietition> timeDietition;
  ClientUser dietDetails;
  SlotWithTime? bookedSlot;
  var pdfFile = ''.obs;
  bool isBooked;
  String status;
  DateTime date;
  int id;
  GetDietPlanDetails({
    required this.timeDietition,
    required this.dietDetails,
    required this.bookedSlot,
    required this.isBooked,
    required this.status,
    required this.id,
    required this.date,
  });

  factory GetDietPlanDetails.fromJson(Map<String, dynamic> json) => GetDietPlanDetails(
      timeDietition: List<TimeDietition>.from(json["TimeDietition"].map((x) => TimeDietition.fromJson(x))),
      dietDetails: ClientUser.fromJson(json["dietDetails"]),
      bookedSlot: json["bookedSlot"] == null ? null : SlotWithTime.fromJson(json["bookedSlot"]),
      isBooked: json["isBooked"] ?? false,
      status: json["status"] ?? "pending",
      id: json["id"] ?? 0,
      date: DateTime.parse(json["date"] ?? DateTime.now().toString())) ;

  Map<String, dynamic> toJson() => {
        "TimeDietition": List<dynamic>.from(timeDietition.map((x) => x.toJson())),
        "dietDetails": dietDetails.toJson(),
        "bookedSlot": bookedSlot?.toJson(),
        "isBooked": isBooked,
        "status": status,
        "id": id,
        "date": date
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

  factory TimeDietitionNot.fromJson(Map<String, dynamic> json) => TimeDietitionNot(
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
        start: json["start"] == "Start Time"
            ? "Start Time"
            : (json["start"].toString().contains("AM") || json["start"].toString().contains("PM"))
                ? json["start"]
                : DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(json["start"]))),
        end: json["end"] == "End Time"
            ? "End Time"
            : (json["end"].toString().contains("AM") || json["end"].toString().contains("PM"))
                ? json["end"]
                : DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(json["end"]))),
        dietitionLink: json["dietitionLink"],
        timeDietition: json["TimeDietition"] == null ? null : TimeDietitionNot.fromJson(json["TimeDietition"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start": start,
        "end": end,
        "dietitionLink": dietitionLink,
        "TimeDietition": timeDietition?.toJson(),
      };
}
