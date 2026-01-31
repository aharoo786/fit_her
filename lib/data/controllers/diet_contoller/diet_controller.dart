import 'dart:convert';
import 'dart:io';
import 'package:fitness_zone_2/data/models/nutrition_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fitness_zone_2/data/models/diet_appointments.dart';
import 'package:fitness_zone_2/data/models/dietitian_times.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_trainers/get_all_diet_plans_of_user.dart';
import 'package:fitness_zone_2/data/models/food_suggestion_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../UI/diet_screen/calerie_info.dart';
import '../../../helper/permissions.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/day_slots_of_diet.dart';
import '../../models/diet_schedule_status.dart';
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
  var dietPlanStatusLoad = false.obs;
  var consultationStatusLoad = false.obs;
  var timesLoad = false.obs;
  var slotsLoad = false.obs;
  var dietPlanDetailsLoad = false.obs;
  var bookAppointmentSlotId = 0.obs;
  var foodSuggestionLoad = false.obs;

  ///Calori xFile
  XFile? calorieFile;

  ///File Variable
  File? addDietPdfFil;
  List<Appointment> rescheduleAppointments = [];
  List<Appointment> consultationStatus = [];
  List<PdfDiet> pdfDietStatus = [];

  ///models
  GetDietAllPlans? getDietAllPlans;
  GetDietPlanDetails? getDietPlanDetails;
  DietClients? getDietClientsModel;
  DietAppointments? dietAppointmentsModel;
  DietitianTiming? dietitianTimingModel;
  DaySlotsOfDiet? daySlotsOfDietModel;
  FoodSuggestionResponse? foodSuggestionResponse;

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
            ApiResponse<GetDietAllPlans> model = ApiResponse.fromJson(response.body, GetDietAllPlans.fromJson);
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
            ApiResponse<DietClients> model = ApiResponse.fromJson(response.body, DietClients.fromJson);
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
            ApiResponse<DietAppointments> model = ApiResponse.fromJson(response.body, DietAppointments.fromJson);
            if (model.status == "1") {
              dietAppointmentsModel = model.data;

              appointmentLoad.value = true;
            }
          }
        });
      }
    });
  }

  getRescheduleAppointments({bool reschedule = false}) {
    appointmentLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getRescheduleAppointments(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          reschedule: reschedule,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DietAppointments> model = ApiResponse.fromJson(response.body, DietAppointments.fromJson);
            if (model.status == "1") {
              rescheduleAppointments = model.data?.appointments ?? [];

              appointmentLoad.value = true;
            }
          }
        });
      }
    });
  }

  getConsultationStatus() {
    consultationStatusLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getConsultationStatus(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DietAppointments> model = ApiResponse.fromJson(response.body, DietAppointments.fromJson);
            if (model.status == "1") {
              consultationStatus = model.data?.appointments ?? [];

              consultationStatusLoad.value = true;
            }
          }
        });
      }
    });
  }

  getDietPlanScheduleStatus() {
    dietPlanStatusLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getReschedulePdfStatus(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DietPlanScheduleStatus> model = ApiResponse.fromJson(response.body, DietPlanScheduleStatus.fromJson);
            if (model.status == "1") {
              pdfDietStatus = model.data?.pdfDiets ?? [];
              dietPlanStatusLoad.value = true;
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
            ApiResponse<DietitianTiming> model = ApiResponse.fromJson(response.body, DietitianTiming.fromJson);
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
          map: {"dietitionId": sharedPreferences.getString(Constants.userId) ?? "", "dayId": dayId},
        ).then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<DaySlotsOfDiet> model = ApiResponse.fromJson(response.body, DaySlotsOfDiet.fromJson);
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
            ApiResponse<GetDietPlanDetails> model = ApiResponse.fromJson(response.body, GetDietPlanDetails.fromJson);
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
              getDietPlanDetails!.pdfFile.value = "${Constants.baseUrl}/${response.body["data"]["details"]["pdfFile"] ?? ""}";

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
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.addPdfFileRepo(accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", map: {
          "image": addDietPdfFil!.path,
          "userId": userId,
          "userPlanId": planId,
        }).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(jsonDecode(response.bodyString!), (p0) {});
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

  bookAppointment(int planId, int dietId, DateTime date) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.bookAppointment(accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", map: {
          "date": date.toIso8601String(),
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
              getDietPlanDetails?.isBooked = true;
              getDietPlanDetails?.status = response.body["data"]["appointment"]['status'] ?? "pending";
              getDietPlanDetails?.id = response.body["data"]["appointment"]["id"] ?? 0;
              // update(["dietBottomScreen"]);
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

  addCaloriesImage(String foodName) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo
            .addCalorieImage(
                accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
                map: {
                  "foodName": foodName,
                },
                id: sharedPreferences.getString(Constants.userId) ?? "")
            .then((response) async {
          Get.back();
          if (response.statusCode == 200) {
            ApiResponse<NutritionModel> model = ApiResponse.fromJson(response.body, NutritionModel.fromJson);
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);
              Get.to(() => NutritionScreen(
                    nutritionModel: model.data!,
                  ));
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  removeImage() {
    calorieFile = null;
    update(["colorieUpdate"]);
  }

  getFoodSuggestions(String query) {
    foodSuggestionLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        try {
          final response = await http.get(
            Uri.parse(
              'https://api.spoonacular.com/food/ingredients/autocomplete?query=${Uri.encodeComponent(query)}&number=10&apiKey=a2291fd5db7543429f91495c0654f28f',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
          );
          print('DietController.getFoodSuggestions ${response.body}');

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);

            // jsonData will be a List, so you may need a new model
            // Example format: [{ "name": "apple", "id": 9003, "image": "apple.png" }, ...]

            foodSuggestionResponse =
                FoodSuggestionResponse.fromJson(jsonData);

            foodSuggestionLoad.value = true;
          } else {
            CustomToast.failToast(msg: "Failed to get food suggestions");
            foodSuggestionLoad.value = false;
          }
        } catch (e) {
          CustomToast.failToast(msg: "Error getting food suggestions");
          foodSuggestionLoad.value = false;
        }
      }
    });
  }

  updateAppointmentStatus(int id, String status,
      {bool isFromAppointment = false, bool reschedule = false, bool isFromDietDetails = false, String? planId}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        print('DietController.updateAppointmentStatus ${status}');
        await homeRepo
            .updateAppointment(accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", map: {"status": status}, id: id.toString())
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);

              if (isFromAppointment) {
                appointmentLoad.value = false;
                var value = dietAppointmentsModel!.appointments.firstWhereOrNull((v) => v.id == id);
                if (value != null) {
                  value.status = status;
                  Get.back();
                }
              }
              if (isFromDietDetails) {
                getDietPlanDetailsFunc(planId.toString());
              }
              appointmentLoad.value = true;
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  deletedAppointment(int id, int planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await homeRepo
            .deleteAppointment(accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", id: id.toString())
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);
              getDietPlanDetailsFunc(planId.toString());
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  updateReschedule() {
    getDietPlanDetails?.isBooked = false;
    update(["dietBottomScreen"]);
  }

  addDaySlots(String dayId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
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
            accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
            map: {"dietitionId": sharedPreferences.getString(Constants.userId) ?? "", "dayId": dayId, "slotsList": list}).then((response) async {
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
      var downloadDir = (Platform.isIOS) ? (await getApplicationDocumentsDirectory()).path : (await getApplicationSupportDirectory()).path;

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
