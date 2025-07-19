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
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json["id"],
    date: DateTime.parse(json["date"]),
    status: json["status"],
    userId: json["userId"]??0,
    message: json["message"]??"N/A",
    dietitionId: json["dietitionId"],
    timeSlotId: json["timeSlotId"],
    clientUser:json["ClientUser"]==null?null: ClientUser.fromJson(json["ClientUser"]),
    slotDiet: json["SlotDiet"]==null?null:SlotDiet.fromJson(json["SlotDiet"]),
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
