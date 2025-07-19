import 'dart:async';
import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:fitness_zone_2/UI/auth_module/welcom_screen.dart';
import 'package:fitness_zone_2/helper/notification_services.dart';
import 'package:fitness_zone_2/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/api_provider/app_link_handler.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../values/constants.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  AuthController authController = Get.find();
  @override
  void initState() {
    super.initState();
    NotificationServices().requestNotificationPermission();
    NotificationServices().firebaseInit(Get.context!);
    WidgetsFlutterBinding.ensureInitialized();

    WidgetsBinding.instance.addObserver(this);
    Timer(const Duration(seconds: 2), () async {
      var share = authController.sharedPreferences;

      if (share.getString(Constants.email) == null ||
          share.getString(Constants.password) == null ||
          share.getString(Constants.loginAsa) == null) {
        Get.offAll(() => WelcomeScreen());
        Future.delayed((Duration(seconds: 1)), () {
          AppLinkHandler().init(Get.context!);
        });
      } else {
        Get.find<AuthController>().login(
            userType: share.getString(Constants.loginAsa),
            email: share.getString(Constants.email),
            password: share.getString(Constants.password));
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.log("in app resume");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness:
          Brightness.dark, // this will change the brightness of the icons
      statusBarColor: MyColors.buttonColor, // or any color you want
    ));
    final mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    final isLandScape = mediaQuery.orientation == Orientation.landscape;
    var height;
    setState(() {
      if (isLandScape) {
        height = mediaQuery.size.width;
      } else {
        height = mediaQuery.size.height;
      }
    });
    return Scaffold(
        backgroundColor: MyColors.primaryColor,
        body: Container(
          height: height * 1,
          width: MediaQuery.of(context).size.width * 1,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: MyColors.mainGradient)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container(
              //   height: 138.h,
              //   width: 239.w,
              //   decoration: const BoxDecoration(
              //       image: DecorationImage(
              //           image: AssetImage(MyImgs.logo), fit: BoxFit.contain)),
              // ),
              Image.asset(MyImgs.logo),
              // SizedBox(
              //   height: 20.h,
              // ),
              // Text(
              //   "Farm Sharing".tr,
              //   style: textTheme.headline4
              // )
            ],
          ),
        ));
  }
}
