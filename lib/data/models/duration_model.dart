import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class DurationModel {
  final int id;
  final String duration;

  DurationModel({
    required this.id,
    required this.duration,
  });

  // Factory constructor to create a DurationModel instance from JSON
  factory DurationModel.fromJson(Map<String, dynamic> json) {
    return DurationModel(
      id: json['id'] as int,
      duration: json['duration'] as String,
    );
  }

  // Method to convert a DurationModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration,
    };
  }
}

// If you have a list of durations, you can create a wrapper class to parse it
class DurationList extends Serializable{
  final List<DurationModel> durations;

  DurationList({required this.durations});

  // Factory constructor to create a DurationList instance from JSON
  factory DurationList.fromJson(Map<String, dynamic> json) {
    var durationsJson = json['durations'] as List;
    List<DurationModel> durationList =
    durationsJson.map((duration) => DurationModel.fromJson(duration)).toList();

    return DurationList(durations: durationList);
  }

  // Method to convert a DurationList instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'durations': durations.map((duration) => duration.toJson()).toList(),
    };
  }
}
