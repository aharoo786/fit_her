import 'package:fitness_zone_2/data/models/get_all_dietitian_trainers/get_all_diet_plans_of_user.dart';

import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/get_all_dietitian_trainers/get_diet_plan_details.dart';

class DietController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  HomeRepo homeRepo;

  DietController({required this.sharedPreferences, required this.homeRepo});

  CheckConnectionService connectionService = CheckConnectionService();

  ///Rx Variables
  var dietOfUserLoad = false.obs;
  var dietPlanDetailsLoad = false.obs;

  ///models
  GetDietAllPlans? getDietAllPlans;
  GetDietPlanDetails? getDietPlanDetails;

  getDietAllPlansFunc() {
    dietOfUserLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getUserPlansDiet(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetDietAllPlans> model =
                ApiResponse.fromJson(response.body, GetDietAllPlans.fromJson);
            if (model.status == "1") {
              getDietAllPlans = model.data;

              dietOfUserLoad.value = true;
            }
          }
        });
      }
    });
  }

  getDietPlanDetailsFunc(String id) {
    dietPlanDetailsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getUserPlanDetailsDiet(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          planId: id,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetDietPlanDetails> model = ApiResponse.fromJson(
                response.body, GetDietPlanDetails.fromJson);
            if (model.status == "1") {
              getDietPlanDetails = model.data;
                print("line 4 ${getDietPlanDetails!.details.dietitionLink}");
              dietPlanDetailsLoad.value = true;
            }
          }
        });
      }
    });
  }

  @override
  void onInit() {
    getDietAllPlansFunc();

    super.onInit();
  }
}
