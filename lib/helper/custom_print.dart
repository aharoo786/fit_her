import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

void customPrint(String data) {
  if (kDebugMode) {
    print(data);
  }

}
bool isValidUrl(String url) {
  const urlPattern =
      r'^(https?:\/\/)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?(\/.*)?$';
  final result = RegExp(urlPattern).hasMatch(url);
  return result;
}

Future<void> handleCameraAndMic(Permission permission) async {
  final status = await permission.request();
  print(status);
}