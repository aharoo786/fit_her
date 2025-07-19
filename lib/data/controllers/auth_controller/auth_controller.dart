import 'dart:convert';
import 'dart:io';

import 'package:fitness_zone_2/UI/auth_module/choose_any_one/choose_any_one.dart';
import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/result_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/data/api_provider/chat_api_provider.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_users/get_all_dietitian_users.dart';
import 'package:fitness_zone_2/data/models/login_response_model/login_response_model.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helper/get_di.dart';
import '../../../helper/notification_services.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../Repos/auth_repo/auth_repo.dart';
import '../../models/api_response/api_response_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/get_all_users/get_all_users_based_on_type.dart';

class AuthController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  AuthRepo authRepo;
  NotificationServices notificationServices;
  ChatApiProvider chatApiProvider;
  CheckConnectionService connectionService = CheckConnectionService();
  AuthController({required this.sharedPreferences, required this.authRepo, required this.notificationServices, required this.chatApiProvider});

  ///Generating unique id
  var uuid = const Uuid();
  var showDot = false.obs;

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
  TextEditingController editAge = TextEditingController();
  TextEditingController editWeight = TextEditingController();
  TextEditingController editHeight = TextEditingController();
  TextEditingController editBmi = TextEditingController();

  ///countryCode
  var countryCode = Constants.countryCode;
  List<String> addTeamMember = ["Dietition", "Trainer", "Gynecologist", "Psychiatrist", "Customer_Support_Representative", "Admin"];

  ///Sign in User
  TextEditingController loginUserPhone = TextEditingController();
  TextEditingController loginUserPassword = TextEditingController();

  ///Update user
  TextEditingController dateExtendController = TextEditingController();

  String daysDurationValue = "";
  String monthDurationValue = "";
  var selectCustomerSupport = 0.obs;

  bool daysSelected = false;
  bool monthSelected = false;
  var getUsersBasedOnUserTypeLoad = false.obs;

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
  GetUsersBasedOnUserType? getUsersBasedOnUserTypeModel;

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

  ///Listerner
  ///
  ValueNotifier<List<dynamic>?> sharedPrefNotifier = ValueNotifier<List<dynamic>?>(null);

  final fAuth.FirebaseAuth _auth = fAuth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

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
    initNotifications();
    super.onInit();
  }

  addLocalStorage(LoginModel model, String password) {
    sharedPreferences.setString(Constants.accessToken, model.accessToken);
    sharedPreferences.setString(Constants.userId, model.id.toString());
    sharedPreferences.setString(Constants.email, model.email.toString());
    sharedPreferences.setString(Constants.password, password);
    sharedPreferences.setString(Constants.loginAsa, loginAsA.value);

    sharedPreferences.setBool(Constants.isGuest, false);
  }

  login({String? userType, String? email, String? password}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        if (userType != null) {
          loginAsA.value = userType;
        }
        await authRepo
            .loginUserRepo(
          email: email ?? loginUserPhone.text.removeAllWhitespace,
          password: password ?? loginUserPassword.text,
          deviceToken: sharedPreferences.getString(Constants.deviceToken) ?? "",
          userType: loginAsA.value,
        )
            .then((response) async {
          Get.back();
          print('AuthController.login ${response}}');
          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
              if (email != null) {
                Get.offAll(() => const WalkThroughScreen());
              }
            } else if (response.body["status"] != "0") {
              ApiResponse<LoginModel> model = ApiResponse.fromJson(response.body, LoginModel.fromJson);
              debugPrint(model.data!.accessToken.toString());
              if (model.status == "1") {
                logInUser = model.data;

                addLocalStorage(logInUser!, password ?? loginUserPassword.text);

                if (loginAsA.value == Constants.trainer) {
                  //  Get.find<HomeController>().getTrainerHomeFunc();
                } else if (loginAsA.value == Constants.dietitian) {
                  //   Get.find<HomeController>().getDietHomeFunc();
                } else if (loginAsA.value == Constants.admin) {
                  // Get.find<HomeController>().getTrialPlanDetails();
                } else if (loginAsA.value == Constants.user) {
                  if (!logInUser!.status) {
                    Get.find<HomeController>().getPlansUser();
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

  signInUsingGoogle(String userEmail, String name, String signedFrom) {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    connectionService.checkConnection().then((value) async {
      if (!value) {
        Get.back();

        CustomToast.noInternetToast();
        // Get.back();
      } else {
        authRepo
            .googleSignIn(
          email: userEmail,
          deviceToken: sharedPreferences.getString(Constants.deviceToken) ?? "",
          userType: loginAsA.value,
        )
            .then((response) async {
          Get.log("login api response :${response.body}");
          Get.back();
          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                ApiResponse<LoginModel> model = ApiResponse.fromJson(response.body, LoginModel.fromJson);
                debugPrint(model.data!.accessToken.toString());
                logInUser = model.data;

                addLocalStorage(logInUser!, signedFrom);

                if (loginAsA.value == Constants.user) {
                  if (!logInUser!.status) {
                    Get.find<HomeController>().getPlansUser();
                  } else {
                    Get.find<HomeController>().getUserHomeFunc();
                  }
                }

                loginUserPhone.clear();
                loginUserPassword.clear();
                updateUserDetails();
              } else if (response.body["status"] == "2") {
                print('AuthController.signInUsingGoogle}');
                emailNameController.text = userEmail;
                firstNameController.text = name.split(" ").first;
                lastNameController.text = name.split(" ").last;

                Get.to(() => SignUpNewUser(
                      isSocial: true,
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

  getUsersBasedOnUserType(String userType, {bool addNull = false}) {
    getUsersBasedOnUserTypeLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        authRepo
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
                  selectCustomerSupport.value = getUsersBasedOnUserTypeModel!.users[0].id;
                }
              }
              getUsersBasedOnUserTypeLoad.value = true;
            }
          }
        });
      }
    });
  }

  Future<void> showEmailsDialog({bool isFromResortScreen = false}) async {
    // Get.dialog(Center(child: CircularProgressIndicator()),
    //     barrierDismissible: false);
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        // Get.back();

        CustomToast.noInternetToast();
      } else {
        try {
          final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
          if (googleSignInAccount != null) {
            final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
            final fAuth.AuthCredential credential = fAuth.GoogleAuthProvider.credential(
              accessToken: googleSignInAuthentication.accessToken,
              idToken: googleSignInAuthentication.idToken,
            );

            final fAuth.UserCredential authResult = await _auth.signInWithCredential(credential);
            final fAuth.User? user = authResult.user;
            if (user != null) {
              signInUsingGoogle(
                user.email ?? "",
                user.displayName ?? "",
                "google",
              );
            }
          }
        } catch (error) {
          //Get.back();
          print("Error during Google Sign-In: $error");
        }
      }
    });
  }

  void handleappleLogin() async {
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        final appleAuthProvider = fAuth.AppleAuthProvider();
        appleAuthProvider.addScope("email");

        var authCredentials = await _auth.signInWithProvider(appleAuthProvider);
        final fAuth.User? user = authCredentials.user;
        print("User :   $user");
        if (user != null) {
          if (Platform.isIOS) {
            if (user.email == null) {
              if (user.providerData.isNotEmpty) {
                signInUsingGoogle(user.providerData[0].email ?? "", user.displayName ?? "", "apple");
              } else {
                signInUsingGoogle(user.email ?? "", user.displayName ?? "", "apple");
              }
            } else {
              signInUsingGoogle(user.email ?? "", user.displayName ?? "", "apple");
            }
          } else {
            signInUsingGoogle(user.email ?? "", user.displayName ?? "", "apple");
          }
        } else {
          CustomToast.failToast(msg: "Something went wrong");
        }
      }
    });
  }

  initNotifications() {
    var list = sharedPreferences.getString(Constants.notificationList);
    List<NotificationMessage> notificationMessages = [];

    if (list != null) {
      var list2 = jsonDecode(list);
      notificationMessages = List<NotificationMessage>.from(
        list2.map((item) => NotificationMessage.fromJson(item)),
      );
    }
    sharedPrefNotifier.value = notificationMessages;
  }

  updateUserDetails({bool updateFields = true}) async {
    Map<String, dynamic> userMap;
    await FirebaseFirestore.instance.collection("users").doc(logInUser!.id.toString()).set({
      "id": logInUser!.id.toString(),
      "name": logInUser!.firstName,
      "time": Timestamp.now(),
      "remoteId": 0,
      "newMessageArrived": false,
      "days": "",
      "deviceToken": sharedPreferences.getString(Constants.deviceToken)
    });
    // var userMap1 = await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(logInUser!.adminId.toString())
    //     .get();§§§
    // userMap = userMap1.data()!;
    // String roomId = (logInUser!.id.toString().hashCode +
    //         logInUser!.adminId.toString().hashCode)
    //     .toString();
    editFirstName.text = logInUser?.firstName ?? "";
    editLastName.text = logInUser?.lastName ?? "";
    editEmail.text = logInUser?.email ?? "";

    if (updateFields) {
      editBmi.text = logInUser?.bmiResult ?? "";
      editAge.text = logInUser?.age ?? "";
      editWeight.text = logInUser?.weight ?? "";
      editHeight.text = logInUser?.height ?? "";
    }
    Get.find<HomeController>().getUserHomeFunc();
    Get.offAll(() => BottomBarScreen());
  }

  guestLogin(String result) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
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

  Future<String?> forgotPassword(String email) async {
    String? otp;
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        otp = null;
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await authRepo
            .forgotPasswordRepo(
          email: email,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
              otp = null;
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                otp = response.body["data"]["otp"];
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
            otp = null;
          }
        });
      }
    });
    return otp;
  }

  resetPassword(String email, String password) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await authRepo
            .resetPasswordRepo(
          email: email,
          password: password,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                Get.offAll(() => Login());
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

  void removeItem(int index) {
    // Update the list by removing the item at the given index
    if (sharedPrefNotifier.value != null) {
      var list = sharedPreferences.getString(Constants.notificationList);

      // Create a new list if none exists
      List<NotificationMessage> notificationMessages = [];

      // If the list already exists in SharedPreferences
      if (list != null) {
        // Decode the existing list
        var list2 = jsonDecode(list);

        // Convert each item back to NotificationMessage and add to notificationMessages list
        notificationMessages = List<NotificationMessage>.from(list2.map((item) => NotificationMessage.fromJson(item)));
      }

      sharedPrefNotifier.value?.removeAt(index);
      notificationMessages.removeAt(index);
      sharedPreferences.setString(Constants.notificationList, jsonEncode(notificationMessages));
      sharedPrefNotifier.notifyListeners();
    }
  }

  logout() async {
    var token = sharedPreferences.getString(Constants.deviceToken);
    if (token != null) {
      connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.noInternetToast();
        } else {
          Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
          await authRepo.logoutUserRepo(deviceToken: token).then((response) async {
            Get.back();
            if (response.statusCode == 200) {
              if (response.body["status"] == "0") {
                CustomToast.failToast(msg: response.body["message"]);
              } else if (response.body["status"] != "0") {
                if (response.body["status"] == "1") {
                  CustomToast.successToast(msg: response.body["message"]);
                  sharedPreferences.clear();
                  Get.offAll(() => ChooseAnyOne());
                  NotificationServices().getDeviceToken();
                  await init();
                  if (await googleSignIn.isSignedIn()) {
                    googleSignIn.signOut();
                  }
                  loginAsA.value = Constants.user;
                }
              }
            } else {
              CustomToast.failToast(msg: response.body["message"]);
            }
          });
        }
      });
    } else {
      CustomToast.failToast(msg: "Successfully Logout");
      sharedPreferences.clear();
      await init();
      loginAsA.value = Constants.user;
      Get.offAll(() => ChooseAnyOne());
    }
  }

  deleteUser({String? id}) {
    var token = sharedPreferences.getString(Constants.accessToken);
    if (token != null) {
      connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.noInternetToast();
        } else {
          Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
          await authRepo.deleteUser(id: id ?? sharedPreferences.getString(Constants.userId) ?? "").then((response) {
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
