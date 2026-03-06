import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/UI/free_trail/free_trail_question.dart';
import 'package:fitness_zone_2/UI/free_trail/free_trial_slots.dart';
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

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/free_trial_user_details.dart';
import '../../models/get_user_plan/get_user_plan.dart';
import '../auth_controller/auth_controller.dart';
import '../../../helper/analytics_helper.dart';

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
  var getFreeTrialUserDetailsLoad = false.obs;
  var trainerHomeLoad = false.obs;

  var freeTrialSlots = [].obs;
  var freeTrailSlotIndex = 0;

  List<FreeTrialUser> freeTrialUser = [];
  List<addPackage.Time> addPackageTimeTable = [];

  ///models
  AllPlanModel? workoutPlans;
  GetUserWorkoutPlanDetails? getUserWorkoutPlanDetailsPlan;
  GetUserWorkoutPlanDetails? getTrainerHome;

  getWorkoutAllPlansFunc({bool isFree = false}) {
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
              print(
                  'WorkOutController.getWorkoutAllPlansFunc ${(workoutPlans?.plans.isNotEmpty)}');
              if (isFree && !(workoutPlans?.plans.isNotEmpty ?? true)) {
                Get.to(() => FreeTrialSlots());
                getDietPlanDetailsFunc("0", showSlots: true);
              }
            }
          }
        });
      }
    });
  }

  getDietPlanDetailsFunc(String id, {bool showSlots = false}) {
    print('WorkOutController.getDietPlanDetailsFunc');
    workOutPlanDetailsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        await homeRepo
            .getUserPlanDetailsWorkout(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          planId: id,
          userId: sharedPreferences.getString(Constants.userId) ?? "",
          showSlots: showSlots,
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

              ///filtering slots for two days
              if (showSlots) {
                var today = DateFormat('EEEE').format(DateTime.now());
                var tomorrow = DateFormat('EEEE')
                    .format(DateTime.now().add(const Duration(days: 1)));

                List<TrainerSlot> filter = getUserWorkoutPlanDetailsPlan
                        ?.trainerSlots
                        .where((t) => t.day == today || t.day == tomorrow)
                        .toList() ??
                    [];

                getUserWorkoutPlanDetailsPlan?.trainerSlots = filter;
              }
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
          userId: sharedPreferences.getString(Constants.userId) ?? "",
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

  getFreeTrialUserDetails(String slotId) {
    getFreeTrialUserDetailsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getAllFreeTrialUsers(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          id: sharedPreferences.getString(Constants.userId) ?? "",
          slotId: slotId,
        )
            .then((response) async {
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetFreeTrialUserDetails> model = ApiResponse.fromJson(
                response.body, GetFreeTrialUserDetails.fromJson);

            if (response.body["status"] == "1") {
              print(
                  'WorkOutController.getFreeTrialUserDetails ${model.data?.user}');
              freeTrialUser = model.data?.user ?? [];

              getFreeTrialUserDetailsLoad.value = true;
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

  updateFreeTrialData(List<Map<String, dynamic>> answers) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.addFreeTrialUserData(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "mainGoal": answers[0]["other"]
                ? answers[0]["otherText"]
                : answers[0]["answersList"].join(","),
            "specificIssues": answers[1]["other"]
                ? answers[1]["otherText"]
                : answers[1]["answersList"].join(","),
            "prefrences": answers[2]["other"]
                ? answers[2]["otherText"]
                : answers[2]["answersList"].join(","),
            "freeTrialUser":
                sharedPreferences.getString(Constants.userId) ?? "",
            "slots": freeTrialSlots
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                // Track free trial completed
                AnalyticsHelper.trackFreeTrialEvent('completed', step: 'slots');

                CustomToast.successToast(msg: model.message);
                Get.offAll(() => BottomBarScreen());
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
