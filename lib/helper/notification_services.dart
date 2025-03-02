import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/controllers/home_controller/home_controller.dart';
import '../firebase_options.dart';
import '../values/constants.dart';
import 'package:get/get.dart';

const vapidKey =
    "BDWl3SA7SiHCyDYKJSWH_e6kgFg_EcvJvoWhUAvqH-6wLK14vBIO5INqVNnmkXq8_ZiArqUsJ7iBHEqaKM_hXEU";

class NotificationServices {
  //initialising firebase message plugin
  NotificationServices({required this.sharedPreferences});
  SharedPreferences sharedPreferences;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      print("onDidReceiveNotificationResponse");
      // handle interaction when app is active for android
      handleMessage(message);
    });
  }

  Future<void> firebaseInit() async {
    FirebaseMessaging.onMessage.listen((message) {
      print('----------- valuee    ');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      //if (kDebugMode) {
      print("notifications title:${notification!.title}");
      print("notifications body:${notification.body}");
      print('data:${message.data.toString()}');
      //}
      if (kIsWeb) {
        initLocalNotifications(message);
        showNotification(message);
      } else if (Platform.isIOS) {
        forgroundMessage();
        //initLocalNotifications( message);
        showNotification(message);
      } else if (Platform.isAndroid) {
        initLocalNotifications(message);
        showNotification(message);
      }
    });
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails? androidNotificationDetails;
    DarwinNotificationDetails? darwinNotificationDetails;

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        AndroidNotificationChannel channel = AndroidNotificationChannel(
          message.messageId!,
          message.messageId!,
          importance: Importance.max,
          showBadge: true,
          playSound: true,
        );
        androidNotificationDetails = AndroidNotificationDetails(
            channel.id, channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker',
            sound: channel.sound
            //c
            //  icon: largeIconPath
            );
      } else {
        darwinNotificationDetails = const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: null);
      }
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: darwinNotificationDetails);
      _flutterLocalNotificationsPlugin.show(
        message.messageId!.hashCode,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
      if (message.notification?.title == "Trainer has Joined") {
        if (selectedPlan != "") {
          Get.find<WorkOutController>().getDietPlanDetailsFunc(selectedPlan);
        }
      } else if (message.notification?.title == "Congratulations!") {
        Get.find<HomeController>().getUserHomeFunc(isFromFree: true);
      }
      addNotification(message);
    } else {
      Get.snackbar(
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    }
  }

  addNotification(RemoteMessage message) {
    AuthController authController = Get.find();

    if (message.notification?.title == "A new message arrived") {
      sharedPreferences.setBool("showDot", true);
      Get.find<AuthController>().showDot.value = true;
    }

    // Retrieve the existing list from SharedPreferences
    var list = sharedPreferences.getString(Constants.notificationList);

    // Create a new list if none exists
    List<NotificationMessage> notificationMessages = [];

    // If the list already exists in SharedPreferences
    if (list != null) {
      // Decode the existing list
      var list2 = jsonDecode(list);

      // Convert each item back to NotificationMessage and add to notificationMessages list
      notificationMessages = List<NotificationMessage>.from(
          list2.map((item) => NotificationMessage.fromJson(item)));
    }

    // Add the new message
    notificationMessages.add(NotificationMessage.fromRemoteMessage(message));
    authController.sharedPrefNotifier.value = notificationMessages;

    // Encode the list back to JSON and save it
    sharedPreferences.setString(Constants.notificationList,
        jsonEncode(notificationMessages.map((msg) => msg.toJson()).toList()));

    // Update the notifier with the new list
  }

  static String? deviceToken;
  Future<String?> getDeviceToken() async {
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

  Future<String?> getApns() async {
    await FirebaseMessaging.instance.getAPNSToken().then((token) {
      if (token != null) {
        deviceToken = token;
        print("device Token: $token");
        sharedPreferences.setString(Constants.deviceToken, deviceToken!);
      }
    }).catchError((onError) {
      print("the error is $onError");
    });
    return deviceToken;
  }
  //function to get device token on which we will send the notifications
  // Future<String> getDeviceToken() async {
  //   String? token = await messaging.getToken();
  //   return token!;
  // }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      sharedPreferences.setString(Constants.deviceToken, event.toString());

      if (kDebugMode) {
        print('refresh  ${event.toString()}');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage() async {
    // print(" i am intracting with message");

    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("initialMessage");
      handleMessage(initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("onMessageOpenedApp");
      handleMessage(event);
    });
  }

  ///On Tap Go To Screen
  ///You can Handle onTap of notification here
  void handleMessage(RemoteMessage message) {}

  ///initializing new https firebase setting to get token
  initializeNewHttpsSettingS() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      sharedPreferences.setString(Constants.fcmToken, value!);
    }).onError((error, stackTrace) {
      print("messging erro $error");
    });
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

class NotificationMessage {
  final String title;
  final String body;

  NotificationMessage({required this.title, required this.body});

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
    );
  }

  // Create a NotificationMessage from RemoteMessage
  factory NotificationMessage.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
    );
  }
}
