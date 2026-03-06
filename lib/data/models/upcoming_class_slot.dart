import 'package:fitness_zone_2/data/models/get_clients_diet.dart';
import 'get_user_plan/get_workout_user_plan_details.dart';

class UpcomingClassSlot {
  Slot? upcomingSlot;
  ClientUser? trainer;

  UpcomingClassSlot({
    required this.upcomingSlot,
    required this.trainer,
  });

  factory UpcomingClassSlot.fromJson(Map<String, dynamic> json) =>
      UpcomingClassSlot(
        upcomingSlot: json["upcomingSlot"] != null
            ? Slot.fromJson(json["upcomingSlot"])
            : null,
        trainer: json["trainer"] != null
            ? ClientUser.fromJson(json["trainer"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "upcomingSlot": upcomingSlot?.toJson(),
    "trainer": trainer?.toJson(),
  };
}
