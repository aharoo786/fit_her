import 'package:app_links/app_links.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/auth_module/welcom_screen.dart';

class AppLinkHandler {
  static final AppLinkHandler _instance = AppLinkHandler._internal();

  factory AppLinkHandler() => _instance;

  AppLinkHandler._internal();

  final AppLinks _appLinks = AppLinks();
  Uri? _initialLinkData;

  void init(BuildContext context) async {
    try {
      _initialLinkData = await _appLinks.getInitialLink();
      final uri = _initialLinkData;
      if (uri != null) {
        _handleIncomingUri(context, uri);
      }
    } catch (e) {
      debugPrint('Error getting initial app link: $e');
    }

    // Handle app in background/foreground
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleIncomingUri(context, uri);
      }
    }, onError: (err) {
      debugPrint('App link error: $err');
    });
  }

  void _handleIncomingUri(BuildContext context, Uri uri) {
    print('AppLinkHandler._handleIncomingUri ${uri}');
    print('AppLinkHandler._handleIncomingUri ${uri.toString().split("/").last}');
    if (uri.toString().contains('customerSupport')) {
      Get.offAll(() => SignUpNewUser(
            supporterId: uri.toString().split("/").last,
          ));
    } else {
      Get.offAll(() => WelcomeScreen());
    }
  }
}
