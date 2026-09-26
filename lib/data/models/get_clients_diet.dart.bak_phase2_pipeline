// To parse this JSON data, do
//
//     final dietClients = dietClientsFromJson(jsonString);

import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

DietClients dietClientsFromJson(String str) => DietClients.fromJson(json.decode(str));

String dietClientsToJson(DietClients data) => json.encode(data.toJson());

class DietClients extends Serializable {
  List<Cliet> cliets;

  DietClients({
    required this.cliets,
  });

  factory DietClients.fromJson(Map<String, dynamic> json) => DietClients(
        cliets: List<Cliet>.from(json["cliets"].map((x) => Cliet.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cliets": List<dynamic>.from(cliets.map((x) => x.toJson())),
      };
}

class Cliet {
  int id;
  DateTime buyingDate;
  DateTime expireDate;
  ClientUser? user;

  /// Server-computed status so the Clients list can show something
  /// actionable instead of just a purchase date range. One of: FLAGGED,
  /// CONSULTATION_TODAY, PLAN_OVERDUE, AWAITING_PLAN, ON_TRACK, NEW.
  /// Null when talking to an older backend that doesn't send it yet —
  /// callers should treat that the same as "ON_TRACK" (unknown, not
  /// urgent) rather than crash.
  String? status;
  String? statusDetail;
  bool hasConsultationToday;
  DateTime? consultationTodayAt;

  Cliet({
    required this.id,
    required this.buyingDate,
    required this.expireDate,
    required this.user,
    this.status,
    this.statusDetail,
    this.hasConsultationToday = false,
    this.consultationTodayAt,
  });

  factory Cliet.fromJson(Map<String, dynamic> json) => Cliet(
        id: json["id"],
        buyingDate: DateTime.parse(json["buyingDate"] ?? DateTime.now()),
        expireDate: DateTime.parse(json["expireDate"] ?? DateTime.now()),
        user: json["User"] == null ? null : ClientUser.fromJson(json["User"]),
        status: json["status"] as String?,
        statusDetail: json["statusDetail"] as String?,
        hasConsultationToday: json["hasConsultationToday"] == true,
        consultationTodayAt: json["consultationTodayAt"] == null
            ? null
            : DateTime.tryParse(json["consultationTodayAt"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "buyingDate": buyingDate.toIso8601String(),
        "expireDate": expireDate.toIso8601String(),
        "User": user?.toJson(),
        "status": status,
        "statusDetail": statusDetail,
        "hasConsultationToday": hasConsultationToday,
        "consultationTodayAt": consultationTodayAt?.toIso8601String(),
      };
}

class ClientUser {
  int id;
  String firstName;
  String lastName;
  String email;
  String experience;
  String? phone;
  String? bmiResult;
  ClientUser? supporter;

  /// Backend's user-type discriminator. Per CLAUDE.md, expected values
  /// are: 'User', 'Trainer', 'Dietition' (typo preserved by backend),
  /// 'Gynecologist', 'Psychiatrist', 'Admin'. Defensive add — null when
  /// the backend response omits the field, so consumers must null-check.
  /// Powers the TRAINER / DIETITIAN badges on community post cards.
  String? userType;

  ClientUser(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.experience,
      required this.bmiResult,
      required this.supporter,
      this.userType});

  factory ClientUser.fromJson(Map<String, dynamic> json) => ClientUser(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        bmiResult: json["bmiResult"],
        phone: json["phone"],
        email: json["email"],
        experience: json["experience"] ?? "N/A",
        supporter: json["supporter"] == null ? null : ClientUser.fromJson(json["supporter"]),
        userType: json["userType"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "phone": phone,
        "lastName": lastName,
        "email": email,
        "experience": experience,
        "supporter": supporter,
        "userType": userType,
      };

  get fullName => "${this.firstName} ${this.lastName}";
}
