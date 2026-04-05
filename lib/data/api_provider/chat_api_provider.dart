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

Future<String> getAccessToken() async {
  print("i am here -----------");
  final accountCredentials = auth.ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "fither-e7a36",
    "private_key_id": "2145b07b5e5a1bd463166a989a1c457e5fb6ace5",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDGRKNv4f8AnzAd\nPlsj6EALW26JR1TT5Cmwkix5LPAkGxN4vWd9muDXwNOVVtNoETddFrdkn84BROw9\nRgL2UGTtl6yk24ze2uNBCRoYBNsLitYLN8AKz+j/TzQv4JfuNVSFkQKknA8rQVKT\niwNc6b4jdVBKHbN0YTn4ga3+TE0NHo6BKxZNe+ok2fAst90gZ3+r3D32xNP0wyhC\nzlOLyttk6JdIRgy1kE2wVrsNuy1xS2rqG2EZ66TZl/o1agkK4Lv9rk6Q4wXzH13t\nLx0k1UjEZkpqBW4tZX6lo08PVW2LbbdAm2E6ZQ4l/Z0szWnEiwHzs7/VtWLMi6VV\n1DT6nsGjAgMBAAECggEAEDu+qmKPHe5qvC8Gu4YAqs1ijtCtbduHD4MQXoWJTfN9\n+lgYeQZgaKayZc5VNdz+/8F95FO/RFRWOvgYaWSqUHFaoqh4b42HDaQ6PWnPkEtF\nFjSk2SqUi0VHyRaMnTJ2bqjLIufFYcdet8Z26oZK2dCS19arT39fnzmC7pWYID3R\nnXY6/wPnVcu5XOm6jTl4/GT0CKWiJYPEwXzGab31LBSalgNFKhHyEppxzJ7x6fCz\npRGOEyMfG49jn5Q/KOu6ynuP59FqVEhrIdCRLofyTB7Oxm7/wrIPViNKKodJbkuw\n54SW5bQ7g2x5oCnbj4cTK+85cACa9Ymc3F31euIQAQKBgQDrVwvasVzVGdVWvGpC\nZF5y2czAo8+dOroxTo7POgBFWKlAmxqzdaEIWgJwfBlRKaCUGkKXb2PLb6Lk/1HC\nscIsLHTZ/vI3kuCK74CpjEgnmyEz4m6XJ/zZk52GBLnfYEezAtQwY1HKkC9cfwo5\nxNrfwKjvw09OWSY1CDfk3ZDxowKBgQDXrHNNZLoUnRqYVH+5XZ+dB/lmKo9KDRrK\nP5aTXbIxJtYr0aZEMHA66lIdmueb4PMm4MYczbwtxLuZdhaAwS/Ttf6bdVfTdje+\nVhXujQEi+JBYCVWOPx74tp799Eqw6mWxfrW7w2r4hvbMQ1IGsEQEJuo1wvsYUppG\nsBcEdbfwAQKBgQCdQFHEdITyQ8vApC9gY46UsaHWCt88UTR+o95a64eozqBxcfJ6\nfZv3Z6V/ofyMtgL9Uzqx05VcJyEyYMQyEvMK7z25OFiC99qgG37eS8Ue6dJax+9b\ngzW58J/uIBRPBReDrt034/WQI53x8VVU2ovhvOtlIh1I3drgzrgCbmZefwKBgD00\n9LgHGQQWneCTQngxyMWA6NeExouGco7pQutpkNOAKRHgeqYpdQBTVaCPQKGtUnQ7\nIB42iOwYRAFGURaTPOaBZNNrltQtXZ6HwcukeqkZD6XcaEppQXnmIfMCbFwO+XNI\n+Xxi9i2357yKcnHxfiwLezZssmPxtVTQTof2fJABAoGBAJVHn1KNxmxoC38UA6Sk\n15umIQMoFbz97v/5bZ4MZZHciq7TZAOUq36D+d0mxCQxGZ+DQIfDR3PmsycVCwTA\n6CIUjaaNW3bSWN4w6LI0C7IlFKA9dYfWnK6fIMjkjdQvff7X5xU9cfIwe26wZ4Qm\nuXihzfiU3zOgREl4V91K87ge\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-d0hnv@fither-e7a36.iam.gserviceaccount.com",
    "client_id": "105802922805064479433",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-d0hnv%40fither-e7a36.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
  );

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final authClient =
      await auth.clientViaServiceAccount(accountCredentials, scopes);

  final accessToken = authClient.credentials.accessToken;
  print("accessToken.data  ${accessToken.data}");
  // sharedPreferences.setString(Constants.fcmToken, accessToken.data);
  return accessToken.data;
}
