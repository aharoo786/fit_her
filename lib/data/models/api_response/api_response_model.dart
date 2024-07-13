abstract class Serializable {
  Map<String, dynamic> toJson();
}

class ApiResponse<T extends Serializable> {
  String status;
  String message;

  T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, Function(Map<String, dynamic>) create) {
    return ApiResponse<T>(
      status: json["status"],
      message: json["message"],
      data: create(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}
