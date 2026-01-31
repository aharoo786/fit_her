import 'dart:convert';
import 'dart:math';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_cat_plan/get_all_sub_cat.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_trainers/add_diet_of_user.dart';
import 'package:fitness_zone_2/data/models/get_team_members/get_team_members.dart';
import 'package:fitness_zone_2/data/models/upcoming_class_slot.dart';
import 'package:fitness_zone_2/helper/permissions.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/UI/web_view.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import '../../../UI/auth_module/sign_up_screen/BMI_result.dart';
import '../../../UI/auth_module/sign_up_screen/sign_up_screen_questions.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/get_all_cat_plan/get_all_categories.dart';
import '../../models/get_all_dietitian_users/get_all_dietitian_users.dart';
import '../../models/get_all_health_tips/get_health_tips.dart';
import '../../models/get_all_users/get_all_users.dart';
import '../../models/get_all_users/get_all_users_based_on_type.dart';
import '../../models/get_trainer_home/get_trainer_home.dart';
import '../../models/home_model/home_model.dart';

class HomeController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  HomeRepo homeRepo;

  HomeController({required this.sharedPreferences, required this.homeRepo});

  CheckConnectionService connectionService = CheckConnectionService();

  @override
  void onInit() {
    initUpcomingSlot();
    dietOfUserByDiet = [
      getDietOfUser("Monday"),
      getDietOfUser("Tuesday"),
      getDietOfUser("Wednesday"),
      getDietOfUser("Thursday"),
      getDietOfUser("Friday"),
      getDietOfUser("Saturday"),
      getDietOfUser("Sunday"),
    ];
    if (sharedPreferences.getBool("showDotHome") == null) {
      showDotHome.value = false;
    } else if (sharedPreferences.getBool("showDotHome") == true) {
      showDotHome.value = false;
    }

    super.onInit();
  }

  bool get isFrozen => (userHomeData?.freeze.value == 1);

  ///Notifcation listern

  ///adding team member
  List<String> addTeamMember = ["Dietition", "Trainer", "Gynecologist", "Psychiatrist", "Customer_Support_Representative"];
  var addedTeamMember = "Dietition".obs;

  RxBool get isCustomerSupport => RxBool(addTeamMember[4] == addedTeamMember.value);

  // String get customerSupporter =>
  //     "Customer Support Representative".replaceAll(" ", "_");

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
  TextEditingController tellUsMore = TextEditingController();
  var selectedSatisfaction = 4.obs;
  final List<String> satisfactionEmojis = [
    '😡', // Very Unsatisfied
    '😕', // Unsatisfied
    '😐', // Neutral
    '😊', // Satisfied
    '😁', // Very Satisfied
  ];
  final List<String> labels = ["Very Unsatisfied", "Unsatisfied", "Neutral", "Satisfied", "Very Satisfied"];

  ValueNotifier<UpcomingClassSlot?> upComingClassNotifier = ValueNotifier<UpcomingClassSlot?>(null);

  checkTiming(String start, String end) {
    Timestamp timestamp = Timestamp.fromDate(DateTime.now());
    int startTime = covertToTimeStamp(start);
    int endTime = covertToTimeStamp(end);

    if (timestamp.millisecondsSinceEpoch > startTime && timestamp.millisecondsSinceEpoch < endTime) {
      return true;
    }
    return false;
  }

  initUpcomingSlot() {
    var list = sharedPreferences.getString(Constants.upcomingSlot);
    UpcomingClassSlot? notificationMessages;

    if (list != null) {
      notificationMessages = UpcomingClassSlot.fromJson(jsonDecode(list));
    }
    upComingClassNotifier.value = notificationMessages;
  }

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
    tellUsMore.clear();
  }

  ///Get Cat
  AllCategoriesOfPlan? allCategoriesOfPlan;
  GetSubCategories? allSubCategories;
  GetUsersBasedOnUserType? getUsersBasedOnUserTypeModel;
  AllPlanModel? allPlanModel;
  GetAllHealthTips? getAllHealthTips;
  GetAllDietitianAndTrainers? getAllDietitianAndTrainers;
  GetAllUsers? getAllUsers;
  GetGuestData? getGuestData;
  GetAllPlansImages? getAllPlansImages;
  GetTeamMembers? getTeamMembers;
  GetTrainerHome? getTrainerHome;
  GetDietitianUsers? getDietitianUsers;
  UserHomeData? userHomeData;
  GetWeeklyReportsModel? getWeeklyReportsModel;

  var team = [MyImgs.team1, MyImgs.team2, MyImgs.team3, MyImgs.team4];

  ///My Weekly Report Function

  var selectedPlanIndex = 0.obs;

  // List<addPackage.Time> addPackageTimeTable = [];
  List<DietOfUser> dietOfUserByDiet = [];

  ///get Cat
  var getCatLoaded = false.obs;
  var getSubCatLoaded = false.obs;
  var getUsersBasedOnUserTypeLoad = false.obs;
  var getPlanLoaded = false.obs;
  var getHealthTipsLoad = false.obs;
  var getDietitianLoad = false.obs;
  var getAllUsersLoad = false.obs;
  var trainerHomeLoad = false.obs;
  var weeklyReportLoad = false.obs;
  var dietHomeLoad = false.obs;
  var guestUserLoad = false.obs;
  var userHomeLoad = false.obs;
  var getPlanImagesLoad = false.obs;
  var getTeamMembersLoad = false.obs;

  ///testimonials pic
  XFile? testiPicture;
  XFile? dietPicture;
  XFile? profilePicture;
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
  var selectedSubCatId = 0.obs;
  var selectCustomerSupport = 0.obs;
  var selectedPlanId = 0.obs;
  var selectedDurationId = 0.obs;
  var selectedDietId = 0.obs;
  var selectedDietIdForMember = 0.obs;
  var selectedTrainerId = 0.obs;
  var selectedTrainerIdForMember = 0.obs;
  var selectedTrainerIdForBoth = 0.obs;

  // getTimeModel(String day) {
  //   addPackage.Time timeModel = addPackage.Time(
  //       day: day,
  //       slots: [addPackage.Slot(start: "Start Time", end: "End Time")]);
  //   return timeModel;
  // }

  getDietOfUser(String day) {
    DietOfUser dietofDay = DietOfUser(day: day, meals: [MealOfUser(time: "Time", food: "N/A", calories: "N/A")]);
    return dietofDay;
  }

  getSubCatBasedOnUserType(String userType) {
    getSubCatLoaded.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getSubCategoriesBasedOnUserTypes(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userType: userType,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetSubCategories> model = ApiResponse.fromJson(response.body, GetSubCategories.fromJson);
            if (model.status == "1") {
              allSubCategories = model.data!;
              if (allSubCategories!.data.isNotEmpty) {
                selectedSubCatId.value = allSubCategories!.data[0].id;
              }

              getSubCatLoaded.value = true;
            }
          }
        });
      }
    });
  }

  getUsersBasedOnUserType(String userType, {bool addNull = false}) {
    getUsersBasedOnUserTypeLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getSubUserBasedOnUserTypes(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userType: userType,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetUsersBasedOnUserType> model = ApiResponse.fromJson(response.body, GetUsersBasedOnUserType.fromJson);
            if (model.status == "1") {
              getUsersBasedOnUserTypeModel = model.data!;
              if (addNull) {
                getUsersBasedOnUserTypeModel?.users.insert(0, UserTypeData(id: 0, firstName: "Select", lastName: "..", email: "", phone: ""));
              } else {
                if (getUsersBasedOnUserTypeModel!.users.isNotEmpty) {
                  selectCustomerSupport.value = getUsersBasedOnUserTypeModel!.users.first.id;
                }
              }
              getUsersBasedOnUserTypeLoad.value = true;
            }
          }
        });
      }
    });
  }

  getPlansBasedOnSubCat(String subCatId) {
    getPlanLoaded.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getPlansBasedOnSubCat(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          subCat: subCatId,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model = ApiResponse.fromJson(response.body, AllPlanModel.fromJson);
            if (model.status == "1") {
              allPlanModel = model.data!;

              getPlanLoaded.value = true;
            }
          }
        });
      }
    });
  }

  getWorkoutAndTrainerPlan() {
    getPlanLoaded.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getWorkoutAndTrainerPlan(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model = ApiResponse.fromJson(response.body, AllPlanModel.fromJson);
            if (model.status == "1") {
              allPlanModel = model.data!;

              getPlanLoaded.value = true;
            }
          }
        });
      }
    });
  }

  Future<Map<String, dynamic>> getUserNameUsingId(int id) async {
    Map<String, dynamic> name = {"name": "unknown", "days": ""};

    // Use try-catch to handle errors
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection("users").where("remoteId", isEqualTo: id).get();

      print("querySnapshot: ${querySnapshot.docs.first.data()}");

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs.first;
        var data = documentSnapshot.data();
        name = {"name": data["name"], "days": data["days"]};
      }
    } catch (error) {
      print("Error: $error");
      // Handle errors as needed
    }

    return name;
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
            .getAllPlansAdmin(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model = ApiResponse.fromJson(response.body, AllPlanModel.fromJson);
            if (model.status == "1") {
              allPlanModel = model.data!;
              if (allPlanModel!.plans.isNotEmpty) {
                selectedPlanId.value = allPlanModel!.plans[0].id ?? 0;
                selectedPlanIndex.value = 0;
                if (allPlanModel!.plans[0].countries!.isNotEmpty) {
                  allPlanModel!.plans[0].selectedDurationId.value = allPlanModel!.plans[0].countries![0].duration![0].id!;
                }
              }

              getPlanLoaded.value = true;
            }
          }
        });
      }
    });
  }

  getPlansUser() {
    getPlanLoaded.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);
        dietPlanList.value = [];
        trainerPlanList.value = [];
        String code = await getCountryCode();
        homeRepo
            .getAllPlans(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          code: code,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model = ApiResponse.fromJson(response.body, AllPlanModel.fromJson);
            if (model.status == "1") {
              allPlanModel = model.data!;
              if (allPlanModel!.plans.isNotEmpty) {
                selectedPlanId.value = allPlanModel!.plans[0].id ?? 0;
                selectedPlanIndex.value = 0;
                if (allPlanModel!.plans[0].countries!.isNotEmpty) {
                  allPlanModel!.plans[0].selectedDurationId.value = allPlanModel!.plans[0].countries![0].duration![0].id!;
                }
              }

              getPlanLoaded.value = true;
            }
          }
        });
      }
    });
  }

  Future<bool> addFreeTrial() async {
    bool already = false;
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        already = false;
        CustomToast.noInternetToast();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        var c = await getCountryCode();
        await homeRepo.addFreeTrialUser(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"userId": sharedPreferences.getString(Constants.userId) ?? "", "country": c},
        ).then((response) async {
          Get.back();
          if (response.body["status"] == "0") {
            if (response.body["message"] == "You can't subscribe free trial at this movement") {
              already = true;
            } else {
              CustomToast.failToast(msg: response.body["message"]);
            }

            //  print('HomeController.addFreeTrial here');
          } else if (response.body["status"] != "0") {
            ApiResponse<AllPlanModel> model = ApiResponse.fromJson(response.body, (p0) {});
            if (model.status == "1") {
              CustomToast.successToast(msg: model.message);

              Get.find<WorkOutController>().getWorkoutAllPlansFunc(isFree: true);
              getUserHomeFunc(isFromFree: true);
              already = false;
            }
          }
        });
      }
    });
    return already;
  }

  double getPlanValue() {
    var value = userHomeData!.userAllPlans[0].spendDays / (userHomeData!.userAllPlans[0].remainingDays + userHomeData!.userAllPlans[0].spendDays);

    print("value-------------333  $value");

    if (value >= 0 && value <= 1) {
      return value;
    }
    return 1;
  }

  getHealthTips() {
    getHealthTipsLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        homeRepo
            .getHealthTips(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetAllHealthTips> model = ApiResponse.fromJson(response.body, GetAllHealthTips.fromJson);
            if (model.status == "1") {
              getAllHealthTips = model.data!;

              getHealthTipsLoad.value = true;
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
            ApiResponse<GetAllDietitianAndTrainers> model = ApiResponse.fromJson(response.body, GetAllDietitianAndTrainers.fromJson);
            if (model.status == "1") {
              getAllDietitianAndTrainers = model.data!;
              selectedPlanIndex.value = 0;
              if (getAllDietitianAndTrainers!.dietitions.isNotEmpty) {
                selectedDietId.value = getAllDietitianAndTrainers!.dietitions[0].id;
              }
              if (getAllDietitianAndTrainers!.trainers.isNotEmpty) {
                selectedTrainerId.value = getAllDietitianAndTrainers!.trainers[0].id;
              }

              getDietitianLoad.value = true;
            }
          }
        });
      }
    });
  }

  getAllUsersFunc({bool isCustomerSupport = false}) {
    getAllUsersLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getAllUsers(
          isCustomerSupport: isCustomerSupport,
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetAllUsers> model = ApiResponse.fromJson(response.body, GetAllUsers.fromJson);
            if (model.status == "1") {
              getAllUsers = model.data!;

              getAllUsersLoad.value = true;
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
            ApiResponse<GetWeeklyReportsModel> model = ApiResponse.fromJson(response.body, GetWeeklyReportsModel.fromJson);
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
            ApiResponse<GetDietitianUsers> model = ApiResponse.fromJson(response.body, GetDietitianUsers.fromJson);
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

  Plan? trailPlan;
  var trialPlanLoad = false.obs;

  getTrialPlanDetails() {
    trialPlanLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getFreePlan(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<Plan> model = ApiResponse.fromJson(response.body, Plan.fromJson);
            if (model.status == "1") {
              trailPlan = model.data!;
              trialPlanLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  postTrialPlanDetails(String id, bool status) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await homeRepo.changeFreeTrialStatus(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"status": status, "id": id},
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
            ApiResponse<GetGuestData> model = ApiResponse.fromJson(response.body, GetGuestData.fromJson);
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
            ApiResponse<GetAllPlansImages> model = ApiResponse.fromJson(response.body, GetAllPlansImages.fromJson);
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

  getAllTeamMembers() {
    getTeamMembersLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);

        homeRepo
            .getTeamMembersRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetTeamMembers> model = ApiResponse.fromJson(response.body, GetTeamMembers.fromJson);
            if (model.status == "1") {
              getTeamMembers = model.data!;

              getTeamMembersLoad.value = true;
              update();
            }
          }
        });
      }
    });
  }

  getUserHomeFunc({bool isFromFree = false}) {
    userHomeLoad.value = false;

    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        // Get.dialog(const Center(child: CircularProgressIndicator()),
        //     barrierDismissible: false);
        String code = await getCountryCode();
        homeRepo
            .getUserHome(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userId: sharedPreferences.getString(Constants.userId) ?? "0",
          code: code,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<UserHomeData> model = ApiResponse.fromJson(response.body, UserHomeData.fromJson);
            if (model.status == "1") {
              userHomeData = model.data!;
              userHomeLoad.value = true;
              if (userHomeData!.userAllPlans.isEmpty) {
                upComingClassNotifier.value = null;
                await FirebaseMessaging.instance.unsubscribeFromTopic('userPlan');
              }
              if (userHomeData!.userAllPlans.isNotEmpty) {
                await FirebaseMessaging.instance.subscribeToTopic('userPlan');
              }

              if (isFromFree) {
                Get.find<AuthController>().logInUser!.status = true;
              }
              update();
            }
          }
        });
      }
    });
  }

  addUser(
      {bool status = true,
      required String firstName,
      required String lastName,
      required String email,
      required String phone,
      required String password,
      required int customerSupportId,
      String? age,
      String? height,
      String? weight,
      String? price,
      String? bmiResult}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

        await homeRepo.addUserRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password,
            "phone": phone.isEmpty ? Random.secure().nextInt(10000) : phone,
            "planId": status ? allPlanModel!.plans[selectedPlanIndex.value].id : null,
            "status": status,
            "deviceToken": sharedPreferences.getString(Constants.deviceToken) ?? "",
            "customSupporterId": customerSupportId,
            "durationId": status ? allPlanModel!.plans[selectedPlanIndex.value].selectedDurationId.value : null,
            "age": age,
            "weight": weight,
            "height": height,
            "bmiResult": bmiResult,
            "price": price,
            "timeZone": currentTimeZone
          },
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse<LoginModel> model = ApiResponse.fromJson(response.body, LoginModel.fromJson);
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);

                if (status) {
                  getAllUsersFunc();
                } else {
                  Get.find<AuthController>().loginAsA.value = Constants.user;
                  sharedPreferences.setString(Constants.accessToken, model.data!.accessToken);
                  sharedPreferences.setString(Constants.userId, model.data!.id.toString());

                  sharedPreferences.setBool(Constants.isGuest, false);
                  Get.find<AuthController>().logInUser = model.data;
                  Get.find<AuthController>().addLocalStorage(model.data!, password);
                  // getPlans();
                  Get.offAll(() => SignUpScreenQuestions());
                }
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

  addUserDetails({bool status = true, String? age, String? height, String? weight, String? bmiResult}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.addUserDetails(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"userId": sharedPreferences.getString(Constants.userId), "age": age, "weight": weight, "height": height, "bmiResult": bmiResult},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse<LoginModel> model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);

                Get.offAll(() => BmiResult(
                      bmi: bmiResult ?? "0",
                    ));
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
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await homeRepo.getPaymentLink(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"amount": amount, "planId": id},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse<PaymentLink> model = ApiResponse.fromJson(response.body, PaymentLink.fromJson);
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

  addWorkoutAndTrainerApp() {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await homeRepo.assignWorkoutAndTrainer(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"planId": allPlanModel!.plans[selectedPlanIndex.value].id, "dietitianId": selectedDietId.value, "trainerId": selectedTrainerId.value},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: model.message);
                Get.back();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  getspecificUserFromFireStore(String id) async {
    Map<String, dynamic>? userMap;
    await FirebaseFirestore.instance.collection("users").doc(id).get().then((value) {
      userMap = value.data();
    });
    userMap ??= {"id": id, "name": "", "deviceToken": ""};
    return userMap;
  }

  makeRoomId(String id) async {
    String roomId = (sharedPreferences.getString(Constants.userId).hashCode + id.hashCode).toString();
    return roomId;
  }

  addAnnouncement(TextEditingController title, TextEditingController body) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

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

  freezeMyAccount(bool freeze) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.freezeMyAccount(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "userId": sharedPreferences.getString(Constants.userId),
            "freeze": freeze,
            "freezingDays": !freeze ? null : Get.find<AuthController>().dateExtendController.text.split(" ").first
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
                // userHomeData?.userData.usedFreezeOption.value =
                //     freeze ? false : true;
                //   userHomeData!.userData.freeze.value = freeze;
                getUserHomeFunc();
                update(['freezeButton']);
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
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

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
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

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
            "weist": waist.text,
            "review": labels[selectedSatisfaction.value],
            "aboutService": tellUsMore.text
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

  updateLinkFunc(TextEditingController textEditingController, int slotId, bool isDiet, int userId, String planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo
            .updateLinkRepo(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            isDiet ? "id" : "slotId": slotId,
            "link": textEditingController.text,
            "userId": userId,
            "planId": planId,
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
                CustomToast.successToast(msg: response.body["message"]);
                Get.find<WorkOutController>().getTrainerHomeFunc();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updateSlotStatus(String slotId, String status) async {
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.updateSlotStatus(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "slotId": slotId,
            "status": status,
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
                WorkOutController workOutController = Get.find();

                var trainerSlots = workOutController.getTrainerHome?.trainerSlots;
                if (trainerSlots != null && trainerSlots.isNotEmpty) {
                  for (var slot in trainerSlots) {
                    for (var s in slot.slots) {
                      if (s.id.toString() == slotId) {
                        s.status = status;
                      }
                    }
                  }
                }

                // Get.find<WorkOutController>().getTrainerHomeFunc();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updateTrainerJoin(int uid, int slotId, String channel, {bool isTrainerJoined = true}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.updateTrainerJoin(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {
            "slotId": slotId,
            "isTrainerJoined": isTrainerJoined,
            "joinedUserUID": uid,
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

  addTeamMemberFunc(int? planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

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
            "planId": null
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

  updateUser(int userId, bool freeze, String days, String planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
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
            "days": days,
            "UserPlanId": planId
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

  updateUserPlanStatus(String planId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await homeRepo.updateUserPayment(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"userId": sharedPreferences.getString(Constants.userId) ?? "", "planId": planId},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
                getUserHomeFunc();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  approveUser(String imageId, bool reject) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await homeRepo.approveUser(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          map: {"planImageId": imageId, "rejected": reject},
        ).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                getAllPlansImages?.data.removeWhere((image) => image.id.toString() == imageId);
                update(["newList"]);
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
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.addTestimonials(
            accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", map: {"image": testiPicture!.path}).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(jsonDecode(response.bodyString!), (p0) {});
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

  updateUserProfile(String speciality, String totalPatients, String experience, String description) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo.updateUserProfile(accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", map: {
          "image": profilePicture!.path,
          "userId": sharedPreferences.getString(Constants.userId),
          "speciality": speciality,
          "totalPatients": totalPatients,
          "experience": experience,
          "description": description
        }).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(jsonDecode(response.bodyString!), (p0) {});
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

  updateUserDietOfWeek(String userID, String userPlanId) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        await homeRepo
            .updateUserDietOfWeek(
                accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
                map: AddDietOfUser(userId: userID, userPlanId: userPlanId, dietOfUser: dietOfUserByDiet).toJson())
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse model = ApiResponse.fromJson(response.body, (p0) {});
              if (model.status == "1") {
                CustomToast.successToast(msg: response.body["message"]);
                Get.back();
              }
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
  }

  Future<bool> addPlanBuyImage(String planId, int durationId, String price) async {
    bool success = false;
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        Plan? plan = allPlanModel?.plans.firstWhereOrNull((p) => p.id == selectedPlanId.value);

        await homeRepo.addPlanImageRepo(accessToken: sharedPreferences.getString(Constants.accessToken) ?? "", map: {
          "image": planPicture!.path,
          "planId": planId,
          // "durationId": durationId.toString(),
          "price": price,
          "durationId": durationId.toString(),
          "userId": sharedPreferences.getString(Constants.userId),
        }).then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            ApiResponse model = ApiResponse.fromJson(jsonDecode(response.bodyString!), (p0) {});
            if (model.status == "0") {
              CustomToast.failToast(msg: model.message);
            }
            if (model.status == "1") {
              // CustomToast.successToast(msg: model.message);
              planPicture = null;
              success = true;
            }
          } else {
            CustomToast.failToast(msg: "Something wrong happened");
          }
        });
      }
    });
    return success;
  }

  var showDotHome = false.obs;

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };
      // var data = await Stripe.instance.confirmPlatformPayPaymentIntent(
      //     clientSecret: DotEnv().get("STRIPE_PUBLIC_KEY_TEST"),
      //     confirmParams: PlatformPayConfirmParams.fromJson(body));
      // print("data $data");

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {'Authorization': 'Bearer ${dotenv.get("STRIPE_SECRET_KEY_TEST")}', 'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      print("response    ${response.body}");
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
