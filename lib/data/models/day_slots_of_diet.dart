// To parse this JSON data, do
//
//     final daySlotsOfDiet = daySlotsOfDietFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

DaySlotsOfDiet daySlotsOfDietFromJson(String str) => DaySlotsOfDiet.fromJson(json.decode(str));

String daySlotsOfDietToJson(DaySlotsOfDiet data) => json.encode(data.toJson());

class DaySlotsOfDiet extends Serializable {
  List<Slot> slots;

  DaySlotsOfDiet({
    required this.slots,
  });

  factory DaySlotsOfDiet.fromJson(Map<String, dynamic> json) => DaySlotsOfDiet(
    slots: List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
  };
}

class Slot {
  int? id;
  String start;
  String end;
  dynamic dietitionLink;
  dynamic isAvailble;
  int? dietitionId;
  int? timeDietitionId;

  Slot({
    required this.id,
    required this.start,
    required this.end,
    required this.dietitionLink,
    required this.isAvailble,
     this.dietitionId,
     this.timeDietitionId,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json["id"],
    start: json["start"] == "Start Time"
        ? "Start Time"
        : DateFormat('hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(json["start"]))),
    end: json["end"] == "End Time"
        ? "End Time"
        : DateFormat('hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(json["end"]))),
    dietitionLink: json["dietitionLink"],
    isAvailble: json["isAvailble"],
    dietitionId: json["dietitionId"],
    timeDietitionId: json["TimeDietitionId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start": start,
    "end": end,
    "dietitionLink": dietitionLink,
    "isAvailble": isAvailble,
    "dietitionId": dietitionId,
    "TimeDietitionId": timeDietitionId,
  };
}
