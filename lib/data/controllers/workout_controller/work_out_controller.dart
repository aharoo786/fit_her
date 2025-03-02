import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../helper/permissions.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:fitness_zone_2/data/models/add_package/add_package_model.dart'
    as addPackage;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/get_user_plan/get_user_plan.dart';
import '../auth_controller/auth_controller.dart';

class WorkOutController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  HomeRepo homeRepo;
  AuthController authController = Get.find();

  WorkOutController({required this.sharedPreferences, required this.homeRepo});

  CheckConnectionService connectionService = CheckConnectionService();

  ///Rx Variables
  var workOutOfUserLoad = false.obs;
  var workOutPlanDetailsLoad = false.obs;
  var getAllTimesSlotsLoad = false.obs;
  var trainerHomeLoad = false.obs;

  List<addPackage.Time> addPackageTimeTable = [];

  ///models
  AllPlanModel? workoutPlans;
  GetUserWorkoutPlanDetails? getUserWorkoutPlanDetailsPlan;
  GetUserWorkoutPlanDetails? getTrainerHome;

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

  getTrainerHomeFunc() {
    trainerHomeLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getTrainerHome(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "0",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetUserWorkoutPlanDetails> model = ApiResponse.fromJson(
                response.body, GetUserWorkoutPlanDetails.fromJson);
            if (model.status == "1") {
              getTrainerHome = model.data!;

              trainerHomeLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  addTrainerSlots() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        addPackageTimeTable.removeWhere((time) {
          // Remove invalid slots
          time.slots.removeWhere((slot) =>
              slot.start == "Start Time" ||
              slot.end == "End Time" ||
              slot.trainerId == null);

          // Optionally remove the entire time object if slots list is empty
          return time.slots.isEmpty;
        });
        for (var time in addPackageTimeTable) {
          for (var slot in time.slots) {
            //  if(slot.start.contains("AM")||slot.start.contains("PM")){
            slot.start = covertToTimeStamp(slot.start).toString();
            slot.end = covertToTimeStamp(slot.end).toString();
            //   }
          }
        }
        await homeRepo.addTrainerSlots(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"times": addPackageTimeTable},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: model.message);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  checkTiming(String start, String end) {
    Timestamp timestamp = Timestamp.fromDate(DateTime.now());
    int startTime = covertToTimeStamp(start);
    int endTime = covertToTimeStamp(end);

    if (timestamp.millisecondsSinceEpoch > startTime &&
        timestamp.millisecondsSinceEpoch < endTime) {
      return true;
    }
    return false;
  }

  getAllTimesSlotsTrainerFunc() {
    getAllTimesSlotsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getAllTimesWithSlotsTrainer(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            // ApiResponse model = ApiResponse.fromJson(
            //     response.body,(p0){});

            if (response.body["status"] == "1") {
              addPackageTimeTable = List<addPackage.Time>.from(response
                  .body["data"]["times"]
                  .map((x) => addPackage.Time.fromJson(x)));
              for (var time in addPackageTimeTable) {
                if (time.slots.isEmpty) {
                  time.slots.add(addPackage.Slot(
                      start: 'Start Time',
                      end: 'End Time',
                      id: null,
                      dayId: time.id,
                      trainerId: null));
                }
              }
              // for (var time in addPackageTimeTable) {
              //   time.slots.forEach((slot) {
              //     print("slot ${slot.toJson()}");
              //   });
              // }

              getAllTimesSlotsLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  updateClassDetails(int id, TextEditingController type,
      TextEditingController level, TextEditingController description) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.addClassDetails(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "type": type.text,
            "level": level.text,
            "description": description.text,
            "slotId": id
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: model.message);
                type.clear();
                level.clear();
                description.clear();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }
}
