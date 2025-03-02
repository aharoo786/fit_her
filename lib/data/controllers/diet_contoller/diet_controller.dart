import 'dart:convert';
import 'dart:io';
import 'package:fitness_zone_2/data/models/diet_appointments.dart';
import 'package:fitness_zone_2/data/models/dietitian_times.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_trainers/get_all_diet_plans_of_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../helper/permissions.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/day_slots_of_diet.dart';
import '../../models/get_all_dietitian_trainers/get_diet_plan_details.dart';
import '../../models/get_clients_diet.dart';
import '../auth_controller/auth_controller.dart';

class DietController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  HomeRepo homeRepo;
  AuthController authController = Get.find();

  DietController({required this.sharedPreferences, required this.homeRepo});

  CheckConnectionService connectionService = CheckConnectionService();

  ///Rx Variables
  var dietOfUserLoad = false.obs;
  var clientDataLoad = false.obs;
  var appointmentLoad = false.obs;
  var timesLoad = false.obs;
  var slotsLoad = false.obs;
  var dietPlanDetailsLoad = false.obs;
  var bookAppointmentSlotId = 0.obs;

  ///File Variable
  File? addDietPdfFil;

  ///models
  GetDietAllPlans? getDietAllPlans;
  GetDietPlanDetails? getDietPlanDetails;
  DietClients? getDietClientsModel;
  DietAppointments? dietAppointmentsModel;
  DietitianTiming? dietitianTimingModel;
  DaySlotsOfDiet? daySlotsOfDietModel;

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

  clientsOfDietFunc() {
    clientDataLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getClients(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DietClients> model =
                ApiResponse.fromJson(response.body, DietClients.fromJson);
            if (model.status == "1") {
              getDietClientsModel = model.data;

              clientDataLoad.value = true;
            }
          }
        });
      }
    });
  }

  getAppointmentsOfDiets() {
    appointmentLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getAppointments(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DietAppointments> model =
                ApiResponse.fromJson(response.body, DietAppointments.fromJson);
            if (model.status == "1") {
              dietAppointmentsModel = model.data;

              appointmentLoad.value = true;
            }
          }
        });
      }
    });
  }

  getDietTimes() {
    timesLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getTimesOfDiet(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DietitianTiming> model =
                ApiResponse.fromJson(response.body, DietitianTiming.fromJson);
            if (model.status == "1") {
              dietitianTimingModel = model.data;

              timesLoad.value = true;
            }
          }
        });
      }
    });
  }

  getSlotsOfDay(int dayId) {
    slotsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo.getDaySlots(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
          map: {
            "dietitionId": sharedPreferences.getString(Constants.userId) ?? "",
            "dayId": dayId
          },
        ).then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DaySlotsOfDiet> model =
                ApiResponse.fromJson(response.body, DaySlotsOfDiet.fromJson);
            if (model.status == "1") {
              daySlotsOfDietModel = model.data;

              slotsLoad.value = true;
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
              await getUserPdfFile(id.toString());
              //
              dietPlanDetailsLoad.value = true;
            }
          }
        });
      }
    });
  }

  getUserPdfFile(String id) {
    // dietPlanDetailsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getDietPdfRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          planId: id,
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
            if (model.status == "1") {
              getDietPlanDetails!.pdfFile.value =
                  "${Constants.baseUrl}/${response.body["data"]["details"]["pdfFile"] ?? ""}";

              dietPlanDetailsLoad.value = true;
            }
          }
        });
      }
    });
  }

  addDietPdFFile(String planId, String userId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.addPdfFileRepo(
            accessToken:
                sharedPreferences.getString(Constants.accessToken) ?? "",
            map: {
              "image": addDietPdfFil!.path,
              "userId": userId,
              "userPlanId": planId
            }).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model =
                ApiResponse.fromJson(jsonDecode(response.bodyString!), (p0) {});
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);
              addDietPdfFil = null;
              Get.back();
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  bookAppointment(int planId, int dietId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.bookAppointment(
            accessToken:
                sharedPreferences.getString(Constants.accessToken) ?? "",
            map: {
              "date": DateTime.now().toIso8601String(),
              "userId": sharedPreferences.getString(Constants.userId) ?? "",
              "dietitionId": dietId,
              "timeSlotId": bookAppointmentSlotId.value,
              "userPlanId": planId
            }).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);
              getDietPlanDetailsFunc(planId.toString());
              //  Get.back();
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  addDaySlots(String dayId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        var list = [];
        if (daySlotsOfDietModel != null) {
          for (var value in daySlotsOfDietModel!.slots) {
            value.start = covertToTimeStamp(value.start).toString();
            value.end = covertToTimeStamp(value.end).toString();
            list.add({"start": value.start, "end": value.end, "id": value.id});
          }
        } else {
          return;
        }

        await homeRepo.addDaySlots(
            accessToken:
                sharedPreferences.getString(Constants.accessToken) ?? "",
            map: {
              "dietitionId":
                  sharedPreferences.getString(Constants.userId) ?? "",
              "dayId": dayId,
              "slotsList": list
            }).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);
              Get.back();
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  Future<String> downloadFile(var filePath, var documentUrl) async {
    try {
      final filename = filePath;
      var downloadDir = (Platform.isIOS)
          ? (await getApplicationDocumentsDirectory()).path
          : (await getApplicationSupportDirectory()).path;

      String dir = downloadDir;

      // Construct the full file path
      File file = File('$dir/$filename');
      print('Downloading file to: $dir/$filename');

      // Create the directory if it doesn't exist
      if (!await Directory(dir).exists()) {
        await Directory(dir).create(recursive: true);
        print('Created directory: $dir');
      }

      // Make the HTTP request
      String url = documentUrl;
      print('Fetching from URL: $url');
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();

      // Check if the response is successful
      if (response.statusCode != 200) {
        print('Failed to download file. Status code: ${response.statusCode}');
        return "Error: Failed to download file";
      }

      // Write the file
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      print('File downloaded successfully: ${file.path}');
      return file.path;
    } catch (err) {
      print('Error during file download: $err');
      return "Error: $err";
    }
  }

  @override
  void onInit() {
    //  getDietAllPlansFunc();
    if (authController.loginAsA.value == Constants.dietitian) {
      getAppointmentsOfDiets();
    }
    super.onInit();
  }
}
