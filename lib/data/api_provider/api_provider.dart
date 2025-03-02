import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../values/constants.dart';

class ApiProvider {
  final String baseUrl = Constants.baseUrl;

  Future<Response> postData(String url,
      {required Map<String, dynamic> body,
      Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$body  \n $headers');

    var response = await http.post(Uri.parse(baseUrl + url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),);
    return handleData(url, response);
  }

  Future<Response> putData(String url,
      {required Map<String, dynamic> body,
      Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$body  \n $headers');

    var response = await http.put(Uri.parse(baseUrl + url),
        body: jsonEncode(body), headers: headers ?? {});
    return handleData(url, response);
  }

  Future<Response<dynamic>> getData(String url,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$query  \n $headers');
    var uri = Uri.parse(baseUrl + url).replace(queryParameters: query);
    var response = await http.get(uri, headers: headers ?? {});
    return handleData(url, response);
  }

  Future<Response<dynamic>> handleData(
      String url, http.Response response) async {
    debugPrint(
        '====> API Response: [${response.statusCode}] $baseUrl$url\n${response.body}');

    dynamic _body;
    try {
      _body = jsonDecode(response.body);
    } catch (e) {
      _body = {};
    }

    return Response(
      body: _body,
      bodyString: response.body,
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
  }

  Future<Response> setFormData({
    required String url,
    required Map<String, dynamic> formData,
    bool isProgress = false,
    Map<String, String>? headers,
  }) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$formData  \n $headers');
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl + url));
    headers?.forEach((key, value) => request.headers[key] = value);

    formData.forEach((key, value) {
      if (key != "image" && key != "before" && key != "after") {
        request.fields[key] = value.toString();
      }
    });

    if (isProgress) {
      request.files
          .add(await http.MultipartFile.fromPath('after', formData["after"]));
      request.files
          .add(await http.MultipartFile.fromPath('before', formData["before"]));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('image', formData["image"]));
    }

    var response = await http.Response.fromStream(await request.send());
    debugPrint(
        '====> API Response: [${response.statusCode}] $baseUrl$url\n${response.body}');
    return Response(statusCode: response.statusCode, bodyString: response.body);
  }
}
