import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

/// Response from backend for Direct Pay (Payin PWA) payment URL.
/// Backend builds the URL and checksum server-side so client_secret never touches the app.
class DirectPayUrlResponse extends Serializable {
  final String url;
  final String? clientTransactionId;

  DirectPayUrlResponse({
    required this.url,
    this.clientTransactionId,
  });

  factory DirectPayUrlResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DirectPayUrlResponse(url: "");
    return DirectPayUrlResponse(
      url: json["url"] ?? "",
      clientTransactionId: json["client_transaction_id"],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "url": url,
        if (clientTransactionId != null) "client_transaction_id": clientTransactionId,
      };
}
