import 'dart:convert';

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
    // final String? fcmToken = sharedPreferences.getString(Constants.deviceToken);
    // if (fcmToken == null) {
    //   print('Device token is null');
    //   return null;
    // }
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
    print("accessttoke  $accessToken");

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


