import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';

import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/get_user_plan/get_user_plan.dart';

class WorkOutController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  HomeRepo homeRepo;

  WorkOutController({required this.sharedPreferences, required this.homeRepo});

  CheckConnectionService connectionService = CheckConnectionService();

  ///Rx Variables
  var workOutOfUserLoad = false.obs;
  var workOutPlanDetailsLoad = false.obs;

  ///models
  AllPlanModel? workoutPlans;
  GetUserWorkoutPlanDetails? getUserWorkoutPlanDetailsPlan;

  getWorkoutAllPlansFunc() {
    workOutOfUserLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getUserPlansWorkout(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model =
                ApiResponse.fromJson(response.body, AllPlanModel.fromJson);
            if (model.status == "1") {
              workoutPlans = model.data;

              workOutOfUserLoad.value = true;
            }
          }
        });
      }
    });
  }

  getDietPlanDetailsFunc(String id) {
    workOutPlanDetailsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getUserPlanDetailsWorkout(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          planId: id,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetUserWorkoutPlanDetails> model = ApiResponse.fromJson(
                response.body, GetUserWorkoutPlanDetails.fromJson);
            if (model.status == "1") {
              getUserWorkoutPlanDetailsPlan = model.data;

              workOutPlanDetailsLoad.value = true;
            }
          }
        });
      }
    });
  }

  @override
  void onInit() {
    getWorkoutAllPlansFunc();

    super.onInit();
  }
}
