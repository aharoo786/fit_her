import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../values/constants.dart';

// MultipartFile.fromPath defaults to application/octet-stream when no
// contentType is supplied — which the backend's image fileFilter (multer)
// rejects with "Only image files (jpg, png, webp, gif) are allowed". Map
// the extension to a real image MIME so multipart parts arrive correctly
// labelled.
MediaType _mediaTypeForPath(String filePath) {
  final lower = filePath.toLowerCase();
  final dot = lower.lastIndexOf('.');
  final ext = dot >= 0 ? lower.substring(dot + 1) : '';
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'webp':
      return MediaType('image', 'webp');
    case 'gif':
      return MediaType('image', 'gif');
    case 'heic':
      return MediaType('image', 'heic');
    case 'heif':
      return MediaType('image', 'heif');
    default:
      return MediaType('application', 'octet-stream');
  }
}

class ApiProvider extends GetxService {
  final String baseUrl = Constants.baseUrl;

  Future<Response> postData(String url, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$body  \n $headers');

    final defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    var response = await http.post(
      Uri.parse(baseUrl + url),
      headers: defaultHeaders,
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

  Future<Response> patchData(String url, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    debugPrint('====> API Call: [$baseUrl$url]\n$body  \n $headers');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    var response = await http.patch(Uri.parse(baseUrl + url), body: jsonEncode(body), headers: defaultHeaders);
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
          final beforePath = formData['before'] as String;
          final afterPath = formData['after'] as String;
          request.files.add(await http.MultipartFile.fromPath(
            'before',
            beforePath,
            contentType: _mediaTypeForPath(beforePath),
          ));
          request.files.add(await http.MultipartFile.fromPath(
            'after',
            afterPath,
            contentType: _mediaTypeForPath(afterPath),
          ));
        } else {
          throw Exception("Missing 'before' or 'after' file for progress upload.");
        }
      } else {
        if (formData['image'] != null) {
          final imagePath = formData['image'] as String;
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: _mediaTypeForPath(imagePath),
          ));
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
