import 'dart:convert';
import 'dart:io';
import 'package:fitness_zone_2/helper/notification_services.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/values/styles.dart';
import 'package:fitness_zone_2/widgets/zoom_meeting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '/helper/get_di.dart' as di;
import 'UI/auth_module/splash.dart';
import 'data/api_provider/app_link_handler.dart';
import 'data/controllers/auth_controller/auth_controller.dart';
import 'data/controllers/home_controller/home_controller.dart';
import 'data/models/get_clients_diet.dart';
import 'data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'data/models/upcoming_class_slot.dart';
import 'data/services/analytics_service.dart';
import 'firebase_options.dart';
import 'get_food_kcal_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  await di.init();

  // Initialize Analytics
  final analyticsService = Get.find<AnalyticsService>();
  await analyticsService.init();

  // Track app open
  await analyticsService.logAppOpen();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await SentryFlutter.init((options) {
    options.dsn = 'https://a2619a7785d52ef8d6a3e59ef891bcdb@o4510731863916544.ingest.de.sentry.io/4510731866931280';
  },
      // Init your App.
      appRunner: () => runApp(const MyApp()));
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationServices noti = Get.find();
  if (message.data != null) {
    if (message.data["annoucement"] != null) {
      var sharedPreferences = await SharedPreferences.getInstance();
      var announcement = {"title": message.notification?.title, "body": message.notification?.body, "date": DateTime.now().toString()};
      sharedPreferences.setString(Constants.announcementNotification, jsonEncode(announcement));
      ();
      noti.addNotification(message);
    }
    UpcomingClassSlot? upcomingClassSlot;

    if (message.notification?.title == "Upcoming Class" ||
        message.notification?.title == "Class Link Added" ||
        message.notification?.title == "Sweat Now, Selfies Later" ||
        message.notification?.title == "Class Cancelled") {
      upcomingClassSlot = UpcomingClassSlot(
          upcomingSlot: Slot.fromJson(jsonDecode(message.data["upcomingSlot"])), trainer: ClientUser.fromJson(jsonDecode(message.data["trainer"])));
      AuthController authController = Get.find();
      var sharedPreferences = authController.sharedPreferences;
      if (Get.find<HomeController>().upComingClassNotifier.value == null || message.notification?.title == "Upcoming Class") {
        sharedPreferences.setString(Constants.upcomingSlot, jsonEncode(upcomingClassSlot.toJson()));

        Get.find<HomeController>().upComingClassNotifier.value = upcomingClassSlot;
      } else {
        if (Get.find<HomeController>().upComingClassNotifier.value?.upcomingSlot?.id == upcomingClassSlot.upcomingSlot?.id) {
          sharedPreferences.setString(Constants.upcomingSlot, jsonEncode(upcomingClassSlot.toJson()));

          Get.find<HomeController>().upComingClassNotifier.value = upcomingClassSlot;
        }
      }
    }
  }
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
