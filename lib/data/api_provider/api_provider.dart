import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import '../../values/constants.dart';
import 'package:http/http.dart' as http;

class ApiProvider extends GetConnect implements GetxService {
  ApiProvider() {
    httpClient.baseUrl = Constants.baseUrl;
    httpClient.timeout = const Duration(seconds: 40);
  }

  Future<Response> postData(String url,
      {required Map<String, dynamic> body,
      Map<String, String>? headers}) async {
    debugPrint(
        '====> API Call: [${Constants.baseUrl + url}]\n$body  \n $headers');

    var response = await post(url, body, headers: headers ?? {});
    print("body  ${response.body}");
    return handleData(url, response);
  }

  Future<Response> putData(String url,
      {required Map<String, dynamic> body,
      Map<String, String>? headers}) async {
    Get.log("in api client");
    debugPrint(
        '====> API Call: [${Constants.baseUrl + url}]\n$body  \n $headers');

    var response = await put(url, body, headers: headers ?? {});
    print(response.statusCode);
    return handleData(url, response);
  }

  Future<Response> postFormData(String url,
      {required FormData body, Map<String, String>? headers}) async {
    Get.log("form data ${body.fields} ");
    debugPrint(
        '====> API Call: [${Constants.baseUrl + url}]\n$body  \n $headers');
    dynamic _body;
    Response _response;
    ReceivePort p = ReceivePort();
    try {
      Get.log("isolates start");
      _body = await Isolate.spawn(
          _sendDataInBackGround, [p.sendPort, body, post, url, headers]);
    } catch (e) {}
    var resp = await p.first;
    // p.listen((data) {
    //   print("Printed data" + data.toString());
    //   _response = data;
    // });
    _response = Response(
        body: resp[0],
        bodyString: resp[0].toString(),
        statusCode: resp[1],
        request: resp[2],
        headers: resp[3],
        statusText: resp[4]);
    Get.log("Response: outside Isolate: ${_response.toString()}");
    // return _response;
    return handleData(url, _response);
  }

  Future<Response> putFormData(String url,
      {required FormData body, Map<String, String>? headers}) async {
    debugPrint(
        '====> API Call: [${Constants.baseUrl + url}]\n$body  \n $headers');
    dynamic _body;
    Response _response;
    Response response = await put(url, body, headers: headers ?? {});
    // ReceivePort p = ReceivePort();
    // try {
    //   _body = await Isolate.spawn(
    //       _putDataInBackGround, [p.sendPort, body, put, url, headers]);
    // } catch (e) {}
    // var resp = [
    //   response.body,
    //   response.statusCode,
    //   response.request,
    //   response.headers,
    //   response.statusText
    // ];
    // p.listen((data) {
    //   print("Printed data" + data.toString());
    //   _response = data;
    // });
    _response = Response(
        body: response.body,
        statusCode: response.statusCode,
        request: response.request,
        headers: response.headers,
        statusText: response.statusText);
    debugPrint("Response: outside Isolate: ${_response.toString()}");
    // return _response;
    return handleData(url, _response);
  }

  Future<Response<dynamic>> getData(String url,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    debugPrint(
        '====> API Call: [${Constants.baseUrl + url}]\n$query  \n $headers');
    var response = await get(url, query: query, headers: headers ?? {});
    return handleData(url, response);
  }

  Future<Response<dynamic>> handleData(url, response) async {
    dynamic _body;
    Response _response;

    debugPrint(
        '====> API Response: [${response.statusCode}] ${Constants.baseUrl + url}\n${response.body}');

    try {
      final p = ReceivePort();
      _body = await Isolate.spawn(
          _decodeDataInBackground, [p.sendPort, response.body, jsonDecode]);
    } catch (e) {}
    if (response.statusCode != 200) {
      _response = Response(
        body: {
          "status": "0",
          "message": "Some Error has occured\n",
          "data": {},
          "error": "Please try again later"
        },
        bodyString: "{}",
        request: Request(
            headers: response.request!.headers,
            method: response.request!.method,
            url: response.request!.url),
        headers: response.headers,
        statusCode: response.statusCode,
        statusText: response.statusText,
      );
    } else {
      _response = Response(
        body: response.body,
        bodyString: response.body.toString(),
        request: Request(
            headers: response.request!.headers,
            method: response.request!.method,
            url: response.request!.url),
        headers: response.headers,
        statusCode: response.statusCode,
        statusText: response.statusText,
      );
    }

    debugPrint(
        '====>After Decoding API Response: [${_response.statusCode}] ${Constants.baseUrl + url}\n====>After Decoding _Body ${_response.body}');
    return _response;
  }

  _decodeDataInBackground(List<dynamic> args) {
    SendPort responsePort = args[0];
    dynamic data = args[1];
    dynamic jsonDecodeMethod = args[2];

    try {
      final decodedData = jsonDecodeMethod(data);
      Isolate.exit(responsePort, decodedData);
    } catch (e) {
      debugPrint(e.toString());
      Isolate.exit(responsePort, null);
    }
  }

  _sendDataInBackGround(List<dynamic> args) async {
    SendPort responsePort = args[0];
    FormData data = args[1];
    dynamic func = args[2];
    dynamic url = args[3];
    dynamic headers = args[4];
    try {
      Get.log("isolates ");
      print(data.fields);
      Response response = await post(url, data, headers: headers ?? {});
      print("Response in Isolate: ${response.body}");
      // responsePort.send(response.body);
      Isolate.exit(responsePort, [
        response.body,
        response.statusCode,
        response.request,
        response.headers,
        response.statusText
      ]);
    } catch (e) {
      Get.log("isolates erroer ");
      debugPrint(e.toString());
      Isolate.exit(responsePort, null);
    }
  }

  _putDataInBackGround(List<dynamic> args) async {
    SendPort responsePort = args[0];
    FormData data = args[1];
    dynamic func = args[2];
    dynamic url = args[3];
    dynamic headers = args[4];
    try {
      print(data.fields);
      Response response = await put(url, data, headers: headers ?? {});
      print("Response in Isolate: ${response.body}");
      // responsePort.send(response.body);
      Isolate.exit(responsePort, [
        response.body,
        response.statusCode,
        response.request,
        response.headers,
        response.statusText
      ]);
    } catch (e) {
      debugPrint(e.toString());
      Isolate.exit(responsePort, null);
    }
  }

  Future<Response> setFormData(
      {required String url,
      required Map<String, dynamic> formData,
      bool isProgress = false,
      Map<String, String>? headers}) async {
    debugPrint(
        '====> API Call: [${Constants.baseUrl + url}]\n$query  \n $headers');
    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse("${Constants.baseUrl}$url"),
    );

    formData.forEach((key, value) {
      request.fields.addIf(
          key != "image" && key != "before" && key != "after", key, value);
    });
    if (isProgress) {
      request.files.add(await http.MultipartFile.fromPath(
        'after',
        formData["after"],
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'before',
        formData["before"],
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        formData["image"],
      ));
    }

    var response = await http.Response.fromStream(await request.send());
    debugPrint(
        '====> API Response: [${response.statusCode}] ${Constants.baseUrl + url}\n${response.body}');
    return Response(statusCode: response.statusCode, bodyString: response.body);
  }
}
