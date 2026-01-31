import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../values/constants.dart';

class ApiProvider extends GetxService {
  final String baseUrl = Constants.baseUrl;

  Future<Response> postData(String url, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$body  \n $headers');

    var response = await http.post(
      Uri.parse(baseUrl + url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return handleData(url, response);
  }

  Future<Response> putData(String url, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$body  \n $headers');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    var response = await http.put(Uri.parse(baseUrl + url), body: jsonEncode(body), headers: defaultHeaders ?? {});
    return handleData(url, response);
  }

  Future<Response<dynamic>> getData(String url, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$query  \n $headers');
    var uri = Uri.parse(baseUrl + url).replace(queryParameters: query);
    var response = await http.get(uri, headers: headers ?? {});
    return handleData(url, response);
  }

  Future<Response<dynamic>> deleteData(String url, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$query  \n $headers');
    var uri = Uri.parse(baseUrl + url).replace(queryParameters: query);
    var response = await http.delete(uri, headers: headers ?? {});
    return handleData(url, response);
  }

  Future<Response<dynamic>> handleData(String url, http.Response response) async {
    debugPrint('====> API Response: [${response.statusCode}] $baseUrl$url\n${response.body}');

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
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final fullUrl = Uri.parse('$baseUrl$url');
    debugPrint('====> API Call: [$fullUrl]\n$formData\n$headers');

    final request = http.MultipartRequest('POST', fullUrl);

    // Add headers if available
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add non-file fields
    formData.forEach((key, value) {
      if (!['image', 'before', 'after'].contains(key)) {
        request.fields[key] = value.toString();
      }
    });

    try {
      // Add files based on the isProgress flag
      if (isProgress) {
        if (formData['before'] != null && formData['after'] != null) {
          request.files.add(await http.MultipartFile.fromPath('before', formData['before']));
          request.files.add(await http.MultipartFile.fromPath('after', formData['after']));
        } else {
          throw Exception("Missing 'before' or 'after' file for progress upload.");
        }
      } else {
        if (formData['image'] != null) {
          request.files.add(await http.MultipartFile.fromPath('image', formData['image']));
        } else {
          throw Exception("Missing 'image' file for upload.");
        }
      }

      // Send request with timeout
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('====> API Response: [${response.statusCode}] $fullUrl\n${response.body}');

      return Response(
        statusCode: response.statusCode,
        bodyString: response.body,
      );
    } on TimeoutException {
      debugPrint('====> API Timeout: Request to $fullUrl timed out.');
      return Response(
        statusCode: 408,
        bodyString: 'Request timed out. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('====> API ERROR: $e\n$stack');
      return Response(
        statusCode: 500,
        bodyString: 'Error: ${e.toString()}',
      );
    }
  }
}
