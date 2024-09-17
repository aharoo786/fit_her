import 'dart:io';

import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/BMI_result.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen_questions.dart';
import 'package:fitness_zone_2/UI/freee_test_module/free_test.dart';
import 'package:fitness_zone_2/UI/freee_test_module/my_journey_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitness_zone_2/values/styles.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import '/helper/get_di.dart' as di;
import 'UI/auth_module/splash.dart';
import 'UI/dashboard_module/profile_screen/profile_screen_user.dart';
import 'UI/diet_screen/diet_plan_food_details.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.get("STRIPE_PUBLIC_KEY_TEST");
  // Stripe.merchantIdentifier = "merchant.abtechnologies.applepay";
  await Stripe.instance.applySettings();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCrH8hJ_VE_VYRj4Kx3anZ4hl_0ypfxzvU",
            appId: "1:591042819842:android:617bd82a60657e9b77f41b",
            messagingSenderId: "591042819842",
            projectId: "fither-e7a36"));
  }

  await di.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // @override;
  MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // return GetBuilder<LocalizationController>(builder: (localizeController) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (context, Widget) => GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,

        theme: Styles.appTheme,
        getPages: [
          GetPage<void>(page: () => SplashScreen(), name: '/'),
        ],
        // home: BuySubscriptions(),
      ),
    );
    // });
  }
}
