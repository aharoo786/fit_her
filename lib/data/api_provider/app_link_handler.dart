import 'package:app_links/app_links.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_journey_screen.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/auth_module/walt_through/walk_through_screenn.dart';
import '../../values/constants.dart';

class AppLinkHandler {
  static final AppLinkHandler _instance = AppLinkHandler._internal();

  factory AppLinkHandler() => _instance;

  AppLinkHandler._internal();

  final AppLinks _appLinks = AppLinks();
  Uri? _initialLinkData;
  bool _initialized = false;

  void init(BuildContext context) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      _initialLinkData = await _appLinks.getInitialLink();
      final uri = _initialLinkData;
      if (uri != null) {
        await _handleIncomingUri(context, uri);
      }
    } catch (e) {
      debugPrint('Error getting initial app link: $e');
    }

    // Handle app in background/foreground
    _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        await _handleIncomingUri(context, uri);
      }
    }, onError: (err) {
      debugPrint('App link error: $err');
    });
  }

  Future<void> _handleIncomingUri(BuildContext context, Uri uri) async {
    print('AppLinkHandler._handleIncomingUri ${uri}');
    print('AppLinkHandler._handleIncomingUri ${uri.toString().split("/").last}');
    final token = uri.queryParameters["token"];
    if (uri.toString().contains("trial") && token != null && token.isNotEmpty) {
      final homeController = Get.find<HomeController>();
      final authController = Get.find<AuthController>();
      final isValid = await homeController.validateTrialToken(token);
      if (!isValid) {
        return;
      }

      final accessToken =
          authController.sharedPreferences.getString(Constants.accessToken) ?? "";
      if (accessToken.isNotEmpty) {
        final started = await homeController.startTrialFromSavedToken();
        if (started) {
          await homeController.getMyTrialJourney();
          Get.offAll(() => const TrialJourneyScreen());
          return;
        }
      }

      Get.offAll(() => const WalkThroughScreen());
      return;
    }

    if (uri.toString().contains('customerSupport')) {
      Get.offAll(() => SignUpNewUser(
            supporterId: uri.toString().split("/").last,
          ));
    } else {
      Get.offAll(() => const WalkThroughScreen());
    }
  }
}
