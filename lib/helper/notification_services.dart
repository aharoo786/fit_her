import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_zone_2/data/models/get_clients_diet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/controllers/auth_controller/auth_controller.dart';
import '../data/controllers/home_controller/home_controller.dart';
import '../data/controllers/workout_controller/work_out_controller.dart';
import '../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../data/models/upcoming_class_slot.dart';
import '../firebase_options.dart';
import '../main.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/constants.dart';

// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
// import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart';
// import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
// import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
// import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
// import 'package:fitness_zone_2/data/models/upcoming_class_slot.dart';
// import 'package:fitness_zone_2/main.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../data/controllers/home_controller/home_controller.dart';
// import '../data/models/get_clients_diet.dart';
// import '../firebase_options.dart';
// import '../values/constants.dart';
// import 'package:get/get.dart';
//

//
// class NotificationServices {
//   //initialising firebase message plugin
//   NotificationServices({required this.sharedPreferences});
//   SharedPreferences sharedPreferences;
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   //initialising firebase message plugin
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   //function to initialise flutter local notification plugin to show notifications for android when app is active
//   void initLocalNotifications(RemoteMessage message) async {
//     var androidInitializationSettings =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iosInitializationSettings = const DarwinInitializationSettings();
//
//     var initializationSetting = InitializationSettings(
//         android: androidInitializationSettings, iOS: iosInitializationSettings);
//
//     await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
//         onDidReceiveNotificationResponse: (payload) {
//       print("onDidReceiveNotificationResponse");
//       // handle interaction when app is active for android
//       handleMessage(message);
//     });
//   }
//
//   Future<void> firebaseInit() async {
//     FirebaseMessaging.onMessage.listen((message) {
//       print('----------- valuee    ');
//
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification!.android;
//
//       //if (kDebugMode) {
//       print("notifications title:${notification!.title}");
//       print("notifications body:${notification.body}");
//       print('data:${message.data.toString()}');
//       //}
//       if (kIsWeb) {
//         initLocalNotifications(message);
//         showNotification(message);
//       } else if (Platform.isIOS) {
//         forgroundMessage();
//         //initLocalNotifications( message);
//         showNotification(message);
//       } else if (Platform.isAndroid) {
//         initLocalNotifications(message);
//         showNotification(message);
//       }
//     });
//     await FirebaseMessaging.instance.setAutoInitEnabled(true);
//   }
//
//   void requestNotificationPermission() async {
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: true,
//       criticalAlert: true,
//       provisional: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       if (kDebugMode) {
//         print('user granted permission');
//       }
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       if (kDebugMode) {
//         print('user granted provisional permission');
//       }
//     } else {
//       //appsetting.AppSettings.openNotificationSettings();
//       if (kDebugMode) {
//         print('user denied permission');
//       }
//     }
//   }
//
//   // function to show visible notification when app is active
//   Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationDetails? androidNotificationDetails;
//     DarwinNotificationDetails? darwinNotificationDetails;
//
//     if (!kIsWeb) {
//       if (Platform.isAndroid) {
//         AndroidNotificationChannel channel = AndroidNotificationChannel(
//           message.messageId!,
//           message.messageId!,
//           importance: Importance.max,
//           showBadge: true,
//           playSound: true,
//         );
//         androidNotificationDetails = AndroidNotificationDetails(
//             channel.id, channel.name.toString(),
//             channelDescription: 'your channel description',
//             importance: Importance.high,
//             priority: Priority.high,
//             playSound: true,
//             ticker: 'ticker',
//             sound: channel.sound
//             //c
//             //  icon: largeIconPath
//             );
//       } else {
//         darwinNotificationDetails = const DarwinNotificationDetails(
//             presentAlert: true, presentBadge: true, presentSound: null);
//       }
//       NotificationDetails notificationDetails = NotificationDetails(
//           android: androidNotificationDetails, iOS: darwinNotificationDetails);
//
//       if (message.notification?.title == "Upcoming Class" ||
//           message.notification?.title == "Class Link Added") {
//         UpcomingClassSlot upcomingClassSlot = UpcomingClassSlot(
//             upcomingSlot:
//                 Slot.fromJson(jsonDecode(message.data["upcomingSlot"])),
//             trainer: ClientUser.fromJson(jsonDecode(message.data["trainer"])));
//         sharedPreferences.setString(
//             Constants.upcomingSlot, jsonEncode(upcomingClassSlot.toJson()));
//         Get.find<HomeController>().upComingClassNotifier.value =
//             upcomingClassSlot;
//       }
//       if (message.notification?.title != "Upcoming Class") {
//         if (message.data["status"] != "Confirmed") {
//           _flutterLocalNotificationsPlugin.show(
//             message.messageId!.hashCode,
//             message.notification!.title.toString(),
//             message.notification!.body.toString(),
//             notificationDetails,
//           );
//         }
//       }
//
//       if (message.notification?.title == "Trainer has Joined") {
//         if (selectedPlan != "") {
//           Get.find<WorkOutController>().getDietPlanDetailsFunc(selectedPlan);
//         }
//       } else if (message.notification?.title == "Congratulations!") {
//         Get.find<HomeController>().getUserHomeFunc(isFromFree: true);
//       }
//       if (message.notification?.title != "Upcoming Class") {
//         addNotification(message);
//       }
//     } else {
//       Get.snackbar(
//         message.notification?.title ?? '',
//         message.notification?.body ?? '',
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 5),
//       );
//     }
//   }
//
//   Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     addNotification(message);
//   }
//
//   addNotification(RemoteMessage message) {
//     AuthController authController = Get.find();
//
//     if (message.notification?.title == "A new message arrived") {
//       sharedPreferences.setBool("showDot", true);
//       Get.find<AuthController>().showDot.value = true;
//     } else {
//       sharedPreferences.setBool("showDotHome", true);
//       Get.find<HomeController>().showDotHome.value = true;
//     }
//
//     var list = sharedPreferences.getString(Constants.notificationList);
//     List<NotificationMessage> notificationMessages = [];
//
//     if (list != null) {
//       var list2 = jsonDecode(list);
//       notificationMessages = List<NotificationMessage>.from(
//         list2.map((item) => NotificationMessage.fromJson(item)),
//       );
//     }
//
//     var newMessage = NotificationMessage.fromRemoteMessage(message);
//
//     bool alreadyExists =
//         notificationMessages.any((msg) => msg.id == newMessage.id);
//
//     if (!alreadyExists) {
//       notificationMessages.add(newMessage);
//       authController.sharedPrefNotifier.value = notificationMessages;
//       print('NotificationServices.addNotification $notificationMessages');
//       sharedPreferences.setString(
//         Constants.notificationList,
//         jsonEncode(notificationMessages.map((msg) => msg.toJson()).toList()),
//       );
//     }
//   }
//
//   static String? deviceToken;
//   Future<String?> getDeviceToken() async {
//     FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//     if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
//       await _firebaseMessaging.deleteToken();
//     }
//     if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
//       deviceToken = await _firebaseMessaging.getToken(
//         vapidKey: vapidKey,
//       );
//     } else {
//       deviceToken = await _firebaseMessaging.getToken();
//     }
//     sharedPreferences.setString(Constants.deviceToken, deviceToken!);
//     print("device toke $deviceToken");
//
//     // await FirebaseMessaging.instance.getToken().then((token) {
//     //   if (token != null) {
//     //     deviceToken = token;
//     //     print("device Token: $token");
//     //     sharedPreferences.setString(Constants.deviceToken, deviceToken!);
//     //   }
//     // }).catchError((onError) {
//     //   print("the error is $onError");
//     // });
//     return deviceToken;
//   }
//
//   Future<String?> getApns() async {
//     await FirebaseMessaging.instance.getAPNSToken().then((token) {
//       if (token != null) {
//         deviceToken = token;
//         print("device Token: $token");
//         sharedPreferences.setString(Constants.deviceToken, deviceToken!);
//       }
//     }).catchError((onError) {
//       print("the error is $onError");
//     });
//     return deviceToken;
//   }
//   //function to get device token on which we will send the notifications
//   // Future<String> getDeviceToken() async {
//   //   String? token = await messaging.getToken();
//   //   return token!;
//   // }
//
//   void isTokenRefresh() async {
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//       sharedPreferences.setString(Constants.deviceToken, event.toString());
//
//       if (kDebugMode) {
//         print('refresh  ${event.toString()}');
//       }
//     });
//   }
//
//   //handle tap on notification when app is in background or terminated
//   Future<void> setupInteractMessage() async {
//     // print(" i am intracting with message");
//
//     // when app is terminated
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//
//     if (initialMessage != null) {
//       print("initialMessage");
//       handleMessage(initialMessage);
//     }
//
//     //when app ins background
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       print("onMessageOpenedApp");
//       handleMessage(event);
//     });
//   }
//
//   ///On Tap Go To Screen
//   ///You can Handle onTap of notification here
//   void handleMessage(RemoteMessage message) {
//     if (message.notification?.title == "Trainer has Joined") {
//       if (selectedPlan != "") {
//         Get.find<WorkOutController>().getDietPlanDetailsFunc(selectedPlan);
//         Get.to(() => WorkOutBottomScreen(planId: selectedPlan));
//       }
//     }
//   }
//
//   ///initializing new https firebase setting to get token
//   initializeNewHttpsSettingS() async {
//     await FirebaseMessaging.instance.getToken().then((value) {
//       sharedPreferences.setString(Constants.fcmToken, value!);
//     }).onError((error, stackTrace) {
//       print("messging erro $error");
//     });
//   }
//
//   Future forgroundMessage() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
// }
//
class NotificationMessage {
  final String title;
  final String body;
  final String? id; // message.messageId

  NotificationMessage({required this.title, required this.body, this.id});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }

  // Create from JSON
  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      id: json['id'] ?? '',
    );
  }

  // Create a NotificationMessage from RemoteMessage
  factory NotificationMessage.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      id: message.messageId?.hashCode.toString() ?? '',
    );
  }
}

const vapidKey =
    "BDWl3SA7SiHCyDYKJSWH_e6kgFg_EcvJvoWhUAvqH-6wLK14vBIO5INqVNnmkXq8_ZiArqUsJ7iBHEqaKM_hXEU";

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes Firebase messaging and local notification settings.
  void firebaseInit(BuildContext context) {
    // Listen for foreground notifications

    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message, context);
      onNotificationGet(message, context);
    });

    // Handle background and terminated state interactions
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleNotificationTap(message, context);
    });
  }

  /// Request notification permissions for iOS
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User denied notification permissions.');
    } else {
      await getDeviceToken();
    }
  }

  /// Initializes local notifications for Android and iOS.
  Future<void> initLocalNotifications(
      RemoteMessage message, BuildContext context) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) =>
          handleNotificationTap(message, context),
    );
  }

  /// Display a notification when the app is in the foreground.
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher', // Update with your launcher icon
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.messageId.hashCode,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      platformDetails,
    );
  }

  /// Foreground message handler for displaying notifications and updating UI.
  void _handleForegroundMessage(RemoteMessage message, BuildContext context) {
    if (message.notification != null) {
      UpcomingClassSlot? upcomingClassSlot;
      AuthController authController = Get.find();
      var sharedPreferences = authController.sharedPreferences;
      initLocalNotifications(message, context);
      if (message.notification?.title == "Upcoming Class" ||
          message.notification?.title == "Class Link Added" ||
          message.notification?.title == "Sweat Now, Selfies Later" ||
          message.notification?.title == "Class Cancelled") {
        upcomingClassSlot = UpcomingClassSlot(
            upcomingSlot:
                Slot.fromJson(jsonDecode(message.data["upcomingSlot"])),
            trainer: ClientUser.fromJson(jsonDecode(message.data["trainer"])));

        if (Get.find<HomeController>().upComingClassNotifier.value == null ||
            message.notification?.title == "Upcoming Class") {
          sharedPreferences.setString(
              Constants.upcomingSlot, jsonEncode(upcomingClassSlot.toJson()));

          Get.find<HomeController>().upComingClassNotifier.value =
              upcomingClassSlot;
        } else {
          if (Get.find<HomeController>()
                  .upComingClassNotifier
                  .value
                  ?.upcomingSlot
                  ?.id ==
              upcomingClassSlot.upcomingSlot?.id) {
            sharedPreferences.setString(
                Constants.upcomingSlot, jsonEncode(upcomingClassSlot.toJson()));

            Get.find<HomeController>().upComingClassNotifier.value =
                upcomingClassSlot;
          }
        }
      }
      print(
          'NotificationServices._handleForegroundMessage ${message.notification?.title}');
      print(
          'NotificationServices._handleForegroundMessage ${message.notification?.body}');
      if (message.notification?.title != "Upcoming Class") {
        if (upcomingClassSlot?.upcomingSlot?.status != "Confirmed") {
          addNotification(message);
          showNotification(message);
        }
      }
      print(
          'NotificationServices._handleForegroundMessage $upcomingClassSlot}');
      if (message.notification?.title == "Trainer has Joined") {
        if (selectedPlan != "") {
          Get.find<WorkOutController>().getDietPlanDetailsFunc(selectedPlan);
          addNotification(message);
        }
      } else if (message.notification?.title == "Congratulations!") {
        Get.find<HomeController>().getUserHomeFunc(isFromFree: true);
        addNotification(message);
      }
      if (upcomingClassSlot?.upcomingSlot?.status != "Confirmed") {
        if (message.notification?.title != "Upcoming Class") {
          showNotification(message);
        }
      }
    }
  }

  static String? deviceToken;
  void onNotificationGet(RemoteMessage message, BuildContext context) {}
  Future<String?> getDeviceToken() async {
    AuthController authController = Get.find();
    var sharedPreferences = authController.sharedPreferences;
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
      await _firebaseMessaging.deleteToken();
    }
    if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
      deviceToken = await _firebaseMessaging.getToken(
        vapidKey: vapidKey,
      );
    } else {
      deviceToken = await _firebaseMessaging.getToken();
    }
    sharedPreferences.setString(Constants.deviceToken, deviceToken!);
    print("device toke $deviceToken");

    // await FirebaseMessaging.instance.getToken().then((token) {
    //   if (token != null) {
    //     deviceToken = token;
    //     print("device Token: $token");
    //     sharedPreferences.setString(Constants.deviceToken, deviceToken!);
    //   }
    // }).catchError((onError) {
    //   print("the error is $onError");
    // });
    return deviceToken;
  }

  /// Handles notification tap interactions and navigates to appropriate screens.
  void handleNotificationTap(
      RemoteMessage message, BuildContext context) async {}
  addNotification(RemoteMessage message) {
    AuthController authController = Get.find();
    var sharedPreferences = authController.sharedPreferences;

    if (message.notification?.title == "A new message arrived") {
      sharedPreferences.setBool("showDot", true);
      Get.find<AuthController>().showDot.value = true;
    } else {
      sharedPreferences.setBool("showDotHome", true);
      Get.find<HomeController>().showDotHome.value = true;
    }

    var list = sharedPreferences.getString(Constants.notificationList);
    List<NotificationMessage> notificationMessages = [];

    if (list != null) {
      var list2 = jsonDecode(list);
      notificationMessages = List<NotificationMessage>.from(
        list2.map((item) => NotificationMessage.fromJson(item)),
      );
    }

    var newMessage = NotificationMessage.fromRemoteMessage(message);

    bool alreadyExists =
        notificationMessages.any((msg) => msg.id == newMessage.id);

    if (!alreadyExists) {
      notificationMessages.add(newMessage);
      authController.sharedPrefNotifier.value = notificationMessages;
      print('NotificationServices.addNotification $notificationMessages');
      sharedPreferences.setString(
        Constants.notificationList,
        jsonEncode(notificationMessages.map((msg) => msg.toJson()).toList()),
      );
    }
  }
}
