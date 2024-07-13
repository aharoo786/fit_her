import 'dart:convert';

import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

PaymentLink paymentLinkFromJson(String str) => PaymentLink.fromJson(json.decode(str));

String paymentLinkToJson(PaymentLink data) => json.encode(data.toJson());

class PaymentLink  extends Serializable{
  final Session session;

  PaymentLink({
    required this.session,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) => PaymentLink(
    session: Session.fromJson(json["session"]),
  );

  Map<String, dynamic> toJson() => {
    "session": session.toJson(),
  };
}

class Session {
  final String successUrl;
  final String cancelUrl;
  final String url;

  Session({
    required this.successUrl,
    required this.cancelUrl,
    required this.url,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    successUrl: json["success_url"],
    cancelUrl: json["cancel_url"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "success_url": successUrl,
    "cancel_url": cancelUrl,
    "url": url,
  };
}
