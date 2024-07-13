import 'dart:convert';

import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/UI/web_view.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/models/add_package/add_package_model.dart'
    as addPackage;
import 'package:agora_token_service/agora_token_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_trainers/get_all_dietitian_trainers.dart';
import 'package:fitness_zone_2/data/models/get_guest_user/get_guest_users.dart';
import 'package:fitness_zone_2/data/models/get_user_plan/get_user_plan.dart';
import 'package:fitness_zone_2/data/models/get_users_plan_images/get_user_plan_images.dart';
import 'package:fitness_zone_2/data/models/get_weekly_report/get_weekly_report.dart';
import 'package:fitness_zone_2/data/models/login_response_model/login_response_model.dart';
import 'package:fitness_zone_2/data/models/paymetn/payment_link.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/get_all_cat_plan/get_all_categories.dart';
import '../../models/get_all_dietitian_users/get_all_dietitian_users.dart';
import '../../models/get_all_users/get_all_users.dart';
import '../../models/get_trainer_home/get_trainer_home.dart';
import '../../models/home_model/home_model.dart';

class HomeController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  HomeRepo homeRepo;

  HomeController({required this.sharedPreferences, required this.homeRepo});
  CheckConnectionService connectionService = CheckConnectionService();
  @override
  void onInit() {
    // TODO: implement onInit
    addPackageTimeTable = [
      getTimeModel("Monday"),
      getTimeModel("Tuesday"),
      getTimeModel("Wednesday"),
      getTimeModel("Thursday"),
      getTimeModel("Friday"),
      getTimeModel("Saturday"),
      getTimeModel("Sunday"),
    ];

    super.onInit();
  }

  ///adding team member
  List<String> addTeamMember = ["Dietition", "Trainer"];
  var addedTeamMember = "Dietition".obs;

  ///Measurement controllers Weekly
  TextEditingController firstDay = TextEditingController();
  TextEditingController currentDate = TextEditingController();
  TextEditingController firstWeight = TextEditingController();
  TextEditingController currentWeight = TextEditingController();
  TextEditingController waist = TextEditingController();
  TextEditingController hips = TextEditingController();
  TextEditingController shoulder = TextEditingController();
  TextEditingController arms = TextEditingController();
  TextEditingController chest = TextEditingController();
  TextEditingController abdonmen = TextEditingController();
  TextEditingController thighs = TextEditingController();
  List<Map<String, dynamic>> participantList = [];

  clearMeasurementController() {
    firstDay.clear();
    currentDate.clear();
    firstWeight.clear();
    currentWeight.clear();
    waist.clear();
    hips.clear();
    shoulder.clear();
    arms.clear();
    hips.clear();
    thighs.clear();
    abdonmen.clear();
    chest.clear();
  }

  ///for adding Package

  TextEditingController packageName = TextEditingController();
  TextEditingController shortDis = TextEditingController();
  TextEditingController longDis = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController packageDuration = TextEditingController();

  ///Get Cat
  AllCategoriesOfPlan? allCategoriesOfPlan;
  AllPlanModel? allPlanModel;
  GetAllDietitianAndTrainers? getAllDietitianAndTrainers;
  GetAllUsers? getAllUsers;
  GetGuestData? getGuestData;
  GetAllPlansImages? getAllPlansImages;
  GetTrainerHome? getTrainerHome;
  GetDietitianUsers? getDietitianUsers;
  UserHomeData? userHomeData;
  GetWeeklyReportsModel? getWeeklyReportsModel;

  /// call screen variabls
  var muteAudio = false.obs;
  var muteVideo = false.obs;

  ///My Weekly Report Function

  var selectedPlanIndex = 0.obs;

  List<addPackage.Time> addPackageTimeTable = [];

  ///get Cat
  var getCatLoaded = false.obs;
  var getPlanLoaded = false.obs;
  var getDietitianLoad = false.obs;
  var getAllUsersLoad = false.obs;
  var trainerHomeLoad = false.obs;
  var weeklyReportLoad = false.obs;
  var dietHomeLoad = false.obs;
  var guestUserLoad = false.obs;
  var userHomeLoad = false.obs;
  var getPlanImagesLoad = false.obs;

  ///testimonials pic
  XFile? testiPicture;
  XFile? planPicture;

  ///Add a new User
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateExtendController = TextEditingController();

  clearyControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
  }

  ///plans list
  var dietPlanList = <Plan>[].obs;
  var trainerPlanList = <Plan>[].obs;

  ///select cat id
  var selectedId = 0.obs;
  var selectedPlanId = 0.obs;
  var selectedDietId = 0.obs;
  var selectedDietIdForMember = 0.obs;
  var selectedTrainerId = 0.obs;
  var selectedTrainerIdForMember = 0.obs;
  var selectedTrainerIdForBoth = 0.obs;

  getTimeModel(String day) {
    addPackage.Time timeModel = addPackage.Time(
        day: day,
        slots: [addPackage.Slot(start: "Start Time", end: "End Time")]);
    return timeModel;
  }

  Future<String?> getAgoraToken(String channelName) async {
    const expirationInSeconds = 84600;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTimestamp = currentTimestamp + expirationInSeconds;
    final token = RtcTokenBuilder.build(
      appId: Constants.appID,
      appCertificate: Constants.appCertificate,
      channelName: channelName,
      uid: "0",
      role: RtcRole.publisher,
      expireTimestamp: expireTimestamp,
    );
    print("token    $token");
    update();
    return token;
  }

  getCategories() {
    getCatLoaded.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getAllCategories(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllCategoriesOfPlan> model = ApiResponse.fromJson(
                response.body, AllCategoriesOfPlan.fromJson);
            if (model.status == "1") {
              allCategoriesOfPlan = model.data!;
              if (allCategoriesOfPlan!.categories.isNotEmpty) {
                selectedId.value = allCategoriesOfPlan!.categories[0].id;
              }

              getCatLoaded.value = true;
            }
          }
        });
      }
    });
  }

  Future<String> getUserNameUsingId(int id) async {
    String name = "Unknown";

    // Use try-catch to handle errors
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("remoteId", isEqualTo: id)
          .get();

      print("querySnapshot: $querySnapshot");

      if (querySnapshot.docs.isNotEmpty) {
        // Access the first document in the result
        var documentSnapshot = querySnapshot.docs.first;

        // Access the data within the document
        var data = documentSnapshot.data();

        //  var userModel = UserModel.fromJson(data);
        //   print("remote id $id    ...local  ${userModel.remoteId}");
        //   name = userModel.fullName;
      }
    } catch (error) {
      print("Error: $error");
      // Handle errors as needed
    }

    return name;
  }

  updateUserRemoteId(int id) async {
    await FirebaseFirestore.instance
        .collection(Constants.customers)
        .doc(Get.find<AuthController>().logInUser!.id.toString())
        .update({"remoteId": id});
  }

  getPlans() {
    getPlanLoaded.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);
        dietPlanList.value = [];
        trainerPlanList.value = [];

        homeRepo
            .getAllPlans(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model =
                ApiResponse.fromJson(response.body, AllPlanModel.fromJson);
            if (model.status == "1") {
              allPlanModel = model.data!;
              if (allPlanModel!.plans.isNotEmpty) {
                selectedPlanId.value = allPlanModel!.plans[0].id;
                for (var element in allPlanModel!.plans) {
                  if (element.categoryId == 1) {
                    dietPlanList.value.add(element);
                    selectedDietIdForMember.value = dietPlanList[0].id;
                  } else if (element.categoryId == 2) {
                    trainerPlanList.value.add(element);
                    selectedTrainerIdForMember.value = trainerPlanList[0].id;
                  }
                }
              }

              getPlanLoaded.value = true;
            }
          }
        });
      }
    });
  }

  getAllDietitian() {
    getDietitianLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getDietAndTrain(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetAllDietitianAndTrainers> model =
                ApiResponse.fromJson(
                    response.body, GetAllDietitianAndTrainers.fromJson);
            if (model.status == "1") {
              getAllDietitianAndTrainers = model.data!;
              selectedPlanIndex.value = 0;
              if (getAllDietitianAndTrainers!.dietitions.isNotEmpty) {
                selectedDietId.value =
                    getAllDietitianAndTrainers!.dietitions[0].id;
              }
              if (getAllDietitianAndTrainers!.trainers.isNotEmpty) {
                selectedTrainerId.value =
                    getAllDietitianAndTrainers!.trainers[0].id;
              }

              getDietitianLoad.value = true;
            }
          }
        });
      }
    });
  }

  getAllUsersFunc() {
    getAllUsersLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getAllUsers(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetAllUsers> model =
                ApiResponse.fromJson(response.body, GetAllUsers.fromJson);
            if (model.status == "1") {
              getAllUsers = model.data!;

              getAllUsersLoad.value = true;
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
            ApiResponse<GetTrainerHome> model =
                ApiResponse.fromJson(response.body, GetTrainerHome.fromJson);
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

  getWeeklyReportsFunc() {
    weeklyReportLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getWeeklyReportsRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetWeeklyReportsModel> model = ApiResponse.fromJson(
                response.body, GetWeeklyReportsModel.fromJson);
            if (model.status == "1") {
              getWeeklyReportsModel = model.data!;

              weeklyReportLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  getDietHomeFunc() {
    dietHomeLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getDietHome(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "0",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetDietitianUsers> model =
                ApiResponse.fromJson(response.body, GetDietitianUsers.fromJson);
            if (model.status == "1") {
              getDietitianUsers = model.data!;

              dietHomeLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  getGuestUsers() {
    guestUserLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getGuestUsers(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "0",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetGuestData> model =
                ApiResponse.fromJson(response.body, GetGuestData.fromJson);
            if (model.status == "1") {
              getGuestData = model.data!;

              guestUserLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  getAllImagesPlan() {
    getPlanImagesLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getPlanImages(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetAllPlansImages> model =
                ApiResponse.fromJson(response.body, GetAllPlansImages.fromJson);
            if (model.status == "1") {
              getAllPlansImages = model.data!;

              getPlanImagesLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  getUserHomeFunc() {
    userHomeLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getUserHome(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "0",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<UserHomeData> model =
                ApiResponse.fromJson(response.body, UserHomeData.fromJson);
            if (model.status == "1") {
              userHomeData = model.data!;

              userHomeLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  addPlan() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await homeRepo
            .addPlanRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: addPackage.AddPackageModel(
                  title: packageName.text,
                  shortDescription: shortDis.text,
                  longDescription: longDis.text,
                  categoryId: selectedId.toString(),
                  price: price.text,
                  times: addPackageTimeTable,
                  duration: packageDuration.text)
              .toJson(),
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.failToast(msg: response.body["message"]);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updatePlan() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await homeRepo
            .updatePlanRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: addPackage.AddPackageModel(
                  title: packageName.text,
                  shortDescription: shortDis.text,
                  longDescription: longDis.text,
                  categoryId: selectedId.toString(),
                  price: price.text,
                  times: addPackageTimeTable,
                  duration: packageDuration.text)
              .toJson(),
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.failToast(msg: response.body["message"]);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  addUser({bool status = true}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        var plan;
        var expiryDate;
        var price;
        if (status) {
          plan = allPlanModel!.plans[selectedPlanIndex.value];
          expiryDate = DateTime.now()
              .add(Duration(days: int.parse(plan.duration.split(" ").first)));
          price = plan.price;
        }

        await homeRepo.addUserRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "firstName": firstNameController.text,
            "lastName": lastNameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "phone": phoneController.text,
            "categoryId": status ? plan.categoryId : null,
            "plans": status
                ? [
                    {
                      "planId": selectedPlanId.value,
                      "buyingDate": DateTime.now().toString(),
                      "expireDate": expiryDate.toString(),
                      "price": price.toString(),
                      "trainerId": plan.categoryId == 2 || plan.categoryId == 3
                          ? selectedTrainerId.value
                          : "",
                      "dietitianId":
                          plan.categoryId == 1 || plan.categoryId == 3
                              ? selectedDietId.value
                              : ""
                    }
                  ]
                : null,
            "status": status,
            "deviceToken":
                sharedPreferences.getString(Constants.deviceToken) ?? ""
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse<LoginModel> model =
                  ApiResponse.fromJson(response.body, LoginModel.fromJson);
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);

                clearyControllers();
                if (status) {
                  getAllUsersFunc();
                } else {
                  sharedPreferences.setString(
                      Constants.accessToken, model.data!.accessToken);
                  sharedPreferences.setString(
                      Constants.userId, model.data!.id.toString());

                  sharedPreferences.setBool(Constants.isGuest, false);
                  Get.find<AuthController>().logInUser = model.data;
                  Get.offAll(() => BottomBarScreen());
                  getPlans();
                }
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  getPaymentLink(String amount, int id) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await homeRepo.getPaymentLink(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"amount": amount, "planId": id},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse<PaymentLink> model =
                  ApiResponse.fromJson(response.body, PaymentLink.fromJson);
              if (model.status == "1") {
                Get.to(() => WebViewScreen(url: model.data!.session.url));
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  addAnnouncement(TextEditingController title, TextEditingController body) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.addAnnouncement(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"title": title.text, "body": body.text},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
                title.clear();
                body.clear();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  freezeMyAccount() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.freezeMyAccount(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "userId": sharedPreferences.getString(Constants.userId),
            "freeze": true,
            "freezingDays": Get.find<AuthController>()
                .dateExtendController
                .text
                .split(" ")
                .first
          },
        ).then((response) async {
          Get.back();
          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  synchronization() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo
            .synchronizationRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          Get.back();
          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: "Reminder Send Successfully");
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updateMyWeeklyReport() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.updateWeeklyReportRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "weight": firstWeight.text,
            "currentWeight": currentWeight.text,
            "arms": arms.text,
            "chest": chest.text,
            "abdoman": abdonmen.text,
            "shoulder": shoulder.text,
            "thighs": thighs.text,
            "userId": sharedPreferences.getString(Constants.userId) ?? "",
            "hips": hips.text,
            "istDayDate": firstDay.text.replaceAll("/", "-"),
            "currentDate": currentDate.text.replaceAll("/", "-"),
            "weist": waist.text
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
                clearMeasurementController();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updateLinkFunc(TextEditingController textEditingController, int slotId,
      bool isDiet, int userId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo
            .updateLinkRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            isDiet ? "id" : "slotId": slotId,
            "link": textEditingController.text,
            "userId": userId
          },
          isDiet: isDiet,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                textEditingController.clear();
                CustomToast.successToast(msg: response.body["message"]);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  addTeamMemberFunc(int planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        // var plan = allPlanModel!.plans[selectedPlanIndex.value];
        // var expiryDate = DateTime.now()
        //     .add(Duration(days: int.parse(plan.duration.split(" ").first)));
        // var price = plan.price;

        await homeRepo.addTeamMemberRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "firstName": firstNameController.text,
            "lastName": lastNameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "phone": phoneController.text,
            "userType": addedTeamMember.value,
            "planId": planId
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
                clearyControllers();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updateUser(int userId, bool freeze,String days,String planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await homeRepo.updateUserRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "firstName": firstNameController.text,
            "lastName": lastNameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "phone": phoneController.text,
            "userId": userId,
            "freeze": freeze,
            "days":days,
            "UserPlanId":planId
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
                getAllUsersFunc();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  approveUser(String imageId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await homeRepo.approveUser(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "planImageId": imageId,
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  addTestimonials() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.addTestimonials(
            accessToken:
                sharedPreferences.getString(Constants.accessToken) ?? "",
            map: {"image": testiPicture!.path}).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model =
                ApiResponse.fromJson(jsonDecode(response.bodyString!), (p0) {});
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

  addPlanBuyImage(String planId, int catId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);

        await homeRepo.addPlanImageRepo(
            accessToken:
                sharedPreferences.getString(Constants.accessToken) ?? "",
            map: {
              "image": planPicture!.path,
              "planId": planId,
              "userId": sharedPreferences.getString(Constants.userId),
              "trainerId": catId == 2 || catId == 3
                  ? selectedTrainerId.value.toString()
                  : "",
              "dietitianId": catId == 1 || catId == 3
                  ? selectedDietId.value.toString()
                  : ""
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
              planPicture = null;
              Get.back();
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }
}
