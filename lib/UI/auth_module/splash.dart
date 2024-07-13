import 'dart:async';
import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../values/constants.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import 'login/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    WidgetsBinding.instance.addObserver(this);
    Timer(const Duration(seconds: 2), () async {

      if(Get.find<AuthController>().sharedPreferences.getBool(Constants.login)==null){

        Get.offAll(() => WalkThroughScreen());
      }
      else{

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 138.h,
                width: 239.w,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(MyImgs.logo), fit: BoxFit.contain)),
              ),
              SizedBox(
                height: 20.h,
              ),
              // Text(
              //   "Farm Sharing".tr,
              //   style: textTheme.headline4
              // )
            ],
          ),
        ));
  }
}
