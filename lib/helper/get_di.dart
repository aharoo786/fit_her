import 'package:fitness_zone_2/data/Repos/auth_repo/auth_repo.dart';
import 'package:fitness_zone_2/data/Repos/home_repo/home_repo.dart';
import 'package:fitness_zone_2/data/Repos/cycle_repo/cycle_data_repository.dart';
import 'package:fitness_zone_2/data/Repos/checkin_repo/checkin_repository.dart';
import 'package:fitness_zone_2/data/Repos/plan_freeze_repo/plan_freeze_repository.dart';
import 'package:fitness_zone_2/data/Repos/user_plan_repo/user_plan_repository.dart';
import 'package:fitness_zone_2/data/Repos/diet_plan_v2/diet_plan_admin_repository.dart';
import 'package:fitness_zone_2/data/Repos/diet_plan_v2/diet_plan_user_repository.dart';
import 'package:fitness_zone_2/data/controllers/diet_plan_admin_controller/diet_plan_admin_controller.dart';
import 'package:fitness_zone_2/data/controllers/diet_plan_user_controller/diet_plan_user_controller.dart';
import 'package:fitness_zone_2/data/controllers/day7_review_controller/day7_review_controller.dart';
import 'package:fitness_zone_2/data/api_provider/chat_api_provider.dart';
import 'package:fitness_zone_2/data/controllers/consultation_controller/consultation_controller.dart';
import 'package:fitness_zone_2/data/controllers/dietitian_dashboard_controller/dietitian_dashboard_controller.dart';
import 'package:fitness_zone_2/data/controllers/meal_log_controller/meal_log_controller.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/paid_home_controller/paid_home_controller.dart';
import 'package:fitness_zone_2/data/controllers/plan_controller/plan_controller.dart';
import 'package:fitness_zone_2/data/controllers/post_controller.dart';
import 'package:fitness_zone_2/data/controllers/progress_controller/progress_controller.dart';
import 'package:fitness_zone_2/data/controllers/rating_controller/rating_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/controllers/motivation_controller/motivation_controller.dart';
import 'package:fitness_zone_2/data/controllers/zoom_controller.dart';
import 'package:fitness_zone_2/data/services/youtube_tutorial_service.dart';
import 'package:fitness_zone_2/data/services/analytics_service.dart';
import 'package:fitness_zone_2/data/services/timezone_sync_service.dart';
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
  NotificationServices notificationServices = NotificationServices();
  Get.lazyPut(() => ApiProvider());
  Get.lazyPut(() => ChatApiProvider(sharedPreferences));

  ///Repos
  Get.lazyPut(() => AuthRepo(apiProvider: Get.find()));
  Get.lazyPut(() => HomeRepo(apiProvider: Get.find()));
  Get.lazyPut(() => CycleDataRepository(apiProvider: Get.find()));
  Get.lazyPut(() => CheckinRepository(apiProvider: Get.find()));
  Get.lazyPut(() => PlanFreezeRepository(apiProvider: Get.find()));
  Get.lazyPut(() => UserPlanRepository(apiProvider: Get.find()));
  Get.lazyPut(() => DietPlanAdminRepository(apiProvider: Get.find()));
  Get.lazyPut(() => DietPlanUserRepository(apiProvider: Get.find()));

  ///Services
  Get.lazyPut(() => YouTubeTutorialService());
  Get.lazyPut(() => AnalyticsService());

  Get.lazyPut(() => AuthController(
      sharedPreferences: sharedPreferences, authRepo: Get.find(), notificationServices: notificationServices, chatApiProvider: Get.find()));
  Get.lazyPut(() => HomeController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => DietController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => ProgressController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => WorkOutController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => MotivationController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => PlanController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => RatingController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => PostController(sharedPreferences: sharedPreferences, homeRepo: Get.find()));
  Get.lazyPut(() => PaidHomeController(
        homeRepo: Get.find(),
        checkinRepo: Get.find(),
        sharedPreferences: sharedPreferences,
      ));
  Get.lazyPut(() => ConsultationController(
        homeRepo: Get.find(),
        sharedPreferences: sharedPreferences,
      ));
  Get.lazyPut(() => MealLogController(
        homeRepo: Get.find(),
        sharedPreferences: sharedPreferences,
      ));
  Get.lazyPut(() => DietitianDashboardController(
        homeRepo: Get.find(),
        sharedPreferences: sharedPreferences,
      ));
  Get.lazyPut(() => DietPlanAdminController(
        repo: Get.find<DietPlanAdminRepository>(),
        auth: Get.find<AuthController>(),
      ));
  Get.lazyPut(() => DietPlanUserController(
        repo: Get.find<DietPlanUserRepository>(),
        auth: Get.find<AuthController>(),
      ));
  Get.lazyPut(() => Day7ReviewController(
        repo: Get.find<DietPlanUserRepository>(),
        auth: Get.find<AuthController>(),
      ));
  Get.lazyPut(() => TimezoneSyncService(
        auth: Get.find<AuthController>(),
        repo: Get.find<DietPlanUserRepository>(),
      ));
  Get.lazyPut(() => ZoomMeetingGetxController());
}
