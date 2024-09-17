import 'package:fitness_zone_2/UI/auth_module/result_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/data/api_provider/chat_api_provider.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_users/get_all_dietitian_users.dart';
import 'package:fitness_zone_2/data/models/home_model/home_model.dart';
import 'package:fitness_zone_2/data/models/login_response_model/login_response_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helper/notification_services.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../Repos/auth_repo/auth_repo.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/get_user_plan/get_user_plan.dart';
import '../../models/user_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/helper/get_di.dart' as di;

import '../diet_contoller/diet_controller.dart';
import '../progress_controller/progress_controller.dart';
import '../workout_controller/work_out_controller.dart';

class AuthController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  AuthRepo authRepo;
  NotificationServices notificationServices;
  ChatApiProvider chatApiProvider;
  CheckConnectionService connectionService = CheckConnectionService();
  AuthController(
      {required this.sharedPreferences,
      required this.authRepo,
      required this.notificationServices,
      required this.chatApiProvider});

  ///Generating unique id
  var uuid = const Uuid();

  ///TextEditing Controller for Adding User
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  ///payment controller
  TextEditingController cardHolderName = TextEditingController();
  TextEditingController cardNumber = TextEditingController();
  TextEditingController expiryDate = TextEditingController();
  TextEditingController cvc = TextEditingController();

  ///Edit controller
  TextEditingController editFirstName = TextEditingController();
  TextEditingController editLastName = TextEditingController();
  TextEditingController editEmail = TextEditingController();

  ///countryCode
  var countryCode = Constants.countryCode;
  List<String> addTeamMember = [
    "Dietition",
    "Trainer",
    "Gynecologist",
    "Psychiatrist",
    "Admin"
  ];

  ///Sign in User
  TextEditingController loginUserPhone = TextEditingController();
  TextEditingController loginUserPassword = TextEditingController();

  ///Update user
  TextEditingController dateExtendController = TextEditingController();

  String daysDurationValue = "";
  String monthDurationValue = "";

  bool daysSelected = false;
  bool monthSelected = false;

  ///User Model
  LoginModel? logInUser;

  var loginAsA = Constants.user.obs;

  List<String> packageState = [
    "Start",
    "Pause",
  ];
  List<String> screenShot = [
    "Yes",
    "No",
  ];
  List<String> recording = [
    "Yes",
    "No",
  ];
  List<String> memberDesignation = [
    "Trainer",
    "Dietitian",
  ];

  ///get All users
  GetDietitianUsers getDietitianUsers = GetDietitianUsers(result: []);

  var memerDesig = "Trainer";

  List<XFile> mealImages = [];
  int i = 0;

  /// getting days function
  int gettingDays() {
    if (daysSelected) {
      return int.parse(daysDurationValue.split(" ").first);
    } else {
      return int.parse(monthDurationValue.split(" ").first) * 30;
    }
  }

  initializeFireBase() {
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit();
    notificationServices.setupInteractMessage();
    notificationServices.isTokenRefresh();
    notificationServices.initializeNewHttpsSettingS();
    // notificationServices.getAccessToken();
    notificationServices.getApns();
    notificationServices.getDeviceToken();

    //print('device token ${localStorageMethods.getDvToken()}');
  }

  ///Clear sign up Controllers
  clearSignUpController() {
    firstNameController.clear();
    lastNameController.clear();
    emailNameController.clear();
    passwordController.clear();
    passwordController.clear();
  }

  @override
  onInit() {
    initializeFireBase();
    super.onInit();
  }

  login(String userType) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await authRepo
            .loginUserRepo(
          email: loginUserPhone.text,
          password: loginUserPassword.text,
          deviceToken: sharedPreferences.getString(Constants.deviceToken) ?? "",
          userType: loginAsA.value,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              ApiResponse<LoginModel> model =
                  ApiResponse.fromJson(response.body, LoginModel.fromJson);
              debugPrint(model.data!.accessToken.toString());
              if (model.status == "1") {
                logInUser = model.data;
                sharedPreferences.setString(
                    Constants.accessToken, model.data!.accessToken);
                sharedPreferences.setString(
                    Constants.userId, model.data!.id.toString());

                sharedPreferences.setBool(Constants.isGuest, false);
                if (loginAsA.value == Constants.trainer) {
                  Get.find<HomeController>().getTrainerHomeFunc();
                } else if (loginAsA.value == Constants.dietitian) {
                  Get.find<HomeController>().getDietHomeFunc();
                } else if (loginAsA.value == Constants.admin) {
                  Get.find<HomeController>().getTrialPlanDetails();
                } else if (loginAsA.value == Constants.user) {
                  if (!logInUser!.status) {
                    Get.find<HomeController>().getPlans();
                  } else {
                    Get.find<HomeController>().getUserHomeFunc();
                  }
                }

                loginUserPhone.clear();
                loginUserPassword.clear();
                updateUserDetails();
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  updateUserDetails() async {
    Map<String, dynamic> userMap;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(logInUser!.id.toString())
        .set({
      "id": logInUser!.id.toString(),
      "name": logInUser!.firstName,
      "time": Timestamp.now(),
      "remoteId": 0,
      "deviceToken": sharedPreferences.getString(Constants.deviceToken)
    });
    var userMap1 = await FirebaseFirestore.instance
        .collection("users")
        .doc(logInUser!.adminId.toString())
        .get();
    userMap = userMap1.data()!;
    String roomId = (logInUser!.id.toString().hashCode +
            logInUser!.adminId.toString().hashCode)
        .toString();
    editFirstName.text = logInUser!.firstName;
    editLastName.text = logInUser!.lastName;
    editEmail.text = logInUser!.email;
    Get.offAll(() => BottomBarScreen(
          roomId: roomId,
          userMap: userMap,
        ));
  }

  guestLogin(String result) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await authRepo
            .loginGuestRepo(
          email: emailNameController.text,
          name: firstNameController.text,
          phone: phoneNumberController.text,
          result: result,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                emailNameController.clear();
                phoneNumberController.clear();
                firstNameController.clear();
                Get.offAll(() => ResultScreen(result: result));
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  logout() {
    var token = sharedPreferences.getString(Constants.accessToken);
    if (token != null) {
      debugPrint(" => Access Token :$token");

      connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.noInternetToast();
        } else {
          Get.dialog(const Center(child: CircularProgressIndicator()),
              barrierDismissible: false);
          await authRepo.logout(accessToken: token).then((response) async {
            Get.back();
            if (response.statusCode == 200) {
              if (response.body["status"] == "0") {
                CustomToast.failToast(msg: response.body["message"]);
              } else if (response.body["status"] != "0") {
                if (response.body["status"] == "1") {
                  sharedPreferences.clear();

                  Get.offAll(() => const WalkThroughScreen());
                }
              }
            } else {
              CustomToast.failToast(msg: response.body["message"]);
            }
          });
        }
      });
    } else {
      CustomToast.failToast(msg: "You are not Logged in.");
    }
  }

  deleteUser() {
    var token = sharedPreferences.getString(Constants.accessToken);
    if (token != null) {
      debugPrint(" => Access Token :$token");

      connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.noInternetToast();
        } else {
          Get.dialog(const Center(child: CircularProgressIndicator()),
              barrierDismissible: false);
          await authRepo
              .deleteUser(
                  id: sharedPreferences.getString(Constants.userId) ?? "")
              .then((response) {
            Get.back();
            if (response.statusCode == 200) {
              if (response.body["status"] == "0") {
                CustomToast.failToast(msg: response.body["message"]);
              } else if (response.body["status"] != "0") {
                if (response.body["status"] == "1") {
                  sharedPreferences.clear();
                  Get.offAll(() => const WalkThroughScreen());
                }
              }
            } else {
              CustomToast.failToast(msg: response.body["message"]);
            }
          });
        }
      });
    } else {
      CustomToast.failToast(msg: "You are not Logged in.");
    }
  }

  var homeDataLoad = false.obs;

  sendMessageNotifications(Map<String, dynamic> body) async {
    await chatApiProvider.postData(body: body);
  }
}
