import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';

import '../../zoom_meeting.dart';

class ZoomMeetingGetxController extends GetxController {
  final ZoomMeetingController zoomController = ZoomMeetingController();

  // State
  var isInitialized = false.obs;
  var status = 'Not initialized'.obs;

  @override
  void onInit() {
    super.onInit();
    const sdkKey = 'hLsFMz5nRKyRXt2SUOONw';
    const sdkSecret = 'R5z8c6RmcnSRdKbvacQwrjIdMDv7lTW6';
    generateZoomJwt(sdkKey: sdkKey, sdkSecret: sdkSecret);
  }

  Future<void> initializeZoom(String jwtToken) async {
    await zoomController.initialize(jwtToken);
    isInitialized.value = true;
    status.value = 'Initialized';
  }

  Future<bool> joinMeeting(String meetingNumber, String name) async {
    status.value = 'Joining meeting...';
    return await zoomController.joinMeeting(
      meetingNumber: meetingNumber,
      displayName: name,
      password: null,
    );
  }

  Future<void> leaveMeeting() async {
    status.value = 'Leaving meeting...';
    await zoomController.leaveMeeting();
    status.value = 'Left meeting';
  }

  void generateZoomJwt({
    required String sdkKey,
    required String sdkSecret,
    int expiryInSeconds = 360000000,
  }) {
    final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = iat + expiryInSeconds;

    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final payload = {
      'appKey': sdkKey,
      'iat': iat,
      'exp': exp,
      'tokenExp': exp,
    };

    String base64UrlEncode(Object value) => base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');

    final headerEncoded = base64UrlEncode(header);
    final payloadEncoded = base64UrlEncode(payload);
    final data = '$headerEncoded.$payloadEncoded';

    final hmac = Hmac(sha256, utf8.encode(sdkSecret));
    final signature = hmac.convert(utf8.encode(data));
    final signatureEncoded = base64Url.encode(signature.bytes).replaceAll('=', '');

    final token = '$data.$signatureEncoded';
    print('Generated Zoom JWT: $token');

    initializeZoom(token);
  }
}
