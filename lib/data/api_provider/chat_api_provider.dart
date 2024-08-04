import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../values/constants.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class ChatApiProvider extends GetConnect implements GetxService {
  SharedPreferences sharedPreferences;

  ChatApiProvider(this.sharedPreferences) {
    httpClient.baseUrl = Constants.chatBaseUrl;
    httpClient.timeout = const Duration(seconds: 40);
  }

  Future<http.Response?> postData({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final String? fcmToken = sharedPreferences.getString(Constants.deviceToken);
    if (fcmToken == null) {
      print('Device token is null');
      return null;
    }
   print("body  ${body[Constants.deviceToken]}");
    var newBody = {
      "message": {
        "token": body[Constants.deviceToken],
        "notification": {
          "title": "A new message arrived",
          "body": body["body"]
        }
      }
    };

    headers ??= {};
    headers['Content-Type'] = 'application/json';

    final accessToken = await getAccessToken();
    headers['Authorization'] = 'Bearer $accessToken';

    final Uri url = Uri.parse(Constants.chatBaseUrl);

    print('===: API Call: [${url.toString()}]\n$body\n$headers');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(newBody),
      );

      print("message response ${response.statusCode}");
      print("message response body ${response.body}");

      if (response.statusCode == 200) {
        return response;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error making post request: $e");
      return null;
    }
  }
}

Future<String> getAccessToken() async {
  final accountCredentials = auth.ServiceAccountCredentials.fromJson({
  "type" : dotenv.get('FIREBASE_TYPE'),
  "project_id" : dotenv.get('FIREBASE_PROJECT_ID'),
  "private_key_id" : dotenv.get('FIREBASE_PRIVATE_KEY_ID'),
  "private_key" : dotenv.get('FIREBASE_PRIVATE_KEY'),
  "client_email" : dotenv.get('FIREBASE_CLIENT_EMAIL'),
  "client_id" : dotenv.get('FIREBASE_CLIENT_ID'),
  "auth_uri" : dotenv.get('FIREBASE_AUTH_URI'),
  "token_uri" : dotenv.get('FIREBASE_TOKEN_URI'),
  "auth_provider_x509_cert_url" : dotenv.get('FIREBASE_AUTH_PROVIDER_X509_CERT_URL'),
  "client_x509_cert_url" : dotenv.get('FIREBASE_CLIENT_X509_CERT_URL'),
  "universe_domain" : dotenv.get('FIREBASE_UNIVERSE_DOMAIN'),
  });

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final authClient =
      await auth.clientViaServiceAccount(accountCredentials, scopes);

  final accessToken = authClient.credentials.accessToken;
  print("accessToken.data  ${accessToken.data}");
  // sharedPreferences.setString(Constants.fcmToken, accessToken.data);
  return accessToken.data;
}
