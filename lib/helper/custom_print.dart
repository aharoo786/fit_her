import 'package:flutter/foundation.dart';

void customPrint(String data) {
  if (kDebugMode) {
    print(data);
  }
}
