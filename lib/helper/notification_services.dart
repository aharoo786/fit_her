import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../values/constants.dart';

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
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      //if (kDebugMode) {
      print("notifications title:${notification!.title}");
      print("notifications body:${notification.body}");
      print('data:${message.data.toString()}');
      //}

      if (Platform.isIOS) {
        forgroundMessage();
        //initLocalNotifications( message);
        showNotification(message);
      }

      if (Platform.isAndroid) {
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
  }

  static String? deviceToken;
  Future<String?> getDeviceToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
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
