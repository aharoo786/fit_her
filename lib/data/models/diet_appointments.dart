// To parse this JSON data, do
//
//     final dietAppointments = dietAppointmentsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

import 'get_clients_diet.dart';
import 'package:intl/intl.dart';

DietAppointments dietAppointmentsFromJson(String str) => DietAppointments.fromJson(json.decode(str));

String dietAppointmentsToJson(DietAppointments data) => json.encode(data.toJson());

class DietAppointments  extends Serializable{
  List<Appointment> appointments;

  DietAppointments({
    required this.appointments,
  });

  factory DietAppointments.fromJson(Map<String, dynamic> json) => DietAppointments(
    appointments: List<Appointment>.from(json["appointments"].map((x) => Appointment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "appointments": List<dynamic>.from(appointments.map((x) => x.toJson())),
  };
}

class Appointment {
  int id;
  DateTime date;
  String status;
  int userId;
  int dietitionId;
  int timeSlotId;
  String message;
  ClientUser? clientUser;
  SlotDiet? slotDiet;
  // 'initial' | 'followup' | null (legacy rows predate this column —
  // treat null as 'initial', same convention the backend itself uses
  // wherever it queries by kind).
  String? kind;
  // Per-appointment snapshot of the meeting link, taken at confirm time
  // (see backend Appointments.js meetLink doc comment). Null for older
  // rows or ones confirmed before a link existed on the slot yet — in
  // that case fall back to slotDiet.dietitionLink, same rule the client
  // side already applies server-side. Use `resolvedMeetLink` below
  // rather than reading this directly.
  dynamic meetLink;

  Appointment({
    required this.id,
    required this.date,
    required this.status,
    required this.userId,
    required this.dietitionId,
    required this.timeSlotId,
    required this.clientUser,
    required this.message,
    required this.slotDiet,
    this.meetLink,
    this.kind,
  });

  /// The link to actually open for this appointment: this appointment's
  /// own frozen snapshot if it has one, otherwise the weekly slot's
  /// current link. Null (or blank) means no link has been set yet.
  String? get resolvedMeetLink {
    final own = meetLink?.toString().trim();
    if (own != null && own.isNotEmpty) return own;
    final slotLink = slotDiet?.dietitionLink?.toString().trim();
    if (slotLink != null && slotLink.isNotEmpty) return slotLink;
    return null;
  }

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    // Same `?? 0` defensive pattern already used for userId below.
    // Backend has been observed returning null timeSlotId for some
    // appointment rows (e.g. unassigned slot deleted server-side);
    // without the guard, the int cast crashes the whole list parse
    // and no appointments render at all.
    id: json["id"] ?? 0,
    date: DateTime.parse(json["date"]),
    status: json["status"] ?? "",
    userId: json["userId"]??0,
    message: json["message"]??"N/A",
    dietitionId: json["dietitionId"] ?? 0,
    timeSlotId: json["timeSlotId"] ?? 0,
    clientUser:json["ClientUser"]==null?null: ClientUser.fromJson(json["ClientUser"]),
    slotDiet: json["SlotDiet"]==null?null:SlotDiet.fromJson(json["SlotDiet"]),
    meetLink: json["meetLink"],
    kind: json["kind"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toIso8601String(),
    "status": status,
    "message": message,
    "userId": userId,
    "dietitionId": dietitionId,
    "timeSlotId": timeSlotId,
    "ClientUser": clientUser?.toJson(),
    "SlotDiet": slotDiet?.toJson(),
    "meetLink": meetLink,
    "kind": kind,
  };
}



class SlotDiet {
  int? id;
  String? start;
  String? end;
  dynamic dietitionLink;
  dynamic isAvailble;
  int? dietitionId;
  int? timeDietitionId;

  SlotDiet({
    required this.id,
    required this.start,
    required this.end,
    required this.dietitionLink,
    required this.isAvailble,
    required this.dietitionId,
    required this.timeDietitionId,
  });

  factory SlotDiet.fromJson(Map<String, dynamic> json) => SlotDiet(
    id: json["id"],
    start: json["start"] == "Start Time"
        ? "Start Time"
        : (json["start"].toString().contains("AM") ||
        json["start"].toString().contains("PM"))
        ? json["start"]
        : DateFormat('hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(
            int.parse(json["start"]))),
    end: json["end"] == "End Time"
        ? "End Time"
        : (json["end"].toString().contains("AM") ||
        json["end"].toString().contains("PM"))
        ? json["end"]
        : DateFormat('hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(
            int.parse(json["end"]))),
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
  get time => "${this.start} - ${this.end}";

}
