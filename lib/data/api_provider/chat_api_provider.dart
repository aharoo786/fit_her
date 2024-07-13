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

    print('====> API Call: [${url.toString()}]\n$body\n$headers');

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
    "type": "service_account",
    "project_id": "fither-e7a36",
    "private_key_id": "b4eec18c6270a00ea7f9b58040f148a21ddad0c0",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDntR5krZmdG77j\nEJ514+hLbDot4FoTQII10lJhaR3nrbNtjGO8MdV7JSpPSJSXZaS1wF+NPH9EKsX8\nFZvLOlI0VaZhLcnlAp93dM86cGyTU0lzPWJTXtAle/9qNdfJ7SVPTTLrR+Xj+cA4\nEeC/b9BouO76jfL6bosH7kAAbTB/KvvQkaUtg3B2VsH/P4jWzN/B2YlNRn5jou1X\nmKDFUylhMXERb0TxAaXphtIjlui9PGr6R4lXbr4EmYvPGicV8CrO5QH3DUPAKoHf\nMyI0DFpC7mFTozxQFHsiaS9U53jA2DFeryTyCR1r8hPWDqf5V5ykELf2idaGWzcI\n4EMnQa4nAgMBAAECggEACgA1REnXPC1luyM307Ah50TP6179maB1KPbfpg4FbmnU\nOWw6ecr6LeCCx6ftp0M0gsEU3rcNFIIhctSemXz2Q1qsXbwTihY85R5eO2V9f4u0\nEIybtoF8dmxjBSXhyc4PMtxgJZZALpYpsmyDHirTUfx5bshlrmLLDsKScfJEikMu\n+uLE2jdorbBeEbN1g1/AxALyTlsGG02EgbYr52Wn4BIJAj7EQI12XkRgNvL+23xN\n2xNvNtM+RI75jA6ISlDRRhPEwrQJtcn9zfHtIbhLst3AyCiGcgy00PN4hm8FjBFa\nMP62TL0XfXPugkZnmE3B8zhtV0w4HG7XvGQ1vP6GsQKBgQD8cWyAmkyFX4jLR1Lh\nej/GTcYx7ZsM4/f76mDZcYwKHYhr9AC2xiAWIZN6w0Hze+QrgF8ycZA/nKz19uCR\nols33fI+piWOzYJFHhqi0ZjOa3+fcs2bbY4x4MgX49Cv1FXftZry73IQAug0lxkl\nzlAau1ag955DiAoUtF4DY1YRowKBgQDq+OaKB3SuLCDyIHd+nt1z2yc5FqpBUnNk\nX6Q8HSeK3aR1IY4Qu6ZZr3KalwGX0EsIsCcAO91t89k1ViLd1jBog0lEcynL1JPC\npIV8OAcOiryPgb/ac9OtcWNqpuNhpynYS8exyc9S7Ui+hp1AKH5YAjbfFyd6zO/r\nbz3wQYNhrQKBgEvAdYC5zJCRNGlbg8Fpf82v9PNyi354wid0E4/shMtcRV2voK84\nENTTSoAiK5425ScwpGBst45/I1/Dr2vEPn8rONAX51lMzfSTrgaBwsreczOTraMg\nYvUQsLqKgEri+sngoxiXRbEMTkXJuaAgouUCpmIzK+iz3+KKpVN68Y7lAoGAF4Fm\nrpAoX/QSJ6aPzZ7e0GQv/EoEJhy1Zmka6NiRyBZ8CSueJpZfAcHHWSeaBTHVD71v\naVqTwBgQtoEzY7W1if74KVzL5ZQSY/pJUC/apN3EFycHpjbICiW5qEWhoXczfGu4\nQlTJ5KXQDR8yQ+TJHsy56H9Md8Bgj9DFBW/IUNECgYA6eAf1o8EJ8bgYr6YrIga/\nY0S9PuZQRdjEnLS2M6V5vd+baGqLyNgN+NLridN/BfoLQomqDiDGFPRUaHcL35oe\nbzFI2FOBH29QRWNkykADLZY3Jk1axDxOZJFrbCTqjaez2vgzl7HkoHXLcVJo5oUR\n3kxWSJbmRYPBhPNaz4eZZw==\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-d0hnv@fither-e7a36.iam.gserviceaccount.com",
    "client_id": "105802922805064479433",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-d0hnv%40fither-e7a36.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  });

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final authClient =
      await auth.clientViaServiceAccount(accountCredentials, scopes);

  final accessToken = authClient.credentials.accessToken;
  print("accessToken.data  ${accessToken.data}");
  // sharedPreferences.setString(Constants.fcmToken, accessToken.data);
  return accessToken.data;
}