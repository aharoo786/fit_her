import 'package:fitness_zone_2/data/Repos/auth_repo/auth_repo.dart';
import 'package:fitness_zone_2/data/Repos/home_repo/home_repo.dart';
import 'package:fitness_zone_2/data/api_provider/chat_api_provider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api_provider/api_provider.dart';
import '../data/controllers/auth_controller/auth_controller.dart';
import '../data/controllers/home_controller/home_controller.dart';
import 'notification_services.dart';

Future init() async {
  Get.log("int di");
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  NotificationServices notificationServices =
      NotificationServices(sharedPreferences: sharedPreferences);
  Get.lazyPut(() => ApiProvider());
  Get.lazyPut(() => ChatApiProvider(sharedPreferences));

  ///Repos
  Get.lazyPut(() => AuthRepo(apiProvider: Get.find()));
  Get.lazyPut(() => HomeRepo(apiProvider: Get.find()));

  Get.lazyPut(() => AuthController(
      sharedPreferences: sharedPreferences,
      authRepo: Get.find(),
      notificationServices: notificationServices,
      chatApiProvider: Get.find()));
  Get.lazyPut(() => HomeController(
      sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  // Get.lazyPut(() => AuthController(sharedPreferences:sharedPreferences));
}
