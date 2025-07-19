import 'dart:io';
import 'package:fitness_zone_2/helper/notification_services.dart';
import 'package:fitness_zone_2/values/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '/helper/get_di.dart' as di;
import 'UI/auth_module/splash.dart';
import 'data/api_provider/app_link_handler.dart';
import 'firebase_options.dart';
import 'get_food_kcal_details.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

String selectedPlan = "";
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  await di.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationServices noti = Get.find();
  noti.addNotification(message);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
